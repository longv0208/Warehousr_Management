package controller.dashboard.saleStaff;

import dao.ProductDAO;
import dao.SalesOrderDAO;
import dao.SalesOrderDetailDAO;
import dao.UserDAO;
import utils.SessionUtil;
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
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "SalesOrderController", urlPatterns = {"/sale-staff/sales-order"})
public class SalesOrderController extends HttpServlet {

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
                listMyOrders(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "view":
                viewOrderDetails(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "cancel":
                cancelOrder(request, response);
                break;
            default:
                listMyOrders(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
            return;
        }

        switch (action) {
            case "create":
                createOrder(request, response);
                break;
            case "edit":
                updateOrder(request, response);
                break;
            default:
                listMyOrders(request, response);
                break;
        }
    }

    private void listMyOrders(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get pagination and filter parameters
        String statusFilter = request.getParameter("status");
        String customerFilter = request.getParameter("customer");
        String pageStr = request.getParameter("page");
        int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
        int pageSize = 10;

        // Only show orders created by this user
        String userIdFilter = String.valueOf(currentUser.getUserId());
        
        List<SalesOrder> orders = salesOrderDAO.findOrdersWithFilters(statusFilter, customerFilter, userIdFilter, page, pageSize);
        int totalOrders = salesOrderDAO.getTotalFilteredOrders(statusFilter, customerFilter, userIdFilter);
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);

        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("customerFilter", customerFilter);

        request.getRequestDispatcher("/view/dashboard/saleStaff/salesOrder/salesOrderList.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get all active products for selection with detailed information
            List<Product> products = productDAO.findActiveProducts();
            System.out.println("DEBUG: Found " + (products != null ? products.size() : 0) + " active products");
            
            if (products != null && !products.isEmpty()) {
                for (int i = 0; i < Math.min(3, products.size()); i++) {
                    Product p = products.get(i);
                    System.out.println("DEBUG: Product " + (i+1) + " - ID: " + p.getProductId() + 
                                     ", Name: " + p.getProductName() + 
                                     ", Code: " + p.getProductCode() +
                                     ", Price: " + p.getSalePrice() +
                                     ", Quantity: " + p.getQuantity());
                }
            } else {
                System.err.println("ERROR: No products found or products list is empty!");
            }
            
            // Generate new order code
            String orderCode = salesOrderDAO.generateOrderCode();
            System.out.println("DEBUG: Generated order code: " + orderCode);
            
            request.setAttribute("products", products);
            request.setAttribute("orderCode", orderCode);
            
            // Add debug attribute and product count for JSP
            int productCount = products != null ? products.size() : 0;
            request.setAttribute("debugProductCount", productCount);
            request.setAttribute("productCount", productCount);
            
            request.getRequestDispatcher("/view/dashboard/saleStaff/salesOrder/createSalesOrder.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("ERROR in showCreateForm: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
        }
    }

    private void createOrder(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Get order information
            String orderCode = request.getParameter("orderCode");
            String customerName = request.getParameter("customerName");
            String notes = request.getParameter("notes");
            String orderDateStr = request.getParameter("orderDate");
            
            // Parse order date
            Date orderDate = Date.valueOf(orderDateStr != null ? orderDateStr : LocalDate.now().toString());
            
            // Get product details from form for validation
            String[] productIds = request.getParameterValues("productId");
            String[] quantities = request.getParameterValues("quantity");
            String[] unitPrices = request.getParameterValues("unitPrice");
            
            // Validate products and calculate total
            BigDecimal orderTotal = validateAndCalculateOrderTotal(productIds, quantities, unitPrices, session);
            
            if (orderTotal.compareTo(BigDecimal.ZERO) == 0) {
                session.setAttribute("toastMessage", "Đơn hàng phải có ít nhất một sản phẩm hợp lệ!");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=create");
                return;
            }
            
            // Create sales order
            SalesOrder salesOrder = new SalesOrder();
            salesOrder.setOrderCode(orderCode);
            salesOrder.setCustomerName(customerName);
            salesOrder.setUserId(currentUser.getUserId());
            salesOrder.setOrderDate(orderDate);
            salesOrder.setStatus("pending_stock_check");
            salesOrder.setNotes(notes);

            int salesOrderId = salesOrderDAO.insert(salesOrder);
            
            if (salesOrderId > 0) {
                List<SalesOrderDetail> orderDetails = new ArrayList<>();
                
                if (productIds != null && quantities != null && unitPrices != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (productIds[i] != null && !productIds[i].isEmpty() &&
                            quantities[i] != null && !quantities[i].isEmpty() &&
                            unitPrices[i] != null && !unitPrices[i].isEmpty()) {
                            
                            // Validate product exists before adding to order
                            Product product = productDAO.findById(Integer.parseInt(productIds[i]));
                            if (product != null && product.getIsActive()) {
                                SalesOrderDetail detail = new SalesOrderDetail();
                                detail.setSalesOrderId(salesOrderId);
                                detail.setProductId(Integer.parseInt(productIds[i]));
                                detail.setQuantityOrdered(Integer.parseInt(quantities[i]));
                                detail.setUnitSalePrice(new BigDecimal(unitPrices[i]));
                                
                                orderDetails.add(detail);
                            }
                        }
                    }
                }
                
                if (!orderDetails.isEmpty()) {
                    boolean detailsInserted = salesOrderDetailDAO.insertDetails(orderDetails);
                    if (detailsInserted) {
                        String message = "Đơn bán hàng đã được tạo thành công! Tổng giá trị: " + 
                                       orderTotal.toString() + " đ";
                        if (session.getAttribute("hasStockWarning") != null) {
                            message += " (Có cảnh báo về tồn kho)";
                            session.removeAttribute("hasStockWarning");
                        }
                        session.setAttribute("toastMessage", message);
                        session.setAttribute("toastType", "success");
                    } else {
                        session.setAttribute("toastMessage", "Lỗi khi tạo chi tiết đơn hàng!");
                        session.setAttribute("toastType", "error");
                    }
                } else {
                    session.setAttribute("toastMessage", "Không có sản phẩm hợp lệ nào để tạo đơn hàng!");
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
        
        response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
    }

    private void viewOrderDetails(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            SalesOrder order = salesOrderDAO.findById(orderId);
            
            if (order != null) {
                // Check if this order belongs to current user
                User currentUser = SessionUtil.getUserFromSession(request);
                if (currentUser == null || !order.getUserId().equals(currentUser.getUserId())) {
                    response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
                    return;
                }
                
                // Get order details with complete product information from database join
                List<SalesOrderDetailDAO.SalesOrderDetailWithProduct> orderDetailsWithProduct = 
                    salesOrderDetailDAO.findBySalesOrderIdWithCompleteProductInfo(orderId);
                
                // Calculate total order value
                BigDecimal totalOrderValue = BigDecimal.ZERO;
                for (SalesOrderDetailDAO.SalesOrderDetailWithProduct detail : orderDetailsWithProduct) {
                    totalOrderValue = totalOrderValue.add(detail.getTotalPrice());
                }
                
                request.setAttribute("order", order);
                request.setAttribute("orderDetailsWithProduct", orderDetailsWithProduct);
                request.setAttribute("totalOrderValue", totalOrderValue);
                
                request.getRequestDispatcher("/view/dashboard/saleStaff/salesOrder/viewSalesOrder.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            SalesOrder order = salesOrderDAO.findById(orderId);
            
            if (order != null) {
                // Check if this order belongs to current user and is editable
                HttpSession session = request.getSession();
                User currentUser = SessionUtil.getUserFromSession(request);
                if (currentUser == null || !order.getUserId().equals(currentUser.getUserId())) {
                    response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
                    return;
                }
                
                // Only allow editing if order is still pending
                if (!"pending_stock_check".equals(order.getStatus())) {
                    session.setAttribute("toastMessage", "Không thể chỉnh sửa đơn hàng đã được xử lý!");
                    session.setAttribute("toastType", "error");
                    response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
                    return;
                }
                
                // Get order details with complete product information
                List<SalesOrderDetailDAO.SalesOrderDetailWithProduct> orderDetailsWithProduct = 
                    salesOrderDetailDAO.findBySalesOrderIdWithCompleteProductInfo(orderId);
                
                // Get all active products for selection
                List<Product> products = productDAO.findActiveProducts();
                
                request.setAttribute("order", order);
                request.setAttribute("orderDetailsWithProduct", orderDetailsWithProduct);
                request.setAttribute("products", products);
                
                request.getRequestDispatcher("/view/dashboard/saleStaff/salesOrder/editSalesOrder.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
        }
    }

    private void updateOrder(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String idStr = request.getParameter("id");
            int orderId = Integer.parseInt(idStr);
            
            SalesOrder existingOrder = salesOrderDAO.findById(orderId);
            if (existingOrder == null || !existingOrder.getUserId().equals(currentUser.getUserId())) {
                session.setAttribute("toastMessage", "Không tìm thấy đơn hàng hoặc bạn không có quyền chỉnh sửa!");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
                return;
            }
            
            // Only allow editing if order is still pending
            if (!"pending_stock_check".equals(existingOrder.getStatus())) {
                session.setAttribute("toastMessage", "Không thể chỉnh sửa đơn hàng đã được xử lý!");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
                return;
            }
            
            // Update order information
            String customerName = request.getParameter("customerName");
            String notes = request.getParameter("notes");
            String orderDateStr = request.getParameter("orderDate");
            
            Date orderDate = Date.valueOf(orderDateStr != null ? orderDateStr : LocalDate.now().toString());
            
            existingOrder.setCustomerName(customerName);
            existingOrder.setNotes(notes);
            existingOrder.setOrderDate(orderDate);
            
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
        
        response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
    }

    private void cancelOrder(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            SalesOrder order = salesOrderDAO.findById(orderId);
            
            if (order != null && order.getUserId().equals(currentUser.getUserId())) {
                // Only allow cancelling if order is pending or awaiting shipment
                if ("pending_stock_check".equals(order.getStatus()) || "awaiting_shipment".equals(order.getStatus())) {
                    boolean cancelled = salesOrderDAO.updateStatus(orderId, "cancelled");
                    if (cancelled) {
                        session.setAttribute("toastMessage", "Đơn hàng đã được hủy thành công!");
                        session.setAttribute("toastType", "success");
                    } else {
                        session.setAttribute("toastMessage", "Lỗi khi hủy đơn hàng!");
                        session.setAttribute("toastType", "error");
                    }
                } else {
                    session.setAttribute("toastMessage", "Không thể hủy đơn hàng ở trạng thái này!");
                    session.setAttribute("toastType", "error");
                }
            } else {
                session.setAttribute("toastMessage", "Không tìm thấy đơn hàng hoặc bạn không có quyền hủy!");
                session.setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("toastMessage", "ID đơn hàng không hợp lệ!");
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
    }

    /**
     * Validate product availability and calculate order total
     */
    private BigDecimal validateAndCalculateOrderTotal(String[] productIds, String[] quantities, 
                                                     String[] unitPrices, HttpSession session) {
        if (productIds == null || quantities == null || unitPrices == null) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal total = BigDecimal.ZERO;
        boolean hasStockIssue = false;
        
        for (int i = 0; i < productIds.length; i++) {
            if (productIds[i] != null && !productIds[i].isEmpty() &&
                quantities[i] != null && !quantities[i].isEmpty() &&
                unitPrices[i] != null && !unitPrices[i].isEmpty()) {
                
                try {
                    int productId = Integer.parseInt(productIds[i]);
                    int quantity = Integer.parseInt(quantities[i]);
                    BigDecimal unitPrice = new BigDecimal(unitPrices[i]);
                    
                    // Validate product exists and get stock information
                    Product product = productDAO.findById(productId);
                    if (product != null) {
                        // Check stock availability
                        if (product.getQuantity() < quantity) {
                            session.setAttribute("toastMessage", 
                                "Sản phẩm " + product.getProductName() + " không đủ tồn kho! " +
                                "Tồn kho hiện tại: " + product.getQuantity() + ", Yêu cầu: " + quantity);
                            session.setAttribute("toastType", "warning");
                            hasStockIssue = true;
                        }
                        
                        // Calculate line total
                        BigDecimal lineTotal = unitPrice.multiply(BigDecimal.valueOf(quantity));
                        total = total.add(lineTotal);
                    }
                } catch (NumberFormatException e) {
                    // Skip invalid entries
                }
            }
        }
        
        if (hasStockIssue) {
            session.setAttribute("hasStockWarning", true);
        }
        
        return total;
    }
} 