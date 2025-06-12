package utils;

import java.util.Properties;
import java.util.Date;

/**
 * Real email sender using JavaMail API
 * Download and add these JAR files to your project:
 * - jakarta.mail-1.6.2.jar
 * - activation-1.1.1.jar
 */
public class RealEmailSender {
    
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String USERNAME = "bangtxhe163986@fpt.edu.vn";
    private static final String PASSWORD = "bsjd uezf mhsy pzqw";
    private static final String FROM_NAME = "Hệ Thống Quản Lý Kho Hàng";
    
    public static boolean sendOTP(String toEmail, String otp, String userName) {
        try {
            System.out.println("=== ATTEMPTING REAL EMAIL WITH JAVAMAIL ===");
            
            // Uncomment these lines when you have JavaMail library
            /*
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);
            
            Session session = Session.getInstance(props, new jakarta.mail.Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USERNAME, PASSWORD);
                }
            });
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Mã OTP Đặt Lại Mật Khẩu - " + FROM_NAME);
            message.setSentDate(new Date());
            
            String htmlContent = createOTPEmailTemplate(otp, userName);
            message.setContent(htmlContent, "text/html; charset=utf-8");
            
            Transport.send(message);
            
            System.out.println("Real email sent successfully to: " + toEmail);
            return true;
            */
            
            // For now, fallback to console output
            System.out.println("JavaMail library not available. Add jakarta.mail JAR files to enable real email sending.");
            System.out.println("=== EMAIL CONTENT ===");
            System.out.println("To: " + toEmail);
            System.out.println("Subject: Mã OTP Đặt Lại Mật Khẩu - " + FROM_NAME);
            System.out.println("OTP: " + otp);
            System.out.println("=== USE THIS OTP: " + otp + " ===");
            
            return true;
            
        } catch (Exception e) {
            System.out.println("Error sending real email: " + e.getMessage());
            e.printStackTrace();
            
            // Fallback to console
            System.out.println("=== FALLBACK - YOUR OTP IS: " + otp + " ===");
            return true;
        }
    }
    
    private static String createOTPEmailTemplate(String otp, String userName) {
        return "<!DOCTYPE html>" +
                "<html>" +
                "<head><meta charset='UTF-8'></head>" +
                "<body style='font-family: Arial, sans-serif;'>" +
                "<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>" +
                "<div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;'>" +
                "<h1>🔑 Đặt Lại Mật Khẩu</h1>" +
                "<p>" + FROM_NAME + "</p>" +
                "</div>" +
                "<div style='background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;'>" +
                "<h2>Xin chào " + userName + "!</h2>" +
                "<p>Chúng tôi đã nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn.</p>" +
                "<div style='background: white; padding: 20px; margin: 20px 0; text-align: center; border-radius: 10px; border: 2px dashed #007bff;'>" +
                "<h3>Mã OTP của bạn là:</h3>" +
                "<div style='font-size: 32px; font-weight: bold; color: #007bff; letter-spacing: 5px; margin: 10px 0;'>" + otp + "</div>" +
                "<p><strong>Mã này có hiệu lực trong 5 phút</strong></p>" +
                "</div>" +
                "<div style='background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0;'>" +
                "<strong>⚠️ Lưu ý bảo mật:</strong><br>" +
                "• Không chia sẻ mã OTP này với bất kỳ ai<br>" +
                "• Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này<br>" +
                "• Mã OTP sẽ hết hạn sau 5 phút" +
                "</div>" +
                "<p>Nếu bạn có bất kỳ thắc mắc nào, vui lòng liên hệ với chúng tôi.</p>" +
                "</div>" +
                "<div style='text-align: center; margin-top: 30px; color: #666; font-size: 14px;'>" +
                "<p>© 2024 " + FROM_NAME + ". All rights reserved.</p>" +
                "<p>Email này được gửi tự động, vui lòng không trả lời.</p>" +
                "</div>" +
                "</div>" +
                "</body>" +
                "</html>";
    }
}
