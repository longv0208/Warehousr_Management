package dao;

import context.DBContext;
import model.StockInwardDetail;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StockInwardDetailDAO extends DBContext implements I_DAO<StockInwardDetail> {

    private static final Logger LOGGER = Logger.getLogger(StockInwardDetailDAO.class.getName());

    @Override
    public StockInwardDetail getFromResultSet(ResultSet rs) throws SQLException {
        return StockInwardDetail.builder()
                .inwardDetailId(rs.getInt("inward_detail_id"))
                .stockInwardId(rs.getInt("stock_inward_id"))
                .productId(rs.getInt("product_id"))
                .quantityReceived(rs.getInt("quantity_received"))
                .unitPurchasePrice(rs.getBigDecimal("unit_purchase_price"))
                .actualPrice(rs.getBigDecimal("actual_price"))
                // Thông tin join
                .productCode(rs.getString("product_code"))
                .productName(rs.getString("product_name"))
                .unit(rs.getString("unit"))
                .build();
    }

    @Override
    public List<StockInwardDetail> findAll() {
        List<StockInwardDetail> details = new ArrayList<>();
        String sql = "SELECT sid.*, p.product_code, p.product_name, p.unit " +
                "FROM stockinwarddetails sid " +
                "LEFT JOIN products p ON sid.product_id = p.product_id " +
                "ORDER BY sid.inward_detail_id";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all stock inward details", ex);
        } finally {
            close();
        }
        return details;
    }

    @Override
    public int insert(StockInwardDetail detail) {
        String sql = "INSERT INTO stockinwarddetails (stock_inward_id, product_id, quantity_received, " +
                "unit_purchase_price, actual_price) VALUES (?, ?, ?, ?, ?)";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, detail.getStockInwardId());
            statement.setInt(2, detail.getProductId());
            statement.setInt(3, detail.getQuantityReceived());
            statement.setBigDecimal(4, detail.getUnitPurchasePrice());
            statement.setBigDecimal(5, detail.getActualPrice());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating stock inward detail failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating stock inward detail failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting stock inward detail: " + detail.toString(), ex);
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(StockInwardDetail detail) {
        String sql = "UPDATE stockinwarddetails SET quantity_received = ?, unit_purchase_price = ?, actual_price = ? " +
                "WHERE inward_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getQuantityReceived());
            statement.setBigDecimal(2, detail.getUnitPurchasePrice());
            statement.setBigDecimal(3, detail.getActualPrice());
            statement.setInt(4, detail.getInwardDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating stock inward detail: " + detail.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(StockInwardDetail detail) {
        String sql = "DELETE FROM stockinwarddetails WHERE inward_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getInwardDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting stock inward detail: " + detail.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    @Override
    public StockInwardDetail findById(Integer id) {
        String sql = "SELECT sid.*, p.product_code, p.product_name, p.unit " +
                "FROM stockinwarddetails sid " +
                "LEFT JOIN products p ON sid.product_id = p.product_id " +
                "WHERE sid.inward_detail_id = ?";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding stock inward detail by ID: " + id, ex);
        } finally {
            close();
        }
        return null;
    }

    public List<StockInwardDetail> findByStockInwardId(Integer stockInwardId) {
        List<StockInwardDetail> details = new ArrayList<>();
        String sql = "SELECT sid.*, p.product_code, p.product_name, p.unit " +
                "FROM stockinwarddetails sid " +
                "LEFT JOIN products p ON sid.product_id = p.product_id " +
                "WHERE sid.stock_inward_id = ? " +
                "ORDER BY sid.inward_detail_id";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockInwardId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                details.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding stock inward details by stock inward ID: " + stockInwardId, ex);
        } finally {
            close();
        }
        return details;
    }

    public boolean insertDetails(List<StockInwardDetail> details) {
        String sql = "INSERT INTO stockinwarddetails (stock_inward_id, product_id, quantity_received, " +
                "unit_purchase_price, actual_price) VALUES (?, ?, ?, ?, ?)";
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            statement = conn.prepareStatement(sql);

            for (StockInwardDetail detail : details) {
                statement.setInt(1, detail.getStockInwardId());
                statement.setInt(2, detail.getProductId());
                statement.setInt(3, detail.getQuantityReceived());
                statement.setBigDecimal(4, detail.getUnitPurchasePrice());
                statement.setBigDecimal(5, detail.getActualPrice());
                statement.addBatch();
            }

            statement.executeBatch();
            conn.commit();
            return true;
        } catch (SQLException ex) {
            try {
                if (conn != null)
                    conn.rollback();
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", rollbackEx);
            }
            LOGGER.log(Level.SEVERE, "Error inserting stock inward details batch", ex);
            return false;
        } finally {
            close();
        }
    }
}