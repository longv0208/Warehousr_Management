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

@WebServlet(name = "ManageUserController", urlPatterns = {
        "/admin/manage-user",
        "/UserServlet",
        "/UserServlet/AddUserServlet",
        "/UserServlet/EditUserServlet", 
        "/UserServlet/InactiveUserServlet"
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
                case "/admin/manage-user":
                    listUsers(req, resp);
                    break;
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
                    resp.sendRedirect(req.getContextPath() + "/admin/manage-user");
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
                    resp.sendRedirect(req.getContextPath() + "/admin/manage-user");
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
        HttpSession session = req.getSession(false);
        if (session != null) {
            String successMsg = (String) session.getAttribute("success");
            if (successMsg != null) {
                req.setAttribute("success", successMsg);
                session.removeAttribute("success");
            }
            String message = (String) session.getAttribute("message");
            if (message != null) {
                req.setAttribute("message", message);
                session.removeAttribute("message");
            }
        }
        req.getRequestDispatcher("/view/dashboard/admin/manageUser/ManageUser.jsp").forward(req, resp);
    }

    private void showUserForm(HttpServletRequest req, HttpServletResponse resp, String errorMessage) throws ServletException, IOException, SQLException {
        List<Role> roleList = roleDAO.getAllRoles();
        req.setAttribute("roleList", roleList);
        req.setAttribute("showAddForm", true);
        if (errorMessage != null) req.setAttribute("error", errorMessage);
        req.getRequestDispatcher("/view/dashboard/admin/manageUser/ManageUser.jsp").forward(req, resp);
    }

    private void showUserFormWithError(HttpServletRequest req, HttpServletResponse resp, String errorMessage) throws ServletException, IOException, SQLException {
        List<Role> roleList = roleDAO.getAllRoles();
        req.setAttribute("roleList", roleList);
        req.setAttribute("showAddForm", true);
        req.setAttribute("error", errorMessage);
        req.getRequestDispatcher("/view/dashboard/admin/manageUser/ManageUser.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        String param = req.getParameter("userId");
        if (param == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/manage-user");
            return;
        }

        int userId = Integer.parseInt(param);
        User user = userDAO.getUserById(userId);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/manage-user");
            return;
        }

        List<Role> roleList = roleDAO.getAllRoles();
        req.setAttribute("user", user);
        req.setAttribute("roleList", roleList);
        req.setAttribute("showEditForm", true);
        req.getRequestDispatcher("/view/dashboard/admin/manageUser/ManageUser.jsp").forward(req, resp);
    }

    private void showEditFormWithError(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException, SQLException {
        List<Role> roleList = roleDAO.getAllRoles();
        req.setAttribute("user", user);
        req.setAttribute("roleList", roleList);
        req.setAttribute("showEditForm", true);
        req.getRequestDispatcher("/view/dashboard/admin/manageUser/ManageUser.jsp").forward(req, resp);
    }

    private void addUser(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, NoSuchAlgorithmException, SQLException {
    String username = req.getParameter("username");
    String password = req.getParameter("password");
    String fullName = req.getParameter("fullName");
    String email = req.getParameter("email");
    String phone = req.getParameter("phone");
    String roleId = req.getParameter("roleId");

    // Preserve form data
    req.setAttribute("formUsername", username);
    req.setAttribute("formFullName", fullName);
    req.setAttribute("formEmail", email);
    req.setAttribute("formPhone", phone);
    req.setAttribute("formRoleId", roleId);

    if (password == null || password.isEmpty()) {
        showUserFormWithError(req, resp, "Mật khẩu không được để trống!");
        return;
    }

    if (!PasswordUtil.isValidPassword(password)) {
        showUserFormWithError(req, resp, "Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ và số!");
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

    HttpSession session = req.getSession();
    if (success) {
        session.setAttribute("toastMessage", "Thêm người dùng thành công.");
        session.setAttribute("toastType", "success");
        resp.sendRedirect(req.getContextPath() + "/admin/manage-user");
    } else {
        showUserFormWithError(req, resp, "Username đã tồn tại.");
    }
}


    private void editUser(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
    int userId = Integer.parseInt(req.getParameter("userId"));
    User user = userDAO.getUserById(userId);
    if (user == null) {
        resp.sendRedirect(req.getContextPath() + "/admin/manage-user");
        return;
    }

    // Preserve form data
    req.setAttribute("formFullName", req.getParameter("fullName"));
    req.setAttribute("formEmail", req.getParameter("email"));
    req.setAttribute("formPhone", req.getParameter("phone"));
    req.setAttribute("formRoleId", req.getParameter("roleId"));
    req.setAttribute("formIsActive", req.getParameter("isActive"));

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
            showEditFormWithError(req, resp, user);
            return;
        }
    }

    boolean success = userDAO.update(user);
    HttpSession session = req.getSession();
    if (success) {
        session.setAttribute("toastMessage", "Cập nhật người dùng thành công.");
        session.setAttribute("toastType", "success");
        resp.sendRedirect(req.getContextPath() + "/admin/manage-user");
    } else {
        req.setAttribute("error", "Cập nhật thất bại.");
        showEditFormWithError(req, resp, user);
    }
}

    private void inactiveUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = Integer.parseInt(req.getParameter("userId"));
        boolean success = userDAO.inactive(userId);
        HttpSession session = req.getSession();
        session.setAttribute("toastMessage", success ? "Vô hiệu hóa thành công." : "Không thể vô hiệu hóa.");
        session.setAttribute("toastType", success ? "success" : "error");
        resp.sendRedirect(req.getContextPath() + "/admin/manage-user");
    }

}
