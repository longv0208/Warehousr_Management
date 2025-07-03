package dao;

import context.DBContext;
import model.PurchaseOrder;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PurchaseOrderDAO extends DBContext implements I_DAO<PurchaseOrder> {

    public void closeResources() {
        try {
            if (resultSet != null && !resultSet.isClosed()) {
                resultSet.close();
            }
            if (statement != null && !statement.isClosed()) {
                statement.close();
            }
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    @Override
    public PurchaseOrder getFromResultSet(ResultSet rs) throws SQLException {
        PurchaseOrder po = new PurchaseOrder();
        po.setPoId(rs.getInt("po_id"));
        po.setRfqId(rs.getInt("rfq_id"));
        po.setPoCode(rs.getString("po_code"));
        po.setProviderId(rs.getInt("provider_id"));
        po.setWarehouseId(rs.getInt("warehouse_id"));
        
        Timestamp orderDateTime = rs.getTimestamp("order_date");
        if (orderDateTime != null) {
            po.setOrderDate(orderDateTime.toLocalDateTime());
        }
        
        po.setExpectedDeliveryDate(rs.getDate("expected_delivery_date"));
        po.setStatus(rs.getString("status"));
        po.setCreatedAt(rs.getTimestamp("created_at"));
        return po;
    }

    @Override
    public List<PurchaseOrder> findAll() {
        List<PurchaseOrder> pos = new ArrayList<>();
        String sql = "SELECT * FROM purchase_orders ORDER BY created_at DESC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                pos.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding all Purchase Orders: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return pos;
    }

    @Override
    public PurchaseOrder findById(Integer id) {
        String sql = "SELECT * FROM purchase_orders WHERE po_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Purchase Order by ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return null;
    }

    @Override
    public int insert(PurchaseOrder po) {
        String sql = "INSERT INTO purchase_orders (rfq_id, po_code, provider_id, warehouse_id, " +
                    "order_date, expected_delivery_date, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, po.getRfqId());
            statement.setString(2, po.getPoCode());
            statement.setInt(3, po.getProviderId());
            statement.setInt(4, po.getWarehouseId());
            statement.setTimestamp(5, po.getOrderDate() != null ? Timestamp.valueOf(po.getOrderDate()) : null);
            statement.setDate(6, po.getExpectedDeliveryDate());
            statement.setString(7, po.getStatus());
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating Purchase Order failed, no rows affected.");
            }
            
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating Purchase Order failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting Purchase Order: " + ex.getMessage());
            return -1;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean update(PurchaseOrder po) {
        String sql = "UPDATE purchase_orders SET rfq_id = ?, po_code = ?, provider_id = ?, " +
                    "warehouse_id = ?, order_date = ?, expected_delivery_date = ?, status = ? WHERE po_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, po.getRfqId());
            statement.setString(2, po.getPoCode());
            statement.setInt(3, po.getProviderId());
            statement.setInt(4, po.getWarehouseId());
            statement.setTimestamp(5, po.getOrderDate() != null ? Timestamp.valueOf(po.getOrderDate()) : null);
            statement.setDate(6, po.getExpectedDeliveryDate());
            statement.setString(7, po.getStatus());
            statement.setInt(8, po.getPoId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating Purchase Order: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean delete(PurchaseOrder po) {
        String sql = "DELETE FROM purchase_orders WHERE po_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, po.getPoId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error deleting Purchase Order: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    // Custom methods
    public List<PurchaseOrder> findByStatus(String status) {
        List<PurchaseOrder> pos = new ArrayList<>();
        String sql = "SELECT * FROM purchase_orders WHERE status = ? ORDER BY created_at DESC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, status);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                pos.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Purchase Orders by status: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return pos;
    }

    public PurchaseOrder findByRfqId(Integer rfqId) {
        String sql = "SELECT * FROM purchase_orders WHERE rfq_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, rfqId);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Purchase Order by RFQ ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return null;
    }

    public String generatePoCode() {
        String sql = "SELECT COUNT(*) + 1 as next_id FROM purchase_orders";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                int nextId = resultSet.getInt("next_id");
                return String.format("PO%06d", nextId);
            }
        } catch (SQLException ex) {
            System.out.println("Error generating PO code: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return "PO000001";
    }
} 