package controller.dashboard.admin;

import dao.ProductDAO;
import dao.SalesOrderDAO;
import dao.SalesOrderDetailDAO;
import dao.UserDAO;
import model.Product;
import model.SalesOrder;
import model.SalesOrderDetail;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ManageSalesOrderController", urlPatterns = {"/admin/manage-sales-order"})
public class ManageSalesOrderController extends HttpServlet {

    private SalesOrderDAO salesOrderDAO;
    private SalesOrderDetailDAO salesOrderDetailDAO;
    private ProductDAO productDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        salesOrderDAO = new SalesOrderDAO();
        salesOrderDetailDAO = new SalesOrderDetailDAO();
        productDAO = new ProductDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                listAllOrders(request, response);
                break;
            case "view":
                viewOrderDetails(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteOrder(request, response);
                break;
            case "update-status":
                updateOrderStatus(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            default:
                listAllOrders(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            return;
        }

        switch (action) {
            case "create":
                createOrder(request, response);
                break;
            case "edit":
                updateOrder(request, response);
                break;
            case "update-status":
                updateOrderStatusPost(request, response);
                break;
            default:
                listAllOrders(request, response);
                break;
        }
    }

    private void listAllOrders(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get pagination and filter parameters
        String statusFilter = request.getParameter("status");
        String customerFilter = request.getParameter("customer");
        String userIdFilter = request.getParameter("userId");
        String pageStr = request.getParameter("page");
        int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
        int pageSize = 10;

        List<SalesOrder> orders = salesOrderDAO.findOrdersWithFilters(statusFilter, customerFilter, userIdFilter, page, pageSize);
        int totalOrders = salesOrderDAO.getTotalFilteredOrders(statusFilter, customerFilter, userIdFilter);
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);

        // Get all users for filter dropdown
        List<User> users = userDAO.findAll();
        List<User> salesStaff = new ArrayList<>();
        for (User user : users) {
            if ("sales_staff".equals(user.getRoleId())) {
                salesStaff.add(user);
            }
        }

        request.setAttribute("orders", orders);
        request.setAttribute("salesStaff", salesStaff);
        request.setAttribute("userDAO", userDAO);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("customerFilter", customerFilter);
        request.setAttribute("userIdFilter", userIdFilter);

        request.getRequestDispatcher("/view/dashboard/admin/salesOrder/manageSalesOrder.jsp").forward(request, response);
    }

