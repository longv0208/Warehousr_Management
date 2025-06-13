package controller.dashboard.admin;

import dao.ProductDAO;
import dao.SalesOrderDAO;
import dao.SalesOrderDetailDAO;
import dao.UserDAO;
import dao.InventoryDAO;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ManageSalesOrderController", urlPatterns = {"/admin/manage-sales-order"})
public class ManageSalesOrderController extends HttpServlet {

    private SalesOrderDAO salesOrderDAO;
    private SalesOrderDetailDAO salesOrderDetailDAO;
    private ProductDAO productDAO;
    private UserDAO userDAO;
    private InventoryDAO inventoryDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        salesOrderDAO = new SalesOrderDAO();
        salesOrderDetailDAO = new SalesOrderDetailDAO();
        productDAO = new ProductDAO();
        userDAO = new UserDAO();
        inventoryDAO = new InventoryDAO();
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
            case "edit":
                updateOrder(request, response);
                break;
            case "update-status":
                updateOrderStatus(request, response);
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
        
        // Prepare valid statuses for each order
        Map<Integer, List<String>> orderValidStatuses = new HashMap<>();
        Map<String, String> statusDisplayNames = new HashMap<>();
        
        // Prepare status display names
        statusDisplayNames.put("pending_stock_check", "Chờ kiểm tra kho");
        statusDisplayNames.put("awaiting_shipment", "Chờ giao hàng");
        statusDisplayNames.put("shipped", "Đã giao");
        statusDisplayNames.put("completed", "Hoàn thành");
        statusDisplayNames.put("cancelled", "Đã hủy");
        
