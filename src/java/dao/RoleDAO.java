package dao;

import context.DBContext;
import model.Role;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO extends DBContext implements I_DAO<Role> {

    public List<Role> getAllRoles() throws SQLException {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT role_id, role_name FROM Roles";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getString("role_id"));
                role.setRoleName(rs.getString("role_name"));
                roles.add(role);
            }
        }

        return roles;
    }

    @Override
    public List<Role> findAll() {
        try {
            return getAllRoles();
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Override
    public boolean update(Role t) {
        String sql = "UPDATE Roles SET role_name = ? WHERE role_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, t.getRoleName());
            stmt.setString(2, t.getRoleId());
            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(Role t) {
        String sql = "DELETE FROM Roles WHERE role_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, t.getRoleId());
            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public int insert(Role t) {
        String sql = "INSERT INTO Roles(role_id, role_name) VALUES (?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, t.getRoleId());
            stmt.setString(2, t.getRoleName());
            return stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Role getFromResultSet(ResultSet rs) throws SQLException {
        Role role = new Role();
        role.setRoleId(rs.getString("role_id"));
        role.setRoleName(rs.getString("role_name"));
        return role;
    }

    @Override
    public Role findById(Integer id) {
        // Không dùng vì roleId là String, dùng findById(String roleId) riêng
        throw new UnsupportedOperationException("Dùng findById(String roleId) thay vì Integer");
    }

    // Viết thêm phương thức tìm theo roleId (string)
    public Role findById(String roleId) {
        String sql = "SELECT role_id, role_name FROM Roles WHERE role_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, roleId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return getFromResultSet(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
