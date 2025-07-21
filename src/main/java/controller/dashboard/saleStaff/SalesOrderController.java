package controller.dashboard.saleStaff;

import dao.ProductDAO;
import dao.SalesOrderDAO;
import dao.SalesOrderDetailDAO;
import dao.UserDAO;
import dao.InventoryDAO;
import dao.WarehouseDAO;
import utils.SessionUtil;
import model.Product;
import model.SalesOrder;
import model.SalesOrderDetail;
import model.User;
import model.Warehouse;
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

@WebServlet(name = "SalesOrderController", urlPatterns = { "/sale-staff/sales-order" })
public class SalesOrderController extends HttpServlet {

    private SalesOrderDAO salesOrderDAO;
    private SalesOrderDetailDAO salesOrderDetailDAO;
    private ProductDAO productDAO;
    private UserDAO userDAO;
    private InventoryDAO inventoryDAO;
    private WarehouseDAO warehouseDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        salesOrderDAO = new SalesOrderDAO();
        salesOrderDetailDAO = new SalesOrderDetailDAO();
        productDAO = new ProductDAO();
        userDAO = new UserDAO();
        inventoryDAO = new InventoryDAO();
        warehouseDAO = new WarehouseDAO();
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
                listMyOrders(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "get-inventory":
                getInventory(request, response);
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

    private void listMyOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        List<SalesOrder> orders = salesOrderDAO.findOrdersWithFilters(statusFilter, customerFilter, userIdFilter, null,
                page, pageSize);
        int totalOrders = salesOrderDAO.getTotalFilteredOrders(statusFilter, customerFilter, userIdFilter, null);
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);

        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("customerFilter", customerFilter);

        request.getRequestDispatcher("/view/dashboard/saleStaff/salesOrder/salesOrderList.jsp").forward(request,
                response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get all active products for selection with detailed information
            List<Product> products = productDAO.findActiveProducts();

            // Create a list of maps containing product and inventory information
            List<Map<String, Object>> productsWithInventory = new ArrayList<>();

            if (products != null && !products.isEmpty()) {
                for (Product p : products) {
                    // Don't get quantity here since it depends on warehouse selection
                    // The quantity will be fetched dynamically via AJAX based on selected warehouse

                    // Create a map with product info only
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
                    // Don't set quantity here - will be fetched per warehouse

                    productsWithInventory.add(productWithInventory);
                }
            } else {
                System.err.println("ERROR: No products found or products list is empty!");
            }

            // Get all warehouses for selection
            List<Warehouse> warehouses = warehouseDAO.findAll();

            request.setAttribute("products", productsWithInventory);
            request.setAttribute("warehouses", warehouses);

            // Set product count for JSP
            int productCount = productsWithInventory != null ? productsWithInventory.size() : 0;
            request.setAttribute("productCount", productCount);

            request.getRequestDispatcher("/view/dashboard/saleStaff/salesOrder/createSalesOrder.jsp").forward(request,
                    response);
        } catch (Exception e) {
            System.err.println("ERROR in showCreateForm: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
        }
    }

    private void getInventory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            int warehouseId = Integer.parseInt(request.getParameter("warehouseId"));

            model.Inventory inventory = inventoryDAO.getInventoryByProductAndWarehouse(productId, warehouseId);

            int quantity = (inventory != null) ? inventory.getQuantityOnHand() : 0;

            response.getWriter().write("{\"quantity\": " + quantity + "}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid request: " + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }

    private void createOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Get order information
            String customerName = request.getParameter("customerName");
            String notes = request.getParameter("notes");
            String orderDateStr = request.getParameter("orderDate");
            String warehouseIdStr = request.getParameter("warehouseId");

            // Parse order date
            Date orderDate = Date.valueOf(orderDateStr != null ? orderDateStr : LocalDate.now().toString());

            // Validate warehouse selection
            if (warehouseIdStr == null || warehouseIdStr.isEmpty()) {
                session.setAttribute("toastMessage", "Vui lòng chọn kho xuất hàng!");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=create");
                return;
            }

            Integer warehouseId = Integer.parseInt(warehouseIdStr);
            Warehouse warehouse = warehouseDAO.findById(warehouseId);
            if (warehouse == null) {
                session.setAttribute("toastMessage", "Kho xuất hàng không hợp lệ!");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=create");
                return;
            }

            // Get product details from form for validation
            String[] productIds = request.getParameterValues("productId[]");
            String[] quantities = request.getParameterValues("quantity[]");
            String[] unitPrices = request.getParameterValues("unitPrice[]");

            // Basic validation: Check if any product was added
            if (productIds == null || productIds.length == 0) {
                session.setAttribute("toastMessage", "Vui lòng thêm ít nhất một sản phẩm vào đơn hàng.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=create");
                return;
            }

            // Create sales order object
            SalesOrder salesOrder = new SalesOrder();
            salesOrder.setCustomerName(customerName);
            salesOrder.setUserId(currentUser.getUserId());
            salesOrder.setOrderDate(orderDate);
            salesOrder.setStatus("pending_stock_check"); // Set a more appropriate initial status
            salesOrder.setNotes(notes);
            salesOrder.setWarehouseId(warehouseId);

