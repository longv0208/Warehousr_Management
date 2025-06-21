package controller.dashboard.purchasingStaff;

import dao.*;
import model.*;
import utils.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

@WebServlet(name = "PurchaseStaffController", urlPatterns = {
    "/purchase-staff/inventory", 
    "/purchase-staff/purchase-request",
    "/purchase-staff/purchase-order"
})
public class PurchaseStaffController extends HttpServlet {

    private InventoryDAO inventoryDAO;
    private ProductDAO productDAO;
    private WarehouseDAO warehouseDAO;
    private SupplierDAO supplierDAO;
    private PurchaseRequestDAO purchaseRequestDAO;
    private PurchaseRequestDetailDAO purchaseRequestDetailDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        inventoryDAO = new InventoryDAO();
        productDAO = new ProductDAO();
        warehouseDAO = new WarehouseDAO();
        supplierDAO = new SupplierDAO();
        purchaseRequestDAO = new PurchaseRequestDAO();
        purchaseRequestDetailDAO = new PurchaseRequestDetailDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        String action = request.getParameter("action");
        
        // Kiểm tra session và role
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Kiểm tra role - chỉ purchasing_staff được truy cập
        if (!"purchasing_staff".equals(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này");
            return;
        }

        switch (path) {
            case "/purchase-staff/inventory":
                showInventoryList(request, response);
                break;
            case "/purchase-staff/purchase-request":
                if ("create".equals(action)) {
                    showCreatePurchaseRequestForm(request, response);
                } else if ("view".equals(action)) {
                    viewPurchaseRequest(request, response);
                } else {
                    listPurchaseRequests(request, response, currentUser);
                }
                break;
            case "/purchase-staff/purchase-order":
                if ("create".equals(action)) {
                    showCreatePurchaseOrderForm(request, response);
                } else if ("view".equals(action)) {
                    viewPurchaseOrder(request, response);
                } else {
                    listPurchaseOrders(request, response);
                }
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/purchase-staff/inventory");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        String action = request.getParameter("action");
        
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Kiểm tra role - chỉ purchasing_staff được truy cập
        if (!"purchasing_staff".equals(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này");
            return;
        }

        switch (path) {
            case "/purchase-staff/purchase-request":
                if ("create".equals(action)) {
                    createPurchaseRequest(request, response, currentUser);
                }
                break;
            case "/purchase-staff/purchase-order":
                if ("create".equals(action)) {
                    createPurchaseOrder(request, response, currentUser);
                }
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/purchase-staff/inventory");
                break;
        }
    }

    // ============ INVENTORY MANAGEMENT ============
    private void showInventoryList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String warehouseIdStr = request.getParameter("warehouseId");
        String searchTerm = request.getParameter("searchTerm");
        
        // Sử dụng method mới để lấy thông tin inventory kèm product và warehouse
        List<InventoryWithProduct> inventoryList = inventoryDAO.findAllWithProductInfo();
        List<Warehouse> warehouses = warehouseDAO.findAll();
        
        // Filter by warehouse if specified
        if (warehouseIdStr != null && !warehouseIdStr.isEmpty()) {
            try {
                Integer warehouseId = Integer.parseInt(warehouseIdStr);
                inventoryList = inventoryList.stream()
                    .filter(inv -> inv.getWarehouseId().equals(warehouseId))
                    .collect(java.util.stream.Collectors.toList());
            } catch (NumberFormatException e) {
                // Handle error
            }
        }
        
        // Filter by search term if specified
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            String searchLower = searchTerm.toLowerCase().trim();
            inventoryList = inventoryList.stream()
                .filter(inv -> 
                    (inv.getProductName() != null && inv.getProductName().toLowerCase().contains(searchLower)) ||
                    (inv.getProductCode() != null && inv.getProductCode().toLowerCase().contains(searchLower))
                )
                .collect(java.util.stream.Collectors.toList());
        }
        
        request.setAttribute("inventoryList", inventoryList);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("warehouseId", warehouseIdStr);
        request.setAttribute("searchTerm", searchTerm);
        
        request.getRequestDispatcher("/view/dashboard/purchasingStaff/inventory-list.jsp").forward(request, response);
    }

