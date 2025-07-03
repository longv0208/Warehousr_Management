package dao;

import context.DBContext;
import model.StockInward;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StockInwardDAO extends DBContext implements I_DAO<StockInward> {

    private static final Logger LOGGER = Logger.getLogger(StockInwardDAO.class.getName());

    @Override
    public StockInward getFromResultSet(ResultSet rs) throws SQLException {
        return StockInward.builder()
                .stockInwardId(rs.getInt("stock_inward_id"))
                .inwardCode(rs.getString("inward_code"))
                .supplierId(rs.getInt("supplier_id"))
                .userId(rs.getInt("user_id"))
                .warehouseId(rs.getInt("warehouse_id"))
                .inwardDate(rs.getTimestamp("inward_date") != null ? rs.getTimestamp("inward_date").toLocalDateTime() : null)
                .notes(rs.getString("notes"))
                .createdAt(rs.getTimestamp("created_at"))
                .poId(rs.getObject("po_id") != null ? rs.getInt("po_id") : null)
                // Thông tin join
                .supplierName(rs.getString("supplier_name"))
                .userFullName(rs.getString("user_full_name"))
                .warehouseName(rs.getString("warehouse_name"))
                .build();
    }

    @Override
    public List<StockInward> findAll() {
        List<StockInward> stockInwards = new ArrayList<>();
        String sql = "SELECT si.*, " +
                "s.supplier_name, " +
                "u.full_name as user_full_name, " +
                "w.warehouse_name " +
                "FROM stockinwards si " +
                "LEFT JOIN suppliers s ON si.supplier_id = s.supplier_id " +
                "LEFT JOIN users u ON si.user_id = u.user_id " +
                "LEFT JOIN warehouses w ON si.warehouse_id = w.warehouse_id " +
                "ORDER BY si.created_at DESC";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                stockInwards.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all stock inwards", ex);
        } finally {
            close();
        }
        return stockInwards;
    }

    @Override
    public int insert(StockInward stockInward) {
        String sql = "INSERT INTO stockinwards (inward_code, supplier_id, user_id, warehouse_id, " +
                "inward_date, notes, po_id) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, stockInward.getInwardCode());
            statement.setObject(2, stockInward.getSupplierId());
            statement.setInt(3, stockInward.getUserId());
            statement.setObject(4, stockInward.getWarehouseId());
            statement.setTimestamp(5, stockInward.getInwardDate() != null ? 
                java.sql.Timestamp.valueOf(stockInward.getInwardDate()) : null);
            statement.setString(6, stockInward.getNotes());
            statement.setObject(7, stockInward.getPoId());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating stock inward failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating stock inward failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting stock inward: " + stockInward.toString(), ex);
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(StockInward stockInward) {
        String sql = "UPDATE stockinwards SET notes = ? WHERE stock_inward_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, stockInward.getNotes());
            statement.setInt(2, stockInward.getStockInwardId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating stock inward: " + stockInward.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(StockInward stockInward) {
        String sql = "DELETE FROM stockinwards WHERE stock_inward_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockInward.getStockInwardId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting stock inward: " + stockInward.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public StockInward findById(Integer id) {
        String sql = "SELECT si.*, " +
                "s.supplier_name, " +
                "u.full_name as user_full_name, " +
                "w.warehouse_name " +
                "FROM stockinwards si " +
                "LEFT JOIN suppliers s ON si.supplier_id = s.supplier_id " +
                "LEFT JOIN users u ON si.user_id = u.user_id " +
                "LEFT JOIN warehouses w ON si.warehouse_id = w.warehouse_id " +
                "WHERE si.stock_inward_id = ?";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding stock inward by ID: " + id, ex);
        } finally {
            close();
        }
        return null;
    }

    public String generateInwardCode() {
        String prefix = "SI";
        String sql = "SELECT COUNT(*) + 1 as next_num FROM stockinwards";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                int nextNum = resultSet.getInt("next_num");
                return String.format("%s%06d", prefix, nextNum);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error generating inward code", ex);
        } finally {
            close();
        }
        return prefix + "000001";
    }

    public StockInward findByPoId(Integer poId) {
        String sql = "SELECT si.*, " +
                "s.supplier_name, " +
                "u.full_name as user_full_name, " +
                "w.warehouse_name " +
                "FROM stockinwards si " +
                "LEFT JOIN suppliers s ON si.supplier_id = s.supplier_id " +
                "LEFT JOIN users u ON si.user_id = u.user_id " +
                "LEFT JOIN warehouses w ON si.warehouse_id = w.warehouse_id " +
                "WHERE si.po_id = ?";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, poId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding stock inward by PO ID: " + poId, ex);
        } finally {
            close();
        }
        return null;
    }

    public List<StockInward> findByCreatedBy(int createdById) {
        List<StockInward> stockInwards = new ArrayList<>();
        String sql = "SELECT si.*, " +
                "s.supplier_name, " +
                "u.full_name as user_full_name, " +
                "w.warehouse_name " +
                "FROM stockinwards si " +
                "LEFT JOIN suppliers s ON si.supplier_id = s.supplier_id " +
                "LEFT JOIN users u ON si.user_id = u.user_id " +
                "LEFT JOIN warehouses w ON si.warehouse_id = w.warehouse_id " +
                "WHERE si.user_id = ? " +
                "ORDER BY si.created_at DESC";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, createdById);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                stockInwards.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting stock inwards by created by", ex);
        } finally {
            close();
        }
        return stockInwards;
    }
} 