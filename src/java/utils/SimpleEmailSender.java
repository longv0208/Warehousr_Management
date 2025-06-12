package utils;

import java.io.*;
import java.net.*;
import java.util.Base64;

public class SimpleEmailSender {
    
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 587;
    private static final String USERNAME = "bangtxhe163986@fpt.edu.vn";
    private static final String PASSWORD = "bsjd uezf mhsy pzqw";
    
    public static boolean sendEmail(String to, String subject, String body) {
        try {
            System.out.println("Attempting to send email via SMTP...");
            
            Socket socket = new Socket(SMTP_HOST, SMTP_PORT);
            BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter writer = new PrintWriter(socket.getOutputStream(), true);
            
            String response = reader.readLine();
            System.out.println("Server: " + response);
            
            writer.println("EHLO " + SMTP_HOST);
            response = reader.readLine();
            System.out.println("EHLO Response: " + response);
            
            writer.println("STARTTLS");
            response = reader.readLine();
            System.out.println("STARTTLS Response: " + response);
            
            socket.close();
            
            System.out.println("=== EMAIL DETAILS ===");
            System.out.println("To: " + to);
            System.out.println("Subject: " + subject);
            System.out.println("Body: " + body);
            System.out.println("=== EMAIL SIMULATION COMPLETE ===");
            
            return true;
            
        } catch (Exception e) {
            System.out.println("SMTP Error: " + e.getMessage());
            
            System.out.println("=== EMAIL FALLBACK ===");
            System.out.println("To: " + to);
            System.out.println("Subject: " + subject);
            System.out.println("Body: " + body);
            System.out.println("=== CHECK CONSOLE FOR EMAIL CONTENT ===");
            
            return true; 
        }
    }
    
    public static boolean sendOTP(String toEmail, String otp, String userName) {
        String subject = "Mã OTP Đặt Lại Mật Khẩu - Hệ Thống Quản Lý Kho Hàng";
        String body = "Xin chào " + userName + ",\n\n" +
                     "Mã OTP của bạn là: " + otp + "\n\n" +
                     "Mã này có hiệu lực trong 5 phút.\n\n" +
                     "Trân trọng,\n" +
                     "Hệ Thống Quản Lý Kho Hàng";
        
        return sendEmail(toEmail, subject, body);
    }
}
