package controller.dashboard.admin;

import dao.StockTakeDAO;
import dao.StockTakeDetailDAO;
import dao.ProductDAO;
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
import java.sql.Date;
import java.util.List;

@WebServlet(name = "StockTakeController", urlPatterns = {"/stock-take"})
public class StockTakeController extends HttpServlet {

    private StockTakeDAO stockTakeDAO;
    private StockTakeDetailDAO stockTakeDetailDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        stockTakeDAO = new StockTakeDAO();
        stockTakeDetailDAO = new StockTakeDetailDAO();
        productDAO = new ProductDAO();
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
            case "report":
                handleViewReport(request, response);
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
            // Admin xem được tất cả
            if (status != null && !status.isEmpty()) {
                stockTakes = stockTakeDAO.findByStatus(status);
            } else {
                stockTakes = stockTakeDAO.findAll();
            }
        }

        request.setAttribute("stockTakes", stockTakes);
        request.setAttribute("currentUser", currentUser);
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
            
            StockTake stockTake = new StockTake();
            stockTake.setStockTakeCode(stockTakeDAO.generateStockTakeCode());
            stockTake.setUserId(currentUser.getUserId());
            stockTake.setStockTakeDate(new Date(System.currentTimeMillis()));
            stockTake.setStatus("pending");
            stockTake.setNotes(notes);

            int stockTakeId = stockTakeDAO.insert(stockTake);
            
            if (stockTakeId > 0) {
                // Tạo chi tiết kiểm kê cho tất cả sản phẩm
                stockTakeDetailDAO.createStockTakeDetailsForAllProducts(stockTakeId);
                
                session.setAttribute("successMessage", "Tạo phiếu kiểm kê thành công!");
                response.sendRedirect(request.getContextPath() + "/stock-take?action=perform&id=" + stockTakeId);
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
        
        if (currentUser == null || !"warehouse_staff".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
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

            boolean updated = stockTakeDetailDAO.updateCountedQuantity(stockTakeDetailId, countedQuantity);
            
            if (updated) {
                // Kiểm tra xem đã hoàn thành kiểm kê chưa
                List<StockTakeDetail> details = stockTakeDetailDAO.findByStockTakeId(stockTakeId);
                boolean allCounted = details.stream().allMatch(d -> d.getCountedQuantity() != null);
                
                if (allCounted) {
                    stockTakeDAO.updateStatus(stockTakeId, "completed");
                } else {
                    stockTakeDAO.updateStatus(stockTakeId, "in_progress");
                }
                
                session.setAttribute("successMessage", "Cập nhật số lượng kiểm kê thành công!");
            } else {
                session.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật!");
            }
            
            response.sendRedirect(request.getContextPath() + "/stock-take?action=perform&id=" + stockTakeId);
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/stock-take");
        }
    }

    private void handleViewReport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        
        if (currentUser == null || !"admin".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
            return;
        }

        try {
            int stockTakeId = Integer.parseInt(request.getParameter("id"));
            StockTake stockTake = stockTakeDAO.findById(stockTakeId);
            
            if (stockTake == null) {
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
            request.getRequestDispatcher("/view/stock-take/report.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/stock-take");
        }
    }

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
} 