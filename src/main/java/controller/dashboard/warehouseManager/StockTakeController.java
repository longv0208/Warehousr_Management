package controller.dashboard.warehouseManager;

import dao.StockTakeDAO;
import dao.StockTakeDetailDAO;
import dao.InventoryDAO;
import dao.WarehouseDAO;
import model.StockTake;
import model.StockTakeDetail;
import model.User;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "WarehouseManagerStockTakeController", urlPatterns = {"/warehouse-manager/stock-take"})
public class StockTakeController extends HttpServlet {

    private StockTakeDAO stockTakeDAO;
    private StockTakeDetailDAO stockTakeDetailDAO;
    private InventoryDAO inventoryDAO;
    private WarehouseDAO warehouseDAO;

    @Override
    public void init() throws ServletException {
        stockTakeDAO = new StockTakeDAO();
        stockTakeDetailDAO = new StockTakeDetailDAO();
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

        // Role check - chỉ warehouse_manager mới có quyền truy cập
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null || !"warehouse_manager".equals(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to access this page.");
            return;
        }

        switch (action) {
            case "list":
                handleListStockTakes(request, response);
                break;
            case "view":
                handleViewStockTake(request, response);
                break;
            case "approve-view":
            case "view-completed":
                handleViewCompleted(request, response);
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
            response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take");
            return;
        }

        // Role check - chỉ warehouse_manager mới có quyền thực hiện
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null || !"warehouse_manager".equals(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to perform this action.");
            return;
        }

        switch (action) {
            case "reconcile":
                handleReconcileStockTake(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take");
                break;
        }
    }

    private void handleListStockTakes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String statusFilter = request.getParameter("status");
        String warehouseIdStr = request.getParameter("warehouseId");
        Integer warehouseIdFilter = null;
        
        if (warehouseIdStr != null && !warehouseIdStr.trim().isEmpty()) {
            try {
                warehouseIdFilter = Integer.parseInt(warehouseIdStr);
            } catch (NumberFormatException e) {
                // Ignore invalid warehouse ID
            }
        }

        List<StockTake> stockTakes;
        
        // Lọc theo status và warehouse nếu có
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            if (warehouseIdFilter != null) {
                stockTakes = stockTakeDAO.findByStatus(statusFilter);
                // Filter by warehouse if needed (có thể cần thêm method mới trong DAO)
                Integer finalWarehouseIdFilter = warehouseIdFilter;
                stockTakes = stockTakes.stream()
                    .filter(st -> finalWarehouseIdFilter.equals(st.getWarehouseId()))
                    .toList();
            } else {
                stockTakes = stockTakeDAO.findByStatus(statusFilter);
            }
        } else if (warehouseIdFilter != null) {
            stockTakes = stockTakeDAO.findByWarehouseId(warehouseIdFilter);
        } else {
            stockTakes = stockTakeDAO.findAll();
        }

        // Lấy danh sách warehouses cho filter
        List<model.Warehouse> warehouses = warehouseDAO.findAll();
        
