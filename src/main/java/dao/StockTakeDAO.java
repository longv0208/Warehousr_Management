package dao;

import context.DBContext;
import model.StockTake;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StockTakeDAO extends DBContext implements I_DAO<StockTake> {

    @Override
    public List<StockTake> findAll() {
        List<StockTake> list = new ArrayList<>();
        String sql = "SELECT st.*, u.full_name as user_full_name, "
                + "(SELECT COUNT(*) FROM stocktakedetails std WHERE std.stock_take_id = st.stock_take_id) as total_products, "
                + "(SELECT COUNT(*) FROM stocktakedetails std WHERE std.stock_take_id = st.stock_take_id AND std.counted_quantity IS NOT NULL) as completed_products "
                + "FROM stocktakes st "
                + "LEFT JOIN users u ON st.user_id = u.user_id "
                + "ORDER BY st.created_at DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return list;
    }

    @Override
    public boolean update(StockTake stockTake) {
        String sql = "UPDATE stocktakes SET stock_take_code = ?, user_id = ?, stock_take_date = ?, status = ?, notes = ? WHERE stock_take_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, stockTake.getStockTakeCode());
            statement.setInt(2, stockTake.getUserId());
            statement.setDate(3, stockTake.getStockTakeDate());
            statement.setString(4, stockTake.getStatus());
            statement.setString(5, stockTake.getNotes());
            statement.setInt(6, stockTake.getStockTakeId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(StockTake stockTake) {
        String sql = "DELETE FROM stocktakes WHERE stock_take_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockTake.getStockTakeId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public int insert(StockTake stockTake) {
        String sql = "INSERT INTO stocktakes (stock_take_code, user_id, stock_take_date, status, notes) VALUES (?, ?, ?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, stockTake.getStockTakeCode());
            statement.setInt(2, stockTake.getUserId());
            statement.setDate(3, stockTake.getStockTakeDate());
            statement.setString(4, stockTake.getStatus());
            statement.setString(5, stockTake.getNotes());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating stock take failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating stock take failed, no ID obtained.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public StockTake getFromResultSet(ResultSet rs) throws SQLException {
        if (rs == null) {
            return null;
        }

        StockTake stockTake = new StockTake();

        // Đọc an toàn với check metadata
        ResultSetMetaData meta = rs.getMetaData();
        List<String> columns = new ArrayList<>();
        for (int i = 1; i <= meta.getColumnCount(); i++) {
            columns.add(meta.getColumnLabel(i));
        }

        if (columns.contains("stock_take_id")) {
            stockTake.setStockTakeId(rs.getInt("stock_take_id"));
        }
        if (columns.contains("stock_take_code")) {
            stockTake.setStockTakeCode(rs.getString("stock_take_code"));
        }
        if (columns.contains("user_id")) {
            stockTake.setUserId(rs.getInt("user_id"));
        }
        if (columns.contains("stock_take_date")) {
            stockTake.setStockTakeDate(rs.getDate("stock_take_date"));
        }
        if (columns.contains("status")) {
            stockTake.setStatus(rs.getString("status"));
        }
        if (columns.contains("notes")) {
            stockTake.setNotes(rs.getString("notes"));
        }
        if (columns.contains("created_at")) {
            stockTake.setCreatedAt(rs.getTimestamp("created_at"));
        }

        if (columns.contains("user_full_name")) {
            stockTake.setUserFullName(rs.getString("user_full_name"));
        }
        if (columns.contains("total_products")) {
            stockTake.setTotalProducts(rs.getInt("total_products"));
        }
        if (columns.contains("completed_products")) {
            stockTake.setCompletedProducts(rs.getInt("completed_products"));
        }

        return stockTake;
    }

    @Override
    public StockTake findById(Integer id) {
        String sql = "SELECT st.*, u.full_name as user_full_name FROM stocktakes st LEFT JOIN users u ON st.user_id = u.user_id WHERE st.stock_take_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return null;
    }

    // Phương thức tìm stock takes theo userId
   public List<StockTake> findByUserId(Integer userId) {
    List<StockTake> list = new ArrayList<>();
    String sql = "SELECT st.stock_take_id, st.stock_take_code, st.user_id, st.stock_take_date, st.status, st.notes, st.created_at, " +
                 "u.full_name AS user_full_name, " +
                 "(SELECT COUNT(*) FROM stocktakedetails std WHERE std.stock_take_id = st.stock_take_id) AS total_products, " +
                 "(SELECT COUNT(*) FROM stocktakedetails std WHERE std.stock_take_id = st.stock_take_id AND std.counted_quantity IS NOT NULL) AS completed_products " +
                 "FROM stocktakes st " +
                 "LEFT JOIN users u ON st.user_id = u.user_id " +
                 "WHERE st.user_id = ? " +
                 "ORDER BY st.created_at DESC";
    try {
        conn = getConnection();
        statement = conn.prepareStatement(sql);
        statement.setInt(1, userId);
        resultSet = statement.executeQuery();
        while (resultSet.next()) {
            list.add(getFromResultSet(resultSet));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        close();
    }
    return list;
}


    // Phương thức tìm stock takes theo status
    public List<StockTake> findByStatus(String status) {
        List<StockTake> list = new ArrayList<>();
        String sql = "SELECT st.*, u.full_name as user_full_name, "
                + "(SELECT COUNT(*) FROM stocktakedetails std WHERE std.stock_take_id = st.stock_take_id) as total_products, "
                + "(SELECT COUNT(*) FROM stocktakedetails std WHERE std.stock_take_id = st.stock_take_id AND std.counted_quantity IS NOT NULL) as completed_products "
                + "FROM stocktakes st "
                + "LEFT JOIN users u ON st.user_id = u.user_id "
                + "WHERE st.status = ? "
                + "ORDER BY st.created_at DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, status);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return list;
    }

    // Phương thức cập nhật status
    public boolean updateStatus(Integer stockTakeId, String status) {
        String sql = "UPDATE stocktakes SET status = ? WHERE stock_take_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, status);
            statement.setInt(2, stockTakeId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Phương thức cập nhật notes
    public boolean updateNotes(Integer stockTakeId, String notes) {
        String sql = "UPDATE stocktakes SET notes = ? WHERE stock_take_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, notes);
            statement.setInt(2, stockTakeId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Tạo mã stock take code tự động
    public String generateStockTakeCode() {
        String sql = "SELECT MAX(CAST(SUBSTRING(stock_take_code, 3) AS UNSIGNED)) as max_num FROM stocktakes WHERE stock_take_code LIKE 'ST%'";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                int maxNum = resultSet.getInt("max_num");
                return String.format("ST%06d", maxNum + 1);
            } else {
                return "ST000001";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return "ST000001";
        } finally {
            close();
        }
    }
}
