package dao;

import context.DBContext;
import model.UserNotification;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserNotificationDAO extends DBContext implements I_DAO<UserNotification> {

    // Phương thức thêm thông báo
    public boolean add(UserNotification notification) {
        String sql = "INSERT INTO user_notifications (sender_id, receiver_id, title, message, is_read, created_at) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, notification.getSenderId());
            statement.setInt(2, notification.getReceiverId());
            statement.setString(3, notification.getTitle());
            statement.setString(4, notification.getMessage());
            statement.setBoolean(5, notification.isRead());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(UserNotification notification) {
        String sql = "UPDATE user_notifications SET sender_id = ?, receiver_id = ?, title = ?, message = ?, is_read = ? WHERE notification_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, notification.getSenderId());
            statement.setInt(2, notification.getReceiverId());
            statement.setString(3, notification.getTitle());
            statement.setString(4, notification.getMessage());
            statement.setBoolean(5, notification.isRead());
            statement.setInt(6, notification.getNotificationId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(UserNotification notification) {
        String sql = "DELETE FROM user_notifications WHERE notification_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, notification.getNotificationId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public int insert(UserNotification notification) {
        String sql = "INSERT INTO user_notifications (sender_id, receiver_id, title, message, is_read, created_at) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, notification.getSenderId());
            statement.setInt(2, notification.getReceiverId());
            statement.setString(3, notification.getTitle());
            statement.setString(4, notification.getMessage());
            statement.setBoolean(5, notification.isRead());
            
            int rowsAffected = statement.executeUpdate();
            if (rowsAffected > 0) {
                ResultSet generatedKeys = statement.getGeneratedKeys();
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
            }
            return -1;
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public UserNotification findById(Integer id) {
        String sql = "SELECT n.*, u1.full_name as sender_name, u2.full_name as receiver_name " +
                    "FROM user_notifications n " +
                    "LEFT JOIN users u1 ON n.sender_id = u1.user_id " +
                    "LEFT JOIN users u2 ON n.receiver_id = u2.user_id " +
                    "WHERE n.notification_id = ?";
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

    @Override
    public List<UserNotification> findAll() {
        List<UserNotification> notifications = new ArrayList<>();
        String sql = "SELECT n.*, u1.full_name as sender_name, u2.full_name as receiver_name " +
                    "FROM user_notifications n " +
                    "LEFT JOIN users u1 ON n.sender_id = u1.user_id " +
                    "LEFT JOIN users u2 ON n.receiver_id = u2.user_id " +
                    "ORDER BY n.created_at DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                notifications.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return notifications;
    }

    @Override
    public UserNotification getFromResultSet(ResultSet rs) throws SQLException {
        return UserNotification.builder()
                .notificationId(rs.getInt("notification_id"))
                .senderId(rs.getInt("sender_id"))
                .receiverId(rs.getInt("receiver_id"))
                .title(rs.getString("title"))
                .message(rs.getString("message"))
                .isRead(rs.getBoolean("is_read"))
                .createdAt(rs.getTimestamp("created_at"))
                .senderName(rs.getString("sender_name"))
                .receiverName(rs.getString("receiver_name"))
                .build();
    }

    // Lấy thông báo theo receiver_id
    public List<UserNotification> getNotificationsByReceiverId(int receiverId) {
        List<UserNotification> notifications = new ArrayList<>();
        String sql = "SELECT n.*, u1.full_name as sender_name, u2.full_name as receiver_name " +
                    "FROM user_notifications n " +
                    "LEFT JOIN users u1 ON n.sender_id = u1.user_id " +
                    "LEFT JOIN users u2 ON n.receiver_id = u2.user_id " +
                    "WHERE n.receiver_id = ? ORDER BY n.created_at DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, receiverId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                notifications.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return notifications;
    }

    // Lấy thông báo theo sender_id
    public List<UserNotification> getNotificationsBySenderId(int senderId) {
        List<UserNotification> notifications = new ArrayList<>();
        String sql = "SELECT n.*, u1.full_name as sender_name, u2.full_name as receiver_name " +
                    "FROM user_notifications n " +
                    "LEFT JOIN users u1 ON n.sender_id = u1.user_id " +
                    "LEFT JOIN users u2 ON n.receiver_id = u2.user_id " +
                    "WHERE n.sender_id = ? ORDER BY n.created_at DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, senderId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                notifications.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return notifications;
    }

    // Đánh dấu thông báo đã đọc
    public boolean markAsRead(int notificationId) {
        String sql = "UPDATE user_notifications SET is_read = TRUE WHERE notification_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, notificationId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Đếm số thông báo chưa đọc của user
    public int countUnreadNotifications(int receiverId) {
        String sql = "SELECT COUNT(*) FROM user_notifications WHERE receiver_id = ? AND is_read = FALSE";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, receiverId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return 0;
    }

    // Gửi thông báo đến nhiều user cùng lúc
    public boolean sendNotificationToMultipleUsers(int senderId, List<Integer> receiverIds, String title, String message) {
        String sql = "INSERT INTO user_notifications (sender_id, receiver_id, title, message, is_read, created_at) VALUES (?, ?, ?, ?, FALSE, CURRENT_TIMESTAMP)";
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            statement = conn.prepareStatement(sql);
            
            for (int receiverId : receiverIds) {
                statement.setInt(1, senderId);
                statement.setInt(2, receiverId);
                statement.setString(3, title);
                statement.setString(4, message);
                statement.addBatch();
            }
            
            int[] results = statement.executeBatch();
            conn.commit();
            
            // Kiểm tra xem tất cả insert có thành công không
            for (int result : results) {
                if (result <= 0) {
                    return false;
                }
            }
            return true;
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            close();
        }
    }
} 