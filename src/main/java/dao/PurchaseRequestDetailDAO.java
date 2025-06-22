package dao;

import context.DBContext;
import model.PurchaseRequestDetail;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PurchaseRequestDetailDAO extends DBContext implements I_DAO<PurchaseRequestDetail> {

    private static final Logger LOGGER = Logger.getLogger(PurchaseRequestDetailDAO.class.getName());

    @Override
    public PurchaseRequestDetail getFromResultSet(ResultSet rs) throws SQLException {
        return PurchaseRequestDetail.builder()
                .requestDetailId(rs.getInt("request_detail_id"))
                .requestId(rs.getInt("request_id"))
                .productId(rs.getInt("product_id"))
                .requestedQuantity(rs.getInt("requested_quantity"))
                .suggestedSupplierId(rs.getObject("supplier_id_suggested") != null ? rs.getInt("supplier_id_suggested") : null)
                .notes("") // Database không có cột notes, set empty string
                // Thông tin join
                .productName(rs.getString("product_name"))
                .productCode(rs.getString("product_code"))
                .unit(rs.getString("unit"))
                .purchasePrice(rs.getFloat("purchase_price"))
                .supplierName(rs.getString("supplier_name"))
                .build();
    }

    @Override
    public List<PurchaseRequestDetail> findAll() {
        List<PurchaseRequestDetail> details = new ArrayList<>();
        String sql = "SELECT prd.*, p.product_name, p.product_code, p.unit, p.purchase_price, s.supplier_name " +
                    "FROM purchaserequestdetails prd " +
                    "LEFT JOIN products p ON prd.product_id = p.product_id " +
                    "LEFT JOIN suppliers s ON prd.supplier_id_suggested = s.supplier_id";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all purchase request details", ex);
        } finally {
            close();
        }
        return details;
    }

    @Override
    public int insert(PurchaseRequestDetail detail) {
        String sql = "INSERT INTO purchaserequestdetails (request_id, product_id, requested_quantity, supplier_id_suggested) " +
                    "VALUES (?, ?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, detail.getRequestId());
            statement.setInt(2, detail.getProductId());
            statement.setInt(3, detail.getRequestedQuantity());
            if (detail.getSuggestedSupplierId() != null) {
                statement.setInt(4, detail.getSuggestedSupplierId());
            } else {
                statement.setNull(4, Types.INTEGER);
            }

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating purchase request detail failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating purchase request detail failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting purchase request detail: " + detail.toString(), ex);
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(PurchaseRequestDetail detail) {
        String sql = "UPDATE purchaserequestdetails SET requested_quantity = ?, supplier_id_suggested = ? " +
                    "WHERE request_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getRequestedQuantity());
            if (detail.getSuggestedSupplierId() != null) {
                statement.setInt(2, detail.getSuggestedSupplierId());
            } else {
                statement.setNull(2, Types.INTEGER);
            }
            statement.setInt(3, detail.getRequestDetailId());

            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating purchase request detail: " + detail.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(PurchaseRequestDetail detail) {
        String sql = "DELETE FROM purchaserequestdetails WHERE request_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getRequestDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting purchase request detail: " + detail.getRequestDetailId(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public PurchaseRequestDetail findById(Integer id) {
        String sql = "SELECT prd.*, p.product_name, p.product_code, p.unit, p.purchase_price, s.supplier_name " +
                    "FROM purchaserequestdetails prd " +
                    "LEFT JOIN products p ON prd.product_id = p.product_id " +
                    "LEFT JOIN suppliers s ON prd.supplier_id_suggested = s.supplier_id " +
                    "WHERE prd.request_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding purchase request detail by ID: " + id, ex);
        } finally {
            close();
        }
        return null;
    }

    // Tìm chi tiết theo request ID
    public List<PurchaseRequestDetail> findByRequestId(Integer requestId) {
        List<PurchaseRequestDetail> details = new ArrayList<>();
        String sql = "SELECT prd.*, p.product_name, p.product_code, p.unit, p.purchase_price, s.supplier_name " +
                    "FROM purchaserequestdetails prd " +
                    "LEFT JOIN products p ON prd.product_id = p.product_id " +
                    "LEFT JOIN suppliers s ON prd.supplier_id_suggested = s.supplier_id " +
                    "WHERE prd.request_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, requestId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding purchase request details by request ID: " + requestId, ex);
        } finally {
            close();
        }
        return details;
    }

    // Xóa tất cả chi tiết theo request ID
    public boolean deleteByRequestId(Integer requestId) {
        String sql = "DELETE FROM purchaserequestdetails WHERE request_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, requestId);
            return statement.executeUpdate() >= 0; // Có thể xóa 0 records và vẫn thành công
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting purchase request details by request ID: " + requestId, ex);
            return false;
        } finally {
            close();
        }
    }
} 