            // Use a map to handle product aggregation and prevent duplicates from form submission
            Map<Integer, SalesOrderDetail> productMap = new HashMap<>();
            if (productIds != null) {
                for (int i = 0; i < productIds.length; i++) {
                    // Trim the product ID to handle whitespace and check if it's genuinely empty
                    String productIdStr = (productIds[i] != null) ? productIds[i].trim() : "";
                    if (productIdStr.isEmpty() || 
                        quantities[i] == null || quantities[i].trim().isEmpty() || 
                        unitPrices[i] == null || unitPrices[i].trim().isEmpty()) {
                        continue;
                    }

                    int productId = Integer.parseInt(productIdStr);
                    
                    // If a product is added more than once, we only take the first entry.
                    if (productMap.containsKey(productId)) {
                        continue; 
                    }

                    int quantity = Integer.parseInt(quantities[i]);
                    BigDecimal unitPrice = new BigDecimal(unitPrices[i]);

                    SalesOrderDetail detail = new SalesOrderDetail();
                    detail.setProductId(productId);
                    detail.setQuantityOrdered(quantity);
                    detail.setUnitSalePrice(unitPrice);
                    productMap.put(productId, detail);
                }
            }

            List<SalesOrderDetail> details = new ArrayList<>(productMap.values());

            if (details.isEmpty()) {
                session.setAttribute("toastMessage", "Đơn hàng không có sản phẩm nào hợp lệ.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=create");
                return;
            }

            // To prevent cascading saves from the persistence layer causing duplicates,
            // we first insert the SalesOrder without its details to get an ID.
            int salesOrderId = salesOrderDAO.insert(salesOrder);

            if (salesOrderId != -1) {
                // Now, assign the retrieved ID to each detail and insert them manually.
                // This ensures details are saved exactly once and prevents duplication.
                for (SalesOrderDetail detail : details) {
                    detail.setSalesOrderId(salesOrderId);
                    salesOrderDetailDAO.insert(detail);
                }
                
                // After saving, we can associate the details with the order object if needed,
                // though it's not strictly necessary here as we are redirecting.
                salesOrder.setDetails(details);

                session.setAttribute("toastMessage", "Tạo đơn hàng thành công!");
                session.setAttribute("toastType", "success");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
            } else {
                session.setAttribute("toastMessage", "Tạo đơn hàng thất bại. Vui lòng thử lại.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=create");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("toastMessage", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=create");
        }
    }

    private void viewOrderDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
                List<SalesOrderDetailDAO.SalesOrderDetailWithProduct> orderDetailsWithProduct = salesOrderDetailDAO
                        .findBySalesOrderIdWithCompleteProductInfo(orderId);

                // Get warehouse info
                Warehouse warehouse = null;
                if (order.getWarehouseId() != null) {
                    warehouse = warehouseDAO.findById(order.getWarehouseId());
                }

                // Calculate total order value
                BigDecimal totalOrderValue = BigDecimal.ZERO;
                for (SalesOrderDetailDAO.SalesOrderDetailWithProduct detail : orderDetailsWithProduct) {
                    totalOrderValue = totalOrderValue.add(detail.getTotalPrice());
                }

                request.setAttribute("order", order);
                request.setAttribute("orderDetailsWithProduct", orderDetailsWithProduct);
                request.setAttribute("totalOrderValue", totalOrderValue);
                request.setAttribute("warehouse", warehouse);

