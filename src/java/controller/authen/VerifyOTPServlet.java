package controller.authen;

import utils.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "VerifyOTPServlet", urlPatterns = {"/verify-otp"})
public class VerifyOTPServlet extends HttpServlet {

    private static final long OTP_VALIDITY_DURATION = 5 * 60 * 1000; // 5 minutes

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "form";
        }

        switch (action) {
            case "form":
                handleShowOTPForm(request, response);
                break;
            case "resend":
                handleResendOTP(request, response);
                break;
            default:
                handleShowOTPForm(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "verify";
        }

        switch (action) {
            case "verify":
                handleVerifyOTP(request, response);
                break;
            default:
                SessionUtil.setErrorMessage(request, "Hành động không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/verify-otp");
                break;
        }
    }

    private void handleShowOTPForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Validate session has reset email
        if (!validateOTPSession(request, response)) {
            return;
        }

        request.getRequestDispatcher("/view/authen/verify-otp.jsp").forward(request, response);
    }

    private void handleResendOTP(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Validate session
        if (!validateOTPSession(request, response)) {
            return;
        }

        // For now, redirect back to forgot password to resend
        SessionUtil.setErrorMessage(request, "Vui lòng yêu cầu gửi lại mã OTP");
        response.sendRedirect(request.getContextPath() + "/forgot-password");
    }

    private void handleVerifyOTP(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Validate OTP session and expiry
        if (!validateOTPSessionAndExpiry(request, response)) {
            return;
        }

        // Extract OTP from request
        String enteredOTP = extractOTPFromRequest(request);
        if (!validateOTPInput(request, response, enteredOTP)) {
            return;
        }

        // Verify OTP code
        if (!verifyOTPCode(request, response, enteredOTP)) {
            return;
        }

        // Mark OTP as verified and redirect
        markOTPAsVerified(request, response);
    }

    private boolean validateOTPSession(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        String resetEmail = (String) session.getAttribute("resetEmail");

        if (resetEmail == null) {
            SessionUtil.setErrorMessage(request, "Phiên làm việc đã hết hạn. Vui lòng thử lại");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return false;
        }

        return true;
    }

    private boolean validateOTPSessionAndExpiry(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        String storedOTP = (String) session.getAttribute("resetOTP");
        String resetEmail = (String) session.getAttribute("resetEmail");
        Long otpGeneratedTime = (Long) session.getAttribute("otpGeneratedTime");

        if (storedOTP == null || resetEmail == null || otpGeneratedTime == null) {
            SessionUtil.setErrorMessage(request, "Phiên làm việc đã hết hạn. Vui lòng thử lại");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return false;
        }

        long currentTime = System.currentTimeMillis();
        if (currentTime - otpGeneratedTime > OTP_VALIDITY_DURATION) {
            SessionUtil.setErrorMessage(request, "Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới");
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return false;
        }

        return true;
    }

    private String extractOTPFromRequest(HttpServletRequest request) {
        String enteredOTP = request.getParameter("otpCode");
        
        // If otpCode parameter is not available, try to get from individual inputs
        if (enteredOTP == null || enteredOTP.trim().isEmpty()) {
            StringBuilder otpBuilder = new StringBuilder();
            for (int i = 1; i <= 6; i++) {
                String digit = request.getParameter("otp" + i);
                if (digit != null && !digit.trim().isEmpty()) {
                    otpBuilder.append(digit.trim());
                }
            }
            enteredOTP = otpBuilder.toString();
        }
        
        return enteredOTP;
    }

    private boolean validateOTPInput(HttpServletRequest request, HttpServletResponse response, String enteredOTP)
            throws IOException {

        if (enteredOTP == null || enteredOTP.length() != 6) {
            SessionUtil.setErrorMessage(request, "Vui lòng nhập đầy đủ 6 chữ số");
            response.sendRedirect(request.getContextPath() + "/verify-otp");
            return false;
        }

        // Validate that OTP contains only digits
        if (!enteredOTP.matches("\\d{6}")) {
            SessionUtil.setErrorMessage(request, "Mã OTP chỉ được chứa số");
            response.sendRedirect(request.getContextPath() + "/verify-otp");
            return false;
        }

        return true;
    }

    private boolean verifyOTPCode(HttpServletRequest request, HttpServletResponse response, String enteredOTP)
            throws IOException {

        HttpSession session = request.getSession();
        String storedOTP = (String) session.getAttribute("resetOTP");

        if (!enteredOTP.equals(storedOTP)) {
            SessionUtil.setErrorMessage(request, "Mã OTP không chính xác. Vui lòng thử lại");
            response.sendRedirect(request.getContextPath() + "/verify-otp");
            return false;
        }

        return true;
    }

    private void markOTPAsVerified(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        session.setAttribute("otpVerified", true);
        
        SessionUtil.setSuccessMessage(request, "Xác thực thành công! Vui lòng đặt mật khẩu mới");
        response.sendRedirect(request.getContextPath() + "/reset-password");
    }
}
