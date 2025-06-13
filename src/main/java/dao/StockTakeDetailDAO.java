package dao;

import context.DBContext;
import model.StockTakeDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StockTakeDetailDAO extends DBContext implements I_DAO<StockTakeDetail> {

    @Override
    public List<StockTakeDetail> findAll() {
        List<StockTakeDetail> list = new ArrayList<>();
        String sql = "SELECT std.*, p.product_code, p.product_name, p.unit " +
                    "FROM stocktakedetails std " +
                    "LEFT JOIN products p ON std.product_id = p.product_id " +
                    "ORDER BY std.stock_take_detail_id DESC";
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
    public boolean update(StockTakeDetail stockTakeDetail) {
        String sql = "UPDATE stocktakedetails SET stock_take_id = ?, product_id = ?, system_quantity = ?, counted_quantity = ? WHERE stock_take_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockTakeDetail.getStockTakeId());
            statement.setInt(2, stockTakeDetail.getProductId());
            statement.setInt(3, stockTakeDetail.getSystemQuantity());
            if (stockTakeDetail.getCountedQuantity() != null) {
                statement.setInt(4, stockTakeDetail.getCountedQuantity());
            } else {
                statement.setNull(4, Types.INTEGER);
            }
            statement.setInt(5, stockTakeDetail.getStockTakeDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(StockTakeDetail stockTakeDetail) {
        String sql = "DELETE FROM stocktakedetails WHERE stock_take_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockTakeDetail.getStockTakeDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public int insert(StockTakeDetail stockTakeDetail) {
        String sql = "INSERT INTO stocktakedetails (stock_take_id, product_id, system_quantity, counted_quantity) VALUES (?, ?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, stockTakeDetail.getStockTakeId());
            statement.setInt(2, stockTakeDetail.getProductId());
            statement.setInt(3, stockTakeDetail.getSystemQuantity());
            if (stockTakeDetail.getCountedQuantity() != null) {
                statement.setInt(4, stockTakeDetail.getCountedQuantity());
            } else {
                statement.setNull(4, Types.INTEGER);
            }
            
            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating stock take detail failed, no rows affected.");
            }
            
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating stock take detail failed, no ID obtained.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public StockTakeDetail getFromResultSet(ResultSet rs) throws SQLException {
        StockTakeDetail detail = new StockTakeDetail();
        detail.setStockTakeDetailId(rs.getInt("stock_take_detail_id"));
        detail.setStockTakeId(rs.getInt("stock_take_id"));
        detail.setProductId(rs.getInt("product_id"));
        detail.setSystemQuantity(rs.getInt("system_quantity"));
        
        int countedQty = rs.getInt("counted_quantity");
        if (rs.wasNull()) {
            detail.setCountedQuantity(null);
        } else {
            detail.setCountedQuantity(countedQty);
        }
        
        int discrepancy = rs.getInt("discrepancy");
        if (rs.wasNull()) {
            detail.setDiscrepancy(null);
        } else {
            detail.setDiscrepancy(discrepancy);
        }
        
        // Additional fields if available
        try {
            detail.setProductCode(rs.getString("product_code"));
            detail.setProductName(rs.getString("product_name"));
            detail.setUnit(rs.getString("unit"));
        } catch (SQLException e) {
            // Fields may not exist in all queries
        }
        
        return detail;
    }

    @Override
    public StockTakeDetail findById(Integer id) {
        String sql = "SELECT std.*, p.product_code, p.product_name, p.unit " +
                    "FROM stocktakedetails std " +
                    "LEFT JOIN products p ON std.product_id = p.product_id " +
                    "WHERE std.stock_take_detail_id = ?";
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

    // Tìm chi tiết theo stock_take_id
    public List<StockTakeDetail> findByStockTakeId(Integer stockTakeId) {
        List<StockTakeDetail> list = new ArrayList<>();
        String sql = "SELECT std.*, p.product_code, p.product_name, p.unit, COALESCE(i.quantity_on_hand, 0) as current_quantity " +
                    "FROM stocktakedetails std " +
                    "LEFT JOIN products p ON std.product_id = p.product_id " +
                    "LEFT JOIN inventory i ON p.product_id = i.product_id " +
                    "WHERE std.stock_take_id = ? " +
                    "ORDER BY p.product_code";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockTakeId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                StockTakeDetail detail = new StockTakeDetail();
                detail.setStockTakeDetailId(resultSet.getInt("stock_take_detail_id"));
                detail.setStockTakeId(resultSet.getInt("stock_take_id"));
                detail.setProductId(resultSet.getInt("product_id"));
                
                // Lấy quantity hiện tại từ products thay vì system_quantity cũ
                detail.setSystemQuantity(resultSet.getInt("current_quantity"));
                
                int countedQty = resultSet.getInt("counted_quantity");
                if (resultSet.wasNull()) {
                    detail.setCountedQuantity(null);
                } else {
                    detail.setCountedQuantity(countedQty);
                }
                
                // Additional fields
                detail.setProductCode(resultSet.getString("product_code"));
                detail.setProductName(resultSet.getString("product_name"));
                detail.setUnit(resultSet.getString("unit"));
                
                list.add(detail);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return list;
    }

    // Cập nhật counted_quantity và system_quantity
    public boolean updateCountedQuantity(Integer stockTakeDetailId, Integer countedQuantity) {
        String sql = "UPDATE stocktakedetails std " +
                    "LEFT JOIN inventory i ON std.product_id = i.product_id " +
                    "SET std.counted_quantity = ?, std.system_quantity = COALESCE(i.quantity_on_hand, 0) " +
                    "WHERE std.stock_take_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            if (countedQuantity != null) {
                statement.setInt(1, countedQuantity);
            } else {
                statement.setNull(1, Types.INTEGER);
            }
            statement.setInt(2, stockTakeDetailId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Tạo chi tiết kiểm kê cho tất cả sản phẩm có tồn kho
    public boolean createStockTakeDetailsForAllProducts(Integer stockTakeId) {
        String sql = "INSERT INTO stocktakedetails (stock_take_id, product_id, system_quantity) " +
                    "SELECT ?, p.product_id, COALESCE(i.quantity_on_hand, 0) " +
                    "FROM products p " +
                    "LEFT JOIN inventory i ON p.product_id = i.product_id " +
                    "WHERE p.is_active = 1";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockTakeId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Lấy danh sách các mục kiểm kê có chênh lệch
    public List<StockTakeDetail> findDiscrepanciesByStockTakeId(Integer stockTakeId) {
        List<StockTakeDetail> list = new ArrayList<>();
        String sql = "SELECT std.*, p.product_code, p.product_name, p.unit " +
                    "FROM stocktakedetails std " +
                    "LEFT JOIN products p ON std.product_id = p.product_id " +
                    "WHERE std.stock_take_id = ? AND std.discrepancy != 0 " +
                    "ORDER BY ABS(std.discrepancy) DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockTakeId);
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

    // Lấy thống kê tổng quan kiểm kê
    public List<Object[]> getStockTakeStatistics(Integer stockTakeId) {
        List<Object[]> statistics = new ArrayList<>();
        String sql = "SELECT " +
                    "COUNT(*) as total_items, " +
                    "SUM(CASE WHEN counted_quantity IS NOT NULL THEN 1 ELSE 0 END) as counted_items, " +
                    "SUM(CASE WHEN discrepancy > 0 THEN 1 ELSE 0 END) as positive_discrepancies, " +
                    "SUM(CASE WHEN discrepancy < 0 THEN 1 ELSE 0 END) as negative_discrepancies, " +
                    "SUM(CASE WHEN discrepancy = 0 THEN 1 ELSE 0 END) as no_discrepancies " +
                    "FROM stocktakedetails WHERE stock_take_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, stockTakeId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                Object[] stats = new Object[5];
                stats[0] = resultSet.getInt("total_items");
                stats[1] = resultSet.getInt("counted_items");
                stats[2] = resultSet.getInt("positive_discrepancies");
                stats[3] = resultSet.getInt("negative_discrepancies");
                stats[4] = resultSet.getInt("no_discrepancies");
                statistics.add(stats);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return statistics;
    }
} 