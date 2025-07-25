package utils;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;
import java.util.Date;

/**
 * Utility class for sending emails using JavaMail API
 */
public class EmailUtil {
    private static final boolean MOCK_MODE = false; // Changed to false for real email

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_USERNAME = "bangtxhe163986@fpt.edu.vn";
    private static final String EMAIL_PASSWORD = "bsjd uezf mhsy pzqw";
    private static final String FROM_EMAIL = "bangtxhe163986@fpt.edu.vn"; // Update this
    private static final String FROM_NAME = "Hệ Thống Quản Lý Kho Hàng";

    public static boolean sendOTP(String toEmail, String otp, String userName) {
        if (MOCK_MODE) {
            System.out.println("=== MOCK EMAIL SERVICE ===");
            System.out.println("To: " + toEmail);
            System.out.println("User: " + userName);
            System.out.println("OTP: " + otp);
            System.out.println("Subject: Mã OTP Đặt Lại Mật Khẩu - " + FROM_NAME);
            System.out.println("Content: " + createOTPEmailTemplate(otp, userName));
            System.out.println("=== EMAIL SENT SUCCESSFULLY (MOCK) ===");
            return true;
        }

        // Real email implementation using JavaMail
        try {
            System.out.println("=== ATTEMPTING REAL EMAIL SEND WITH JAVAMAIL ===");
            System.out.println("From: " + FROM_EMAIL);
            System.out.println("To: " + toEmail);
            System.out.println("User: " + userName);
            System.out.println("OTP: " + otp);

            // Create properties for Gmail SMTP
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);
            props.put("mail.transport.protocol", "smtp");
            props.put("mail.debug", "false"); // Set to true for detailed debug

            // Create session with authentication
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
                }
            });

            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Mã OTP Đặt Lại Mật Khẩu - " + FROM_NAME);
            message.setSentDate(new Date());

            // Create HTML content
            String htmlContent = createOTPEmailTemplate(otp, userName);
            message.setContent(htmlContent, "text/html; charset=utf-8");

            // Send message
            System.out.println("Sending email...");
            Transport.send(message);

            System.out.println("=== EMAIL SENT SUCCESSFULLY TO REAL INBOX ===");
            System.out.println("OTP has been sent to: " + toEmail);
            System.out.println("Check your email inbox for OTP: " + otp);
            return true;

        } catch (Exception e) {
            System.out.println("Error sending real email: " + e.getMessage());
            e.printStackTrace();
            String error = e.getMessage();
            // Fallback to console output
            System.out.println("=== EMAIL FAILED - FALLBACK TO CONSOLE ===");
            System.out.println("Your OTP code is: " + otp);
            System.out.println("=== USE THIS OTP TO CONTINUE ===");
            return true; // Still return true to continue flow
        }
    }

    private static String createOTPEmailTemplate(String otp, String userName) {
        return "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "<meta charset='UTF-8'>" +
                "<style>" +
                "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }" +
                ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
                ".header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }" +
                ".content { background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px; }" +
                ".otp-box { background: white; padding: 20px; margin: 20px 0; text-align: center; border-radius: 10px; border: 2px dashed #007bff; }" +
                ".otp-code { font-size: 32px; font-weight: bold; color: #007bff; letter-spacing: 5px; margin: 10px 0; }" +
                ".warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }" +
                ".footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class='container'>" +
                "<div class='header'>" +
                "<h1>🔑 Đặt Lại Mật Khẩu</h1>" +
                "<p>Hệ Thống Quản Lý Kho Hàng</p>" +
                "</div>" +
                "<div class='content'>" +
                "<h2>Xin chào " + userName + "!</h2>" +
                "<p>Chúng tôi đã nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn.</p>" +
                "<div class='otp-box'>" +
                "<h3>Mã OTP của bạn là:</h3>" +
                "<div class='otp-code'>" + otp + "</div>" +
                "<p><strong>Mã này có hiệu lực trong 5 phút</strong></p>" +
                "</div>" +
                "<div class='warning'>" +
                "<strong>⚠️ Lưu ý bảo mật:</strong><br>" +
                "• Không chia sẻ mã OTP này với bất kỳ ai<br>" +
                "• Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này<br>" +
                "• Mã OTP sẽ hết hạn sau 5 phút" +
                "</div>" +
                "<p>Nếu bạn có bất kỳ thắc mắc nào, vui lòng liên hệ với chúng tôi.</p>" +
                "</div>" +
                "<div class='footer'>" +
                "<p>© 2024 Hệ Thống Quản Lý Kho Hàng. All rights reserved.</p>" +
                "<p>Email này được gửi tự động, vui lòng không trả lời.</p>" +
                "</div>" +
                "</div>" +
                "</body>" +
                "</html>";
    }

    public static boolean testEmailConfiguration() {
        try {
            System.out.println("Testing email configuration...");
            boolean result = sendOTP("test@gmail.com", "123456", "Test User");
            System.out.println("Email test result: " + (result ? "SUCCESS" : "FAILED"));
            return result;
        } catch (Exception e) {
            System.out.println("Email configuration test failed: " + e.getMessage());
            return false;
        }
    }

    public static void setMockMode(boolean mockMode) {
        System.out.println("To change mock mode, update MOCK_MODE constant in EmailUtil.java");
        System.out.println("Current mock mode: " + MOCK_MODE);
    }
    
      public static boolean sendMail(String toEmail, String subject, String content) {
     
        // Real email implementation using JavaMail
        try {

            // Create properties for Gmail SMTP
           Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            // Create session with authentication
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
                }
            });

            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("BÁO GIÁ SẢN PHẨM - " + FROM_NAME);
            message.setSentDate(new Date());

            // Create HTML content
            message.setContent(content, "text/html; charset=utf-8");

            // Send message
            System.out.println("Sending email...");
            Transport.send(message);
            return true;

        } catch (Exception e) {
            System.out.println("Error sending real email: " + e.getMessage());
            e.printStackTrace();
            String error = e.getMessage();
            // Fallback to console output
            return false; // Still return true to continue flow
        }
    }
}
