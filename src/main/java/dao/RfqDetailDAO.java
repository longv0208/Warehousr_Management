package dao;

import context.DBContext;
import model.RfqDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RfqDetailDAO extends DBContext implements I_DAO<RfqDetail> {

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
    public RfqDetail getFromResultSet(ResultSet rs) throws SQLException {
        RfqDetail rfqDetail = new RfqDetail();
        rfqDetail.setRfqDetailId(rs.getInt("rfq_detail_id"));
        rfqDetail.setRfqId(rs.getInt("rfq_id"));
        rfqDetail.setProductId(rs.getInt("product_id"));
        rfqDetail.setQuantity(rs.getInt("quantity"));
        
        // Handle price field (may be null)
        Double price = rs.getDouble("price");
        if (!rs.wasNull()) {
            rfqDetail.setPrice(price);
        }
        
        return rfqDetail;
    }

    @Override
    public List<RfqDetail> findAll() {
        List<RfqDetail> rfqDetails = new ArrayList<>();
        String sql = "SELECT * FROM rfq_details";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                rfqDetails.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding all RFQ details: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return rfqDetails;
    }

    @Override
    public RfqDetail findById(Integer id) {
        String sql = "SELECT * FROM rfq_details WHERE rfq_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding RFQ detail by ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return null;
    }
    
    /**
     * Get RFQ details by RFQ ID
     */
    public List<RfqDetail> getRfqDetailsByRfqId(int rfqId) {
        List<RfqDetail> rfqDetails = new ArrayList<>();
        String sql = "SELECT * FROM rfq_details WHERE rfq_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, rfqId);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                rfqDetails.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error getting RFQ details by RFQ ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return rfqDetails;
    }

    @Override
    public int insert(RfqDetail rfqDetail) {
        String sql = "INSERT INTO rfq_details (rfq_id, product_id, quantity) VALUES (?, ?, ?)";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, rfqDetail.getRfqId());
            statement.setInt(2, rfqDetail.getProductId());
            statement.setInt(3, rfqDetail.getQuantity());
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating RFQ detail failed, no rows affected.");
            }
            
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating RFQ detail failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting RFQ detail: " + ex.getMessage());
            return -1;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean update(RfqDetail rfqDetail) {
        String sql = "UPDATE rfq_details SET rfq_id = ?, product_id = ?, quantity = ? WHERE rfq_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, rfqDetail.getRfqId());
            statement.setInt(2, rfqDetail.getProductId());
            statement.setInt(3, rfqDetail.getQuantity());
            statement.setInt(4, rfqDetail.getRfqDetailId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating RFQ detail: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean delete(RfqDetail rfqDetail) {
        String sql = "DELETE FROM rfq_details WHERE rfq_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, rfqDetail.getRfqDetailId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error deleting RFQ detail: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    // Custom methods
    public List<RfqDetail> findByRfqId(Integer rfqId) {
        List<RfqDetail> rfqDetails = new ArrayList<>();
        String sql = "SELECT * FROM rfq_details WHERE rfq_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, rfqId);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                rfqDetails.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding RFQ details by RFQ ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return rfqDetails;
    }

    public boolean deleteByRfqId(Integer rfqId) {
        String sql = "DELETE FROM rfq_details WHERE rfq_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, rfqId);
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected >= 0; // Có thể không có detail nào để xóa
        } catch (SQLException ex) {
            System.out.println("Error deleting RFQ details by RFQ ID: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }
    
    /**
     * Update price for a specific RFQ detail
     */
    public boolean updateRfqDetailPrice(int rfqDetailId, double price) {
        String sql = "UPDATE rfq_details SET price = ? WHERE rfq_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setDouble(1, price);
            statement.setInt(2, rfqDetailId);
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating RFQ detail price: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }
}
