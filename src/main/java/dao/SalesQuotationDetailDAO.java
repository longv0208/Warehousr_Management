package dao;

import context.DBContext;
import model.SalesQuotationDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SalesQuotationDetailDAO extends DBContext implements I_DAO<SalesQuotationDetail> {

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
    public SalesQuotationDetail getFromResultSet(ResultSet rs) throws SQLException {
        SalesQuotationDetail detail = SalesQuotationDetail.builder()
                .quotationDetailId(rs.getInt("quotation_detail_id"))
                .quotationId(rs.getInt("quotation_id"))
                .productId(rs.getInt("product_id"))
                .quantity(rs.getInt("quantity"))
                .unitPrice(rs.getBigDecimal("unit_price"))
                .build();
        return detail;
    }

    @Override
    public List<SalesQuotationDetail> findAll() {
        List<SalesQuotationDetail> details = new ArrayList<>();
        String sql = "SELECT * FROM sales_quotation_details";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding all Sales Quotation details: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return details;
    }

    @Override
    public SalesQuotationDetail findById(Integer id) {
        String sql = "SELECT * FROM sales_quotation_details WHERE quotation_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Sales Quotation detail by ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return null;
    }

    @Override
    public int insert(SalesQuotationDetail detail) {
        String sql = "INSERT INTO sales_quotation_details (quotation_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, detail.getQuotationId());
            statement.setInt(2, detail.getProductId());
            statement.setInt(3, detail.getQuantity());
            statement.setBigDecimal(4, detail.getUnitPrice());
            
            int affectedRows = statement.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating Sales Quotation detail failed, no rows affected.");
            }
            
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating Sales Quotation detail failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting Sales Quotation detail: " + ex.getMessage());
            return -1;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean update(SalesQuotationDetail detail) {
        String sql = "UPDATE sales_quotation_details SET quotation_id = ?, product_id = ?, quantity = ?, unit_price = ? WHERE quotation_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getQuotationId());
            statement.setInt(2, detail.getProductId());
            statement.setInt(3, detail.getQuantity());
            statement.setBigDecimal(4, detail.getUnitPrice());
            statement.setInt(5, detail.getQuotationDetailId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error updating Sales Quotation detail: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public boolean delete(SalesQuotationDetail detail) {
        String sql = "DELETE FROM sales_quotation_details WHERE quotation_detail_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getQuotationDetailId());
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            System.out.println("Error deleting Sales Quotation detail: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    // Custom methods
    public List<SalesQuotationDetail> findByQuotationId(Integer quotationId) {
        List<SalesQuotationDetail> details = new ArrayList<>();
        String sql = "SELECT * FROM sales_quotation_details WHERE quotation_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, quotationId);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error finding Sales Quotation details by quotation ID: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return details;
    }

    public boolean deleteByQuotationId(Integer quotationId) {
        String sql = "DELETE FROM sales_quotation_details WHERE quotation_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, quotationId);
            
            int rowsAffected = statement.executeUpdate();
            return rowsAffected >= 0; // Có thể không có detail nào để xóa
        } catch (SQLException ex) {
            System.out.println("Error deleting Sales Quotation details by quotation ID: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    public boolean insertDetails(List<SalesQuotationDetail> details) {
        String sql = "INSERT INTO sales_quotation_details (quotation_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            statement = conn.prepareStatement(sql);
            
            for (SalesQuotationDetail detail : details) {
                statement.setInt(1, detail.getQuotationId());
                statement.setInt(2, detail.getProductId());
                statement.setInt(3, detail.getQuantity());
                statement.setBigDecimal(4, detail.getUnitPrice());
                statement.addBatch();
            }
            
            statement.executeBatch();
            conn.commit();
            return true;
        } catch (SQLException ex) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException rollbackEx) {
                System.out.println("Error rolling back transaction: " + rollbackEx.getMessage());
            }
            System.out.println("Error inserting Sales Quotation details batch: " + ex.getMessage());
            return false;
        } finally {
            closeResources();
        }
    }

    /**
     * Get quotation details with product information joined
     */
    public List<SalesQuotationDetail> getQuotationDetailsWithProduct(int quotationId) {
        List<SalesQuotationDetail> details = new ArrayList<>();
        String sql = "SELECT sqd.*, p.product_name, p.description " +
                    "FROM sales_quotation_details sqd " +
                    "JOIN products p ON sqd.product_id = p.product_id " +
                    "WHERE sqd.quotation_id = ?";
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, quotationId);
            resultSet = statement.executeQuery();
            
            while (resultSet.next()) {
                SalesQuotationDetail detail = getFromResultSet(resultSet);
                // Có thể thêm các thuộc tính khác từ product nếu cần
                details.add(detail);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting Sales Quotation details with product: " + ex.getMessage());
        } finally {
            closeResources();
        }
        
        return details;
    }
}
