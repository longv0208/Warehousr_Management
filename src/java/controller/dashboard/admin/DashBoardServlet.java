package controller.dashboard.admin;

import context.DBContext;
import model.Product;
import model.Supplier;
import model.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/dashboard")
public class DashBoardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String, Object>> recentProducts = new ArrayList<>();
        int totalProducts = 0;
        int totalReceivedToday = 0;
        int totalUsers = 0;

        DBContext db = null;

        try {
            db = new DBContext();
            Connection conn = db.getConnection();

            String sqlTotalProducts = "SELECT COUNT(*) AS total_products FROM products WHERE isActive = 1";
            try (PreparedStatement ps = conn.prepareStatement(sqlTotalProducts); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalProducts = rs.getInt("total_products");
                }
            }

            String sqlReceivedToday
                    = "SELECT COUNT(*) AS total_products_today "
                    + "FROM products "
                    + "WHERE CAST(created_at AS DATE) = CAST(GETDATE() AS DATE)";
            try (PreparedStatement ps = conn.prepareStatement(sqlReceivedToday); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalReceivedToday = rs.getInt("total_products_today"); // đúng alias
                }
            }

            String sqlTotalUsers = "SELECT COUNT(*) AS total_users FROM users WHERE isActive = 1";
            try (PreparedStatement ps = conn.prepareStatement(sqlTotalUsers); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalUsers = rs.getInt("total_users");
                }
            }

            String sqlRecentProducts
                    = "SELECT TOP 5 p.*, s.supplier_name, c.category_name "
                    + "FROM products p "
                    + "LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id "
                    + "LEFT JOIN categories c ON p.category_id = c.category_id "
                    + "WHERE p.isActive = 1 "
                    + "ORDER BY ISNULL(p.updated_at, p.created_at) DESC";

            try (PreparedStatement ps = conn.prepareStatement(sqlRecentProducts); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setProductId(rs.getInt("product_id"));
                    product.setProductCode(rs.getString("product_code"));
                    product.setProductName(rs.getString("product_name"));
                    product.setDescription(rs.getString("description"));
                    product.setUnit(rs.getString("unit"));
                    product.setPurchasePrice(rs.getFloat("purchase_price"));
                    product.setSalePrice(rs.getFloat("sale_price"));
                    product.setSupplierId(rs.getInt("supplier_id"));
                    product.setCategoryId(rs.getInt("category_id"));
                    product.setLowStockThreshold(rs.getInt("low_stock_threshold"));
                    product.setCreatedAt(rs.getTimestamp("created_at"));
                    product.setUpdatedAt(rs.getTimestamp("updated_at"));
                    product.setIsActive(rs.getBoolean("isActive"));

                    Supplier supplier = new Supplier();
                    supplier.setSupplierId(rs.getInt("supplier_id"));
                    supplier.setSupplierName(rs.getString("supplier_name"));

                    Category category = new Category();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setCategoryName(rs.getString("category_name"));

                    Map<String, Object> map = new HashMap<>();
                    map.put("product", product);
                    map.put("supplier", supplier);
                    map.put("category", category);

                    recentProducts.add(map);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (db != null) {
                db.close();
            }
        }

        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalReceivedToday", totalReceivedToday);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("recentProducts", recentProducts);

        request.getRequestDispatcher("/view/dashboard/admin/dashboard.jsp").forward(request, response);
    }
}
