package model;

public class Role {
    private String roleId;
    private String roleName; 

    public String getRoleId() {
        return roleId;
    }
    public void setRoleId(String roleId) {
        this.roleId = roleId;
    }
    public String getRoleName() {
        return roleName;
    }
    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public static Role fromString(String roleId) {
        if (roleId == null || roleId.trim().isEmpty()) {
            throw new IllegalArgumentException("roleId không được để trống");
        }

        Role role = new Role();
        switch (roleId.trim().toLowerCase()) {
            case "admin":
                role.setRoleId("admin");
                role.setRoleName("Administrator");
                break;
            case "warehouse_manager":
                role.setRoleId("warehouse_manager");
                role.setRoleName("Warehouse Manager");
                break;
            case "purchasing_staff":
                role.setRoleId("purchasing_staff");
                role.setRoleName("Purchasing Staff");
                break;
            case "warehouse_staff":
                role.setRoleId("warehouse_staff");
                role.setRoleName("Warehouse Staff");
                break;
            case "sale_staff":
                role.setRoleId("sale_staff");
                role.setRoleName("Sale Staff");
                break;
            default:
                throw new IllegalArgumentException("Vai trò không hợp lệ: " + roleId);
        }
        return role;
    }
}
