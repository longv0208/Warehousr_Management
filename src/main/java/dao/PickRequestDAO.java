package dao;

import context.DBContext;
import model.PickRequest;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PickRequestDAO extends DBContext implements I_DAO<PickRequest> {

    private static final Logger LOGGER = Logger.getLogger(PickRequestDAO.class.getName());

    @Override
    public PickRequest getFromResultSet(ResultSet rs) throws SQLException {
        return PickRequest.builder()
                .pickRequestId(rs.getInt("pick_request_id"))
                .pickRequestCode(rs.getString("pick_request_code"))
                .salesOrderId(rs.getInt("sales_order_id"))
                .userIdRequester(rs.getInt("user_id_requester"))
                .warehouseId(rs.getInt("warehouse_id"))
                .requestDate(rs.getTimestamp("request_date"))
                .status(rs.getString("status"))
                .notes(rs.getString("notes"))
                .createdAt(rs.getTimestamp("created_at"))
                // Thông tin join
                .requestedByName(rs.getString("requested_by_name"))
                .warehouseName(rs.getString("warehouse_name"))
                .salesOrderCode(rs.getString("sales_order_code"))
                .customerName(rs.getString("customer_name"))
                .build();
    }

    @Override
    public List<PickRequest> findAll() {
        List<PickRequest> pickRequests = new ArrayList<>();
        String sql = "SELECT pr.*, " +
                "u.full_name as requested_by_name, " +
                "w.warehouse_name, " +
                "so.order_code as sales_order_code, " +
                "so.customer_name " +
                "FROM pickrequests pr " +
                "LEFT JOIN users u ON pr.user_id_requester = u.user_id " +
                "LEFT JOIN warehouses w ON pr.warehouse_id = w.warehouse_id " +
                "LEFT JOIN salesorders so ON pr.sales_order_id = so.sales_order_id " +
                "ORDER BY pr.created_at DESC";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                pickRequests.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all pick requests", ex);
        } finally {
            close();
        }
        return pickRequests;
    }

    @Override
    public int insert(PickRequest pickRequest) {
        String sql = "INSERT INTO pickrequests (pick_request_code, sales_order_id, user_id_requester, " +
                "warehouse_id, request_date, status, notes) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, pickRequest.getPickRequestCode());
            statement.setInt(2, pickRequest.getSalesOrderId());
            statement.setInt(3, pickRequest.getUserIdRequester());
            statement.setInt(4, pickRequest.getWarehouseId());
            statement.setTimestamp(5, pickRequest.getRequestDate());
            statement.setString(6, pickRequest.getStatus());
            statement.setString(7, pickRequest.getNotes());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating pick request failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating pick request failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting pick request: " + pickRequest.toString(), ex);
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(PickRequest pickRequest) {
        String sql = "UPDATE pickrequests SET status = ?, notes = ? WHERE pick_request_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, pickRequest.getStatus());
            statement.setString(2, pickRequest.getNotes());
            statement.setInt(3, pickRequest.getPickRequestId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating pick request: " + pickRequest.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(PickRequest pickRequest) {
        String sql = "DELETE FROM pickrequests WHERE pick_request_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, pickRequest.getPickRequestId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting pick request: " + pickRequest.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public PickRequest findById(Integer id) {
        String sql = "SELECT pr.*, " +
                "u.full_name as requested_by_name, " +
                "w.warehouse_name, " +
                "so.order_code as sales_order_code, " +
                "so.customer_name " +
                "FROM pickrequests pr " +
                "LEFT JOIN users u ON pr.user_id_requester = u.user_id " +
                "LEFT JOIN warehouses w ON pr.warehouse_id = w.warehouse_id " +
                "LEFT JOIN salesorders so ON pr.sales_order_id = so.sales_order_id " +
                "WHERE pr.pick_request_id = ?";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding pick request by ID: " + id, ex);
        } finally {
            close();
        }
        return null;
    }

    public List<PickRequest> findByStatus(String status) {
        List<PickRequest> pickRequests = new ArrayList<>();
        String sql = "SELECT pr.*, " +
                "u.full_name as requested_by_name, " +
                "w.warehouse_name, " +
                "so.order_code as sales_order_code, " +
                "so.customer_name " +
                "FROM pickrequests pr " +
                "LEFT JOIN users u ON pr.user_id_requester = u.user_id " +
                "LEFT JOIN warehouses w ON pr.warehouse_id = w.warehouse_id " +
                "LEFT JOIN salesorders so ON pr.sales_order_id = so.sales_order_id " +
                "WHERE pr.status = ? " +
                "ORDER BY pr.created_at DESC";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, status);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                pickRequests.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding pick requests by status: " + status, ex);
        } finally {
            close();
        }
        return pickRequests;
    }

    public List<PickRequest> findBySalesOrderId(Integer salesOrderId) {
        List<PickRequest> pickRequests = new ArrayList<>();
        String sql = "SELECT pr.*, " +
                "u.full_name as requested_by_name, " +
                "w.warehouse_name, " +
                "so.order_code as sales_order_code, " +
                "so.customer_name " +
                "FROM pickrequests pr " +
                "LEFT JOIN users u ON pr.user_id_requester = u.user_id " +
                "LEFT JOIN warehouses w ON pr.warehouse_id = w.warehouse_id " +
                "LEFT JOIN salesorders so ON pr.sales_order_id = so.sales_order_id " +
                "WHERE pr.sales_order_id = ? " +
                "ORDER BY pr.created_at DESC";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, salesOrderId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                pickRequests.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding pick requests by sales order ID: " + salesOrderId, ex);
        } finally {
            close();
        }
        return pickRequests;
    }

    public String generatePickRequestCode() {
        String prefix = "WH/PICK/";
        String sql = "SELECT COUNT(*) + 1 as next_num FROM pickrequests";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                int nextNum = resultSet.getInt("next_num");
                return prefix + String.format("%05d", nextNum);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error generating pick request code", ex);
        } finally {
            close();
        }
        return prefix + "00001";
    }
} 