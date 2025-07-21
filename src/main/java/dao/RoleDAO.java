package dao;

import context.DBContext;
import model.Role;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO extends DBContext implements I_DAO<Role> {

    public List<Role> getAllRoles() throws SQLException {
        List<Role> roles = new ArrayList<>();
        
        // Since roles are stored as enum in users table, we'll return predefined roles
        // that match the database enum values: 'admin','warehouse_staff','sales_staff','purchasing_staff'
        String[] roleIds = {"admin", "warehouse_staff", "sales_staff", "purchasing_staff", "warehouse_manager"};
        String[] roleNames = {"Administrator", "Warehouse Staff", "Sales Staff", "Purchasing Staff", "Warehouse Manager"};
        
        for (int i = 0; i < roleIds.length; i++) {
            Role role = new Role();
            role.setRoleId(roleIds[i]);
            role.setRoleName(roleNames[i]);
            roles.add(role);
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
        // Since roles are enum values, they cannot be updated in database
        // This operation is not supported for enum-based roles
        return false;
    }

    @Override
    public boolean delete(Role t) {
        // Since roles are enum values, they cannot be deleted from database
        // This operation is not supported for enum-based roles
        return false;
    }

    @Override
    public int insert(Role t) {
        // Since roles are enum values, they cannot be inserted into database
        // This operation is not supported for enum-based roles
        return 0;
    }

    @Override
    public Role getFromResultSet(ResultSet rs) throws SQLException {
        Role role = new Role();
        role.setRoleId(rs.getString("role"));
        
        // Map enum values to display names
        String roleId = rs.getString("role");
        switch (roleId) {
            case "admin":
                role.setRoleName("Administrator");
                break;
            case "warehouse_staff":
                role.setRoleName("Warehouse Staff");
                break;
            case "sales_staff":
                role.setRoleName("Sales Staff");
                break;
            case "purchasing_staff":
                role.setRoleName("Purchasing Staff");
                break;
            default:
                role.setRoleName(roleId);
                break;
        }
        
        return role;
    }

    @Override
    public Role findById(Integer id) {
        // Không dùng vì roleId là String, dùng findById(String roleId) riêng
        throw new UnsupportedOperationException("Dùng findById(String roleId) thay vì Integer");
    }

    // Viết thêm phương thức tìm theo roleId (string)
    public Role findById(String roleId) {
        if (roleId == null || roleId.trim().isEmpty()) {
            return null;
        }
        
        Role role = new Role();
        role.setRoleId(roleId);
        
        // Map enum values to display names
        switch (roleId.toLowerCase()) {
            case "admin":
                role.setRoleName("Administrator");
                break;
            case "warehouse_staff":
                role.setRoleName("Warehouse Staff");
                break;
            case "sales_staff":
                role.setRoleName("Sales Staff");
                break;
            case "purchasing_staff":
                role.setRoleName("Purchasing Staff");
                break;
            default:
                return null; // Invalid role
        }
        
        return role;
    }
    
    /**
     * Get all distinct roles currently used in the users table
     */
    public List<Role> getUsedRoles() throws SQLException {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT DISTINCT role FROM users WHERE is_active = 1";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Role role = getFromResultSet(rs);
                roles.add(role);
            }
        }

        return roles;
    }
}
