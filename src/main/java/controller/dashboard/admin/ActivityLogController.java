package controller.dashboard.admin;

import dao.ActivityLogDAO;
import dao.UserDAO;
import model.ActivityLog;
import model.User;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/activity-log")
public class ActivityLogController extends HttpServlet {

    private ActivityLogDAO activityLogDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        activityLogDAO = new ActivityLogDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "login-history";
        }

        switch (action) {
            case "after-hours":
                handleAfterHoursActivities(request, response);
                break;
            case "login-history":
                handleLoginHistory(request, response);
                break;
            default:
                handleLoginHistory(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Since filtering is part of doGet, doPost can redirect or handle other actions if needed.
        // For now, redirecting to default view.
        handleLoginHistory(request, response);
    }

    private void handleAfterHoursActivities(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        
        // Default to last 7 days if no dates provided
        if (startDate == null || startDate.isEmpty()) {
            startDate = java.time.LocalDate.now().minusDays(7).toString();
        }
        if (endDate == null || endDate.isEmpty()) {
            endDate = java.time.LocalDate.now().toString();
        }

        // Pagination
        int page = 1;
        int limit = 10; // Records per page
        if (request.getParameter("page") != null) {
            page = Integer.parseInt(request.getParameter("page"));
        }
        int offset = (page - 1) * limit;

        int totalRecords = activityLogDAO.countAfterHoursLogins(startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalRecords / limit);

        List<ActivityLog> afterHoursLogins = activityLogDAO.getAfterHoursLogins(startDate, endDate, offset, limit);

        // Get all users for name lookup
        List<User> users = userDAO.findAll();

        request.setAttribute("afterHoursLogins", afterHoursLogins);
        request.setAttribute("users", users);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/view/dashboard/admin/activity-logs/after-hours.jsp").forward(request, response);
    }

    private void handleLoginHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String userIdStr = request.getParameter("userId");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String pageStr = request.getParameter("page");

        // Pagination parameters
        int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
        int pageSize = 10; // Number of records per page

        // Default to current month if no dates provided
        if (startDate == null || startDate.isEmpty()) {
            startDate = java.time.LocalDate.now().withDayOfMonth(1).toString();
        }
        if (endDate == null || endDate.isEmpty()) {
            endDate = java.time.LocalDate.now().toString();
        }

        Integer userId = null;
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                userId = Integer.parseInt(userIdStr);
            } catch (NumberFormatException e) {
                userId = null;
            }
        }

        List<ActivityLog> loginHistory = activityLogDAO.getLoginLogoutHistory(userId, startDate, endDate, page, pageSize);
        int totalLogs = activityLogDAO.getTotalLoginLogoutHistory(userId, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalLogs / pageSize);

        // Get all users for dropdown
        List<User> users = userDAO.findAll();

        request.setAttribute("loginHistory", loginHistory);
        request.setAttribute("users", users);
        request.setAttribute("selectedUserId", userId);
        request.setAttribute("selectedStartDate", startDate);
        request.setAttribute("selectedEndDate", endDate);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalLogs", totalLogs);

        request.getRequestDispatcher("/view/dashboard/admin/activity-logs/login-history.jsp").forward(request, response);
    }
} 