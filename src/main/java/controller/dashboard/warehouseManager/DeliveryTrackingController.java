package controller.dashboard.warehouseManager;

import dao.DeliveryTrackingDAO;
import dao.SalesOrderDAO;
import model.DeliveryTracking;
import model.SalesOrder;
import utils.SessionUtil;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "DeliveryTrackingController", urlPatterns = {"/warehouse-manager/delivery"})
public class DeliveryTrackingController extends HttpServlet {

    private DeliveryTrackingDAO deliveryTrackingDAO;
    private SalesOrderDAO salesOrderDAO;

    @Override
    public void init() {
        deliveryTrackingDAO = new DeliveryTrackingDAO();
        salesOrderDAO = new SalesOrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        // Role check
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null || !"sales_staff".equals(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to access this page.");
            return;
        }

        switch (action) {
            case "list":
                listDeliveries(request, response);
                break;
            case "view":
                viewDelivery(request, response);
                break;
            default:
                listDeliveries(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        // Role check
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null || !"sales_staff".equals(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to perform this action.");
            return;
        }
        
        if ("update-status".equals(action)) {
            updateDeliveryStatus(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/warehouse-manager/delivery?action=list");
        }
    }

    private void listDeliveries(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<DeliveryTracking> deliveries = deliveryTrackingDAO.findAllWithSalesOrderDetails();
        request.setAttribute("deliveries", deliveries);
        request.getRequestDispatcher("/view/dashboard/warehouseManager/delivery/list.jsp").forward(request, response);
    }

    private void viewDelivery(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int salesOrderId = Integer.parseInt(request.getParameter("id"));
            SalesOrder salesOrder = salesOrderDAO.findById(salesOrderId);
            List<DeliveryTracking> trackingHistory = deliveryTrackingDAO.findBySalesOrderId(salesOrderId);

            request.setAttribute("salesOrder", salesOrder);
            request.setAttribute("trackingHistory", trackingHistory);
            request.getRequestDispatcher("/view/dashboard/warehouseManager/delivery/view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/warehouse-manager/delivery?action=list");
        }
    }

    private void updateDeliveryStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        try {
            int salesOrderId = Integer.parseInt(request.getParameter("salesOrderId"));
            String newStatus = request.getParameter("status");
            String notes = request.getParameter("notes");

            // Basic validation
            if (newStatus == null || newStatus.isEmpty()) {
                session.setAttribute("toastMessage", "Status cannot be empty.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/warehouse-manager/delivery?action=view&id=" + salesOrderId);
                return;
            }

            DeliveryTracking newTracking = DeliveryTracking.builder()
                    .salesOrderId(salesOrderId)
                    .status(newStatus)
                    .notes(notes)
                    .build();

            int result = deliveryTrackingDAO.insert(newTracking);
            
            // Also update the main sales order status if the delivery is completed or failed
            if ("delivered".equals(newStatus) || "failed".equals(newStatus)) {
                String finalStatus = "completed"; // Assume 'delivered' means 'completed'
                if("failed".equals(newStatus)){
                    finalStatus = "failed"; // Or some other status to indicate failure
                }
                salesOrderDAO.updateStatus(salesOrderId, finalStatus);
            }


            if (result != -1) {
                session.setAttribute("toastMessage", "Delivery status updated successfully.");
                session.setAttribute("toastType", "success");
            } else {
                session.setAttribute("toastMessage", "Failed to update delivery status.");
                session.setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("toastMessage", "Invalid Order ID.");
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/warehouse-manager/delivery?action=view&id=" + request.getParameter("salesOrderId"));
    }
} 