    private void viewOrderDetails(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            SalesOrder order = salesOrderDAO.findById(orderId);
            
            if (order != null) {
                List<SalesOrderDetail> orderDetails = salesOrderDetailDAO.findBySalesOrderId(orderId);
                User creator = userDAO.findById(order.getUserId());
                
                // Get product information for each detail
                for (SalesOrderDetail detail : orderDetails) {
                    Product product = productDAO.findById(detail.getProductId());
                    request.setAttribute("product_" + detail.getProductId(), product);
                }
                
                request.setAttribute("order", order);
                request.setAttribute("orderDetails", orderDetails);
                request.setAttribute("creator", creator);
                request.setAttribute("productDAO", productDAO);
                
                request.getRequestDispatcher("/view/dashboard/admin/salesOrder/viewSalesOrder.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            SalesOrder order = salesOrderDAO.findById(orderId);
            
            if (order != null) {
                List<SalesOrderDetail> orderDetails = salesOrderDetailDAO.findBySalesOrderId(orderId);
                List<Product> products = productDAO.findActiveProducts();
                List<User> users = userDAO.findAll();
                List<User> salesStaff = new ArrayList<>();
                for (User user : users) {
                    if ("sales_staff".equals(user.getRoleId())) {
                        salesStaff.add(user);
                    }
                }
                
                request.setAttribute("order", order);
                request.setAttribute("orderDetails", orderDetails);
                request.setAttribute("products", products);
                request.setAttribute("salesStaff", salesStaff);
                request.setAttribute("productDAO", productDAO);
                
                request.getRequestDispatcher("/view/dashboard/admin/salesOrder/editSalesOrder.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
        }
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get all active products and sales staff for selection
        List<Product> products = productDAO.findActiveProducts();
        List<User> users = userDAO.findAll();
        List<User> salesStaff = new ArrayList<>();
        for (User user : users) {
            if ("sales_staff".equals(user.getRoleId())) {
                salesStaff.add(user);
            }
        }
        
        request.setAttribute("products", products);
        request.setAttribute("salesStaff", salesStaff);
        request.setAttribute("orderCode", salesOrderDAO.generateOrderCode());
        
        request.getRequestDispatcher("/view/dashboard/admin/salesOrder/createSalesOrder.jsp").forward(request, response);
    }

    private void createOrder(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        try {
            // Get order information
            String orderCode = request.getParameter("orderCode");
            String customerName = request.getParameter("customerName");
            String notes = request.getParameter("notes");
            String orderDateStr = request.getParameter("orderDate");
            String userIdStr = request.getParameter("userId");
            String status = request.getParameter("status");
            
            // Parse order date
            Date orderDate = Date.valueOf(orderDateStr != null ? orderDateStr : LocalDate.now().toString());
            
            // Create sales order
            SalesOrder salesOrder = new SalesOrder();
            salesOrder.setOrderCode(orderCode);
            salesOrder.setCustomerName(customerName);
            salesOrder.setUserId(Integer.parseInt(userIdStr));
            salesOrder.setOrderDate(orderDate);
            salesOrder.setStatus(status != null ? status : "pending_stock_check");
            salesOrder.setNotes(notes);

            int salesOrderId = salesOrderDAO.insert(salesOrder);
            
            if (salesOrderId > 0) {
                // Get product details from form
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantity");
                String[] unitPrices = request.getParameterValues("unitPrice");
                
                List<SalesOrderDetail> orderDetails = new ArrayList<>();
                
                if (productIds != null && quantities != null && unitPrices != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (productIds[i] != null && !productIds[i].isEmpty() &&
                            quantities[i] != null && !quantities[i].isEmpty() &&
                            unitPrices[i] != null && !unitPrices[i].isEmpty()) {
                            
                            SalesOrderDetail detail = new SalesOrderDetail();
                            detail.setSalesOrderId(salesOrderId);
                            detail.setProductId(Integer.parseInt(productIds[i]));
                            detail.setQuantityOrdered(Integer.parseInt(quantities[i]));
                            detail.setUnitSalePrice(new BigDecimal(unitPrices[i]));
                            
                            orderDetails.add(detail);
                        }
                    }
                }
                
                if (!orderDetails.isEmpty()) {
                    boolean detailsInserted = salesOrderDetailDAO.insertDetails(orderDetails);
                    if (detailsInserted) {
                        session.setAttribute("toastMessage", "Đơn bán hàng đã được tạo thành công!");
                        session.setAttribute("toastType", "success");
                    } else {
                        session.setAttribute("toastMessage", "Lỗi khi tạo chi tiết đơn hàng!");
                        session.setAttribute("toastType", "error");
                    }
                } else {
                    session.setAttribute("toastMessage", "Đơn hàng đã được tạo nhưng không có sản phẩm nào!");
                    session.setAttribute("toastType", "warning");
                }
            } else {
                session.setAttribute("toastMessage", "Lỗi khi tạo đơn bán hàng!");
                session.setAttribute("toastType", "error");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("toastMessage", "Lỗi hệ thống: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
    }

    private void updateOrder(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        try {
            String idStr = request.getParameter("id");
            int orderId = Integer.parseInt(idStr);
            
            SalesOrder existingOrder = salesOrderDAO.findById(orderId);
            if (existingOrder == null) {
                session.setAttribute("toastMessage", "Không tìm thấy đơn hàng!");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
                return;
            }
            
            // Update order information
            String customerName = request.getParameter("customerName");
            String notes = request.getParameter("notes");
            String orderDateStr = request.getParameter("orderDate");
            String userIdStr = request.getParameter("userId");
            String status = request.getParameter("status");
            
            Date orderDate = Date.valueOf(orderDateStr != null ? orderDateStr : LocalDate.now().toString());
            
            existingOrder.setCustomerName(customerName);
            existingOrder.setNotes(notes);
            existingOrder.setOrderDate(orderDate);
            existingOrder.setUserId(Integer.parseInt(userIdStr));
            existingOrder.setStatus(status);
            
            boolean orderUpdated = salesOrderDAO.update(existingOrder);
            
            if (orderUpdated) {
                // Delete existing order details
                salesOrderDetailDAO.deleteBySalesOrderId(orderId);
                
                // Add new order details
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantity");
                String[] unitPrices = request.getParameterValues("unitPrice");
                
                List<SalesOrderDetail> orderDetails = new ArrayList<>();
                
                if (productIds != null && quantities != null && unitPrices != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (productIds[i] != null && !productIds[i].isEmpty() &&
                            quantities[i] != null && !quantities[i].isEmpty() &&
                            unitPrices[i] != null && !unitPrices[i].isEmpty()) {
                            
                            SalesOrderDetail detail = new SalesOrderDetail();
                            detail.setSalesOrderId(orderId);
                            detail.setProductId(Integer.parseInt(productIds[i]));
                            detail.setQuantityOrdered(Integer.parseInt(quantities[i]));
                            detail.setUnitSalePrice(new BigDecimal(unitPrices[i]));
                            
                            orderDetails.add(detail);
                        }
                    }
                }
                
                if (!orderDetails.isEmpty()) {
                    boolean detailsInserted = salesOrderDetailDAO.insertDetails(orderDetails);
                    if (detailsInserted) {
                        session.setAttribute("toastMessage", "Đơn bán hàng đã được cập nhật thành công!");
                        session.setAttribute("toastType", "success");
                    } else {
                        session.setAttribute("toastMessage", "Lỗi khi cập nhật chi tiết đơn hàng!");
                        session.setAttribute("toastType", "error");
                    }
                } else {
                    session.setAttribute("toastMessage", "Đơn hàng đã được cập nhật nhưng không có sản phẩm nào!");
                    session.setAttribute("toastType", "warning");
                }
            } else {
                session.setAttribute("toastMessage", "Lỗi khi cập nhật đơn bán hàng!");
                session.setAttribute("toastType", "error");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("toastMessage", "Lỗi hệ thống: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
    }

    private void deleteOrder(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            SalesOrder order = salesOrderDAO.findById(orderId);
            
            if (order != null) {
                // Delete order details first
                salesOrderDetailDAO.deleteBySalesOrderId(orderId);
                
                // Then delete the order
                boolean deleted = salesOrderDAO.delete(order);
                if (deleted) {
                    session.setAttribute("toastMessage", "Đơn hàng đã được xóa thành công!");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMessage", "Lỗi khi xóa đơn hàng!");
                    session.setAttribute("toastType", "error");
                }
            } else {
                session.setAttribute("toastMessage", "Không tìm thấy đơn hàng!");
                session.setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("toastMessage", "ID đơn hàng không hợp lệ!");
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String status = request.getParameter("status");
        
        if (idStr == null || idStr.isEmpty() || status == null || status.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            SalesOrder order = salesOrderDAO.findById(orderId);
            
            if (order != null) {
                request.setAttribute("order", order);
                request.setAttribute("newStatus", status);
                request.getRequestDispatcher("/view/dashboard/admin/salesOrder/confirmStatusUpdate.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
        }
    }

    private void updateOrderStatusPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");
        String status = request.getParameter("status");
        
        if (idStr == null || idStr.isEmpty() || status == null || status.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            boolean updated = salesOrderDAO.updateStatus(orderId, status);
            
            if (updated) {
                session.setAttribute("toastMessage", "Trạng thái đơn hàng đã được cập nhật thành công!");
                session.setAttribute("toastType", "success");
            } else {
                session.setAttribute("toastMessage", "Lỗi khi cập nhật trạng thái đơn hàng!");
                session.setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("toastMessage", "ID đơn hàng không hợp lệ!");
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
    }
} 