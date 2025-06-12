package controller.authen;

import context.DBContext;
import dao.UserDAO;
import model.User;
import utils.PasswordUtil;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/forgotpassword2"})
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
//        if (SessionUtil.isUserLoggedIn(request)) {
//            response.sendRedirect(request.getContextPath() + "/dashboard");
//            return;
//        }

        String path = request.getServletPath();
        switch (path) {
            case "/login":
                request.getRequestDispatcher("/view/authen/login.jsp").forward(request, response);
                break;
            default:
                throw new AssertionError();
        }

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/login":
                loginDoPost(request, response);
                break;
            default:
                throw new AssertionError();
        }

    }

    private void loginDoPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            SessionUtil.setErrorMessage(request, "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            User user = userDAO.findByUsername(username.trim());

            if (user == null) {
                SessionUtil.setErrorMessage(request, "Tên đăng nhập không tồn tại");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            if (!PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
                SessionUtil.setErrorMessage(request, "Mật khẩu không chính xác");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            if (!user.isActive()) {
                SessionUtil.setErrorMessage(request, "Tài khoản đã bị vô hiệu hóa");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            SessionUtil.setUserInSession(request, user);
            SessionUtil.setSuccessMessage(request, "Đăng nhập thành công! Chào mừng " + user.getFullName());
            
            // Kiểm tra role và chuyển hướng tương ứng
            if ("admin".equals(user.getRoleId())) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/profile");
            }

        } catch (Exception e) {
            e.printStackTrace();
            SessionUtil.setErrorMessage(request, "Lỗi khi đăng nhập");
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

}
