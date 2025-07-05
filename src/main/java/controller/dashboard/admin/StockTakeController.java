package controller.dashboard.admin;

import dao.StockTakeDAO;
import dao.StockTakeDetailDAO;
import dao.ProductDAO;
import dao.InventoryDAO;
import dao.WarehouseDAO;
import model.StockTake;
import model.StockTakeDetail;
import model.User;
import model.Warehouse;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "StockTakeController", urlPatterns = {"/stock-take"})
@MultipartConfig
public class StockTakeController extends HttpServlet {

    private StockTakeDAO stockTakeDAO;
    private StockTakeDetailDAO stockTakeDetailDAO;
    private ProductDAO productDAO;
    private InventoryDAO inventoryDAO;
    private WarehouseDAO warehouseDAO;

    @Override
    public void init() throws ServletException {
        stockTakeDAO = new StockTakeDAO();
        stockTakeDetailDAO = new StockTakeDetailDAO();
        productDAO = new ProductDAO();
        inventoryDAO = new InventoryDAO();
        warehouseDAO = new WarehouseDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                handleListStockTakes(request, response);
                break;
            case "create":
                handleShowCreateForm(request, response);
                break;
            case "edit":
                handleShowEditForm(request, response);
                break;
            case "view":
                handleViewStockTake(request, response);
                break;
            case "perform":
                handlePerformStockTake(request, response);
                break;
            case "approve-view":
            case "view-completed":
                handleViewCompleted(request, response);
                break;
            case "check-warehouse":
                handleCheckWarehouse(request, response);
                break;
            default:
                handleListStockTakes(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
            return;
        }

        switch (action) {
            case "create":
                handleCreateStockTake(request, response);
                break;
            case "update":
                handleUpdateStockTake(request, response);
                break;
            case "update-status":
                handleUpdateStatus(request, response);
                break;
            case "update-count":
                handleUpdateCount(request, response);
                break;

            // case "reconcile": - Chức năng này đã chuyển cho Warehouse Manager
            case "delete":
                handleDeleteStockTake(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/stock-take");
                break;
        }
    }

    private void handleListStockTakes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String status = request.getParameter("status");
        String warehouseIdStr = request.getParameter("warehouseId");
        List<StockTake> stockTakes;

        if ("warehouse_staff".equals(currentUser.getRoleId())) {
            // Warehouse staff chỉ xem được stock takes của mình
            if (status != null && !status.isEmpty()) {
                stockTakes = stockTakeDAO.findByStatus(status);
                stockTakes.removeIf(st -> !st.getUserId().equals(currentUser.getUserId()));
            } else {
                stockTakes = stockTakeDAO.findByUserId(currentUser.getUserId());
            }
        } else {
            // Admin xem được tất cả, có thể lọc theo warehouse
            if (warehouseIdStr != null && !warehouseIdStr.isEmpty()) {
                try {
                    int warehouseId = Integer.parseInt(warehouseIdStr);
                    stockTakes = stockTakeDAO.findByWarehouseId(warehouseId);
                    if (status != null && !status.isEmpty()) {
                        stockTakes.removeIf(st -> !status.equals(st.getStatus()));
                    }
                } catch (NumberFormatException e) {
                    stockTakes = stockTakeDAO.findAll();
                    if (status != null && !status.isEmpty()) {
                        stockTakes.removeIf(st -> !status.equals(st.getStatus()));
                    }
                }
            } else if (status != null && !status.isEmpty()) {
                stockTakes = stockTakeDAO.findByStatus(status);
            } else {
                stockTakes = stockTakeDAO.findAll();
            }
        }

        // Lấy danh sách warehouse cho filter (admin only)
        if ("admin".equals(currentUser.getRoleId())) {
            List<Warehouse> warehouses = warehouseDAO.findAll();
            request.setAttribute("warehouses", warehouses);
        }

        request.setAttribute("stockTakes", stockTakes);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("selectedWarehouseId", warehouseIdStr);
        request.getRequestDispatcher("/view/stock-take/list.jsp").forward(request, response);
    }

    private void handleShowCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        
        if (currentUser == null || !"warehouse_staff".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
            return;
        }

        // Lấy danh sách warehouse cho form
        List<Warehouse> warehouses = warehouseDAO.findAll();
        request.setAttribute("warehouses", warehouses);

