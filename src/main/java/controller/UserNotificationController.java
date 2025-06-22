package controller;

import dao.UserNotificationDAO;
import model.User;
import model.UserNotification;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "UserNotificationController", urlPatterns = {"/notifications"})
public class UserNotificationController extends HttpServlet {
    
    private UserNotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        notificationDAO = new UserNotificationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "view":
                viewNotification(request, response, currentUser);
                break;
            case "markRead":
                markAsRead(request, response, currentUser);
                break;
            case "list":
            default:
                listNotifications(request, response, currentUser);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        switch (action) {
            case "markRead":
                markAsRead(request, response, currentUser);
                break;
            default:
                listNotifications(request, response, currentUser);
                break;
        }
    }

    private void listNotifications(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        
        List<UserNotification> notifications = notificationDAO.getNotificationsByReceiverId(currentUser.getUserId());
        int unreadCount = notificationDAO.countUnreadNotifications(currentUser.getUserId());
        
        request.setAttribute("notifications", notifications);
        request.setAttribute("unreadCount", unreadCount);
        request.getRequestDispatcher("/view/notifications/notification-list.jsp").forward(request, response);
    }

    private void viewNotification(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        
        String notificationIdStr = request.getParameter("id");
        if (notificationIdStr == null) {
            response.sendRedirect("notifications");
            return;
        }
        
        try {
            int notificationId = Integer.parseInt(notificationIdStr);
            UserNotification notification = notificationDAO.findById(notificationId);
            
            if (notification == null || notification.getReceiverId() != currentUser.getUserId()) {
                request.setAttribute("error", "Không tìm thấy thông báo hoặc bạn không có quyền xem!");
                listNotifications(request, response, currentUser);
                return;
            }
            
            // Tự động đánh dấu đã đọc khi xem chi tiết
            if (!notification.isRead()) {
                notificationDAO.markAsRead(notificationId);
                notification.setRead(true);
            }
            
            request.setAttribute("notification", notification);
            request.getRequestDispatcher("/view/notifications/view-notification.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("notifications");
        }
    }

    private void markAsRead(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        
        String notificationIdStr = request.getParameter("id");
        if (notificationIdStr == null) {
            response.sendRedirect("notifications");
            return;
        }
        
        try {
            int notificationId = Integer.parseInt(notificationIdStr);
            UserNotification notification = notificationDAO.findById(notificationId);
            
            if (notification != null && notification.getReceiverId() == currentUser.getUserId()) {
                boolean success = notificationDAO.markAsRead(notificationId);
                if (success) {
                    request.setAttribute("success", "Đã đánh dấu thông báo là đã đọc!");
                } else {
                    request.setAttribute("error", "Có lỗi xảy ra khi cập nhật trạng thái!");
                }
            } else {
                request.setAttribute("error", "Không tìm thấy thông báo hoặc bạn không có quyền thực hiện!");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
        }
        
        listNotifications(request, response, currentUser);
    }
} 