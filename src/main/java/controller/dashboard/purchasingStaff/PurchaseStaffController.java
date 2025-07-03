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
import java.io.OutputStream;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

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
                if ("export".equals(action)) {
                    exportInventoryToExcel(request, response);
                } else {
                    showInventoryList(request, response);
                }
                break;
            case "/purchase-staff/purchase-request":
                if ("create".equals(action)) {
                    showCreatePurchaseRequestForm(request, response);
                } else if ("view".equals(action)) {
                    viewPurchaseRequest(request, response);
                } else if ("edit".equals(action)) {
                    showEditPurchaseRequestForm(request, response, currentUser);
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
                } else if ("edit".equals(action)) {
                    editPurchaseRequest(request, response, currentUser);
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
        List<InventoryWithProduct> inventoryList;
        try {
            inventoryList = inventoryDAO.findAllWithProductInfo();
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Lỗi khi tải danh sách tồn kho: " + e.getMessage());
            inventoryList = new ArrayList<>();
        }
        
        // Filter by warehouse if specified
        if (warehouseIdStr != null && !warehouseIdStr.isEmpty()) {
            try {
                Integer warehouseId = Integer.parseInt(warehouseIdStr);
                inventoryList = inventoryList.stream()
                    .filter(inv -> inv.getWarehouseId() != null && inv.getWarehouseId().equals(warehouseId))
                    .collect(java.util.stream.Collectors.toList());
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "ID kho không hợp lệ");
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
        
        List<Warehouse> warehouses = warehouseDAO.findAll();
        
        request.setAttribute("inventoryList", inventoryList);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("warehouseId", warehouseIdStr);
        request.setAttribute("searchTerm", searchTerm);
        
        request.getRequestDispatcher("/view/dashboard/purchasingStaff/inventory-list.jsp").forward(request, response);
    }

    // Export inventory to Excel
    private void exportInventoryToExcel(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String warehouseIdStr = request.getParameter("warehouseId");
        String searchTerm = request.getParameter("searchTerm");
        
        // Fetch inventory data
        List<InventoryWithProduct> inventoryList;
        try {
            inventoryList = inventoryDAO.findAllWithProductInfo();
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Lỗi khi tải dữ liệu tồn kho để xuất Excel: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/purchase-staff/inventory");
            return;
        }
        
        // Apply filters
        if (warehouseIdStr != null && !warehouseIdStr.isEmpty()) {
            try {
                Integer warehouseId = Integer.parseInt(warehouseIdStr);
                inventoryList = inventoryList.stream()
                    .filter(inv -> inv.getWarehouseId() != null && inv.getWarehouseId().equals(warehouseId))
                    .collect(java.util.stream.Collectors.toList());
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "ID kho không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/inventory");
                return;
            }
        }
        
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            String searchLower = searchTerm.toLowerCase().trim();
            inventoryList = inventoryList.stream()
                .filter(inv -> 
                    (inv.getProductName() != null && inv.getProductName().toLowerCase().contains(searchLower)) ||
                    (inv.getProductCode() != null && inv.getProductCode().toLowerCase().contains(searchLower))
                )
                .collect(java.util.stream.Collectors.toList());
        }

        // Create Excel workbook
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Báo cáo tồn kho");
            
            // Create header row
            Row headerRow = sheet.createRow(0);
            String[] headers = {"STT", "Kho", "Mã sản phẩm", "Tên sản phẩm", "Đơn vị", "Số lượng tồn", "Cập nhật", "Trạng thái"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                // Bold header
                CellStyle headerStyle = workbook.createCellStyle();
                Font headerFont = workbook.createFont();
                headerFont.setBold(true);
                headerStyle.setFont(headerFont);
                cell.setCellStyle(headerStyle);
            }

            // Fill data
            int rowNum = 1;
            for (int i = 0; i < inventoryList.size(); i++) {
                InventoryWithProduct inventory = inventoryList.get(i);
                Row row = sheet.createRow(rowNum++);
                
                // STT
                row.createCell(0).setCellValue(i + 1);
                // Kho
                row.createCell(1).setCellValue(inventory.getWarehouseName() != null ? inventory.getWarehouseName() : "N/A");
                // Mã sản phẩm
                row.createCell(2).setCellValue(inventory.getProductCode() != null ? inventory.getProductCode() : "N/A");
                // Tên sản phẩm
                row.createCell(3).setCellValue(inventory.getProductName() != null ? inventory.getProductName() : "N/A");
                // Đơn vị
                row.createCell(4).setCellValue(inventory.getUnit() != null ? inventory.getUnit() : "N/A");
                // Số lượng tồn
                row.createCell(5).setCellValue(inventory.getQuantityOnHand());
                // Cập nhật
                row.createCell(6).setCellValue(inventory.getLastUpdated() != null ? 
                    new SimpleDateFormat("dd/MM/yyyy").format(inventory.getLastUpdated()) : "N/A");
                // Trạng thái
                String status;
                if (inventory.getQuantityOnHand() <= 0) {
                    status = "Hết hàng";
                } else if (inventory.getQuantityOnHand() <= 10) {
                    status = "Sắp hết";
                } else {
                    status = "Đủ hàng";
                }
                row.createCell(7).setCellValue(status);
            }

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // Set response headers
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            String filename = "bao_cao_ton_kho_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".xlsx";
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            // Write to response
            try (OutputStream out = response.getOutputStream()) {
                workbook.write(out);
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Lỗi khi xuất báo cáo Excel: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/purchase-staff/inventory");
            return;
        }
    }

    // ============ PURCHASE REQUEST MANAGEMENT ============
    private void listPurchaseRequests(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws ServletException, IOException {
        String status = request.getParameter("status");
        String warehouseIdStr = request.getParameter("warehouseId");
        
        // Lấy danh sách yêu cầu của user hiện tại
        List<PurchaseRequest> requests;
        try {
            requests = purchaseRequestDAO.findByRequestedBy(currentUser.getUserId());
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Lỗi khi tải danh sách yêu cầu nhập hàng: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/purchase-staff/inventory");
            return;
        }
        
        // Filter theo status nếu có
        if (status != null && !status.isEmpty()) {
            requests = requests.stream()
                .filter(req -> status.equals(req.getStatus()))
                .collect(java.util.stream.Collectors.toList());
        }
        
        // Filter theo warehouse nếu có
        if (warehouseIdStr != null && !warehouseIdStr.isEmpty()) {
            try {
                Integer warehouseId = Integer.parseInt(warehouseIdStr);
                requests = requests.stream()
                    .filter(req -> req.getWarehouseId() != null && warehouseId.equals(req.getWarehouseId()))
                    .collect(java.util.stream.Collectors.toList());
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "ID kho không hợp lệ");
            }
        }
        
        // Lấy danh sách warehouses để hiển thị dropdown
        List<Warehouse> warehouses = warehouseDAO.findAll();
        
        request.setAttribute("purchaseRequests", requests);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("status", status);
        request.setAttribute("warehouseId", warehouseIdStr);
        
        request.getRequestDispatcher("/view/dashboard/purchasingStaff/purchase-request/request-list.jsp").forward(request, response);
    }

    private void showCreatePurchaseRequestForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Product> products = productDAO.findAll();
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();
        
        request.setAttribute("products", products);
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("warehouses", warehouses);
        
        request.getRequestDispatcher("/view/dashboard/purchasingStaff/create-purchase-request.jsp").forward(request, response);
    }

    private void showEditPurchaseRequestForm(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws ServletException, IOException {
        String requestIdStr = request.getParameter("id");
        try {
            Integer requestId = Integer.parseInt(requestIdStr);
            PurchaseRequest purchaseRequest = purchaseRequestDAO.findById(requestId);
            
            // Check if request exists, belongs to user, and is editable
            if (purchaseRequest == null) {
                request.getSession().setAttribute("errorMessage", "Yêu cầu không tồn tại!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
                return;
            }
            if (!purchaseRequest.getUserIdRequester().equals(currentUser.getUserId())) {
                request.getSession().setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa yêu cầu này!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
                return;
            }
            if (!"pending_approval".equals(purchaseRequest.getStatus())) {
                request.getSession().setAttribute("errorMessage", "Chỉ có thể chỉnh sửa yêu cầu đang chờ duyệt!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
                return;
            }
            
            List<PurchaseRequestDetail> details = purchaseRequestDetailDAO.findByRequestId(requestId);
            List<Product> products = productDAO.findAll();
            List<Supplier> suppliers = supplierDAO.findAll();
            List<Warehouse> warehouses = warehouseDAO.findAll();
            
            request.setAttribute("purchaseRequest", purchaseRequest);
            request.setAttribute("requestDetails", details);
            request.setAttribute("products", products);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("warehouses", warehouses);
            
            request.getRequestDispatcher("/view/dashboard/purchasingStaff/purchase-request/edit-purchase-request.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "ID yêu cầu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Lỗi khi tải dữ liệu chỉnh sửa: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
        }
    }

    private void createPurchaseRequest(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws ServletException, IOException {
        try {
            // Get request parameters
            String notes = request.getParameter("notes");
            String warehouseIdStr = request.getParameter("warehouseId");
            String[] productIds = request.getParameterValues("productId");
            String[] quantities = request.getParameterValues("quantity");
            String[] supplierIds = request.getParameterValues("supplierId");
            String[] productNotes = request.getParameterValues("productNotes");

            // Validate warehouse ID
            if (warehouseIdStr == null || warehouseIdStr.isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Vui lòng chọn kho nhập hàng!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=create");
                return;
            }

            // Validate product data
            if (productIds == null || productIds.length == 0 || quantities == null || quantities.length == 0) {
                request.getSession().setAttribute("errorMessage", "Vui lòng chọn ít nhất một sản phẩm!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=create");
                return;
            }

            // Validate quantities
            for (String quantity : quantities) {
                try {
                    int qty = Integer.parseInt(quantity);
                    if (qty <= 0) {
                        request.getSession().setAttribute("errorMessage", "Số lượng phải lớn hơn 0!");
                        response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=create");
                        return;
                    }
                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("errorMessage", "Số lượng không hợp lệ!");
                    response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=create");
                    return;
                }
            }

            // Create purchase request
            PurchaseRequest purchaseRequest = PurchaseRequest.builder()
                .requestCode(purchaseRequestDAO.generateRequestCode())
                .userIdRequester(currentUser.getUserId())
                .warehouseId(Integer.parseInt(warehouseIdStr))
                .status("pending_approval")
                .notes(notes)
                .requestDate(new Timestamp(System.currentTimeMillis()))
                .build();

            int requestId = purchaseRequestDAO.insert(purchaseRequest);
            
            if (requestId > 0) {
                // Insert request details
                for (int i = 0; i < productIds.length; i++) {
                    if (productIds[i] != null && !productIds[i].isEmpty()) {
                        try {
                            PurchaseRequestDetail detail = PurchaseRequestDetail.builder()
                                .requestId(requestId)
                                .productId(Integer.parseInt(productIds[i]))
                                .requestedQuantity(Integer.parseInt(quantities[i]))
                                .suggestedSupplierId(supplierIds[i] != null && !supplierIds[i].isEmpty() ? 
                                    Integer.parseInt(supplierIds[i]) : null)
                                .notes(productNotes != null && i < productNotes.length ? productNotes[i] : "")
                                .build();
                            
                            purchaseRequestDetailDAO.insert(detail);
                        } catch (NumberFormatException e) {
                            request.getSession().setAttribute("errorMessage", "Dữ liệu sản phẩm không hợp lệ!");
                            response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
                            return;
                        }
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

    private void editPurchaseRequest(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws ServletException, IOException {
        try {
            String requestIdStr = request.getParameter("requestId");
            String notes = request.getParameter("notes");
            String warehouseIdStr = request.getParameter("warehouseId");
            String[] productIds = request.getParameterValues("productId");
            String[] quantities = request.getParameterValues("quantity");
            String[] supplierIds = request.getParameterValues("supplierId");
            String[] productNotes = request.getParameterValues("productNotes");

            // Validate request ID
            if (requestIdStr == null || requestIdStr.isEmpty()) {
                request.getSession().setAttribute("errorMessage", "ID yêu cầu không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
                return;
            }
            Integer requestId = Integer.parseInt(requestIdStr);
            PurchaseRequest purchaseRequest = purchaseRequestDAO.findById(requestId);
            
            // Check if request exists, belongs to user, and is editable
            if (purchaseRequest == null) {
                request.getSession().setAttribute("errorMessage", "Yêu cầu không tồn tại!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
                return;
            }
            if (!purchaseRequest.getUserIdRequester().equals(currentUser.getUserId())) {
                request.getSession().setAttribute("errorMessage", "Bạn không có quyền chỉnh sửa yêu cầu này!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
                return;
            }
            if (!"pending_approval".equals(purchaseRequest.getStatus())) {
                request.getSession().setAttribute("errorMessage", "Chỉ có thể chỉnh sửa yêu cầu đang chờ duyệt!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
                return;
            }

            // Validate warehouse ID
            if (warehouseIdStr == null || warehouseIdStr.isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Vui lòng chọn kho nhập hàng!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=edit&id=" + requestId);
                return;
            }
            Integer warehouseId;
            try {
                warehouseId = Integer.parseInt(warehouseIdStr);
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "ID kho không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=edit&id=" + requestId);
                return;
            }

            // Validate product data
            if (productIds == null || productIds.length == 0 || quantities == null || quantities.length == 0) {
                request.getSession().setAttribute("errorMessage", "Vui lòng chọn ít nhất một sản phẩm!");
                response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=edit&id=" + requestId);
                return;
            }

            // Validate quantities and product IDs
            for (int i = 0; i < productIds.length; i++) {
                if (productIds[i] == null || productIds[i].isEmpty()) {
                    request.getSession().setAttribute("errorMessage", "ID sản phẩm không hợp lệ!");
                    response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=edit&id=" + requestId);
                    return;
                }
                try {
                    int qty = Integer.parseInt(quantities[i]);
                    if (qty <= 0) {
                        request.getSession().setAttribute("errorMessage", "Số lượng phải lớn hơn 0!");
                        response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=edit&id=" + requestId);
                        return;
                    }
                    Integer.parseInt(productIds[i]); // Validate productId
                    if (supplierIds != null && i < supplierIds.length && supplierIds[i] != null && !supplierIds[i].isEmpty()) {
                        Integer.parseInt(supplierIds[i]); // Validate supplierId if provided
                    }
                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("errorMessage", "Dữ liệu sản phẩm hoặc số lượng không hợp lệ!");
                    response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request?action=edit&id=" + requestId);
                    return;
                }
            }

            // Update purchase request
            purchaseRequest.setWarehouseId(warehouseId);
            purchaseRequest.setNotes(notes != null ? notes : "");
            boolean updateSuccess = purchaseRequestDAO.update(purchaseRequest);

            if (updateSuccess) {
                // Delete existing details
                purchaseRequestDetailDAO.deleteByRequestId(requestId);
                
                // Insert new details
                for (int i = 0; i < productIds.length; i++) {
                    if (productIds[i] != null && !productIds[i].isEmpty()) {
                        PurchaseRequestDetail detail = PurchaseRequestDetail.builder()
                            .requestId(requestId)
                            .productId(Integer.parseInt(productIds[i]))
                            .requestedQuantity(Integer.parseInt(quantities[i]))
                            .suggestedSupplierId(supplierIds != null && i < supplierIds.length && 
                                supplierIds[i] != null && !supplierIds[i].isEmpty() ? 
                                Integer.parseInt(supplierIds[i]) : null)
                            .notes(productNotes != null && i < productNotes.length ? productNotes[i] : "")
                            .build();
                        
                        purchaseRequestDetailDAO.insert(detail);
                    }
                }
                
                request.getSession().setAttribute("successMessage", "Chỉnh sửa yêu cầu nhập hàng thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật yêu cầu!");
            }

        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Lỗi khi chỉnh sửa yêu cầu: " + e.getMessage());
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
            request.getSession().setAttribute("errorMessage", "ID yêu cầu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/purchase-staff/purchase-request");
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Lỗi khi tải chi tiết yêu cầu: " + e.getMessage());
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