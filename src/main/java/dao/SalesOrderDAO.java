package dao;

import context.DBContext;
import model.SalesOrder;
import model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SalesOrderDAO extends DBContext implements I_DAO<SalesOrder> {

    @Override
    public List<SalesOrder> findAll() {
        List<SalesOrder> list = new ArrayList<>();
        String sql = "SELECT so.sales_order_id, so.order_code, so.customer_name, so.user_id, so.order_date, so.status, so.notes, so.created_at, so.warehouse_id, so.quotation_id, " +
                    "u.full_name, u.email " +
                    "FROM salesorders so " +
                    "LEFT JOIN users u ON so.user_id = u.user_id " +
                    "ORDER BY so.created_at DESC";
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
        String sql = "UPDATE salesorders SET order_code = ?, customer_name = ?, user_id = ?, order_date = ?, status = ?, notes = ?, warehouse_id = ?, quotation_id = ? WHERE sales_order_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, salesOrder.getOrderCode());
            statement.setString(2, salesOrder.getCustomerName());
            statement.setInt(3, salesOrder.getUserId());
            statement.setDate(4, salesOrder.getOrderDate());
            statement.setString(5, salesOrder.getStatus());
            statement.setString(6, salesOrder.getNotes());
            if (salesOrder.getWarehouseId() != null) {
                statement.setInt(7, salesOrder.getWarehouseId());
            } else {
                statement.setNull(7, java.sql.Types.INTEGER);
            }
            if (salesOrder.getQuotationId() != null) {
                statement.setInt(8, salesOrder.getQuotationId());
            } else {
                statement.setNull(8, java.sql.Types.INTEGER);
            }
            statement.setInt(9, salesOrder.getSalesOrderId());
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
        String insertSql = "INSERT INTO salesorders (customer_name, user_id, order_date, status, notes, warehouse_id, quotation_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String updateSql = "UPDATE salesorders SET order_code = ? WHERE sales_order_id = ?";

        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Start transaction

            // Step 1: Insert the sales order without the order code to get the ID
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                insertStmt.setString(1, salesOrder.getCustomerName());
                insertStmt.setInt(2, salesOrder.getUserId());
                insertStmt.setDate(3, salesOrder.getOrderDate());
                insertStmt.setString(4, salesOrder.getStatus());
                insertStmt.setString(5, salesOrder.getNotes());
                if (salesOrder.getWarehouseId() != null) {
                    insertStmt.setInt(6, salesOrder.getWarehouseId());
                } else {
                    insertStmt.setNull(6, java.sql.Types.INTEGER);
                }
                if (salesOrder.getQuotationId() != null) {
                    insertStmt.setInt(7, salesOrder.getQuotationId());
                } else {
                    insertStmt.setNull(7, java.sql.Types.INTEGER);
                }

                int affectedRows = insertStmt.executeUpdate();
                if (affectedRows == 0) {
                    conn.rollback();
                    throw new SQLException("Creating sales order failed, no rows affected.");
                }

                // Step 2: Get the generated sales_order_id
                try (ResultSet generatedKeys = insertStmt.getGeneratedKeys()) {
                    int salesOrderId;
                    if (generatedKeys.next()) {
                        salesOrderId = generatedKeys.getInt(1);
                    } else {
                        conn.rollback();
                        throw new SQLException("Creating sales order failed, no ID obtained.");
                    }

                    // Step 3: Generate the order code and update the record
                    String orderCode = String.format("SO%06d", salesOrderId);
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                        updateStmt.setString(1, orderCode);
                        updateStmt.setInt(2, salesOrderId);
                        updateStmt.executeUpdate();
                    }

                    conn.commit(); // Commit transaction
                    return salesOrderId;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return -1;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            close();
        }
    }

    @Override
    public SalesOrder getFromResultSet(ResultSet rs) throws SQLException {
        // Create user object if user information is available
        User user = null;
        if (rs.getObject("user_id") != null) {
            user = User.builder()
                    .userId(rs.getInt("user_id"))
                    .fullName(rs.getString("full_name"))
                    .email(rs.getString("email"))
                    .build();
        }
        
        return SalesOrder.builder()
                .salesOrderId(rs.getInt("sales_order_id"))
                .orderCode(rs.getString("order_code"))
                .customerName(rs.getString("customer_name"))
                .customerPhone(null) // Database doesn't have this field yet, set to null
                .userId(rs.getInt("user_id"))
                .orderDate(rs.getDate("order_date"))
                .status(rs.getString("status"))
                .priority("low") // Default priority since database doesn't have this field yet
                .notes(rs.getString("notes"))
                .quotationId(rs.getObject("quotation_id") != null ? rs.getInt("quotation_id") : null)
                .createdAt(rs.getTimestamp("created_at"))
                .warehouseId(rs.getInt("warehouse_id"))
                .user(user)
                .details(null) // Will be loaded separately
                .build();
    }

    @Override
    public SalesOrder findById(Integer id) {
        String sql = "SELECT so.sales_order_id, so.order_code, so.customer_name, so.user_id, so.order_date, so.status, so.notes, so.created_at, so.warehouse_id, so.quotation_id, " +
                    "u.full_name, u.email " +
                    "FROM salesorders so " +
                    "LEFT JOIN users u ON so.user_id = u.user_id " +
                    "WHERE so.sales_order_id = ?";
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

    // Find orders with filters and pagination
    public List<SalesOrder> findOrdersWithFilters(String statusFilter, String customerFilter, 
                                                  String userIdFilter, Integer warehouseIdFilter, Integer page, Integer pageSize) {
        List<SalesOrder> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT so.sales_order_id, so.order_code, so.customer_name, so.user_id, so.order_date, so.status, so.notes, so.created_at, so.warehouse_id, so.quotation_id, " +
                                             "u.full_name, u.email " +
                                             "FROM salesorders so " +
                                             "LEFT JOIN users u ON so.user_id = u.user_id " +
                                             "WHERE 1=1");
        
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND so.status = ?");
        }
        if (customerFilter != null && !customerFilter.trim().isEmpty()) {
            sql.append(" AND so.customer_name LIKE ?");
        }
        if (userIdFilter != null && !userIdFilter.trim().isEmpty()) {
            sql.append(" AND so.user_id = ?");
        }
        if (warehouseIdFilter != null) {
            sql.append(" AND so.warehouse_id = ?");
        }
        
        sql.append(" ORDER BY so.created_at DESC");
        
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
            if (warehouseIdFilter != null) {
                statement.setInt(paramIndex++, warehouseIdFilter);
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
    public Integer getTotalFilteredOrders(String statusFilter, String customerFilter, String userIdFilter,  Integer warehouseIdFilter) {
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
        if (warehouseIdFilter != null) {
            sql.append(" AND warehouse_id = ?");
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
            if (warehouseIdFilter != null) {
                statement.setInt(paramIndex++, warehouseIdFilter);
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
        String sql = "SELECT so.sales_order_id, so.order_code, so.customer_name, so.user_id, so.order_date, so.status, so.notes, so.created_at, so.warehouse_id, so.quotation_id, " +
                    "u.full_name, u.email " +
                    "FROM salesorders so " +
                    "LEFT JOIN users u ON so.user_id = u.user_id " +
                    "WHERE so.user_id = ? ORDER BY so.created_at DESC";
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

    /**
     * Find sales orders by status
     */
    public List<SalesOrder> findByStatus(String status) {
        List<SalesOrder> list = new ArrayList<>();
        String sql = "SELECT so.sales_order_id, so.order_code, so.customer_name, so.user_id, so.order_date, so.status, so.notes, so.created_at, so.warehouse_id, so.quotation_id, " +
                    "u.full_name, u.email " +
                    "FROM salesorders so " +
                    "LEFT JOIN users u ON so.user_id = u.user_id " +
                    "WHERE so.status = ? ORDER BY so.created_at DESC";
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
} 