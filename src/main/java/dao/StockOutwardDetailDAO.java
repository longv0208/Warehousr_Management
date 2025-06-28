package dao;

import context.DBContext;
import model.StockOutwardDetail;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StockOutwardDetailDAO extends DBContext implements I_DAO<StockOutwardDetail> {

    private static final Logger LOGGER = Logger.getLogger(StockOutwardDetailDAO.class.getName());

    @Override
    public StockOutwardDetail getFromResultSet(ResultSet rs) throws SQLException {
        return StockOutwardDetail.builder()
                .outwardDetailId(rs.getInt("outward_detail_id"))
                .stockOutwardId(rs.getInt("stock_outward_id"))
                .productId(rs.getInt("product_id"))
                .quantityShipped(rs.getInt("quantity_shipped"))
                // Thông tin join
                .productCode(rs.getString("product_code"))
                .productName(rs.getString("product_name"))
                .unit(rs.getString("unit"))
                .build();
    }

    @Override
    public List<StockOutwardDetail> findAll() {
        List<StockOutwardDetail> details = new ArrayList<>();
        String sql = "SELECT sod.*, p.product_code, p.product_name, p.unit " +
                "FROM stockoutwarddetails sod " +
                "LEFT JOIN products p ON sod.product_id = p.product_id " +
                "ORDER BY sod.outward_detail_id";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all stock outward details", ex);
        } finally {
            close();
        }
        return details;
    }

    @Override
    public int insert(StockOutwardDetail detail) {
        String sql = "INSERT INTO stockoutwarddetails (stock_outward_id, product_id, quantity_shipped) " +
                "VALUES (?, ?, ?)";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, detail.getStockOutwardId());
            statement.setInt(2, detail.getProductId());
            statement.setInt(3, detail.getQuantityShipped());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating stock outward detail failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating stock outward detail failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting stock outward detail: " + detail.toString(), ex);
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(StockOutwardDetail detail) {
        String sql = "UPDATE stockoutwarddetails SET quantity_shipped = ? WHERE outward_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getQuantityShipped());
            statement.setInt(2, detail.getOutwardDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating stock outward detail: " + detail.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(StockOutwardDetail detail) {
        String sql = "DELETE FROM stockoutwarddetails WHERE outward_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getOutwardDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting stock outward detail: " + detail.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public StockOutwardDetail findById(Integer id) {
        String sql = "SELECT sod.*, p.product_code, p.product_name, p.unit " +
                "FROM stockoutwarddetails sod " +
                "LEFT JOIN products p ON sod.product_id = p.product_id " +
                "WHERE sod.outward_detail_id = ?";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding stock outward detail by ID: " + id, ex);
        } finally {
            close();
        }
        return null;
    }

    public List<StockOutwardDetail> findByStockOutwardId(Integer stockOutwardId) {
        List<StockOutwardDetail> details = new ArrayList<>();
        String sql = "SELECT sod.*, p.product_code, p.product_name, p.unit " +
                "FROM stockoutwarddetails sod " +
                "LEFT JOIN products p ON sod.product_id = p.product_id " +
                "WHERE sod.stock_outward_id = ? " +
                "ORDER BY sod.outward_detail_id";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockOutwardId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding stock outward details by stock outward ID: " + stockOutwardId, ex);
        } finally {
            close();
        }
        return details;
    }

    public boolean insertDetails(List<StockOutwardDetail> details) {
        String sql = "INSERT INTO stockoutwarddetails (stock_outward_id, product_id, quantity_shipped) " +
                "VALUES (?, ?, ?)";
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            statement = conn.prepareStatement(sql);
            
            for (StockOutwardDetail detail : details) {
                statement.setInt(1, detail.getStockOutwardId());
                statement.setInt(2, detail.getProductId());
                statement.setInt(3, detail.getQuantityShipped());
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
            LOGGER.log(Level.SEVERE, "Error inserting stock outward details batch", ex);
            return false;
        } finally {
            close();
        }
    }
} 