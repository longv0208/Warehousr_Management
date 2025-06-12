package controller.authen;

import dao.UserDAO;
import model.User;
import utils.EmailUtil;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Random;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

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
                handleShowForgotPasswordForm(request, response);
                break;
            default:
                handleShowForgotPasswordForm(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "sendOTP";
        }

        switch (action) {
            case "sendOTP":
                handleSendOTP(request, response);
                break;
            default:
                SessionUtil.setErrorMessage(request, "Hành động không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/forgot-password");
                break;
        }
    }

    private void handleShowForgotPasswordForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/view/authen/forgot-password.jsp").forward(request, response);
    }

    private void handleSendOTP(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Validate email input
        if (!validateEmailInput(request, response)) {
            return;
        }

        String email = request.getParameter("email").trim();

        // Find user by email
        User user = findUserByEmail(request, response, email);
        if (user == null) {
            return;
        }

        // Generate and store OTP in session
        String otp = generateOTP();
        storeOTPInSession(request, email, user.getUserId(), otp);

        // Send OTP email
        sendOTPEmail(request, response, email, otp, user.getFullName());
    }

    private boolean validateEmailInput(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            SessionUtil.setErrorMessage(request, "Vui lòng nhập địa chỉ email");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return false;
        }

        if (!isValidEmail(email.trim())) {
            SessionUtil.setErrorMessage(request, "Định dạng email không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return false;
        }

        return true;
    }

    private User findUserByEmail(HttpServletRequest request, HttpServletResponse response, String email)
            throws IOException {

        try {
            User user = userDAO.findByEmail(email);
            if (user == null) {
                SessionUtil.setErrorMessage(request, "Email không tồn tại trong hệ thống");
                response.sendRedirect(request.getContextPath() + "/forgot-password");
                return null;
            }
            return user;
        } catch (Exception e) {
            e.printStackTrace();
            SessionUtil.setErrorMessage(request, "Có lỗi xảy ra khi tìm kiếm thông tin người dùng");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return null;
        }
    }

    private void storeOTPInSession(HttpServletRequest request, String email, int userId, String otp) {
        HttpSession session = request.getSession();
        session.setAttribute("resetOTP", otp);
        session.setAttribute("resetEmail", email);
        session.setAttribute("resetUserId", userId);
        session.setAttribute("otpGeneratedTime", System.currentTimeMillis());
    }

    private void sendOTPEmail(HttpServletRequest request, HttpServletResponse response, 
                            String email, String otp, String fullName) throws IOException {

        try {
            boolean emailSent = EmailUtil.sendOTP(email, otp, fullName);
            if (emailSent) {
                SessionUtil.setSuccessMessage(request, "Mã OTP đã được gửi đến email của bạn");
                response.sendRedirect(request.getContextPath() + "/verify-otp");
            } else {
                SessionUtil.setErrorMessage(request, "Có lỗi xảy ra khi gửi email. Vui lòng thử lại");
                response.sendRedirect(request.getContextPath() + "/forgot-password");
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionUtil.setErrorMessage(request, "Có lỗi xảy ra trong hệ thống khi gửi email");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
        }
    }

    private String generateOTP() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    private boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        return email.matches(emailRegex);
    }
}
