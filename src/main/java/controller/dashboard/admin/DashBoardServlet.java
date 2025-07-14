package controller.dashboard.admin;

import context.DBContext;
import model.Product;
import model.Supplier;
import model.Category;
import model.User;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import com.google.gson.Gson;

@WebServlet("/dashboard")
public class DashBoardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization - only admins can access this page
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!"admin".equals(currentUser.getRoleId())) {
            request.getSession().setAttribute("toastMessage", "Bạn không có quyền truy cập trang này!");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        int totalProducts = 0;
        int totalReceivedToday = 0;
        int totalUsers = 0;
        int totalLowStock = 0;
        int totalOutOfStock = 0;
        
        // Data for charts
        List<Map<String, Object>> monthlyOrdersData = new ArrayList<>();
        List<Map<String, Object>> categoryData = new ArrayList<>();

        DBContext db = null;

        try {
            db = new DBContext();
            Connection conn = db.getConnection();

            // 1. Total Products (is_active = 1)
            String sqlTotalProducts = "SELECT COUNT(*) AS total_products FROM products WHERE is_active = 1";
            try (PreparedStatement ps = conn.prepareStatement(sqlTotalProducts); 
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalProducts = rs.getInt("total_products");
                }
            }

            // 2. Products received today
            String sqlReceivedToday = "SELECT COUNT(*) AS total_products_today " +
                    "FROM products " +
                    "WHERE DATE(created_at) = CURDATE() AND is_active = 1";
            try (PreparedStatement ps = conn.prepareStatement(sqlReceivedToday); 
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalReceivedToday = rs.getInt("total_products_today");
                }
            }

            // 3. Total Users (is_active = 1)
            String sqlTotalUsers = "SELECT COUNT(*) AS total_users FROM users WHERE is_active = 1";
            try (PreparedStatement ps = conn.prepareStatement(sqlTotalUsers); 
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalUsers = rs.getInt("total_users");
                }
            }

            // 4. Low Stock and Out of Stock products
            String sqlStockStatus = "SELECT " +
                    "SUM(CASE WHEN IFNULL(i.quantity_on_hand, 0) <= p.low_stock_threshold AND IFNULL(i.quantity_on_hand, 0) > 0 THEN 1 ELSE 0 END) AS low_stock, " +
                    "SUM(CASE WHEN IFNULL(i.quantity_on_hand, 0) = 0 THEN 1 ELSE 0 END) AS out_of_stock " +
                    "FROM products p " +
                    "LEFT JOIN inventory i ON p.product_id = i.product_id " +
                    "WHERE p.is_active = 1";
            try (PreparedStatement ps = conn.prepareStatement(sqlStockStatus); 
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalLowStock = rs.getInt("low_stock");
                    totalOutOfStock = rs.getInt("out_of_stock");
                }
            }

            // 5. Monthly Orders Data for Chart (last 6 months)
            String sqlMonthlyOrders = "SELECT " +
                    "YEAR(so.created_at) AS year, " +
                    "MONTH(so.created_at) AS month, " +
                    "COUNT(*) AS order_count, " +
                    "SUM(sod.quantity_ordered * sod.unit_sale_price) AS total_amount " +
                    "FROM salesorders so " +
                    "LEFT JOIN salesorderdetails sod ON so.sales_order_id = sod.sales_order_id " +
                    "WHERE so.created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                    "AND so.status != 'cancelled' " +
                    "GROUP BY YEAR(so.created_at), MONTH(so.created_at) " +
                    "ORDER BY year, month";
            
            try (PreparedStatement ps = conn.prepareStatement(sqlMonthlyOrders); 
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> monthData = new HashMap<>();
                    monthData.put("year", rs.getInt("year"));
                    monthData.put("month", rs.getInt("month"));
                    monthData.put("orderCount", rs.getInt("order_count"));
                    monthData.put("totalAmount", rs.getDouble("total_amount"));
                    monthlyOrdersData.add(monthData);
                }
            }

            // 6. Category Distribution Data
            String sqlCategoryData = "SELECT c.name as category_name, COUNT(DISTINCT cp.product_id) AS product_count " +
                    "FROM category c " +
                    "LEFT JOIN `category-product` cp ON c.id = CAST(cp.category_id AS UNSIGNED) " +
                    "LEFT JOIN products p ON cp.product_id = CAST(p.product_id AS CHAR) AND p.is_active = 1 " +
                    "GROUP BY c.id, c.name " +
                    "ORDER BY product_count DESC";
            
            try (PreparedStatement ps = conn.prepareStatement(sqlCategoryData); 
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> catData = new HashMap<>();
                    catData.put("categoryName", rs.getString("category_name"));
                    catData.put("productCount", rs.getInt("product_count"));
                    categoryData.add(catData);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Dashboard SQL Error: " + e.getMessage());
            request.setAttribute("errorMessage", "Lỗi khi tải dữ liệu dashboard: " + e.getMessage());
        } finally {
            if (db != null) {
                try {
                    db.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        // Convert chart data to JSON using Gson
        Gson gson = new Gson();
        String monthlyOrdersJson = gson.toJson(monthlyOrdersData);
        String categoryDataJson = gson.toJson(categoryData);

        // Debug logging
        System.out.println("Dashboard Debug - Total Products: " + totalProducts);
        System.out.println("Dashboard Debug - Total Users: " + totalUsers);
        System.out.println("Dashboard Debug - Low Stock: " + totalLowStock);
        System.out.println("Dashboard Debug - Out of Stock: " + totalOutOfStock);
        System.out.println("Dashboard Debug - Category Data Count: " + categoryData.size());

        // Set attributes for JSP
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalReceivedToday", totalReceivedToday);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalLowStock", totalLowStock);
        request.setAttribute("totalOutOfStock", totalOutOfStock);
        
        // Chart data as JSON strings
        request.setAttribute("monthlyOrdersJson", monthlyOrdersJson);
        request.setAttribute("categoryDataJson", categoryDataJson);

        request.getRequestDispatcher("/view/dashboard/admin/dashboard.jsp").forward(request, response);
    }
}
