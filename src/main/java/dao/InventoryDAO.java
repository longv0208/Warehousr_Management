package dao;

import context.DBContext;
import model.Inventory;
import model.InventoryWithProduct;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class InventoryDAO extends DBContext implements I_DAO<Inventory> {

    private static final Logger LOGGER = Logger.getLogger(InventoryDAO.class.getName());

    @Override
    public Inventory getFromResultSet(ResultSet rs) throws SQLException {
        return Inventory.builder()
                .inventoryId(rs.getInt("inventory_id"))
                .productId(rs.getInt("product_id"))
                .quantityOnHand(rs.getInt("quantity_on_hand"))
                .lastUpdated(rs.getTimestamp("last_updated"))
                .warehouseId(rs.getInt("warehouse_id"))
                .build();
    }

    @Override
    public List<Inventory> findAll() {
        List<Inventory> inventories = new ArrayList<>();
        String sql = "SELECT * FROM inventory";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                inventories.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all inventories", ex);
        } finally {
            close();
        }
        return inventories;
    }

    @Override
    public int insert(Inventory inventory) {
        String sql = "INSERT INTO inventory (product_id, quantity_on_hand, warehouse_id) VALUES (?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, inventory.getProductId());
            statement.setInt(2, inventory.getQuantityOnHand());
            statement.setInt(3, inventory.getWarehouseId() != null ? inventory.getWarehouseId() : 1); // Default warehouse

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating inventory failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating inventory failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting inventory: " + inventory.toString(), ex);
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(Inventory inventory) {
        String sql = "UPDATE inventory SET quantity_on_hand = ? WHERE product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, inventory.getQuantityOnHand());
            statement.setInt(2, inventory.getProductId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating inventory: " + inventory.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(Inventory inventory) {
        String sql = "DELETE FROM inventory WHERE inventory_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, inventory.getInventoryId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting inventory: " + inventory.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public Inventory findById(Integer id) {
        String sql = "SELECT * FROM inventory WHERE inventory_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding inventory by ID: " + id, ex);
        } finally {
            close();
        }
        return null;
    }

    /**
     * Get inventory quantity for a specific product (tổng từ tất cả kho)
     */
    public Integer getQuantityByProductId(Integer productId) {
        String sql = "SELECT SUM(quantity_on_hand) as total_quantity FROM inventory WHERE product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, productId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("total_quantity");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting quantity for product ID: " + productId, ex);
        } finally {
            close();
        }
        return 0; // Return 0 if no inventory record found
    }

    /**
     * Get inventory quantity for a specific product in a specific warehouse
     */
    public Integer getQuantityByProductIdAndWarehouse(Integer productId, Integer warehouseId) {
        String sql = "SELECT quantity_on_hand FROM inventory WHERE product_id = ? AND warehouse_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, productId);
            statement.setInt(2, warehouseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("quantity_on_hand");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting quantity for product ID: " + productId + " in warehouse: " + warehouseId, ex);
        } finally {
            close();
        }
        return 0; // Return 0 if no inventory record found
    }

    /**
     * Find inventory record by product ID
     */
    public Inventory findByProductId(Integer productId) {
        String sql = "SELECT * FROM inventory WHERE product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, productId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding inventory by product ID: " + productId, ex);
        } finally {
            close();
        }
        return null;
    }

    /**
     * Update quantity for a specific product
     */
    public boolean updateQuantityByProductId(Integer productId, Integer quantity) {
        // Mặc định cập nhật warehouse_id = 1 (kho mặc định)
        return updateQuantityByProductId(productId, quantity, 1);
    }

    /**
     * Update quantity for a specific product in a specific warehouse
     */
    public boolean updateQuantityByProductId(Integer productId, Integer quantity, Integer warehouseId) {
        String sql = "UPDATE inventory SET quantity_on_hand = ? WHERE product_id = ? AND warehouse_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, quantity);
            statement.setInt(2, productId);
            statement.setInt(3, warehouseId);
            int rowsAffected = statement.executeUpdate();
            
            // If no rows were affected, create a new inventory record
            if (rowsAffected == 0) {
                String insertSql = "INSERT INTO inventory (product_id, quantity_on_hand, warehouse_id) VALUES (?, ?, ?)";
                statement = conn.prepareStatement(insertSql);
                statement.setInt(1, productId);
                statement.setInt(2, quantity);
                statement.setInt(3, warehouseId);
                return statement.executeUpdate() > 0;
            }
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating quantity for product ID: " + productId + " in warehouse: " + warehouseId, ex);
            return false;
        } finally {
            close();
        }
    }

    /**
     * Decrease quantity for a product in a specific warehouse (for sales, transfers, etc.)
     * This method ensures that the stock doesn't go below zero.
     *
     * @param productId The ID of the product.
     * @param warehouseId The ID of the warehouse.
     * @param decreaseAmount The amount to decrease.
     * @return true if the update was successful, false otherwise.
     */
    public boolean decreaseQuantity(Integer productId, Integer warehouseId, Integer decreaseAmount) {
        String sql = "UPDATE inventory SET quantity_on_hand = quantity_on_hand - ? "
                + "WHERE product_id = ? AND warehouse_id = ? AND quantity_on_hand >= ?";
        try {
            conn = getConnection(); // Assuming getConnection() is handled by DBContext
            statement = conn.prepareStatement(sql);
            statement.setInt(1, decreaseAmount);
            statement.setInt(2, productId);
            statement.setInt(3, warehouseId);
            statement.setInt(4, decreaseAmount); // Ensure we have enough stock

            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0; // Returns true if a row was updated
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error decreasing quantity for product ID: " + productId + " in warehouse: " + warehouseId, ex);
            return false;
        } finally {
            close(); // Manages closing connections
        }
    }

    /**
     * Increase quantity for a product (for purchases/stock)
     */
    public boolean increaseQuantity(Integer productId, Integer increaseAmount) {
        String sql = "UPDATE inventory SET quantity_on_hand = quantity_on_hand + ? WHERE product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, increaseAmount);
            statement.setInt(2, productId);
            int rowsAffected = statement.executeUpdate();
            
            // If no rows were affected, create a new inventory record
            if (rowsAffected == 0) {
                Inventory inventory = Inventory.builder()
                    .productId(productId)
                    .quantityOnHand(increaseAmount)
                    .build();
                return insert(inventory) > 0;
            }
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error increasing quantity for product ID: " + productId, ex);
            return false;
        } finally {
            close();
        }
    }

    /**
     * Count products with inventory in a specific warehouse
     */
    public int countProductsInWarehouse(Integer warehouseId) {
        String sql = "SELECT COUNT(DISTINCT i.product_id) as product_count " +
                    "FROM inventory i " +
                    "JOIN products p ON i.product_id = p.product_id " +
                    "WHERE i.warehouse_id = ? AND i.quantity_on_hand > 0 AND p.is_active = 1";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, warehouseId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("product_count");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting products in warehouse ID: " + warehouseId, ex);
        } finally {
            close();
        }
        return 0;
    }

    /**
     * Check if warehouse has any products with inventory
     */
    public boolean hasProductsInWarehouse(Integer warehouseId) {
        return countProductsInWarehouse(warehouseId) > 0;
    }

    /**
     * Find all inventory with product and warehouse information
     */
    public List<InventoryWithProduct> findAllWithProductInfo() {
        List<InventoryWithProduct> inventories = new ArrayList<>();
        String sql = "SELECT i.*, p.product_name, p.product_code, p.unit, w.warehouse_name " +
                    "FROM inventory i " +
                    "LEFT JOIN products p ON i.product_id = p.product_id " +
                    "LEFT JOIN warehouses w ON i.warehouse_id = w.warehouse_id " +
                    "ORDER BY w.warehouse_name, p.product_name";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                InventoryWithProduct inventory = InventoryWithProduct.builder()
                    .inventoryId(resultSet.getInt("inventory_id"))
                    .productId(resultSet.getInt("product_id"))
                    .quantityOnHand(resultSet.getInt("quantity_on_hand"))
                    .lastUpdated(resultSet.getTimestamp("last_updated"))
                    .warehouseId(resultSet.getInt("warehouse_id"))
                    .productName(resultSet.getString("product_name"))
                    .productCode(resultSet.getString("product_code"))
                    .unit(resultSet.getString("unit"))
                    .warehouseName(resultSet.getString("warehouse_name"))
                    .build();
                inventories.add(inventory);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all inventories with product info", ex);
        } finally {
            close();
        }
        return inventories;
    }

    /**
     * Update inventory quantity after purchase request approval
     * This method adds the requested quantity to existing inventory
     */
    public boolean updateQuantityAfterApproval(Integer productId, Integer requestedQuantity, Integer warehouseId) {
        try {
            // Kiểm tra xem sản phẩm đã tồn tại trong kho chưa
            Integer currentQuantity = getQuantityByProductIdAndWarehouse(productId, warehouseId);
            
            if (currentQuantity == 0) {
                // Nếu chưa có inventory record, tạo mới
                String insertSql = "INSERT INTO inventory (product_id, quantity_on_hand, warehouse_id) VALUES (?, ?, ?)";
                conn = getConnection();
                statement = conn.prepareStatement(insertSql);
                statement.setInt(1, productId);
                statement.setInt(2, requestedQuantity);
                statement.setInt(3, warehouseId);
                return statement.executeUpdate() > 0;
            } else {
                // Nếu đã có, cộng thêm số lượng
                String updateSql = "UPDATE inventory SET quantity_on_hand = quantity_on_hand + ? WHERE product_id = ? AND warehouse_id = ?";
                conn = getConnection();
                statement = conn.prepareStatement(updateSql);
                statement.setInt(1, requestedQuantity);
                statement.setInt(2, productId);
                statement.setInt(3, warehouseId);
                return statement.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating inventory after approval for product ID: " + productId + 
                      " in warehouse: " + warehouseId + " with quantity: " + requestedQuantity, ex);
            return false;
        } finally {
            close();
        }
    }

    /**
     * Update quantity on hand for a specific product in a specific warehouse
     * @param productId Product ID
     * @param warehouseId Warehouse ID  
     * @param quantity Quantity to add or subtract
     * @param operation "add" to increase, "subtract" to decrease
     * @return true if successful, false otherwise
     */
    public boolean updateQuantityOnHand(Integer productId, Integer warehouseId, Integer quantity, String operation) {
        String sql;
        if ("add".equals(operation)) {
            sql = "UPDATE inventory SET quantity_on_hand = quantity_on_hand + ? WHERE product_id = ? AND warehouse_id = ?";
        } else if ("subtract".equals(operation)) {
            sql = "UPDATE inventory SET quantity_on_hand = quantity_on_hand - ? WHERE product_id = ? AND warehouse_id = ?";
        } else {
            LOGGER.log(Level.WARNING, "Invalid operation: " + operation + ". Use 'add' or 'subtract'");
            return false;
        }

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, quantity);
            statement.setInt(2, productId);
            statement.setInt(3, warehouseId);
            
            int rowsAffected = statement.executeUpdate();
            
            // Nếu không có bản ghi nào được cập nhật và operation là "add", tạo bản ghi mới
            if (rowsAffected == 0 && "add".equals(operation)) {
                String checkSql = "SELECT COUNT(*) FROM inventory WHERE product_id = ? AND warehouse_id = ?";
                statement = conn.prepareStatement(checkSql);
                statement.setInt(1, productId);
                statement.setInt(2, warehouseId);
                resultSet = statement.executeQuery();
                
                if (resultSet.next() && resultSet.getInt(1) == 0) {
                    // Tạo bản ghi mới
                    String insertSql = "INSERT INTO inventory (product_id, quantity_on_hand, warehouse_id) VALUES (?, ?, ?)";
                    statement = conn.prepareStatement(insertSql);
                    statement.setInt(1, productId);
                    statement.setInt(2, quantity);
                    statement.setInt(3, warehouseId);
                    return statement.executeUpdate() > 0;
                }
            }
            
            return rowsAffected > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating quantity on hand for product: " + productId + 
                      " in warehouse: " + warehouseId + " with operation: " + operation, ex);
            return false;
        } finally {
            close();
        }
    }

    public Inventory getInventoryByProductAndWarehouse(int productId, int warehouseId) {
        String sql = "SELECT * FROM inventory WHERE product_id = ? AND warehouse_id = ?";
        try (
            java.sql.Connection c = getConnection(); 
            java.sql.PreparedStatement st = c.prepareStatement(sql)
        ) {
            st.setInt(1, productId);
            st.setInt(2, warehouseId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return getFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting inventory for product " + productId + " in warehouse " + warehouseId, e);
        }
        return null; 
    }
} 