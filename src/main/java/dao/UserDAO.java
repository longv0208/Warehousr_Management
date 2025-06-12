package dao;

import context.DBContext;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import model.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO extends DBContext implements I_DAO<User> {

    // Kiểm tra username đã tồn tại chưa
    public boolean isUsernameExist(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, username);
            resultSet = statement.executeQuery();
            return resultSet.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Kiểm tra email đã tồn tại chưa
    public boolean isEmailExist(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, email);
            resultSet = statement.executeQuery();
            return resultSet.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Thêm user mới
    public boolean add(User user) {
        if (isUsernameExist(user.getUsername())) {
            System.out.println("Username đã tồn tại, không thể thêm.");
            return false;
        }
        if (isEmailExist(user.getEmail())) {
            System.out.println("Email đã tồn tại, không thể thêm.");
            return false;
        }
        String sql = "INSERT INTO users (username, password_hash, full_name, role, email, is_active, created_at, updated_at, phone) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?,?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, user.getUsername());
            statement.setString(2, user.getPasswordHash());
            statement.setString(3, user.getFullName());
            statement.setString(4, user.getRoleId());
            statement.setString(5, user.getEmail());
            statement.setBoolean(6, user.isActive());
            statement.setTimestamp(7, user.getCreatedAt());
            statement.setTimestamp(8, user.getUpdatedAt());
            statement.setString(9, user.getPhone());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Lấy user theo user_id
    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, userId);
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

    // Cập nhật user
    @Override
    public boolean update(User user) {
        String sql = "UPDATE users SET username = ?, password_hash = ?, full_name = ?, role = ?, email = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP, phone = ? WHERE user_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, user.getUsername());
            statement.setString(2, user.getPasswordHash());
            statement.setString(3, user.getFullName());
            statement.setString(4, user.getRoleId());
            statement.setString(5, user.getEmail());
            statement.setBoolean(6, user.isActive());
            statement.setString(7, user.getPhone());
            statement.setInt(8, user.getUserId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Tìm user theo username
    public User findByUsername(String username) {
        String sql = "SELECT user_id, username, password_hash, full_name, role, email, is_active, created_at, updated_at, phone FROM users WHERE username = ?";
        try {
            
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, username);
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

    // Tìm user theo email
    public User findByEmail(String email) {
        String sql = "SELECT user_id, username, password_hash, full_name, role, email, is_active, created_at, updated_at, phone FROM users WHERE email = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, email);
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

    // Cập nhật password
    public boolean updatePassword(int userId, String newHashedPassword) {
        String sql = "UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, newHashedPassword);
            statement.setInt(2, userId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Vô hiệu hóa user
    public boolean inactive(int userId) {
        String sql = "UPDATE users SET is_active = 0, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, userId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public List<User> findAll() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT user_id, username, password_hash, full_name, email, role, is_active, created_at, updated_at,phone FROM users";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                User u = getFromResultSet(resultSet);
                list.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return list;
    }

    @Override
    public boolean delete(User user) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, user.getUserId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public int insert(User user) {
        String sql = "INSERT INTO users (username, password_hash, full_name, role, email, is_active, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, user.getUsername());
            statement.setString(2, user.getPasswordHash());
            statement.setString(3, user.getFullName());
            statement.setString(4, user.getRoleId());
            statement.setString(5, user.getEmail());
            statement.setBoolean(6, user.isActive());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                return -1;
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                return -1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public User getFromResultSet(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setRoleId(rs.getString("role"));
        u.setEmail(rs.getString("email"));
        u.setActive(rs.getBoolean("is_active"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        u.setPhone(rs.getString("phone"));
        return u;
    }

    @Override
    public User findById(Integer id) {
        String sql = "SELECT user_id, username, password_hash, full_name, role, email, is_active, created_at, updated_at,phone FROM users WHERE user_id = ?";
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
    public List<User> findAll(String keyword, String sort) {
        List<User> result = new ArrayList<>();
        String baseQuery = "SELECT * FROM users WHERE (username LIKE ? OR full_name LIKE ? OR email LIKE ?)";

        String orderBy = "";
        switch (sort) {
            case "username_asc":
                orderBy = " ORDER BY username ASC";
                break;
            case "username_desc":
                orderBy = " ORDER BY username DESC";
                break;
            case "created_asc":
                orderBy = " ORDER BY created_at ASC";
                break;
            case "created_desc":
                orderBy = " ORDER BY created_at DESC";
                break;
        }

        String sql = baseQuery + orderBy;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String likeKeyword = "%" + keyword + "%";
            ps.setString(1, likeKeyword);
            ps.setString(2, likeKeyword);
            ps.setString(3, likeKeyword);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
                user.setRoleId(rs.getString("role_id"));
                user.setActive(rs.getBoolean("is_active"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                result.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    public boolean resetPassword(int userId, String hashedPassword) {
        String sql = "UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, "123");
            statement.setInt(2, userId);
            int rows = statement.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

}
