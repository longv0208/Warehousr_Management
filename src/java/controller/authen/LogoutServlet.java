package controller.authen;

import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "logout";
        }

        switch (action) {
            case "logout":
                handleLogout(request, response);
                break;
            case "confirm":
                handleShowLogoutConfirmation(request, response);
                break;
            default:
                handleLogout(request, response);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "logout";
        }

        switch (action) {
            case "logout":
                handleLogout(request, response);
                break;
            default:
                SessionUtil.setErrorMessage(request, "Hành động không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/dashboard");
                break;
        }
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Check if user is logged in
        if (!SessionUtil.isUserLoggedIn(request)) {
            SessionUtil.setErrorMessage(request, "Bạn chưa đăng nhập");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Perform logout
        performLogout(request);

        // Redirect to login page with success message
        SessionUtil.setSuccessMessage(request, "Đăng xuất thành công");
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private void handleShowLogoutConfirmation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check if user is logged in
        if (!SessionUtil.isUserLoggedIn(request)) {
            SessionUtil.setErrorMessage(request, "Bạn chưa đăng nhập");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Show logout confirmation page
        request.getRequestDispatcher("/WEB-INF/views/logout-confirm.jsp").forward(request, response);
    }

    private void performLogout(HttpServletRequest request) {
        // Remove user from session
        SessionUtil.removeUserFromSession(request);
        
        // Invalidate the session for security
        if (request.getSession(false) != null) {
            request.getSession().invalidate();
        }
    }
}