        for (SalesOrder order : orders) {
            List<String> validStatuses = getValidNextStatuses(order.getStatus());
            orderValidStatuses.put(order.getSalesOrderId(), validStatuses);
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
        request.setAttribute("orderValidStatuses", orderValidStatuses);
        request.setAttribute("statusDisplayNames", statusDisplayNames);

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
                
                // Create combined order details with product information
                List<Map<String, Object>> orderDetailsWithProduct = new ArrayList<>();
                BigDecimal totalOrderValue = BigDecimal.ZERO;
                
                for (SalesOrderDetail detail : orderDetails) {
                    Product product = productDAO.findById(detail.getProductId());
                    if (product != null) {
                        // Create a map with combined information
                        Map<String, Object> detailWithProduct = new HashMap<>();
                        detailWithProduct.put("productCode", product.getProductCode());
                        detailWithProduct.put("productName", product.getProductName());
                        detailWithProduct.put("unit", product.getUnit());
                        detailWithProduct.put("quantityOrdered", detail.getQuantityOrdered());
                        detailWithProduct.put("unitSalePrice", detail.getUnitSalePrice());
                        
                        BigDecimal totalPrice = detail.getUnitSalePrice().multiply(new BigDecimal(detail.getQuantityOrdered()));
                        detailWithProduct.put("totalPrice", totalPrice);
                        
                        totalOrderValue = totalOrderValue.add(totalPrice);
                        orderDetailsWithProduct.add(detailWithProduct);
                    }
                }
                
                request.setAttribute("order", order);
                request.setAttribute("orderDetailsWithProduct", orderDetailsWithProduct);
                request.setAttribute("totalOrderValue", totalOrderValue);
                request.setAttribute("creator", creator);
                
                request.getRequestDispatcher("/view/dashboard/admin/salesOrder/viewSalesOrder.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
                // Validate that order can only be edited when status is pending_stock_check
                if (!"pending_stock_check".equals(order.getStatus())) {
                    session.setAttribute("toastMessage", "Chỉ có thể chỉnh sửa đơn hàng khi trạng thái là 'Chờ kiểm tra kho'. Trạng thái hiện tại: '" + getStatusDisplayName(order.getStatus()) + "'");
                    session.setAttribute("toastType", "error");
                    response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=view&id=" + orderId);
                    return;
                }
                
                List<SalesOrderDetail> orderDetails = salesOrderDetailDAO.findBySalesOrderId(orderId);
                List<Product> products = productDAO.findActiveProducts();
                User creator = userDAO.findById(order.getUserId());
                
                // Get all users for staff selection
                List<User> users = userDAO.findAll();
                List<User> salesStaff = new ArrayList<>();
                for (User user : users) {
                    if ("sales_staff".equals(user.getRoleId())) {
                        salesStaff.add(user);
                    }
                }
                
                // Create a list of maps containing product and inventory information
                List<Map<String, Object>> productsWithInventory = new ArrayList<>();
                if (products != null && !products.isEmpty()) {
                    for (Product p : products) {
                        Integer quantity = inventoryDAO.getQuantityByProductId(p.getProductId());
                        
                        // Create a map with product and inventory info
                        Map<String, Object> productWithInventory = new HashMap<>();
                        productWithInventory.put("productId", p.getProductId());
                        productWithInventory.put("productCode", p.getProductCode());
                        productWithInventory.put("productName", p.getProductName());
                        productWithInventory.put("description", p.getDescription());
                        productWithInventory.put("unit", p.getUnit());
                        productWithInventory.put("purchasePrice", p.getPurchasePrice());
                        productWithInventory.put("salePrice", p.getSalePrice());
                        productWithInventory.put("supplierId", p.getSupplierId());
                        productWithInventory.put("lowStockThreshold", p.getLowStockThreshold());
                        productWithInventory.put("isActive", p.getIsActive());
                        productWithInventory.put("quantity", quantity != null ? quantity : 0);
                        
                        productsWithInventory.add(productWithInventory);
                    }
                }
                
                // Create combined order details with product information for editing
                List<Map<String, Object>> orderDetailsWithProduct = new ArrayList<>();
                
                for (SalesOrderDetail detail : orderDetails) {
                    Product product = productDAO.findById(detail.getProductId());
                    if (product != null) {
                        Map<String, Object> detailWithProduct = new HashMap<>();
                        detailWithProduct.put("productId", detail.getProductId());
                        detailWithProduct.put("productCode", product.getProductCode());
                        detailWithProduct.put("productName", product.getProductName());
                        detailWithProduct.put("unit", product.getUnit());
                        detailWithProduct.put("quantityOrdered", detail.getQuantityOrdered());
                        detailWithProduct.put("unitSalePrice", detail.getUnitSalePrice());
                        
                        // Get quantity from inventory instead of product
                        Integer availableQuantity = inventoryDAO.getQuantityByProductId(product.getProductId());
                        detailWithProduct.put("availableQuantity", availableQuantity);
                        
                        orderDetailsWithProduct.add(detailWithProduct);
                    }
                }
                
                request.setAttribute("order", order);
                request.setAttribute("orderDetails", orderDetails);
                request.setAttribute("orderDetailsWithProduct", orderDetailsWithProduct);
                request.setAttribute("products", productsWithInventory);
                request.setAttribute("salesStaff", salesStaff);
                request.setAttribute("creator", creator);
                
                request.getRequestDispatcher("/view/dashboard/admin/salesOrder/editSalesOrder.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
        }
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
            
            // Validate that order can only be updated when status is pending_stock_check
            if (!"pending_stock_check".equals(existingOrder.getStatus())) {
                session.setAttribute("toastMessage", "Chỉ có thể cập nhật đơn hàng khi trạng thái là 'Chờ kiểm tra kho'. Trạng thái hiện tại: '" + getStatusDisplayName(existingOrder.getStatus()) + "'");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=view&id=" + orderId);
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
        HttpSession session = request.getSession();
        String idStr = request.getParameter("id");
        String newStatus = request.getParameter("status");
        
        if (idStr == null || idStr.isEmpty() || newStatus == null || newStatus.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            SalesOrder order = salesOrderDAO.findById(orderId);
            
            if (order == null) {
                session.setAttribute("toastMessage", "Không tìm thấy đơn hàng!");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
                return;
            }
            
            String currentStatus = order.getStatus();
            
            // Validate status transition
            if (!isValidStatusTransition(currentStatus, newStatus)) {
                session.setAttribute("toastMessage", getStatusTransitionErrorMessage(currentStatus, newStatus));
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-sales-order?action=list");
                return;
            }
            
            boolean updated = salesOrderDAO.updateStatus(orderId, newStatus);
            
            if (updated) {
                session.setAttribute("toastMessage", "Trạng thái đơn hàng đã được cập nhật thành công từ '" + 
                    getStatusDisplayName(currentStatus) + "' thành '" + getStatusDisplayName(newStatus) + "'!");
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
    
    /**
     * Validate if the status transition is allowed
     */
    private boolean isValidStatusTransition(String currentStatus, String newStatus) {
        // Handle null values
        if (currentStatus == null || newStatus == null) {
            return false;
        }
        
        // If same status, no transition needed
        if (currentStatus.equals(newStatus)) {
            return false;
        }
        
        Map<String, List<String>> validTransitions = new HashMap<>();
        
        // Define valid status transitions
        validTransitions.put("pending_stock_check", List.of("awaiting_shipment", "cancelled"));
        validTransitions.put("awaiting_shipment", List.of("shipped", "pending_stock_check", "cancelled"));
        validTransitions.put("shipped", List.of("completed", "awaiting_shipment", "cancelled"));
        validTransitions.put("completed", List.of("shipped")); // Allow reverting completed orders if needed
        validTransitions.put("cancelled", List.of("pending_stock_check")); // Allow restoring cancelled orders
        
        List<String> allowedNextStatuses = validTransitions.get(currentStatus);
        return allowedNextStatuses != null && allowedNextStatuses.contains(newStatus);
    }
    
    /**
     * Get user-friendly status display name
     */
    private String getStatusDisplayName(String status) {
        if (status == null) {
            return "Không xác định";
        }
        
        switch (status) {
            case "pending_stock_check":
                return "Chờ kiểm tra kho";
            case "awaiting_shipment":
                return "Chờ giao hàng";
            case "shipped":
                return "Đã giao";
            case "completed":
                return "Hoàn thành";
            case "cancelled":
                return "Đã hủy";
            default:
                return status;
        }
    }
    
    /**
     * Get specific error message for invalid status transition
     */
    private String getStatusTransitionErrorMessage(String currentStatus, String newStatus) {
        String currentDisplayName = getStatusDisplayName(currentStatus);
        String newDisplayName = getStatusDisplayName(newStatus);
        
        // Specific error messages for common invalid transitions
        if ("completed".equals(currentStatus) && !"shipped".equals(newStatus)) {
            return "Đơn hàng đã hoàn thành chỉ có thể chuyển về trạng thái 'Đã giao' nếu cần xử lý vấn đề.";
        }
        
        if ("cancelled".equals(currentStatus) && !"pending_stock_check".equals(newStatus)) {
            return "Đơn hàng đã hủy chỉ có thể được khôi phục về trạng thái 'Chờ kiểm tra kho'.";
        }
        
        if ("shipped".equals(currentStatus) && "pending_stock_check".equals(newStatus)) {
            return "Đơn hàng đã giao không thể chuyển về trạng thái 'Chờ kiểm tra kho'. Chỉ có thể chuyển về 'Chờ giao hàng' nếu cần giao lại.";
        }
        
        // Generic error message
        return "Không thể chuyển trạng thái từ '" + currentDisplayName + "' thành '" + newDisplayName + "'. Vui lòng kiểm tra quy trình xử lý đơn hàng.";
    }
    
    /**
     * Get list of valid next statuses for a given current status
     * This method is public so JSP can access it
     */
    public List<String> getValidNextStatuses(String currentStatus) {
        // Handle null status
        if (currentStatus == null) {
            return new ArrayList<>();
        }
        
        Map<String, List<String>> validTransitions = new HashMap<>();
        
        // Define valid status transitions (same as in isValidStatusTransition)
        validTransitions.put("pending_stock_check", List.of("awaiting_shipment", "cancelled"));
        validTransitions.put("awaiting_shipment", List.of("shipped", "pending_stock_check", "cancelled"));
        validTransitions.put("shipped", List.of("completed", "awaiting_shipment", "cancelled"));
        validTransitions.put("completed", List.of("shipped"));
        validTransitions.put("cancelled", List.of("pending_stock_check"));
        
        return validTransitions.getOrDefault(currentStatus, new ArrayList<>());
    }
    
    /**
     * Public method to get status display name for JSP
     */
    public String getStatusDisplayNamePublic(String status) {
        return getStatusDisplayName(status);
    }


} 