        request.setAttribute("stockTakes", stockTakes);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("selectedWarehouseId", warehouseIdStr);
        request.setAttribute("statusFilter", statusFilter);
        request.getRequestDispatcher("/view/dashboard/warehouseManager/stock-take/list.jsp").forward(request, response);
    }

    private void handleViewStockTake(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int stockTakeId = Integer.parseInt(request.getParameter("id"));
            StockTake stockTake = stockTakeDAO.findById(stockTakeId);
            
            if (stockTake == null) {
                request.getSession().setAttribute("errorMessage", "Không tìm thấy phiếu kiểm kê!");
                response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take");
                return;
            }

            List<StockTakeDetail> details = stockTakeDetailDAO.findByStockTakeId(stockTakeId);
            
            request.setAttribute("stockTake", stockTake);
            request.setAttribute("stockTakeDetails", details);
            request.getRequestDispatcher("/view/dashboard/warehouseManager/stock-take/view.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take");
        }
    }

    private void handleViewCompleted(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        try {
            int stockTakeId = Integer.parseInt(request.getParameter("id"));
            StockTake stockTake = stockTakeDAO.findById(stockTakeId);
            
            if (stockTake == null) {
                session.setAttribute("errorMessage", "Không tìm thấy phiếu kiểm kê!");
                response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take");
                return;
            }

            // Chỉ cho phép xem với trạng thái completed hoặc reconciled
            if (!"completed".equals(stockTake.getStatus()) && !"reconciled".equals(stockTake.getStatus())) {
                session.setAttribute("errorMessage", "Phiếu kiểm kê chưa hoàn thành!");
                response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take");
                return;
            }

            List<StockTakeDetail> details = stockTakeDetailDAO.findByStockTakeId(stockTakeId);
            List<StockTakeDetail> discrepancies = stockTakeDetailDAO.findDiscrepanciesByStockTakeId(stockTakeId);
            List<Object[]> statistics = stockTakeDetailDAO.getStockTakeStatistics(stockTakeId);
            
            request.setAttribute("stockTake", stockTake);
            request.setAttribute("stockTakeDetails", details);
            request.setAttribute("discrepancies", discrepancies);
            request.setAttribute("statistics", statistics);
            request.getRequestDispatcher("/view/dashboard/warehouseManager/stock-take/approval.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take");
        }
    }

    private void handleReconcileStockTake(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        try {
            int stockTakeId = Integer.parseInt(request.getParameter("stockTakeId"));
            StockTake stockTake = stockTakeDAO.findById(stockTakeId);
            
            if (stockTake == null || !"completed".equals(stockTake.getStatus())) {
                session.setAttribute("errorMessage", "Phiếu kiểm kê không hợp lệ hoặc chưa hoàn thành!");
                response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take");
                return;
            }

            // >> LOGIC MỚI: Kiểm tra xem có phiếu mới hơn đã được đối soát chưa
            if (stockTake.getWarehouseId() != null) {
                boolean hasNewer = stockTakeDAO.hasNewerReconciledStockTake(
                    stockTake.getWarehouseId(),
                    stockTake.getCreatedAt()
                );
                if (hasNewer) {
                    session.setAttribute("errorMessage", 
                        "Không thể đối soát phiếu này vì đã có một phiếu kiểm kê mới hơn cho cùng kho hàng (" 
                        + stockTake.getWarehouseName() + ") đã được đối soát. Vui lòng kiểm tra lại.");
                    response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take?action=approve-view&id=" + stockTakeId);
                    return;
                }
            }
            // << KẾT THÚC LOGIC MỚI

            // Lấy danh sách tất cả chi tiết kiểm kê đã được kiểm đếm
            List<StockTakeDetail> allDetails = stockTakeDetailDAO.findByStockTakeId(stockTakeId);
            
            boolean hasErrors = false;
            int updatedItems = 0;
            
            // Điều chỉnh inventory cho tất cả sản phẩm đã được kiểm đếm theo đúng warehouse
            Integer warehouseId = stockTake.getWarehouseId() != null ? stockTake.getWarehouseId() : 1;
            
            for (StockTakeDetail detail : allDetails) {
                if (detail.getCountedQuantity() != null) {
                    boolean success = inventoryDAO.updateQuantityByProductId(
                        detail.getProductId(), 
                        detail.getCountedQuantity(),
                        warehouseId
                    );
                    
                    if (success) {
                        updatedItems++;
                    } else {
                        hasErrors = true;
                    }
                }
            }
            
            if (!hasErrors) {
                // Cập nhật trạng thái thành reconciled
                stockTakeDAO.updateStatus(stockTakeId, "reconciled");
                session.setAttribute("successMessage", 
                    String.format("Điều chỉnh tồn kho thành công! Đã cập nhật %d sản phẩm.", updatedItems));
            } else {
                session.setAttribute("errorMessage", 
                    String.format("Điều chỉnh hoàn thành với một số lỗi. Đã cập nhật %d sản phẩm.", updatedItems));
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/warehouse-manager/stock-take");
    }
} 