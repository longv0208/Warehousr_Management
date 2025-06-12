package controller.profile;

import dao.UserDAO;
import model.User;
import model.Role;
import utils.PasswordUtil;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "view";
        }

        switch (action) {
            case "view":
                handleViewProfile(request, response);
                break;
            case "edit":
                handleEditProfile(request, response);
                break;
            default:
                handleViewProfile(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            SessionUtil.setErrorMessage(request, "Hành động không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        switch (action) {
            case "updateProfile":
                handleUpdateProfile(request, response);
                break;
            case "changePassword":
                handleChangePassword(request, response);
                break;
            default:
                SessionUtil.setErrorMessage(request, "Hành động không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/profile");
                break;
        }
    }

    private void handleViewProfile(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            SessionUtil.setErrorMessage(request, "Vui lòng đăng nhập để xem profile");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = userDAO.getUserById(currentUser.getUserId());
        if (user == null) {
            SessionUtil.setErrorMessage(request, "Không tìm thấy thông tin người dùng");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("user", user);
        request.getRequestDispatcher("/view/profile/profile.jsp").forward(request, response);
    }

    private void handleEditProfile(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            SessionUtil.setErrorMessage(request, "Vui lòng đăng nhập để chỉnh sửa profile");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = userDAO.getUserById(currentUser.getUserId());
        if (user == null) {
            SessionUtil.setErrorMessage(request, "Không tìm thấy thông tin người dùng");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/edit-profile.jsp").forward(request, response);
    }

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            SessionUtil.setErrorMessage(request, "Vui lòng đăng nhập để cập nhật profile");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String roleStr = request.getParameter("role");

        if (fullName == null || fullName.trim().isEmpty()) {
            SessionUtil.setErrorMessage(request, "Vui lòng nhập họ tên");
            response.sendRedirect(request.getContextPath() + "/profile?action=edit");
            return;
        }

        try {
            //Role role = Role.fromString(roleStr);
            currentUser.setFullName(fullName.trim());
            currentUser.setPhone(phone);
            //currentUser.setRoleId(role.getRoleName());
            boolean success = userDAO.update(currentUser);

            if (success) {
                SessionUtil.setUserInSession(request, currentUser);
                SessionUtil.setSuccessMessage(request, "Cập nhật thông tin thành công");
                response.sendRedirect(request.getContextPath() + "/profile");
            } else {
                SessionUtil.setErrorMessage(request, "Có lỗi xảy ra khi cập nhật thông tin");
                response.sendRedirect(request.getContextPath() + "/profile?action=edit");
            }

        } catch (IllegalArgumentException e) {
            SessionUtil.setErrorMessage(request, "Vai trò không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/profile?action=edit");
        } catch (Exception e) {
            e.printStackTrace();
            SessionUtil.setErrorMessage(request, "Có lỗi xảy ra khi cập nhật thông tin");
            response.sendRedirect(request.getContextPath() + "/profile?action=edit");
        }
    }

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            SessionUtil.setErrorMessage(request, "Vui lòng đăng nhập để đổi mật khẩu");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (currentPassword == null || currentPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {

            SessionUtil.setErrorMessage(request, "Vui lòng điền đầy đủ thông tin mật khẩu");
            response.sendRedirect(request.getContextPath() + "/profile?action=edit");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            SessionUtil.setErrorMessage(request, "Mật khẩu mới xác nhận không khớp");
            response.sendRedirect(request.getContextPath() + "/profile?action=edit");
            return;
        }

        if (!PasswordUtil.isValidPassword(newPassword)) {
            SessionUtil.setErrorMessage(request, "Mật khẩu mới phải có ít nhất 6 ký tự, bao gồm chữ và số");
            response.sendRedirect(request.getContextPath() + "/profile?action=edit");
            return;
        }

        try {
            if (!PasswordUtil.verifyPassword(currentPassword, currentUser.getPasswordHash())) {
                SessionUtil.setErrorMessage(request, "Mật khẩu hiện tại không chính xác");
                response.sendRedirect(request.getContextPath() + "/profile?action=edit");
                return;
            }
            String newHashedPassword = PasswordUtil.hashPassword(newPassword);
            boolean success = userDAO.updatePassword(currentUser.getUserId(), newHashedPassword);

            if (success) {
                SessionUtil.setSuccessMessage(request, "Đổi mật khẩu thành công");
                response.sendRedirect(request.getContextPath() + "/profile");
            } else {
                SessionUtil.setErrorMessage(request, "Có lỗi xảy ra khi đổi mật khẩu");
                response.sendRedirect(request.getContextPath() + "/profile?action=edit");
            }

        } catch (Exception e) {
            e.printStackTrace();
            SessionUtil.setErrorMessage(request, "Có lỗi xảy ra khi đổi mật khẩu");
            response.sendRedirect(request.getContextPath() + "/profile?action=edit");
        }
    }
}
