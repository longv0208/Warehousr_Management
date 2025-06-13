package dao;

import context.DBContext;
import model.LowStockProduct;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class LowStockProductDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(LowStockProductDAO.class.getName());

    /**
     * Lấy danh sách sản phẩm sắp hết hàng
     * @param sortBy sắp xếp theo: "quantity" (số lượng), "product_name" (tên sản phẩm), "threshold" (ngưỡng cảnh báo)
     * @return danh sách sản phẩm sắp hết hàng
     */
    public List<LowStockProduct> getLowStockProducts(String sortBy) {
        List<LowStockProduct> lowStockProducts = new ArrayList<>();
        
        String sql = "SELECT p.product_id, p.product_code, p.product_name, p.description, " +
                    "p.unit, p.purchase_price, p.sale_price, p.low_stock_threshold, " +
                    "i.quantity_on_hand, s.supplier_name " +
                    "FROM products p " +
                    "INNER JOIN inventory i ON p.product_id = i.product_id " +
                    "LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id " +
                    "WHERE p.is_active = true AND i.quantity_on_hand <= p.low_stock_threshold ";
        
        // Thêm sắp xếp
        if ("quantity".equals(sortBy)) {
            sql += "ORDER BY i.quantity_on_hand ASC";
        } else if ("product_name".equals(sortBy)) {
            sql += "ORDER BY p.product_name ASC";
        } else if ("threshold".equals(sortBy)) {
            sql += "ORDER BY p.low_stock_threshold ASC";
        } else {
            sql += "ORDER BY i.quantity_on_hand ASC"; // Mặc định sắp xếp theo số lượng tăng dần
        }
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                lowStockProducts.add(getLowStockProductFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting low stock products", ex);
        } finally {
            close();
        }
        
        return lowStockProducts;
    }
    
    /**
     * Lấy tổng số sản phẩm sắp hết hàng
     * @return số lượng sản phẩm sắp hết hàng
     */
    public int getTotalLowStockProducts() {
        String sql = "SELECT COUNT(*) as total FROM products p " +
                    "INNER JOIN inventory i ON p.product_id = i.product_id " +
                    "WHERE p.is_active = true AND i.quantity_on_hand <= p.low_stock_threshold";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                return resultSet.getInt("total");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting total low stock products count", ex);
        } finally {
            close();
        }
        
        return 0;
    }
    
    /**
     * Lấy danh sách sản phẩm hết hàng hoàn toàn
     * @return danh sách sản phẩm hết hàng
     */
    public List<LowStockProduct> getOutOfStockProducts() {
        List<LowStockProduct> outOfStockProducts = new ArrayList<>();
        
        String sql = "SELECT p.product_id, p.product_code, p.product_name, p.description, " +
                    "p.unit, p.purchase_price, p.sale_price, p.low_stock_threshold, " +
                    "i.quantity_on_hand, s.supplier_name " +
                    "FROM products p " +
                    "INNER JOIN inventory i ON p.product_id = i.product_id " +
                    "LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id " +
                    "WHERE p.is_active = true AND i.quantity_on_hand = 0 " +
                    "ORDER BY p.product_name ASC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                outOfStockProducts.add(getLowStockProductFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting out of stock products", ex);
        } finally {
            close();
        }
        
        return outOfStockProducts;
    }
    
    /**
     * Chuyển đổi ResultSet thành LowStockProduct object
     */
    private LowStockProduct getLowStockProductFromResultSet(ResultSet rs) throws SQLException {
        return LowStockProduct.builder()
                .productId(rs.getInt("product_id"))
                .productCode(rs.getString("product_code"))
                .productName(rs.getString("product_name"))
                .description(rs.getString("description"))
                .unit(rs.getString("unit"))
                .purchasePrice(rs.getFloat("purchase_price"))
                .salePrice(rs.getFloat("sale_price"))
                .lowStockThreshold(rs.getInt("low_stock_threshold"))
                .quantityOnHand(rs.getInt("quantity_on_hand"))
                .supplierName(rs.getString("supplier_name"))
                .build();
    }
} 