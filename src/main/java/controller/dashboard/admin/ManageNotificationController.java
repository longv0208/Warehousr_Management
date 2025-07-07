package controller.dashboard.admin;

import dao.UserDAO;
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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet(name = "ManageNotificationController", urlPatterns = {"/admin/manage-notification"})
public class ManageNotificationController extends HttpServlet {
    
    private UserNotificationDAO notificationDAO;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        notificationDAO = new UserNotificationDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền admin
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null || !"admin".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "create":
                showCreateForm(request, response);
                break;
            case "view":
                viewNotification(request, response);
                break;
            case "list":
            default:
                listNotifications(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra quyền admin
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null || !"admin".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        switch (action) {
            case "send":
                sendNotification(request, response);
                break;
            case "sendToAll":
                sendNotificationToAll(request, response);
                break;
            default:
                listNotifications(request, response);
                break;
        }
    }

    private void listNotifications(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<UserNotification> notifications = notificationDAO.findAll();
        request.setAttribute("notifications", notifications);
        request.getRequestDispatcher("/view/dashboard/admin/notification/notification-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy danh sách tất cả user để admin chọn
        List<User> users = userDAO.findAll();
        // Loại bỏ admin khỏi danh sách
        users.removeIf(user -> "admin".equals(user.getRoleId()));
        
        request.setAttribute("users", users);
        request.getRequestDispatcher("/view/dashboard/admin/notification/create-notification.jsp").forward(request, response);
    }

    private void sendNotification(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User currentUser = SessionUtil.getUserFromSession(request);
        String title = request.getParameter("title");
        String message = request.getParameter("message");
        String[] receiverIds = request.getParameterValues("receiverIds");
        
        if (title == null || title.trim().isEmpty() || 
            message == null || message.trim().isEmpty() || 
            receiverIds == null || receiverIds.length == 0) {
            
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin!");
            showCreateForm(request, response);
            return;
        }

        try {
            List<Integer> receiverIdList = new ArrayList<>();
            for (String id : receiverIds) {
                receiverIdList.add(Integer.parseInt(id));
            }
            
            boolean success = notificationDAO.sendNotificationToMultipleUsers(
                currentUser.getUserId(), 
                receiverIdList, 
                title.trim(), 
                message.trim()
            );
            
            if (success) {
                request.setAttribute("success", "Gửi thông báo thành công!");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi gửi thông báo!");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
        }
        
        showCreateForm(request, response);
    }

    private void sendNotificationToAll(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User currentUser = SessionUtil.getUserFromSession(request);
        String title = request.getParameter("title");
        String message = request.getParameter("message");
        
        if (title == null || title.trim().isEmpty() || 
            message == null || message.trim().isEmpty()) {
            
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin!");
            showCreateForm(request, response);
            return;
        }

        try {
            // Lấy tất cả user trừ admin
            List<User> users = userDAO.findAll();
            List<Integer> receiverIds = new ArrayList<>();
            
            for (User user : users) {
                if (!"admin".equals(user.getRoleId())) {
                    receiverIds.add(user.getUserId());
                }
            }
            
            if (receiverIds.isEmpty()) {
                request.setAttribute("error", "Không có user nào để gửi thông báo!");
                showCreateForm(request, response);
                return;
            }
            
            boolean success = notificationDAO.sendNotificationToMultipleUsers(
                currentUser.getUserId(), 
                receiverIds, 
                title.trim(), 
                message.trim()
            );
            
            if (success) {
                request.setAttribute("success", "Gửi thông báo đến tất cả user thành công!");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi gửi thông báo!");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi hệ thống xảy ra!");
        }
        
        showCreateForm(request, response);
    }

    private void viewNotification(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String notificationIdStr = request.getParameter("id");
        if (notificationIdStr == null) {
            response.sendRedirect("notifications");
            return;
        }
        
        try {
            int notificationId = Integer.parseInt(notificationIdStr);
            UserNotification notification = notificationDAO.findById(notificationId);
            
            if (notification == null) {
                request.setAttribute("error", "Không tìm thấy thông báo!");
                listNotifications(request, response);
                return;
            }
            
            request.setAttribute("notification", notification);
            request.getRequestDispatcher("/view/dashboard/admin/notification/view-notification.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("notifications");
        }
    }
} 