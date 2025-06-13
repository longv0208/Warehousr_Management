package dao;

import context.DBContext;
import model.Inventory;
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
        String sql = "INSERT INTO inventory (product_id, quantity_on_hand) VALUES (?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, inventory.getProductId());
            statement.setInt(2, inventory.getQuantityOnHand());

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
     * Get inventory quantity for a specific product
     */
    public Integer getQuantityByProductId(Integer productId) {
        String sql = "SELECT quantity_on_hand FROM inventory WHERE product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, productId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("quantity_on_hand");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting quantity for product ID: " + productId, ex);
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
        String sql = "UPDATE inventory SET quantity_on_hand = ? WHERE product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, quantity);
            statement.setInt(2, productId);
            int rowsAffected = statement.executeUpdate();
            
            // If no rows were affected, create a new inventory record
            if (rowsAffected == 0) {
                Inventory inventory = Inventory.builder()
                    .productId(productId)
                    .quantityOnHand(quantity)
                    .build();
                return insert(inventory) > 0;
            }
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating quantity for product ID: " + productId, ex);
            return false;
        } finally {
            close();
        }
    }

    /**
     * Decrease quantity for a product (for sales)
     */
    public boolean decreaseQuantity(Integer productId, Integer decreaseAmount) {
        String sql = "UPDATE inventory SET quantity_on_hand = quantity_on_hand - ? WHERE product_id = ? AND quantity_on_hand >= ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, decreaseAmount);
            statement.setInt(2, productId);
            statement.setInt(3, decreaseAmount);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error decreasing quantity for product ID: " + productId, ex);
            return false;
        } finally {
            close();
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
} 