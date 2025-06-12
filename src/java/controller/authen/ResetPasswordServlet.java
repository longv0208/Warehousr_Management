package controller.authen;

import dao.UserDAO;
import utils.PasswordUtil;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {

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
            action = "form";
        }

        switch (action) {
            case "form":
                handleShowResetPasswordForm(request, response);
                break;
            default:
                handleShowResetPasswordForm(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "reset";
        }

        switch (action) {
            case "reset":
                handleResetPassword(request, response);
                break;
            default:
                SessionUtil.setErrorMessage(request, "Hành động không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/reset-password");
                break;
        }
    }

    private void handleShowResetPasswordForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Validate OTP verification session
        if (!validateOTPSession(request, response)) {
            return;
        }

        request.getRequestDispatcher("/view/authen/reset-password.jsp").forward(request, response);
    }

    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Validate session and user ID
        Integer userId = validateResetSession(request, response);
        if (userId == null) {
            return;
        }

        // Validate password input
        if (!validatePasswordInput(request, response)) {
            return;
        }

        String newPassword = request.getParameter("newPassword");

        // Update password and cleanup session
        updatePasswordAndCleanup(request, response, userId, newPassword);
    }

    private boolean validateOTPSession(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        Boolean otpVerified = (Boolean) session.getAttribute("otpVerified");
        String resetEmail = (String) session.getAttribute("resetEmail");

        if (otpVerified == null || !otpVerified || resetEmail == null) {
            SessionUtil.setErrorMessage(request, "Vui lòng hoàn thành xác thực OTP trước");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return false;
        }

        return true;
    }

    private Integer validateResetSession(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        Boolean otpVerified = (Boolean) session.getAttribute("otpVerified");
        Integer userId = (Integer) session.getAttribute("resetUserId");

        if (otpVerified == null || !otpVerified || userId == null) {
            SessionUtil.setErrorMessage(request, "Phiên làm việc không hợp lệ. Vui lòng thử lại");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return null;
        }

        return userId;
    }

    private boolean validatePasswordInput(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            SessionUtil.setErrorMessage(request, "Vui lòng nhập đầy đủ thông tin");
            response.sendRedirect(request.getContextPath() + "/reset-password");
            return false;
        }

        if (!PasswordUtil.isValidPassword(newPassword)) {
            SessionUtil.setErrorMessage(request, "Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ và số");
            response.sendRedirect(request.getContextPath() + "/reset-password");
            return false;
        }

        if (!newPassword.equals(confirmPassword)) {
            SessionUtil.setErrorMessage(request, "Mật khẩu xác nhận không khớp");
            response.sendRedirect(request.getContextPath() + "/reset-password");
            return false;
        }

        return true;
    }

    private void updatePasswordAndCleanup(HttpServletRequest request, HttpServletResponse response,
                                        Integer userId, String newPassword) throws IOException {

        try {
            String hashedPassword = PasswordUtil.hashPassword(newPassword);
            boolean updated = userDAO.updatePassword(userId, hashedPassword);

            if (updated) {
                cleanupResetSession(request);
                SessionUtil.setSuccessMessage(request, "Đặt lại mật khẩu thành công! Vui lòng đăng nhập với mật khẩu mới");
                response.sendRedirect(request.getContextPath() + "/login");
            } else {
                SessionUtil.setErrorMessage(request, "Có lỗi xảy ra khi cập nhật mật khẩu. Vui lòng thử lại");
                response.sendRedirect(request.getContextPath() + "/reset-password");
            }

        } catch (Exception e) {
            System.out.println("Error in reset password: " + e.getMessage());
            e.printStackTrace();
            SessionUtil.setErrorMessage(request, "Có lỗi xảy ra trong hệ thống");
            response.sendRedirect(request.getContextPath() + "/reset-password");
        }
    }

    private void cleanupResetSession(HttpServletRequest request) {
        HttpSession session = request.getSession();
        session.removeAttribute("resetOTP");
        session.removeAttribute("resetEmail");
        session.removeAttribute("resetUserId");
        session.removeAttribute("otpVerified");
        session.removeAttribute("otpGeneratedTime");
    }
}
