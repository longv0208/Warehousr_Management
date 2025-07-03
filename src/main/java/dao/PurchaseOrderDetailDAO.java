package dao;

import context.DBContext;
import model.PurchaseOrderDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PurchaseOrderDetailDAO extends DBContext implements I_DAO<PurchaseOrderDetail> {

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
    public PurchaseOrderDetail getFromResultSet(ResultSet rs) throws SQLException {
        PurchaseOrderDetail poDetail = new PurchaseOrderDetail();
        poDetail.setPoDetailId(rs.getInt("po_detail_id"));
        poDetail.setPoId(rs.getInt("po_id"));
        poDetail.setProductId(rs.getInt("product_id"));
        poDetail.setQuantity(rs.getInt("quantity"));
        poDetail.setUnitPrice(rs.getBigDecimal("unit_price"));
        return poDetail;
    }

    @Override
    public List<PurchaseOrderDetail> findAll() {
        List<PurchaseOrderDetail> poDetails = new ArrayList<>();
        String sql = "SELECT * FROM purchase_order_details";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                poDetails.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding all Purchase Order details: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return poDetails;
    }

    @Override
    public PurchaseOrderDetail findById(Integer id) {
        String sql = "SELECT * FROM purchase_order_details WHERE po_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Purchase Order detail by ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return null;
    }

    @Override
    public int insert(PurchaseOrderDetail poDetail) {
        String sql = "INSERT INTO purchase_order_details (po_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, poDetail.getPoId());
            statement.setInt(2, poDetail.getProductId());
            statement.setInt(3, poDetail.getQuantity());
            statement.setBigDecimal(4, poDetail.getUnitPrice());
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating Purchase Order detail failed, no rows affected.");
            }
            
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating Purchase Order detail failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting Purchase Order detail: " + ex.getMessage());
            return -1;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean update(PurchaseOrderDetail poDetail) {
        String sql = "UPDATE purchase_order_details SET po_id = ?, product_id = ?, quantity = ?, unit_price = ? WHERE po_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, poDetail.getPoId());
            statement.setInt(2, poDetail.getProductId());
            statement.setInt(3, poDetail.getQuantity());
            statement.setBigDecimal(4, poDetail.getUnitPrice());
            statement.setInt(5, poDetail.getPoDetailId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating Purchase Order detail: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean delete(PurchaseOrderDetail poDetail) {
        String sql = "DELETE FROM purchase_order_details WHERE po_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, poDetail.getPoDetailId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error deleting Purchase Order detail: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    // Custom methods
    public List<PurchaseOrderDetail> findByPoId(Integer poId) {
        List<PurchaseOrderDetail> poDetails = new ArrayList<>();
        String sql = "SELECT * FROM purchase_order_details WHERE po_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, poId);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                poDetails.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Purchase Order details by PO ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return poDetails;
    }

    public boolean deleteByPoId(Integer poId) {
        String sql = "DELETE FROM purchase_order_details WHERE po_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, poId);
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected >= 0; // Có thể không có detail nào để xóa
        } catch (SQLException ex) {
            System.out.println("Error deleting Purchase Order details by PO ID: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }
} 