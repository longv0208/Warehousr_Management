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
            action = "list";
        }

        switch (action) {
            case "list":
                handleListLogs(request, response);
                break;
            case "statistics":
                handleStatistics(request, response);
                break;
            case "suspicious":
                handleSuspiciousActivities(request, response);
                break;
            case "after-hours":
                handleAfterHoursActivities(request, response);
                break;
            case "login-history":
                handleLoginHistory(request, response);
                break;
            default:
                handleListLogs(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        switch (action) {
            case "filter":
                handleFilterLogs(request, response);
                break;
            default:
                handleListLogs(request, response);
                break;
        }
    }

    private void handleListLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get filter parameters
        String userIdStr = request.getParameter("userId");
        String actionType = request.getParameter("actionType");
        String entityType = request.getParameter("entityType");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        Integer userId = null;
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                userId = Integer.parseInt(userIdStr);
            } catch (NumberFormatException e) {
                userId = null;
            }
        }

        // Pagination parameters
        int page = 1;
        int pageSize = 20;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        List<ActivityLog> activityLogs = activityLogDAO.getFilteredLogs(userId, actionType, entityType, startDate, endDate, page, pageSize);
        int totalLogs = activityLogDAO.getTotalFilteredLogs(userId, actionType, entityType, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalLogs / pageSize);

        // Get all users for filter dropdown
        List<User> users = userDAO.findAll();

        request.setAttribute("activityLogs", activityLogs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalLogs", totalLogs);
        request.setAttribute("users", users);

        // Set filter values for maintaining state
        request.setAttribute("selectedUserId", userId);
        request.setAttribute("selectedActionType", actionType);
        request.setAttribute("selectedEntityType", entityType);
        request.setAttribute("selectedStartDate", startDate);
        request.setAttribute("selectedEndDate", endDate);

        request.getRequestDispatcher("/view/dashboard/admin/activity-logs/list.jsp").forward(request, response);
    }

    private void handleFilterLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to list method since it now handles filtering too
        handleListLogs(request, response);
    }

    private void handleStatistics(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        // Default to current month if no dates provided
        if (startDate == null || startDate.isEmpty()) {
            startDate = java.time.LocalDate.now().withDayOfMonth(1).toString();
        }
        if (endDate == null || endDate.isEmpty()) {
            endDate = java.time.LocalDate.now().toString();
        }

        List<Object[]> statistics = activityLogDAO.getActionStatistics(startDate, endDate);

        request.setAttribute("statistics", statistics);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);

        request.getRequestDispatcher("/view/dashboard/admin/activity-logs/statistics.jsp").forward(request, response);
    }

    private void handleSuspiciousActivities(HttpServletRequest request, HttpServletResponse response)
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

        List<Object[]> suspiciousActivities = activityLogDAO.getSuspiciousActivities(startDate);

        // Get all users for name lookup
        List<User> users = userDAO.findAll();

        request.setAttribute("suspiciousActivities", suspiciousActivities);
        request.setAttribute("users", users);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);

        request.getRequestDispatcher("/view/dashboard/admin/activity-logs/suspicious.jsp").forward(request, response);
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

        List<Object[]> afterHoursActivities = activityLogDAO.getAfterHoursActivities(startDate);

        // Get all users for name lookup
        List<User> users = userDAO.findAll();

        request.setAttribute("afterHoursActivities", afterHoursActivities);
        request.setAttribute("users", users);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);

        request.getRequestDispatcher("/view/dashboard/admin/activity-logs/after-hours.jsp").forward(request, response);
    }

    private void handleLoginHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String userIdStr = request.getParameter("userId");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        if (userIdStr == null || userIdStr.isEmpty()) {
            // Get current user if no user specified
            User currentUser = SessionUtil.getUserFromSession(request);
            if (currentUser != null) {
                userIdStr = String.valueOf(currentUser.getUserId());
            }
        }

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

        List<ActivityLog> loginHistory = null;
        if (userId != null) {
            loginHistory = activityLogDAO.getLoginLogoutHistory(userId, startDate, endDate);
        }

        // Get all users for dropdown
        List<User> users = userDAO.findAll();

        request.setAttribute("loginHistory", loginHistory);
        request.setAttribute("users", users);
        request.setAttribute("selectedUserId", userId);
        request.setAttribute("selectedStartDate", startDate);
        request.setAttribute("selectedEndDate", endDate);

        request.getRequestDispatcher("/view/dashboard/admin/activity-logs/login-history.jsp").forward(request, response);
    }
} 