    // ============ PURCHASE REQUEST MANAGEMENT ============
    private void listPurchaseRequests(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws ServletException, IOException {
        String status = request.getParameter("status");
        
        List<PurchaseRequest> requests;
        if (status != null && !status.isEmpty()) {
            requests = purchaseRequestDAO.findByStatus(status);
        } else {
            requests = purchaseRequestDAO.findByRequestedBy(currentUser.getUserId());
        }
        
        request.setAttribute("purchaseRequests", requests);
        request.setAttribute("status", status);
        
        request.getRequestDispatcher("/view/dashboard/purchasingStaff/purchase-request/request-list.jsp").forward(request, response);
    }

    private void showCreatePurchaseRequestForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Product> products = productDAO.findAll();
        List<Supplier> suppliers = supplierDAO.findAll();
        
        request.setAttribute("products", products);
        request.setAttribute("suppliers", suppliers);
        
        request.getRequestDispatcher("/view/dashboard/purchasingStaff/create-purchase-request.jsp").forward(request, response);
    }

    private void createPurchaseRequest(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws ServletException, IOException {
        try {
            // Get request parameters
            String notes = request.getParameter("notes");
            String[] productIds = request.getParameterValues("productId");
            String[] quantities = request.getParameterValues("quantity");
            String[] supplierIds = request.getParameterValues("supplierId");
            String[] productNotes = request.getParameterValues("productNotes");

            // Create purchase request
            PurchaseRequest purchaseRequest = PurchaseRequest.builder()
                .requestCode(purchaseRequestDAO.generateRequestCode())
                .userIdRequester(currentUser.getUserId())
                .status("pending_approval")
                .notes(notes)
                .requestDate(new Timestamp(System.currentTimeMillis()))
                .build();

            int requestId = purchaseRequestDAO.insert(purchaseRequest);
            
            if (requestId > 0 && productIds != null) {
                // Insert request details
                for (int i = 0; i < productIds.length; i++) {
                    if (productIds[i] != null && !productIds[i].isEmpty()) {
                        PurchaseRequestDetail detail = PurchaseRequestDetail.builder()
                            .requestId(requestId)
                            .productId(Integer.parseInt(productIds[i]))
                            .requestedQuantity(Integer.parseInt(quantities[i]))
                            .suggestedSupplierId(supplierIds[i] != null && !supplierIds[i].isEmpty() ? 
                                Integer.parseInt(supplierIds[i]) : null)
                            .notes(productNotes[i])
                            .build();
                        
                        purchaseRequestDetailDAO.insert(detail);
                    }
                }
                
                request.getSession().setAttribute("successMessage", "Tạo yêu cầu nhập hàng thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra khi tạo yêu cầu!");
            }

        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
    }

    private void viewPurchaseRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String requestIdStr = request.getParameter("id");
        try {
            Integer requestId = Integer.parseInt(requestIdStr);
            PurchaseRequest purchaseRequest = purchaseRequestDAO.findById(requestId);
            List<PurchaseRequestDetail> details = purchaseRequestDetailDAO.findByRequestId(requestId);
            
            request.setAttribute("purchaseRequest", purchaseRequest);
            request.setAttribute("requestDetails", details);
            
            request.getRequestDispatcher("/view/dashboard/purchasingStaff/purchase-request/view-request.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
        }
    }

    // ============ PURCHASE ORDER MANAGEMENT ============
    private void listPurchaseOrders(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Hiển thị trang purchase order với thông báo đang phát triển
        request.getRequestDispatcher("/view/dashboard/purchasingStaff/purchase-order/purchase-order-list.jsp").forward(request, response);
    }

    private void showCreatePurchaseOrderForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Tạm thời redirect về inventory cho đến khi implement đầy đủ purchase order
        response.sendRedirect(request.getContextPath() + "/purchase-staff/inventory");
    }

    private void viewPurchaseOrder(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Tạm thời redirect về inventory cho đến khi implement đầy đủ purchase order
        response.sendRedirect(request.getContextPath() + "/purchase-staff/inventory");
    }

    private void createPurchaseOrder(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws ServletException, IOException {
        // Tạm thời redirect về inventory cho đến khi implement đầy đủ purchase order
        response.sendRedirect(request.getContextPath() + "/purchase-staff/inventory");
    }
} 