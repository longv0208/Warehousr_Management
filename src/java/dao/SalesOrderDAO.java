package dao;

import context.DBContext;
import model.SalesOrder;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SalesOrderDAO extends DBContext implements I_DAO<SalesOrder> {

    @Override
    public List<SalesOrder> findAll() {
        List<SalesOrder> list = new ArrayList<>();
        String sql = "SELECT sales_order_id, order_code, customer_name, user_id, order_date, status, notes, created_at FROM salesorders ORDER BY created_at DESC";
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
    public boolean update(SalesOrder salesOrder) {
        String sql = "UPDATE salesorders SET order_code = ?, customer_name = ?, user_id = ?, order_date = ?, status = ?, notes = ? WHERE sales_order_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, salesOrder.getOrderCode());
            statement.setString(2, salesOrder.getCustomerName());
            statement.setInt(3, salesOrder.getUserId());
            statement.setDate(4, salesOrder.getOrderDate());
            statement.setString(5, salesOrder.getStatus());
            statement.setString(6, salesOrder.getNotes());
            statement.setInt(7, salesOrder.getSalesOrderId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(SalesOrder salesOrder) {
        String sql = "DELETE FROM salesorders WHERE sales_order_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, salesOrder.getSalesOrderId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public int insert(SalesOrder salesOrder) {
        String sql = "INSERT INTO salesorders (order_code, customer_name, user_id, order_date, status, notes) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, salesOrder.getOrderCode());
            statement.setString(2, salesOrder.getCustomerName());
            statement.setInt(3, salesOrder.getUserId());
            statement.setDate(4, salesOrder.getOrderDate());
            statement.setString(5, salesOrder.getStatus());
            statement.setString(6, salesOrder.getNotes());
            
            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating sales order failed, no rows affected.");
            }
            
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating sales order failed, no ID obtained.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public SalesOrder getFromResultSet(ResultSet rs) throws SQLException {
        SalesOrder salesOrder = new SalesOrder();
        salesOrder.setSalesOrderId(rs.getInt("sales_order_id"));
        salesOrder.setOrderCode(rs.getString("order_code"));
        salesOrder.setCustomerName(rs.getString("customer_name"));
        salesOrder.setUserId(rs.getInt("user_id"));
        salesOrder.setOrderDate(rs.getDate("order_date"));
        salesOrder.setStatus(rs.getString("status"));
        salesOrder.setNotes(rs.getString("notes"));
        salesOrder.setCreatedAt(rs.getTimestamp("created_at"));
        return salesOrder;
    }

    @Override
    public SalesOrder findById(Integer id) {
        String sql = "SELECT sales_order_id, order_code, customer_name, user_id, order_date, status, notes, created_at FROM salesorders WHERE sales_order_id = ?";
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

    // Generate order code
    public String generateOrderCode() {
        String sql = "SELECT COUNT(*) + 1 as next_id FROM salesorders";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                int nextId = resultSet.getInt("next_id");
                return String.format("SO%06d", nextId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return "SO000001";
    }

    // Find orders with filters and pagination
    public List<SalesOrder> findOrdersWithFilters(String statusFilter, String customerFilter, 
                                                  String userIdFilter, Integer page, Integer pageSize) {
        List<SalesOrder> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT sales_order_id, order_code, customer_name, user_id, order_date, status, notes, created_at FROM salesorders WHERE 1=1");
        
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND status = ?");
        }
        if (customerFilter != null && !customerFilter.trim().isEmpty()) {
            sql.append(" AND customer_name LIKE ?");
        }
        if (userIdFilter != null && !userIdFilter.trim().isEmpty()) {
            sql.append(" AND user_id = ?");
        }
        
        sql.append(" ORDER BY created_at DESC");
        
        if (page != null && pageSize != null) {
            sql.append(" LIMIT ? OFFSET ?");
        }
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql.toString());
            
            int paramIndex = 1;
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                statement.setString(paramIndex++, statusFilter);
            }
            if (customerFilter != null && !customerFilter.trim().isEmpty()) {
                statement.setString(paramIndex++, "%" + customerFilter + "%");
            }
            if (userIdFilter != null && !userIdFilter.trim().isEmpty()) {
                statement.setInt(paramIndex++, Integer.parseInt(userIdFilter));
            }
            
            if (page != null && pageSize != null) {
                statement.setInt(paramIndex++, pageSize);
                statement.setInt(paramIndex++, (page - 1) * pageSize);
            }
            
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

    // Get total count for pagination
    public Integer getTotalFilteredOrders(String statusFilter, String customerFilter, String userIdFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) as total FROM salesorders WHERE 1=1");
        
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND status = ?");
        }
        if (customerFilter != null && !customerFilter.trim().isEmpty()) {
            sql.append(" AND customer_name LIKE ?");
        }
        if (userIdFilter != null && !userIdFilter.trim().isEmpty()) {
            sql.append(" AND user_id = ?");
        }
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql.toString());
            
            int paramIndex = 1;
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                statement.setString(paramIndex++, statusFilter);
            }
            if (customerFilter != null && !customerFilter.trim().isEmpty()) {
                statement.setString(paramIndex++, "%" + customerFilter + "%");
            }
            if (userIdFilter != null && !userIdFilter.trim().isEmpty()) {
                statement.setInt(paramIndex++, Integer.parseInt(userIdFilter));
            }
            
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return 0;
    }

    // Update order status
    public boolean updateStatus(Integer salesOrderId, String status) {
        String sql = "UPDATE salesorders SET status = ? WHERE sales_order_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, status);
            statement.setInt(2, salesOrderId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Find orders by user ID
    public List<SalesOrder> findByUserId(Integer userId) {
        List<SalesOrder> list = new ArrayList<>();
        String sql = "SELECT sales_order_id, order_code, customer_name, user_id, order_date, status, notes, created_at FROM salesorders WHERE user_id = ? ORDER BY created_at DESC";
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
} 