package dao;

import context.DBContext;
import model.Rfq;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RfqDAO extends DBContext implements I_DAO<Rfq> {

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
    public Rfq getFromResultSet(ResultSet rs) throws SQLException {
        Rfq rfq = new Rfq();
        rfq.setRfqId(rs.getInt("rfq_id"));
        rfq.setRfqCode(rs.getString("rfq_code"));
        rfq.setExpectedDeliveryDate(rs.getDate("expected_delivery_date"));
        rfq.setProviderId(rs.getInt("provider_id"));
        rfq.setWarehouseId(rs.getInt("warehouse_id"));
        rfq.setUserIdRequester(rs.getInt("user_id_requester"));
        rfq.setStatus(rs.getString("status"));
        rfq.setNote(rs.getString("note"));
        rfq.setCreatedAt(rs.getTimestamp("created_at"));
        return rfq;
    }

    @Override
    public List<Rfq> findAll() {
        List<Rfq> rfqs = new ArrayList<>();
        String sql = "SELECT * FROM rfqs ORDER BY created_at DESC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                rfqs.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding all RFQs: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return rfqs;
    }

    @Override
    public Rfq findById(Integer id) {
        String sql = "SELECT * FROM rfqs WHERE rfq_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding RFQ by ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return null;
    }

    @Override
    public int insert(Rfq rfq) {
        String sql = "INSERT INTO rfqs (rfq_code, expected_delivery_date, provider_id, warehouse_id, " +
                    "user_id_requester, status, note) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, rfq.getRfqCode());
            statement.setDate(2, rfq.getExpectedDeliveryDate());
            statement.setInt(3, rfq.getProviderId());
            statement.setInt(4, rfq.getWarehouseId());
            statement.setInt(5, rfq.getUserIdRequester());
            statement.setString(6, rfq.getStatus());
            statement.setString(7, rfq.getNote());
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating RFQ failed, no rows affected.");
            }
            
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating RFQ failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting RFQ: " + ex.getMessage());
            return -1;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean update(Rfq rfq) {
        String sql = "UPDATE rfqs SET rfq_code = ?, expected_delivery_date = ?, provider_id = ?, " +
                    "warehouse_id = ?, user_id_requester = ?, status = ?, note = ? WHERE rfq_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, rfq.getRfqCode());
            statement.setDate(2, rfq.getExpectedDeliveryDate());
            statement.setInt(3, rfq.getProviderId());
            statement.setInt(4, rfq.getWarehouseId());
            statement.setInt(5, rfq.getUserIdRequester());
            statement.setString(6, rfq.getStatus());
            statement.setString(7, rfq.getNote());
            statement.setInt(8, rfq.getRfqId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating RFQ: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean delete(Rfq rfq) {
        String sql = "DELETE FROM rfqs WHERE rfq_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, rfq.getRfqId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error deleting RFQ: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    // Custom methods
    public List<Rfq> findByStatus(String status) {
        List<Rfq> rfqs = new ArrayList<>();
        String sql = "SELECT * FROM rfqs WHERE status = ? ORDER BY created_at DESC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, status);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                rfqs.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding RFQs by status: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return rfqs;
    }

    public List<Rfq> findByUserId(Integer userId) {
        List<Rfq> rfqs = new ArrayList<>();
        String sql = "SELECT * FROM rfqs WHERE user_id_requester = ? ORDER BY created_at DESC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, userId);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                rfqs.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding RFQs by user: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return rfqs;
    }

    public String generateRfqCode() {
        String sql = "SELECT COUNT(*) + 1 as next_id FROM rfqs";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                int nextId = resultSet.getInt("next_id");
                return String.format("RFQ%06d", nextId);
            }
        } catch (SQLException ex) {
            System.out.println("Error generating RFQ code: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return "RFQ000001";
    }
} 