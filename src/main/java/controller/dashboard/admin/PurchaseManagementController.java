package controller.dashboard.admin;

import dao.*;
import model.*;
import utils.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.io.OutputStream;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

@WebServlet(name = "PurchaseManagementController", urlPatterns = {
    "/admin/purchase-management/requests",
    "/admin/purchase-management/reports"
})
public class PurchaseManagementController extends HttpServlet {

    private PurchaseRequestDAO purchaseRequestDAO;
    private PurchaseRequestDetailDAO purchaseRequestDetailDAO;
    private InventoryDAO inventoryDAO;
    private ProductDAO productDAO;
    private WarehouseDAO warehouseDAO;
    private SupplierDAO supplierDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        purchaseRequestDAO = new PurchaseRequestDAO();
        purchaseRequestDetailDAO = new PurchaseRequestDetailDAO();
        inventoryDAO = new InventoryDAO();
        productDAO = new ProductDAO();
        warehouseDAO = new WarehouseDAO();
        supplierDAO = new SupplierDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        String action = request.getParameter("action");
        
        // Kiểm tra session và role admin
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Kiểm tra role - chỉ admin được truy cập
        if (!"admin".equals(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này");
            return;
        }

        switch (path) {
            case "/admin/purchase-management/requests":
                handlePurchaseRequestManagement(request, response, action, currentUser);
                break;
            case "/admin/purchase-management/reports":
                handleInventoryReports(request, response, action, currentUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/purchase-management/requests");
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
        
        // Kiểm tra role - chỉ admin được truy cập
        if (!"admin".equals(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này");
            return;
        }

        switch (path) {
            case "/admin/purchase-management/requests":
                if ("approve".equals(action)) {
                    approvePurchaseRequest(request, response, currentUser);
                } else if ("reject".equals(action)) {
                    rejectPurchaseRequest(request, response, currentUser);
                }
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/purchase-management/requests");
                break;
        }
    }

    // ============ PURCHASE REQUEST MANAGEMENT ============
    private void handlePurchaseRequestManagement(HttpServletRequest request, HttpServletResponse response, String action, User currentUser) 
            throws ServletException, IOException {
        if (action == null) action = "list";

        switch (action) {
            case "list":
                listPurchaseRequestsForApproval(request, response);
                break;
            case "view":
                viewPurchaseRequestDetail(request, response);
                break;
            case "approve-form":
                showApprovalForm(request, response);
                break;
            default:
                listPurchaseRequestsForApproval(request, response);
                break;
        }
    }

    // Danh sách yêu cầu nhập hàng cần xét duyệt
    private void listPurchaseRequestsForApproval(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String status = request.getParameter("status");
        String warehouseIdStr = request.getParameter("warehouseId");
        
        List<PurchaseRequest> requests;
        if (status != null && !status.isEmpty()) {
            requests = purchaseRequestDAO.findByStatus(status);
        } else {
            requests = purchaseRequestDAO.findAll();
        }
        
        // Note: Database schema không có warehouse_id trong purchaserequests
        // Nên không filter theo warehouse

        List<Warehouse> warehouses = warehouseDAO.findAll();
        
        request.setAttribute("purchaseRequests", requests);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("status", status);
        request.setAttribute("warehouseId", warehouseIdStr);
        
        request.getRequestDispatcher("/view/dashboard/admin/purchase-requests.jsp").forward(request, response);
    }

    // Xem chi tiết yêu cầu nhập hàng
    private void viewPurchaseRequestDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String requestIdStr = request.getParameter("id");
        try {
            Integer requestId = Integer.parseInt(requestIdStr);
            PurchaseRequest purchaseRequest = purchaseRequestDAO.findById(requestId);
            List<PurchaseRequestDetail> details = purchaseRequestDetailDAO.findByRequestId(requestId);
            
            request.setAttribute("purchaseRequest", purchaseRequest);
            request.setAttribute("requestDetails", details);
            
            request.getRequestDispatcher("/view/dashboard/admin/purchase-management/request-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/purchase-management/requests");
        }
    }

    // Hiển thị form phê duyệt
    private void showApprovalForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String requestIdStr = request.getParameter("id");
        try {
            Integer requestId = Integer.parseInt(requestIdStr);
            PurchaseRequest purchaseRequest = purchaseRequestDAO.findById(requestId);
            List<PurchaseRequestDetail> details = purchaseRequestDetailDAO.findByRequestId(requestId);
            
            request.setAttribute("purchaseRequest", purchaseRequest);
            request.setAttribute("requestDetails", details);
            
            request.getRequestDispatcher("/view/dashboard/admin/purchase-management/approval-form.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/purchase-management/requests");
        }
    }

    // Phê duyệt yêu cầu nhập hàng
    private void approvePurchaseRequest(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws ServletException, IOException {
        try {
            Integer requestId = Integer.parseInt(request.getParameter("requestId"));
            String approvalNotes = request.getParameter("approvalNotes");
            
            PurchaseRequest purchaseRequest = purchaseRequestDAO.findById(requestId);
            if (purchaseRequest != null && "pending_approval".equals(purchaseRequest.getStatus())) {
                purchaseRequest.setStatus("approved");
                if (approvalNotes != null && !approvalNotes.isEmpty()) {
                    String currentNotes = purchaseRequest.getNotes() != null ? purchaseRequest.getNotes() : "";
                    purchaseRequest.setNotes(currentNotes + "\n[Ghi chú phê duyệt]: " + approvalNotes);
                }
                
                if (purchaseRequestDAO.update(purchaseRequest)) {
                    request.getSession().setAttribute("successMessage", "Phê duyệt yêu cầu thành công!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra khi phê duyệt!");
                }
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể phê duyệt yêu cầu này!");
            }
            
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/purchase-management/requests");
    }

    // Từ chối yêu cầu nhập hàng
    private void rejectPurchaseRequest(HttpServletRequest request, HttpServletResponse response, User currentUser) 
            throws ServletException, IOException {
        try {
            Integer requestId = Integer.parseInt(request.getParameter("requestId"));
            String rejectionReason = request.getParameter("rejectionReason");
            
            PurchaseRequest purchaseRequest = purchaseRequestDAO.findById(requestId);
            if (purchaseRequest != null && "pending_approval".equals(purchaseRequest.getStatus())) {
                purchaseRequest.setStatus("rejected");
                if (rejectionReason != null && !rejectionReason.isEmpty()) {
                    String currentNotes = purchaseRequest.getNotes() != null ? purchaseRequest.getNotes() : "";
                    purchaseRequest.setNotes(currentNotes + "\n[Lý do từ chối]: " + rejectionReason);
                }
                
                if (purchaseRequestDAO.update(purchaseRequest)) {
                    request.getSession().setAttribute("successMessage", "Từ chối yêu cầu thành công!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra khi từ chối!");
                }
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể từ chối yêu cầu này!");
            }
            
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/purchase-management/requests");
    }

    // ============ INVENTORY REPORTS ============
    private void handleInventoryReports(HttpServletRequest request, HttpServletResponse response, String action, User currentUser) 
            throws ServletException, IOException {
        if (action == null) action = "view";

        switch (action) {
            case "view":
                showInventoryReports(request, response);
                break;
            case "export-excel":
                exportInventoryReportToExcel(request, response);
                break;
            case "export-product-excel":
                exportProductReportToExcel(request, response);
                break;
            case "export-warehouse-excel":
                exportWarehouseReportToExcel(request, response);
                break;
            default:
                showInventoryReports(request, response);
                break;
        }
    }

    // Hiển thị trang báo cáo kho
    private void showInventoryReports(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String warehouseIdStr = request.getParameter("warehouseId");
        String productIdStr = request.getParameter("productId");
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        
        List<Inventory> inventoryList = inventoryDAO.findAll();
        
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
        
        // Filter by product if specified
        if (productIdStr != null && !productIdStr.isEmpty()) {
            try {
                Integer productId = Integer.parseInt(productIdStr);
                inventoryList = inventoryList.stream()
                    .filter(inv -> inv.getProductId().equals(productId))
                    .collect(java.util.stream.Collectors.toList());
            } catch (NumberFormatException e) {
                // Handle error
            }
        }

        List<Warehouse> warehouses = warehouseDAO.findAll();
        List<Product> products = productDAO.findAll();
        
        request.setAttribute("inventoryList", inventoryList);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("products", products);
        request.setAttribute("warehouseId", warehouseIdStr);
        request.setAttribute("productId", productIdStr);
        request.setAttribute("fromDate", fromDateStr);
        request.setAttribute("toDate", toDateStr);
        
        request.getRequestDispatcher("/view/dashboard/admin/inventory-reports.jsp").forward(request, response);
    }

    // Xuất báo cáo tồn kho tổng hợp
    private void exportInventoryReportToExcel(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String warehouseIdStr = request.getParameter("warehouseId");
        String productIdStr = request.getParameter("productId");
        
        List<Inventory> inventoryList = inventoryDAO.findAll();
        
        // Apply filters
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
        
        if (productIdStr != null && !productIdStr.isEmpty()) {
            try {
                Integer productId = Integer.parseInt(productIdStr);
                inventoryList = inventoryList.stream()
                    .filter(inv -> inv.getProductId().equals(productId))
                    .collect(java.util.stream.Collectors.toList());
            } catch (NumberFormatException e) {
                // Handle error
            }
        }

        // Create Excel workbook
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Báo cáo tồn kho");
            
            // Create header row
            Row headerRow = sheet.createRow(0);
            String[] headers = {"Kho", "Mã sản phẩm", "Tên sản phẩm", "Đơn vị", "Số lượng tồn", "Cập nhật lần cuối"};
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
            for (Inventory inventory : inventoryList) {
                Row row = sheet.createRow(rowNum++);
                
                Warehouse warehouse = warehouseDAO.findById(inventory.getWarehouseId());
                Product product = productDAO.findById(inventory.getProductId());
                
                row.createCell(0).setCellValue(warehouse != null ? warehouse.getWarehouseName() : "");
                row.createCell(1).setCellValue(product != null ? product.getProductCode() : "");
                row.createCell(2).setCellValue(product != null ? product.getProductName() : "");
                row.createCell(3).setCellValue(product != null ? product.getUnit() : "");
                row.createCell(4).setCellValue(inventory.getQuantityOnHand());
                row.createCell(5).setCellValue(inventory.getLastUpdated() != null ? 
                    new SimpleDateFormat("dd/MM/yyyy HH:mm").format(inventory.getLastUpdated()) : "");
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
            throw new ServletException("Error generating Excel report", e);
        }
    }

    // Xuất báo cáo theo sản phẩm
    private void exportProductReportToExcel(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Product> products = productDAO.findAll();

        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Báo cáo theo sản phẩm");
            
            // Create header row
            Row headerRow = sheet.createRow(0);
            String[] headers = {"Mã sản phẩm", "Tên sản phẩm", "Đơn vị", "Giá mua", "Giá bán", "Tổng tồn kho"};
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
            for (Product product : products) {
                Row row = sheet.createRow(rowNum++);
                
                // Calculate total inventory for this product across all warehouses
                List<Inventory> productInventory = inventoryDAO.findAll().stream()
                    .filter(inv -> inv.getProductId().equals(product.getProductId()))
                    .collect(java.util.stream.Collectors.toList());
                
                int totalQuantity = productInventory.stream()
                    .mapToInt(Inventory::getQuantityOnHand)
                    .sum();
                
                row.createCell(0).setCellValue(product.getProductCode());
                row.createCell(1).setCellValue(product.getProductName());
                row.createCell(2).setCellValue(product.getUnit());
                row.createCell(3).setCellValue(product.getPurchasePrice());
                row.createCell(4).setCellValue(product.getSalePrice());
                row.createCell(5).setCellValue(totalQuantity);
            }

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // Set response headers
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            String filename = "bao_cao_san_pham_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".xlsx";
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            // Write to response
            try (OutputStream out = response.getOutputStream()) {
                workbook.write(out);
            }
        } catch (Exception e) {
            throw new ServletException("Error generating Excel report", e);
        }
    }

    // Xuất báo cáo theo kho
    private void exportWarehouseReportToExcel(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Warehouse> warehouses = warehouseDAO.findAll();

        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Báo cáo theo kho");
            
            // Create header row
            Row headerRow = sheet.createRow(0);
            String[] headers = {"Tên kho", "Địa chỉ", "Tổng số sản phẩm", "Tổng số lượng tồn"};
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
            for (Warehouse warehouse : warehouses) {
                Row row = sheet.createRow(rowNum++);
                
                // Calculate inventory stats for this warehouse
                List<Inventory> warehouseInventory = inventoryDAO.findAll().stream()
                    .filter(inv -> inv.getWarehouseId().equals(warehouse.getWarehouseId()))
                    .collect(java.util.stream.Collectors.toList());
                
                int totalProducts = warehouseInventory.size();
                int totalQuantity = warehouseInventory.stream()
                    .mapToInt(Inventory::getQuantityOnHand)
                    .sum();
                
                row.createCell(0).setCellValue(warehouse.getWarehouseName());
                row.createCell(1).setCellValue(warehouse.getAddress());
                row.createCell(2).setCellValue(totalProducts);
                row.createCell(3).setCellValue(totalQuantity);
            }

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // Set response headers
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            String filename = "bao_cao_kho_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".xlsx";
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            // Write to response
            try (OutputStream out = response.getOutputStream()) {
                workbook.write(out);
            }
        } catch (Exception e) {
            throw new ServletException("Error generating Excel report", e);
        }
    }
} 