        request.getRequestDispatcher("/view/stock-take/create.jsp").forward(request, response);
    }

    private void handleCreateStockTake(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        
        if (currentUser == null || !"warehouse_staff".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
            return;
        }

        try {
            String notes = request.getParameter("notes");
            String warehouseIdStr = request.getParameter("warehouseId");
            
            if (warehouseIdStr == null || warehouseIdStr.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng chọn kho hàng!");
                response.sendRedirect(request.getContextPath() + "/stock-take?action=create");
                return;
            }
            
            int warehouseId;
            try {
                warehouseId = Integer.parseInt(warehouseIdStr);
            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Thông tin kho hàng không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/stock-take?action=create");
                return;
            }

            // Kiểm tra xem warehouse có sản phẩm tồn kho hay không
            if (!inventoryDAO.hasProductsInWarehouse(warehouseId)) {
                int productCount = inventoryDAO.countProductsInWarehouse(warehouseId);
                session.setAttribute("errorMessage", 
                    String.format("Kho hàng được chọn không có sản phẩm nào có tồn kho! " +
                                 "Hiện tại có %d sản phẩm trong kho này. " +
                                 "Vui lòng chọn kho khác hoặc nhập hàng vào kho trước.", productCount));
                response.sendRedirect(request.getContextPath() + "/stock-take?action=create");
                return;
            }
            
            StockTake stockTake = new StockTake();
            stockTake.setStockTakeCode(stockTakeDAO.generateStockTakeCode());
            stockTake.setUserId(currentUser.getUserId());
            stockTake.setStockTakeDate(new Date(System.currentTimeMillis()));
            stockTake.setStatus("pending");
            stockTake.setNotes(notes);
            stockTake.setWarehouseId(warehouseId);

            int stockTakeId = stockTakeDAO.insert(stockTake);
            
            if (stockTakeId > 0) {
                // Tạo chi tiết kiểm kê cho tất cả sản phẩm có tồn kho trong warehouse được chọn
                boolean detailsCreated = stockTakeDetailDAO.createStockTakeDetailsForWarehouse(stockTakeId, stockTake.getWarehouseId());
                
                if (detailsCreated) {
                    int productCount = inventoryDAO.countProductsInWarehouse(warehouseId);
                    session.setAttribute("successMessage", 
                        String.format("Tạo phiếu kiểm kê thành công! Đã tạo chi tiết kiểm kê cho %d sản phẩm trong kho hàng được chọn.", productCount));
                    response.sendRedirect(request.getContextPath() + "/stock-take?action=perform&id=" + stockTakeId);
                } else {
                    session.setAttribute("errorMessage", "Có lỗi xảy ra khi tạo chi tiết kiểm kê!");
                    response.sendRedirect(request.getContextPath() + "/stock-take?action=create");
                }
            } else {
                session.setAttribute("errorMessage", "Có lỗi xảy ra khi tạo phiếu kiểm kê!");
                response.sendRedirect(request.getContextPath() + "/stock-take?action=create");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/stock-take?action=create");
        }
    }

    private void handlePerformStockTake(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        
        if (currentUser == null || !"warehouse_staff".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
            return;
        }

        try {
            int stockTakeId = Integer.parseInt(request.getParameter("id"));
            StockTake stockTake = stockTakeDAO.findById(stockTakeId);
            
            if (stockTake == null || !stockTake.getUserId().equals(currentUser.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/stock-take");
                return;
            }

            // Lấy chi tiết kiểm kê với system_quantity cập nhật từ inventory
            List<StockTakeDetail> details = stockTakeDetailDAO.findByStockTakeId(stockTakeId);
            
            request.setAttribute("stockTake", stockTake);
            request.setAttribute("stockTakeDetails", details);
            request.getRequestDispatcher("/view/stock-take/perform.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
        }
    }

    private void handleUpdateCount(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        
        // Set response type to JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (currentUser == null || !"warehouse_staff".equals(currentUser.getRoleId())) {
            response.getWriter().write("{\"success\": false, \"message\": \"Không có quyền truy cập\"}");
            return;
        }

        try {
            int stockTakeDetailId = Integer.parseInt(request.getParameter("detailId"));
            int stockTakeId = Integer.parseInt(request.getParameter("stockTakeId"));
            String countedQtyStr = request.getParameter("countedQuantity");
            
            Integer countedQuantity = null;
            if (countedQtyStr != null && !countedQtyStr.trim().isEmpty()) {
                countedQuantity = Integer.parseInt(countedQtyStr);
            }

            // Cập nhật counted_quantity và đồng thời cập nhật system_quantity từ inventory
            boolean updated = stockTakeDetailDAO.updateCountedQuantity(stockTakeDetailId, countedQuantity);
            
            if (updated) {
                // Kiểm tra xem đã hoàn thành kiểm kê chưa
                List<StockTakeDetail> details = stockTakeDetailDAO.findByStockTakeId(stockTakeId);
                boolean allCounted = details.stream().allMatch(d -> d.getCountedQuantity() != null);
                
                if (allCounted) {
                    stockTakeDAO.updateStatus(stockTakeId, "completed");
                    response.getWriter().write("{\"success\": true, \"message\": \"Kiểm kê hoàn thành! Vui lòng chờ admin duyệt để điều chỉnh tồn kho.\", \"allCompleted\": true}");
                } else {
                    stockTakeDAO.updateStatus(stockTakeId, "in_progress");
                    response.getWriter().write("{\"success\": true, \"message\": \"Cập nhật số lượng kiểm kê thành công!\", \"allCompleted\": false}");
                }
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Có lỗi xảy ra khi cập nhật!\"}");
            }
            
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\": false, \"message\": \"Dữ liệu không hợp lệ!\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Có lỗi xảy ra: " + e.getMessage() + "\"}");
        }
    }

    // handleReconcileStockTake method đã được chuyển sang Warehouse Manager Controller
    // Chức năng đối soát kiểm kê hiện tại được quản lý bởi:
    // controller.dashboard.warehouseManager.StockTakeController



    private void handleShowEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for edit form
        response.sendRedirect(request.getContextPath() + "/stock-take");
    }

    private void handleUpdateStockTake(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for update
        response.sendRedirect(request.getContextPath() + "/stock-take");
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        
        if (currentUser == null || !"admin".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
            return;
        }

        try {
            int stockTakeId = Integer.parseInt(request.getParameter("stockTakeId"));
            String newStatus = request.getParameter("status");
            
            boolean updated = stockTakeDAO.updateStatus(stockTakeId, newStatus);
            
            if (updated) {
                session.setAttribute("successMessage", "Cập nhật trạng thái thành công!");
            } else {
                session.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật trạng thái!");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
        }
        
        response.sendRedirect(request.getContextPath() + "/stock-take");
    }

    private void handleDeleteStockTake(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for delete
        response.sendRedirect(request.getContextPath() + "/stock-take");
    }

    private void handleViewStockTake(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int stockTakeId = Integer.parseInt(request.getParameter("id"));
            StockTake stockTake = stockTakeDAO.findById(stockTakeId);
            List<StockTakeDetail> details = stockTakeDetailDAO.findByStockTakeId(stockTakeId);
            
            request.setAttribute("stockTake", stockTake);
            request.setAttribute("stockTakeDetails", details);
            request.getRequestDispatcher("/view/stock-take/view.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
        }
    }



    private void handleViewCompleted(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        
        if (currentUser == null || !"admin".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
            return;
        }
        
        // Admin hiện tại chỉ có quyền xem kết quả, không thể đối soát
        // Chức năng đối soát đã chuyển cho Warehouse Manager

        try {
            int stockTakeId = Integer.parseInt(request.getParameter("id"));
            StockTake stockTake = stockTakeDAO.findById(stockTakeId);
            
            if (stockTake == null) {
                session.setAttribute("errorMessage", "Không tìm thấy phiếu kiểm kê!");
                response.sendRedirect(request.getContextPath() + "/stock-take");
                return;
            }

            // Cho phép xem với trạng thái completed hoặc reconciled
            if (!"completed".equals(stockTake.getStatus()) && !"reconciled".equals(stockTake.getStatus())) {
                session.setAttribute("errorMessage", "Phiếu kiểm kê chưa hoàn thành!");
                response.sendRedirect(request.getContextPath() + "/stock-take");
                return;
            }

            List<StockTakeDetail> details = stockTakeDetailDAO.findByStockTakeId(stockTakeId);
            List<StockTakeDetail> discrepancies = stockTakeDetailDAO.findDiscrepanciesByStockTakeId(stockTakeId);
            List<Object[]> statistics = stockTakeDetailDAO.getStockTakeStatistics(stockTakeId);
            
            request.setAttribute("stockTake", stockTake);
            request.setAttribute("stockTakeDetails", details);
            request.setAttribute("discrepancies", discrepancies);
            request.setAttribute("statistics", statistics);
            request.getRequestDispatcher("/view/stock-take/approval.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/stock-take");
        }
    }

    private void handleCheckWarehouse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            String warehouseIdStr = request.getParameter("warehouseId");
            
            if (warehouseIdStr == null || warehouseIdStr.trim().isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"Warehouse ID không hợp lệ\"}");
                return;
            }
            
            int warehouseId = Integer.parseInt(warehouseIdStr);
            int productCount = inventoryDAO.countProductsInWarehouse(warehouseId);
            boolean hasProducts = productCount > 0;
            
            String message = hasProducts 
                ? String.format("Kho này có %d sản phẩm có thể kiểm kê", productCount)
                : "Kho này không có sản phẩm nào có tồn kho";
            
            response.getWriter().write(String.format(
                "{\"success\": true, \"hasProducts\": %s, \"productCount\": %d, \"message\": \"%s\"}", 
                hasProducts, productCount, message));
                
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\": false, \"message\": \"Warehouse ID không hợp lệ\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Có lỗi xảy ra khi kiểm tra kho hàng\"}");
        }
    }

} 