                request.getRequestDispatcher("/view/dashboard/saleStaff/salesOrder/viewSalesOrder.jsp").forward(request,
                        response);
            } else {
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
                List<SalesOrderDetailDAO.SalesOrderDetailWithProduct> orderDetailsWithProduct = salesOrderDetailDAO
                        .findBySalesOrderIdWithCompleteProductInfo(orderId);

                // Get all active products for selection
                List<Product> products = productDAO.findActiveProducts();

                // Get all warehouses for selection
                List<Warehouse> warehouses = warehouseDAO.findAll();

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

                request.setAttribute("order", order);
                request.setAttribute("orderDetailsWithProduct", orderDetailsWithProduct);
                request.setAttribute("products", productsWithInventory);
                request.setAttribute("warehouses", warehouses);

                request.getRequestDispatcher("/view/dashboard/saleStaff/salesOrder/editSalesOrder.jsp").forward(request,
                        response);
            } else {
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-order?action=list");
        }
    }

    private void updateOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
            String warehouseIdStr = request.getParameter("warehouseId");

            Date orderDate = Date.valueOf(orderDateStr != null ? orderDateStr : LocalDate.now().toString());

            existingOrder.setCustomerName(customerName);
            existingOrder.setNotes(notes);
            existingOrder.setOrderDate(orderDate);
            if (warehouseIdStr != null && !warehouseIdStr.isEmpty()) {
                existingOrder.setWarehouseId(Integer.parseInt(warehouseIdStr));
            }

            boolean orderUpdated = salesOrderDAO.update(existingOrder);

            if (orderUpdated) {
                // Get new order details
                String[] productIds = request.getParameterValues("productId[]");
                String[] quantities = request.getParameterValues("quantity[]");
                String[] unitPrices = request.getParameterValues("unitPrice[]");

                // Only proceed with detail updates if product data was submitted
                if (productIds != null) {
                    // Delete existing order details first
                    salesOrderDetailDAO.deleteBySalesOrderId(orderId);

                    // NOTE: If new products added on the edit page are not being saved,
                    // the issue is likely in the frontend JavaScript. The script that adds new rows
                    // to the product table must ensure the new <input> fields have the correct `name`
                    // attributes (e.g., "productId[]", "quantity[]") so they are included in the form submission.

                    // Use a map to handle product aggregation and prevent duplicates
                    Map<Integer, SalesOrderDetail> productMap = new HashMap<>();
                    if (quantities != null && unitPrices != null) {
                        for (int i = 0; i < productIds.length; i++) {
                            String productIdStr = (productIds[i] != null) ? productIds[i].trim() : "";
                            if (productIdStr.isEmpty() ||
                                    quantities[i] == null || quantities[i].trim().isEmpty() ||
                                    unitPrices[i] == null || unitPrices[i].trim().isEmpty()) {
                                continue;
                            }
                            
                            int productId = Integer.parseInt(productIdStr);
                            
                            // Skip duplicates to ensure data integrity
                            if (productMap.containsKey(productId)) {
                                continue;
                            }

                            SalesOrderDetail detail = new SalesOrderDetail();
                            detail.setSalesOrderId(orderId);
                            detail.setProductId(productId);
                            detail.setQuantityOrdered(Integer.parseInt(quantities[i]));
                            detail.setUnitSalePrice(new BigDecimal(unitPrices[i]));
                            productMap.put(productId, detail);
                        }
                    }
                    List<SalesOrderDetail> orderDetails = new ArrayList<>(productMap.values());

                    if (!orderDetails.isEmpty()) {
                        // Insert details one-by-one for consistency and easier debugging
                        for (SalesOrderDetail detail : orderDetails) {
                            salesOrderDetailDAO.insert(detail);
                        }
                        session.setAttribute("toastMessage", "Đơn bán hàng đã được cập nhật thành công!");
                        session.setAttribute("toastType", "success");
                    } else {
                        // This means the user submitted an empty product list, so all items are removed.
                        session.setAttribute("toastMessage", "Đơn hàng được cập nhật và tất cả sản phẩm đã được xóa.");
                        session.setAttribute("toastType", "success");
                    }
                } else {
                    // If productIds is null, it means the product section of the form wasn't submitted.
                    // We assume the user only intended to update the order's header information.
                    session.setAttribute("toastMessage", "Thông tin đơn hàng đã được cập nhật (sản phẩm không thay đổi).");
                    session.setAttribute("toastType", "success");
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

    private void cancelOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
     * Validate product availability and calculate order total (legacy method -
     * total stock from all warehouses)
     */
    private BigDecimal validateAndCalculateOrderTotal(String[] productIds, String[] quantities,
            String[] unitPrices, HttpSession session) {
        return validateAndCalculateOrderTotal(productIds, quantities, unitPrices, null, session);
    }

    /**
     * Validate product availability and calculate order total with
     * warehouse-specific stock check
     */
    private BigDecimal validateAndCalculateOrderTotal(String[] productIds, String[] quantities,
            String[] unitPrices, Integer warehouseId, HttpSession session) {
        if (productIds == null || quantities == null || unitPrices == null) {
            return BigDecimal.ZERO;
        }

        BigDecimal total = BigDecimal.ZERO;
        boolean hasStockIssue = false;
        String warehouseName = "";

        // Get warehouse name for error messages
        if (warehouseId != null) {
            Warehouse warehouse = warehouseDAO.findById(warehouseId);
            warehouseName = warehouse != null ? warehouse.getWarehouseName() : "Kho không xác định";
        }

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
                        // Check stock availability from inventory
                        Integer stockQuantity;
                        String stockMessage;

                        if (warehouseId != null) {
                            // Check stock in specific warehouse
                            stockQuantity = inventoryDAO.getQuantityByProductIdAndWarehouse(productId, warehouseId);
                            stockMessage = "Sản phẩm " + product.getProductName() + " tại " + warehouseName +
                                    " không đủ tồn kho! Tồn kho hiện tại: " + stockQuantity + ", Yêu cầu: " + quantity;
                        } else {
                            // Check total stock from all warehouses (legacy)
                            stockQuantity = inventoryDAO.getQuantityByProductId(productId);
                            stockMessage = "Sản phẩm " + product.getProductName() + " không đủ tồn kho! " +
                                    "Tồn kho hiện tại: " + stockQuantity + ", Yêu cầu: " + quantity;
                        }

                        if (stockQuantity < quantity) {
                            session.setAttribute("toastMessage", stockMessage);
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
