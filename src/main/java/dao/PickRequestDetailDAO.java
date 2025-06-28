package dao;

import context.DBContext;
import model.PickRequestDetail;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PickRequestDetailDAO extends DBContext implements I_DAO<PickRequestDetail> {

    private static final Logger LOGGER = Logger.getLogger(PickRequestDetailDAO.class.getName());

    @Override
    public PickRequestDetail getFromResultSet(ResultSet rs) throws SQLException {
        return PickRequestDetail.builder()
                .pickDetailId(rs.getInt("pick_detail_id"))
                .pickRequestId(rs.getInt("pick_request_id"))
                .productId(rs.getInt("product_id"))
                .quantityRequested(rs.getInt("quantity_requested"))
                .quantityPicked(rs.getInt("quantity_picked"))
                .location(rs.getString("location"))
                // Thông tin join
                .productCode(rs.getString("product_code"))
                .productName(rs.getString("product_name"))
                .unit(rs.getString("unit"))
                .availableQuantity(rs.getInt("available_quantity"))
                .build();
    }

    @Override
    public List<PickRequestDetail> findAll() {
        List<PickRequestDetail> details = new ArrayList<>();
        String sql = "SELECT prd.*, p.product_code, p.product_name, p.unit, " +
                "COALESCE(i.quantity_on_hand, 0) as available_quantity " +
                "FROM pickrequestdetails prd " +
                "LEFT JOIN products p ON prd.product_id = p.product_id " +
                "LEFT JOIN inventory i ON prd.product_id = i.product_id " +
                "ORDER BY prd.pick_detail_id";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all pick request details", ex);
        } finally {
            close();
        }
        return details;
    }

    @Override
    public int insert(PickRequestDetail detail) {
        String sql = "INSERT INTO pickrequestdetails (pick_request_id, product_id, quantity_requested, " +
                "quantity_picked, location) VALUES (?, ?, ?, ?, ?)";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, detail.getPickRequestId());
            statement.setInt(2, detail.getProductId());
            statement.setInt(3, detail.getQuantityRequested());
            statement.setInt(4, detail.getQuantityPicked() != null ? detail.getQuantityPicked() : 0);
            statement.setString(5, detail.getLocation());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating pick request detail failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating pick request detail failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting pick request detail: " + detail.toString(), ex);
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(PickRequestDetail detail) {
        String sql = "UPDATE pickrequestdetails SET quantity_picked = ?, location = ? WHERE pick_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getQuantityPicked() != null ? detail.getQuantityPicked() : 0);
            statement.setString(2, detail.getLocation());
            statement.setInt(3, detail.getPickDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating pick request detail: " + detail.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(PickRequestDetail detail) {
        String sql = "DELETE FROM pickrequestdetails WHERE pick_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getPickDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting pick request detail: " + detail.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public PickRequestDetail findById(Integer id) {
        String sql = "SELECT prd.*, p.product_code, p.product_name, p.unit, " +
                "COALESCE(i.quantity_on_hand, 0) as available_quantity " +
                "FROM pickrequestdetails prd " +
                "LEFT JOIN products p ON prd.product_id = p.product_id " +
                "LEFT JOIN inventory i ON prd.product_id = i.product_id " +
                "WHERE prd.pick_detail_id = ?";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding pick request detail by ID: " + id, ex);
        } finally {
            close();
        }
        return null;
    }

    public List<PickRequestDetail> findByPickRequestId(Integer pickRequestId) {
        List<PickRequestDetail> details = new ArrayList<>();
        String sql = "SELECT prd.*, p.product_code, p.product_name, p.unit, " +
                "COALESCE(i.quantity_on_hand, 0) as available_quantity " +
                "FROM pickrequestdetails prd " +
                "LEFT JOIN products p ON prd.product_id = p.product_id " +
                "LEFT JOIN inventory i ON prd.product_id = i.product_id " +
                "WHERE prd.pick_request_id = ? " +
                "ORDER BY prd.pick_detail_id";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, pickRequestId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding pick request details by pick request ID: " + pickRequestId, ex);
        } finally {
            close();
        }
        return details;
    }

    public boolean insertDetails(List<PickRequestDetail> details) {
        String sql = "INSERT INTO pickrequestdetails (pick_request_id, product_id, quantity_requested, " +
                "quantity_picked, location) VALUES (?, ?, ?, ?, ?)";
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            statement = conn.prepareStatement(sql);
            
            for (PickRequestDetail detail : details) {
                statement.setInt(1, detail.getPickRequestId());
                statement.setInt(2, detail.getProductId());
                statement.setInt(3, detail.getQuantityRequested());
                statement.setInt(4, detail.getQuantityPicked() != null ? detail.getQuantityPicked() : 0);
                statement.setString(5, detail.getLocation());
                statement.addBatch();
            }
            
            statement.executeBatch();
            conn.commit();
            return true;
        } catch (SQLException ex) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", rollbackEx);
            }
            LOGGER.log(Level.SEVERE, "Error inserting pick request details batch", ex);
            return false;
        } finally {
            close();
        }
    }

    public boolean deleteByPickRequestId(Integer pickRequestId) {
        String sql = "DELETE FROM pickrequestdetails WHERE pick_request_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, pickRequestId);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting pick request details by pick request ID: " + pickRequestId, ex);
            return false;
        } finally {
            close();
        }
    }
} 