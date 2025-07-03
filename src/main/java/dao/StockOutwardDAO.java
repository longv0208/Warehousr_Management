package dao;

import context.DBContext;
import model.StockOutward;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StockOutwardDAO extends DBContext implements I_DAO<StockOutward> {

    private static final Logger LOGGER = Logger.getLogger(StockOutwardDAO.class.getName());

    @Override
    public StockOutward getFromResultSet(ResultSet rs) throws SQLException {
        return StockOutward.builder()
                .stockOutwardId(rs.getInt("stock_outward_id"))
                .outwardCode(rs.getString("outward_code"))
                .salesOrderId(rs.getObject("sales_order_id") != null ? rs.getInt("sales_order_id") : null)
                .userId(rs.getInt("user_id"))
                .warehouseId(rs.getInt("warehouse_id"))
                .outwardDate(rs.getTimestamp("outward_date"))
                .reason(rs.getString("reason"))
                .notes(rs.getString("notes"))
                .createdAt(rs.getTimestamp("created_at"))
                // Thông tin join
                .userFullName(rs.getString("user_full_name"))
                .warehouseName(rs.getString("warehouse_name"))
                .salesOrderCode(rs.getString("sales_order_code"))
                .customerName(rs.getString("customer_name"))
                .build();
    }

    @Override
    public List<StockOutward> findAll() {
        List<StockOutward> stockOutwards = new ArrayList<>();
        String sql = "SELECT so.*, " +
                "u.full_name as user_full_name, " +
                "w.warehouse_name, " +
                "sao.order_code as sales_order_code, " +
                "sao.customer_name " +
                "FROM stockoutwards so " +
                "LEFT JOIN users u ON so.user_id = u.user_id " +
                "LEFT JOIN warehouses w ON so.warehouse_id = w.warehouse_id " +
                "LEFT JOIN salesorders sao ON so.sales_order_id = sao.sales_order_id " +
                "ORDER BY so.created_at DESC";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                stockOutwards.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all stock outwards", ex);
        } finally {
            close();
        }
        return stockOutwards;
    }

    @Override
    public int insert(StockOutward stockOutward) {
        String sql = "INSERT INTO stockoutwards (outward_code, sales_order_id, user_id, warehouse_id, " +
                "outward_date, reason, notes) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, stockOutward.getOutwardCode());
            statement.setObject(2, stockOutward.getSalesOrderId());
            statement.setInt(3, stockOutward.getUserId());
            statement.setObject(4, stockOutward.getWarehouseId());
            statement.setTimestamp(5, stockOutward.getOutwardDate());
            statement.setString(6, stockOutward.getReason());
            statement.setString(7, stockOutward.getNotes());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating stock outward failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating stock outward failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting stock outward: " + stockOutward.toString(), ex);
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(StockOutward stockOutward) {
        String sql = "UPDATE stockoutwards SET notes = ? WHERE stock_outward_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, stockOutward.getNotes());
            statement.setInt(2, stockOutward.getStockOutwardId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating stock outward: " + stockOutward.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(StockOutward stockOutward) {
        String sql = "DELETE FROM stockoutwards WHERE stock_outward_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockOutward.getStockOutwardId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting stock outward: " + stockOutward.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public StockOutward findById(Integer id) {
        String sql = "SELECT so.*, " +
                "u.full_name as user_full_name, " +
                "w.warehouse_name, " +
                "sao.order_code as sales_order_code, " +
                "sao.customer_name " +
                "FROM stockoutwards so " +
                "LEFT JOIN users u ON so.user_id = u.user_id " +
                "LEFT JOIN warehouses w ON so.warehouse_id = w.warehouse_id " +
                "LEFT JOIN salesorders sao ON so.sales_order_id = sao.sales_order_id " +
                "WHERE so.stock_outward_id = ?";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding stock outward by ID: " + id, ex);
        } finally {
            close();
        }
        return null;
    }

    public String generateOutwardCode() {
        String prefix = "SOW";
        String sql = "SELECT COUNT(*) + 1 as next_num FROM stockoutwards";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                int nextNum = resultSet.getInt("next_num");
                return prefix + String.format("%06d", nextNum);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error generating outward code", ex);
        } finally {
            close();
        }
        return prefix + "000001";
    }

    public List<StockOutward> findWithFilters(Integer userId, Integer warehouseId, int page, int pageSize) {
        List<StockOutward> stockOutwards = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT so.*, u.full_name as user_full_name, w.warehouse_name, sao.order_code as sales_order_code, sao.customer_name " +
                "FROM stockoutwards so " +
                "LEFT JOIN users u ON so.user_id = u.user_id " +
                "LEFT JOIN warehouses w ON so.warehouse_id = w.warehouse_id " +
                "LEFT JOIN salesorders sao ON so.sales_order_id = sao.sales_order_id " +
                "WHERE 1=1 ");

        if (userId != null) {
            sql.append("AND so.user_id = ? ");
        }
        if (warehouseId != null) {
            sql.append("AND so.warehouse_id = ? ");
        }

        sql.append("ORDER BY so.created_at DESC LIMIT ? OFFSET ?");

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            if (userId != null) {
                statement.setInt(paramIndex++, userId);
            }
            if (warehouseId != null) {
                statement.setInt(paramIndex++, warehouseId);
            }
            statement.setInt(paramIndex++, pageSize);
            statement.setInt(paramIndex++, (page - 1) * pageSize);

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                stockOutwards.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding stock outwards with filters", ex);
        } finally {
            close();
        }
        return stockOutwards;
    }

    public int countWithFilters(Integer userId, Integer warehouseId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM stockoutwards so WHERE 1=1 ");
        if (userId != null) {
            sql.append("AND so.user_id = ? ");
        }
        if (warehouseId != null) {
            sql.append("AND so.warehouse_id = ? ");
        }

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            if (userId != null) {
                statement.setInt(paramIndex++, userId);
            }
            if (warehouseId != null) {
                statement.setInt(paramIndex++, warehouseId);
            }

            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting stock outwards with filters", ex);
        } finally {
            close();
        }
        return 0;
    }
} 