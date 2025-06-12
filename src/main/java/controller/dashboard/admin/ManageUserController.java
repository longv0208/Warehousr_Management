package controller.dashboard.admin;

import dao.RoleDAO;
import dao.UserDAO;
import model.Role;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.*;
import java.util.stream.Collectors;
import utils.PasswordUtil;

@WebServlet(name = "UserServlet", urlPatterns = {
        "/UserServlet",
        "/UserServlet/AddUserServlet",
        "/UserServlet/EditUserServlet",
        "/UserServlet/InactiveUserServlet",
        "/UserServlet/ResetPasswordServlet"
})
public class ManageUserController extends HttpServlet {

    private UserDAO userDAO;
    private RoleDAO roleDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
        roleDAO = new RoleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/UserServlet":
                    listUsers(req, resp);
                    break;
                case "/UserServlet/AddUserServlet":
                    showUserForm(req, resp, null);
                    break;
                case "/UserServlet/EditUserServlet":
                    showEditForm(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/UserServlet");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Lỗi hệ thống.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/UserServlet/AddUserServlet":
                    addUser(req, resp);
                    break;
                case "/UserServlet/EditUserServlet":
                    editUser(req, resp);
                    break;
                case "/UserServlet/InactiveUserServlet":
                    inactiveUser(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/UserServlet");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Lỗi xử lý dữ liệu.");
        }
    }

    private void listUsers(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        String keyword = req.getParameter("keyword");
        String sort = req.getParameter("sort");
        int page = req.getParameter("page") != null ? Integer.parseInt(req.getParameter("page")) : 1;
        int pageSize = 10;

        List<User> userList = userDAO.findAll();
        List<Role> roleList = roleDAO.getAllRoles();

        if (keyword != null && !keyword.trim().isEmpty()) {
            String keywordLower = keyword.toLowerCase();
            userList = userList.stream()
                    .filter(u -> u.getUsername().toLowerCase().contains(keywordLower)
                            || u.getEmail().toLowerCase().contains(keywordLower)
                            || u.getFullName().toLowerCase().contains(keywordLower))
                    .collect(Collectors.toList());
        }

        if (sort != null) {
            switch (sort) {
                case "username_asc":
                    userList.sort(Comparator.comparing(User::getUsername, String.CASE_INSENSITIVE_ORDER));
                    break;
                case "username_desc":
                    userList.sort(Comparator.comparing(User::getUsername, String.CASE_INSENSITIVE_ORDER).reversed());
                    break;
                case "created_asc":
                    userList.sort(Comparator.comparing(User::getCreatedAt));
                    break;
                case "created_desc":
                    userList.sort(Comparator.comparing(User::getCreatedAt).reversed());
                    break;
            }
        }

        int totalUsers = userList.size();
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);
        int fromIndex = Math.min((page - 1) * pageSize, totalUsers);
        int toIndex = Math.min(fromIndex + pageSize, totalUsers);
        List<User> pagedUsers = userList.subList(fromIndex, toIndex);

        req.setAttribute("userList", pagedUsers);
        req.setAttribute("roleList", roleList);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("keyword", keyword);
        req.setAttribute("sort", sort);
        req.getRequestDispatcher("/view/dashboard/admin/manageUser/ManageUser.jsp").forward(req, resp);
    }

    private void showUserForm(HttpServletRequest req, HttpServletResponse resp, String errorMessage) throws ServletException, IOException, SQLException {
        List<Role> roleList = roleDAO.getAllRoles();
        req.setAttribute("roleList", roleList);
        if (errorMessage != null) req.setAttribute("error", errorMessage);
        req.getRequestDispatcher("/view/dashboard/admin/manageUser/AddUser.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        String param = req.getParameter("userId");
        if (param == null) {
            resp.sendRedirect(req.getContextPath() + "/UserServlet");
            return;
        }

        int userId = Integer.parseInt(param);
        User user = userDAO.getUserById(userId);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/UserServlet");
            return;
        }

        List<Role> roleList = roleDAO.getAllRoles();
        req.setAttribute("user", user);
        req.setAttribute("roleList", roleList);
        req.getRequestDispatcher("/view/dashboard/admin/manageUser/EditUser.jsp").forward(req, resp);
    }

    private void addUser(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, NoSuchAlgorithmException, SQLException {
    String username = req.getParameter("username");
    String password = req.getParameter("password");
    String fullName = req.getParameter("fullName");
    String email = req.getParameter("email");
    String phone = req.getParameter("phone");
    String roleId = req.getParameter("roleId");

    if (password == null || password.isEmpty()) {
        showUserForm(req, resp, "Mật khẩu không được để trống!");
        return;
    }

    if (!PasswordUtil.isValidPassword(password)) {
        showUserForm(req, resp, "Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ và số!");
        return;
    }

    String hashedPassword = PasswordUtil.hashPassword(password); // hash mật khẩu

    Timestamp now = new Timestamp(System.currentTimeMillis());

    User user = User.builder()
            .username(username)
            .passwordHash(hashedPassword)
            .fullName(fullName)
            .email(email)
            .phone(phone)
            .roleId(roleId)
            .isActive(true)
            .createdAt(now)
            .updatedAt(now)
            .build();

    boolean success = userDAO.add(user);

    if (success) {
        resp.sendRedirect(req.getContextPath() + "/UserServlet");
    } else {
        showUserForm(req, resp, "Username đã tồn tại.");
    }
}


    private void editUser(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
    int userId = Integer.parseInt(req.getParameter("userId"));
    User user = userDAO.getUserById(userId);
    if (user == null) {
        resp.sendRedirect(req.getContextPath() + "/UserServlet");
        return;
    }

    user.setFullName(req.getParameter("fullName"));
    user.setEmail(req.getParameter("email"));
    user.setPhone(req.getParameter("phone"));
    user.setRoleId(req.getParameter("roleId"));
    user.setActive("true".equals(req.getParameter("isActive")));
    user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

 
    String resetPassword = req.getParameter("resetPassword");
    if ("true".equals(resetPassword)) {

        String defaultPassword = "123456";
        String hashedPassword = PasswordUtil.hashPassword(defaultPassword); 
        boolean resetSuccess = userDAO.resetPassword(userId, hashedPassword);
        if (!resetSuccess) {
            req.setAttribute("error", "Đặt lại mật khẩu thất bại.");
            listUsers(req, resp);
            return;
        }
    }

    boolean success = userDAO.update(user);
    if (success) {
        resp.sendRedirect(req.getContextPath() + "/UserServlet");
    } else {
        req.setAttribute("error", "Cập nhật thất bại.");
        listUsers(req, resp);
    }
}

    private void inactiveUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = Integer.parseInt(req.getParameter("userId"));
        boolean success = userDAO.inactive(userId);
        HttpSession session = req.getSession();
        session.setAttribute("message", success ? "Vô hiệu hóa thành công." : "Không thể vô hiệu hóa.");
        resp.sendRedirect(req.getContextPath() + "/UserServlet");
    }

}
