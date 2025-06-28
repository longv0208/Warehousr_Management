package dao;

import context.DBContext;
import model.ActivityLog;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ActivityLogDAO extends DBContext implements I_DAO<ActivityLog> {

    @Override
    public int insert(ActivityLog activityLog) {
        String sql = "INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, " +
                "old_value, new_value, note, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, activityLog.getUserId());
            statement.setString(2, activityLog.getActionType());
            statement.setString(3, activityLog.getEntityType());
            if (activityLog.getEntityId() != null) {
                statement.setInt(4, activityLog.getEntityId());
            } else {
                statement.setNull(4, Types.INTEGER);
            }
            statement.setString(5, activityLog.getOldValue());
            statement.setString(6, activityLog.getNewValue());
            statement.setString(7, activityLog.getNote());
            statement.setTimestamp(8, activityLog.getTimestamp());

            int affectedRows = statement.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating activity log failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating activity log failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            System.out.println("Error inserting activity log: " + ex.getMessage());
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(ActivityLog activityLog) {
        return false; // Activity logs should not be updated
    }

    @Override
    public boolean delete(ActivityLog activityLog) {
        return false; // Activity logs should not be deleted
    }

    @Override
    public ActivityLog findById(Integer id) {
        String sql = "SELECT * FROM activity_logs WHERE id = ?";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting activity log by id: " + ex.getMessage());
        } finally {
            close();
        }
        return null;
    }

    @Override
    public List<ActivityLog> findAll() {
        String sql = "SELECT * FROM activity_logs ORDER BY timestamp DESC";
        List<ActivityLog> activityLogs = new ArrayList<>();

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                activityLogs.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error getting all activity logs: " + ex.getMessage());
        } finally {
            close();
        }
        return activityLogs;
    }

    @Override
    public ActivityLog getFromResultSet(ResultSet rs) throws SQLException {
        ActivityLog activityLog = new ActivityLog();
        activityLog.setId(rs.getInt("id"));
        activityLog.setUserId(rs.getInt("user_id"));
        activityLog.setActionType(rs.getString("action_type"));
        activityLog.setEntityType(rs.getString("entity_type"));
        Integer entityId = rs.getInt("entity_id");
        if (rs.wasNull()) {
            activityLog.setEntityId(null);
        } else {
            activityLog.setEntityId(entityId);
        }
        activityLog.setOldValue(rs.getString("old_value"));
        activityLog.setNewValue(rs.getString("new_value"));
        activityLog.setNote(rs.getString("note"));
        activityLog.setTimestamp(rs.getTimestamp("timestamp"));
        return activityLog;
    }

    // Custom methods for filtering and reporting
    public List<ActivityLog> getFilteredLogs(Integer userId, String actionType, String entityType, 
                                           String startDate, String endDate, Integer page, Integer pageSize) {
        StringBuilder sql = new StringBuilder("SELECT * FROM activity_logs WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (userId != null) {
            sql.append(" AND user_id = ?");
            params.add(userId);
        }
        if (actionType != null && !actionType.isEmpty()) {
            sql.append(" AND action_type = ?");
            params.add(actionType);
        }
        if (entityType != null && !entityType.isEmpty()) {
            sql.append(" AND entity_type = ?");
            params.add(entityType);
        }
        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(timestamp) >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(timestamp) <= ?");
            params.add(endDate);
        }

        sql.append(" ORDER BY timestamp DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        List<ActivityLog> activityLogs = new ArrayList<>();

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql.toString());
            
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }
            
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                activityLogs.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error getting filtered activity logs: " + ex.getMessage());
        } finally {
            close();
        }
        return activityLogs;
    }

    public int getTotalFilteredLogs(Integer userId, String actionType, String entityType, 
                                  String startDate, String endDate) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM activity_logs WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (userId != null) {
            sql.append(" AND user_id = ?");
            params.add(userId);
        }
        if (actionType != null && !actionType.isEmpty()) {
            sql.append(" AND action_type = ?");
            params.add(actionType);
        }
        if (entityType != null && !entityType.isEmpty()) {
            sql.append(" AND entity_type = ?");
            params.add(entityType);
        }
        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(timestamp) >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(timestamp) <= ?");
            params.add(endDate);
        }

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql.toString());
            
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }
            
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            System.out.println("Error counting filtered activity logs: " + ex.getMessage());
        } finally {
            close();
        }
        return 0;
    }

    public List<Object[]> getActionStatistics(String startDate, String endDate) {
        String sql = "SELECT u.full_name, al.action_type, COUNT(*) as count " +
                    "FROM activity_logs al " +
                    "JOIN users u ON al.user_id = u.user_id " +
                    "WHERE DATE(al.timestamp) BETWEEN ? AND ? " +
                    "GROUP BY al.user_id, al.action_type, u.full_name " +
                    "ORDER BY u.full_name, al.action_type";
        
        List<Object[]> statistics = new ArrayList<>();

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, startDate);
            statement.setString(2, endDate);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                Object[] row = new Object[3];
                row[0] = resultSet.getString("full_name");
                row[1] = resultSet.getString("action_type");
                row[2] = resultSet.getInt("count");
                statistics.add(row);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting action statistics: " + ex.getMessage());
        } finally {
            close();
        }
        return statistics;
    }

    public List<Object[]> getSuspiciousActivities(String date) {
        String sql = "SELECT u.full_name, COUNT(*) as adjust_count " +
                    "FROM activity_logs al " +
                    "JOIN users u ON al.user_id = u.user_id " +
                    "WHERE al.action_type = 'ADJUST' AND DATE(al.timestamp) = ? " +
                    "GROUP BY al.user_id, u.full_name " +
                    "HAVING COUNT(*) >= 5 " +
                    "ORDER BY adjust_count DESC";

        List<Object[]> suspicious = new ArrayList<>();

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, date);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                Object[] row = new Object[2];
                row[0] = resultSet.getString("full_name");
                row[1] = resultSet.getInt("adjust_count");
                suspicious.add(row);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting suspicious activities: " + ex.getMessage());
        } finally {
            close();
        }
        return suspicious;
    }

    public List<Object[]> getAfterHoursActivities(String date) {
        String sql = "SELECT u.full_name, al.action_type, al.timestamp, al.entity_type " +
                    "FROM activity_logs al " +
                    "JOIN users u ON al.user_id = u.user_id " +
                    "WHERE DATE(al.timestamp) = ? " +
                    "AND (HOUR(al.timestamp) < 8 OR HOUR(al.timestamp) > 18) " +
                    "AND al.action_type NOT IN ('LOGIN', 'LOGOUT') " +
                    "ORDER BY al.timestamp DESC";

        List<Object[]> afterHours = new ArrayList<>();

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, date);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                Object[] row = new Object[4];
                row[0] = resultSet.getString("full_name");
                row[1] = resultSet.getString("action_type");
                row[2] = resultSet.getTimestamp("timestamp");
                row[3] = resultSet.getString("entity_type");
                afterHours.add(row);
            }
        } catch (SQLException ex) {
            System.out.println("Error getting after hours activities: " + ex.getMessage());
        } finally {
            close();
        }
        return afterHours;
    }

    public List<ActivityLog> getLoginLogoutHistory(Integer userId, String startDate, String endDate) {
        String sql = "SELECT * FROM activity_logs " +
                    "WHERE user_id = ? AND action_type IN ('LOGIN', 'LOGOUT') " +
                    "AND DATE(timestamp) BETWEEN ? AND ? " +
                    "ORDER BY timestamp DESC";

        List<ActivityLog> loginHistory = new ArrayList<>();

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, userId);
            statement.setString(2, startDate);
            statement.setString(3, endDate);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                loginHistory.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            System.out.println("Error getting login/logout history: " + ex.getMessage());
        } finally {
            close();
        }
        return loginHistory;
    }
} 