package test;

import dao.UserDAO;
import model.User;
import utils.PasswordUtil;

public class LoginServletTestManual {
    public static void main(String[] args) {
        String username = "admin12";
        String rawPassword = "123456"; // mật khẩu gốc người dùng nhập

        UserDAO userDAO = new UserDAO();
        User user = userDAO.findByUsername(username);

        if (user == null) {
            System.out.println("❌ Tên đăng nhập không tồn tại");
            return;
        }

        // So sánh mật khẩu nhập vào với mật khẩu hash trong DB
        boolean passwordMatch = PasswordUtil.verifyPassword(rawPassword, user.getPasswordHash());
        if (!passwordMatch) {
            System.out.println("❌ Mật khẩu không đúng");
            return;
        }

        if (!user.isActive()) {
            System.out.println("❌ Tài khoản đã bị vô hiệu hóa");
            return;
        }

        System.out.println("✅ Đăng nhập thành công! Chào mừng " + user.getFullName());
    }
}
