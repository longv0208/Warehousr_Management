package controller.dashboard.warehouseManager;

import dao.DeliveryTrackingDAO;
import dao.SalesOrderDAO;
import dao.UserDAO;
import model.DeliveryTracking;
import model.User;
import utils.SessionUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;

@WebServlet(name = "DeliveryTrackingController", urlPatterns = {"/delivery-tracking"})
public class DeliveryTrackingController extends HttpServlet {

    private DeliveryTrackingDAO deliveryTrackingDAO;
    private SalesOrderDAO salesOrderDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        deliveryTrackingDAO = new DeliveryTrackingDAO();
        salesOrderDAO = new SalesOrderDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null || (!"admin".equals(currentUser.getRoleId()) && !"warehouse_manager".equals(currentUser.getRoleId()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to access this page.");
            return;
        }

        switch (action) {
            case "list":
                listTrackings(request, response);
                break;
            case "view":
                viewTracking(request, response);
                break;
            default:
                listTrackings(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
         String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/delivery-tracking?action=list");
            return;
        }

        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null || (!"admin".equals(currentUser.getRoleId()) && !"warehouse_manager".equals(currentUser.getRoleId()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to perform this action.");
            return;
        }

        switch (action) {
            case "update":
                updateTrackingStatus(request, response);
                break;
            default:
                 response.sendRedirect(request.getContextPath() + "/delivery-tracking?action=list");
                break;
        }
    }

    private void listTrackings(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<DeliveryTrackingDAO.DeliveryTrackingInfo> trackingList = deliveryTrackingDAO.getAllDeliveryTrackingInfo();
        request.setAttribute("trackingList", trackingList);
        request.getRequestDispatcher("/view/dashboard/warehouseManager/delivery/list.jsp").forward(request, response);
    }

    private void viewTracking(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int salesOrderId = Integer.parseInt(request.getParameter("soId"));
            List<DeliveryTracking> trackingHistory = deliveryTrackingDAO.findBySalesOrderId(salesOrderId);

            request.setAttribute("trackingHistory", trackingHistory);
            request.setAttribute("salesOrder", salesOrderDAO.findById(salesOrderId));
            request.setAttribute("userDAO", userDAO); // Pass DAO for fetching user names
            request.getRequestDispatcher("/view/dashboard/warehouseManager/delivery/view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Sales Order ID.");
        }
    }

    private void updateTrackingStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int salesOrderId = Integer.parseInt(request.getParameter("salesOrderId"));
            String location = request.getParameter("location");
            String status = request.getParameter("status");
            String notes = request.getParameter("notes");
            User currentUser = SessionUtil.getUserFromSession(request);

            DeliveryTracking newTracking = DeliveryTracking.builder()
                    .salesOrderId(salesOrderId)
                    .location(location)
                    .status(status)
                    .notes(notes)
                    .updatedBy(currentUser.getUserId())
                    .updateTime(Timestamp.from(Instant.now()))
                    .build();

            deliveryTrackingDAO.insert(newTracking);
            
            request.getSession().setAttribute("toastMessage", "Delivery status updated successfully.");
            request.getSession().setAttribute("toastType", "success");
            response.sendRedirect(request.getContextPath() + "/delivery-tracking?action=view&soId=" + salesOrderId);

        } catch (NumberFormatException e) {
             request.getSession().setAttribute("toastMessage", "Invalid data provided.");
             request.getSession().setAttribute("toastType", "error");
             response.sendRedirect(request.getContextPath() + "/delivery-tracking?action=list");
        }
    }
} 