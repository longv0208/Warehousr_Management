package controller.dashboard.admin;

import dao.LowStockProductDAO;
import model.LowStockProduct;
import model.User;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "LowStockReportServlet", urlPatterns = {"/low-stock-report"})
public class LowStockReportServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(LowStockReportServlet.class.getName());
    private LowStockProductDAO lowStockProductDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        lowStockProductDAO = new LowStockProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền truy cập - chỉ admin và warehouse_staff được xem báo cáo
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null || 
            (!currentUser.getRoleId().equals("admin") && 
             !currentUser.getRoleId().equals("warehouse_staff"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if ("out-of-stock".equals(action)) {
                handleOutOfStockReport(request, response);
            } else {
                handleLowStockReport(request, response);
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing low stock report request", e);
            request.setAttribute("errorMessage", "Có lỗi xảy ra khi tải báo cáo: " + e.getMessage());
            request.getRequestDispatcher("/view/low-stock/report.jsp").forward(request, response);
        }
    }
    
    private void handleLowStockReport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy tham số sắp xếp
        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.isEmpty()) {
            sortBy = "quantity"; // Mặc định sắp xếp theo số lượng tăng dần
        }
        
        // Lấy danh sách sản phẩm sắp hết hàng
        List<LowStockProduct> lowStockProducts = lowStockProductDAO.getLowStockProducts(sortBy);
        
        // Lấy tổng số sản phẩm sắp hết hàng
        int totalLowStockProducts = lowStockProductDAO.getTotalLowStockProducts();
        
        // Set attributes cho JSP
        request.setAttribute("lowStockProducts", lowStockProducts);
        request.setAttribute("totalLowStockProducts", totalLowStockProducts);
        request.setAttribute("currentSortBy", sortBy);
        request.setAttribute("reportType", "low-stock");
        
        // Forward tới JSP
        request.getRequestDispatcher("/view/low-stock/report.jsp").forward(request, response);
    }
    
    private void handleOutOfStockReport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy danh sách sản phẩm hết hàng
        List<LowStockProduct> outOfStockProducts = lowStockProductDAO.getOutOfStockProducts();
        
        // Set attributes cho JSP
        request.setAttribute("lowStockProducts", outOfStockProducts);
        request.setAttribute("totalLowStockProducts", outOfStockProducts.size());
        request.setAttribute("reportType", "out-of-stock");
        
        // Forward tới JSP
        request.getRequestDispatcher("/view/low-stock/report.jsp").forward(request, response);
    }
} 