package utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Scanner;

public class PasswordUtil {
    
    private static final String ALGORITHM = "SHA-256";
    private static final int SALT_LENGTH = 16;
    
    private static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[SALT_LENGTH];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }
    
    public static String hashPassword(String password) {
        try {
            String salt = generateSalt();
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.update(salt.getBytes());
            byte[] hashedPassword = md.digest(password.getBytes());
            
            // Combine salt and hash
            String hash = Base64.getEncoder().encodeToString(hashedPassword);
            return salt + ":" + hash;
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
    
    public static boolean verifyPassword(String password, String storedHash) {
        try {
            String[] parts = storedHash.split(":");
            if (parts.length != 2) {
                return false;
            }
            
            String salt = parts[0];
            String hash = parts[1];
            
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.update(salt.getBytes());
            byte[] hashedPassword = md.digest(password.getBytes());
            String newHash = Base64.getEncoder().encodeToString(hashedPassword);
            
            return hash.equals(newHash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error verifying password", e);
        }
    }
    
    
    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 6) {
            return false;
        }
        
        // Check for at least one letter and one number
        boolean hasLetter = false;
        boolean hasDigit = false;
        
        for (char c : password.toCharArray()) {
            if (Character.isLetter(c)) {
                hasLetter = true;
            }
            if (Character.isDigit(c)) {
                hasDigit = true;
            }
        }
        
        return hasLetter && hasDigit;
    }
    
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        System.out.println("=== Password Hash Generator ===\n");
        
        while (true) {
            System.out.println("Chọn chức năng:");
            System.out.println("1. Hash mật khẩu");
            System.out.println("2. Kiểm tra mật khẩu hợp lệ");
            System.out.println("3. Verify mật khẩu với hash");
            System.out.println("4. Thoát");
            System.out.print("Nhập lựa chọn (1-4): ");
            
            String choice = scanner.nextLine();
            
            switch (choice) {
                case "1":
                    System.out.print("Nhập mật khẩu cần hash: ");
                    String passwordToHash = scanner.nextLine();
                    
                    if (isValidPassword(passwordToHash)) {
                        String hashedPassword = hashPassword(passwordToHash);
                        System.out.println("Mật khẩu gốc: " + passwordToHash);
                        System.out.println("Mật khẩu đã hash: " + hashedPassword);
                        System.out.println("Độ dài hash: " + hashedPassword.length() + " ký tự\n");
                    } else {
                        System.out.println("CẢNH BÁO: Mật khẩu không hợp lệ!");
                        System.out.println("Yêu cầu: Tối thiểu 6 ký tự, có ít nhất 1 chữ cái và 1 số");
                        System.out.print("Bạn có muốn hash anyway? (y/n): ");
                        String confirm = scanner.nextLine();
                        if (confirm.equalsIgnoreCase("y")) {
                            String hashedPassword = hashPassword(passwordToHash);
                            System.out.println("Mật khẩu gốc: " + passwordToHash);
                            System.out.println("Mật khẩu đã hash: " + hashedPassword + "\n");
                        }
                    }
                    break;
                    
                case "2":
                    System.out.print("Nhập mật khẩu cần kiểm tra: ");
                    String passwordToCheck = scanner.nextLine();
                    boolean isValid = isValidPassword(passwordToCheck);
                    
                    System.out.println("Mật khẩu: " + passwordToCheck);
                    System.out.println("Trạng thái: " + (isValid ? "HỢP LỆ ✓" : "KHÔNG HỢP LỆ ✗"));
                    
                    if (!isValid) {
                        System.out.println("Lý do không hợp lệ:");
                        if (passwordToCheck.length() < 6) {
                            System.out.println("- Độ dài phải tối thiểu 6 ký tự");
                        }
                        
                        boolean hasLetter = false;
                        boolean hasDigit = false;
                        for (char c : passwordToCheck.toCharArray()) {
                            if (Character.isLetter(c)) hasLetter = true;
                            if (Character.isDigit(c)) hasDigit = true;
                        }
                        
                        if (!hasLetter) {
                            System.out.println("- Phải có ít nhất 1 chữ cái");
                        }
                        if (!hasDigit) {
                            System.out.println("- Phải có ít nhất 1 chữ số");
                        }
                    }
                    System.out.println();
                    break;
                    
                case "3":
                    System.out.print("Nhập mật khẩu gốc: ");
                    String originalPassword = scanner.nextLine();
                    System.out.print("Nhập hash để kiểm tra: ");
                    String hashToVerify = scanner.nextLine();
                    
                    boolean isMatch = verifyPassword(originalPassword, hashToVerify);
                    System.out.println("Kết quả verify: " + (isMatch ? "ĐÚNG ✓" : "SAI ✗"));
                    System.out.println();
                    break;
                    
                case "4":
                    System.out.println("Tạm biệt!");
                    scanner.close();
                    return;
                    
                default:
                    System.out.println("Lựa chọn không hợp lệ. Vui lòng chọn 1-4.\n");
                    break;
            }
        }
    }
}
