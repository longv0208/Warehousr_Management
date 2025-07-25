package dao;

import context.DBContext;
import model.SalesQuotation;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SalesQuotationDAO extends DBContext implements I_DAO<SalesQuotation> {

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
    public SalesQuotation getFromResultSet(ResultSet rs) throws SQLException {
        SalesQuotation quotation = SalesQuotation.builder()
                .quotationId(rs.getInt("quotation_id"))
                .quotationCode(rs.getString("quotation_code"))
                .customerName(rs.getString("customer_name"))
                .customerEmail(rs.getString("customer_email"))
                .customerPhone(rs.getString("customer_phone"))
                .customerAddress(rs.getString("customer_address"))
                .userId(rs.getInt("user_id"))
                .quotationDate(rs.getDate("quotation_date"))
                .validUntil(rs.getDate("valid_until"))
                .status(rs.getString("status"))
                .notes(rs.getString("notes"))
                .warehouseId(rs.getInt("warehouse_id"))
                .createdAt(rs.getTimestamp("created_at"))
                .build();
        return quotation;
    }

    @Override
    public List<SalesQuotation> findAll() {
        List<SalesQuotation> quotations = new ArrayList<>();
        String sql = "SELECT * FROM sales_quotations ORDER BY created_at DESC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                quotations.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding all Sales Quotations: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return quotations;
    }

    @Override
    public SalesQuotation findById(Integer id) {
        String sql = "SELECT * FROM sales_quotations WHERE quotation_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Sales Quotation by ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return null;
    }

    @Override
    public int insert(SalesQuotation quotation) {
        String sql = "INSERT INTO sales_quotations (quotation_code, customer_name, customer_email, " +
                    "customer_phone, customer_address, user_id, quotation_date, valid_until, " +
                    "status, notes, warehouse_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, quotation.getQuotationCode());
            statement.setString(2, quotation.getCustomerName());
            statement.setString(3, quotation.getCustomerEmail());
            statement.setString(4, quotation.getCustomerPhone());
            statement.setString(5, quotation.getCustomerAddress());
            statement.setInt(6, quotation.getUserId());
            statement.setDate(7, quotation.getQuotationDate());
            statement.setDate(8, quotation.getValidUntil());
            statement.setString(9, quotation.getStatus());
            statement.setString(10, quotation.getNotes());
            statement.setInt(11, quotation.getWarehouseId());
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating Sales Quotation failed, no rows affected.");
            }
            
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating Sales Quotation failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting Sales Quotation: " + ex.getMessage());
            return -1;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean update(SalesQuotation quotation) {
        String sql = "UPDATE sales_quotations SET quotation_code = ?, customer_name = ?, " +
                    "customer_email = ?, customer_phone = ?, customer_address = ?, user_id = ?, " +
                    "quotation_date = ?, valid_until = ?, status = ?, notes = ?, warehouse_id = ? " +
                    "WHERE quotation_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, quotation.getQuotationCode());
            statement.setString(2, quotation.getCustomerName());
            statement.setString(3, quotation.getCustomerEmail());
            statement.setString(4, quotation.getCustomerPhone());
            statement.setString(5, quotation.getCustomerAddress());
            statement.setInt(6, quotation.getUserId());
            statement.setDate(7, quotation.getQuotationDate());
            statement.setDate(8, quotation.getValidUntil());
            statement.setString(9, quotation.getStatus());
            statement.setString(10, quotation.getNotes());
            statement.setInt(11, quotation.getWarehouseId());
            statement.setInt(12, quotation.getQuotationId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating Sales Quotation: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean delete(SalesQuotation quotation) {
        String sql = "DELETE FROM sales_quotations WHERE quotation_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, quotation.getQuotationId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error deleting Sales Quotation: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    // Custom methods
    public List<SalesQuotation> findByStatus(String status) {
        List<SalesQuotation> quotations = new ArrayList<>();
        String sql = "SELECT * FROM sales_quotations WHERE status = ? ORDER BY created_at DESC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, status);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                quotations.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Sales Quotations by status: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return quotations;
    }

    public List<SalesQuotation> findByUserId(Integer userId) {
        List<SalesQuotation> quotations = new ArrayList<>();
        String sql = "SELECT * FROM sales_quotations WHERE user_id = ? ORDER BY created_at DESC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, userId);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                quotations.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Sales Quotations by user: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return quotations;
    }

    public String generateQuotationCode() {
        String sql = "SELECT COUNT(*) + 1 as next_id FROM sales_quotations";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                int nextId = resultSet.getInt("next_id");
                return String.format("SQ%06d", nextId);
            }
        } catch (SQLException ex) {
            System.out.println("Error generating Sales Quotation code: " + ex.getMessage());
        } finally {
            closeResources();
        }
        return "SQ000001";
    }

    public SalesQuotation getQuotationById(int quotationId) {
        String sql = "SELECT * FROM sales_quotations WHERE quotation_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, quotationId);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting Sales Quotation by ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return null;
    }

    public List<SalesQuotation> findByCustomerEmail(String customerEmail) {
        List<SalesQuotation> quotations = new ArrayList<>();
        String sql = "SELECT * FROM sales_quotations WHERE customer_email = ? ORDER BY created_at DESC";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, customerEmail);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                quotations.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Sales Quotations by customer email: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return quotations;
    }

    public List<SalesQuotation> findApprovedQuotations() {
        return findByStatus("approved");
    }

    /**
     * Update status of a sales quotation
     */
    public boolean updateStatus(int quotationId, String status) {
        String sql = "UPDATE sales_quotations SET status = ? WHERE quotation_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, status);
            statement.setInt(2, quotationId);
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating Sales Quotation status: " + ex.getMessage());
            ex.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }
}
