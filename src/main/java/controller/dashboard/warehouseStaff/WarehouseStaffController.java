package controller.dashboard.warehouseStaff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.*;
import model.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/warehouse-staff")
public class WarehouseStaffController extends HttpServlet {

    private StockInwardDAO stockInwardDAO = new StockInwardDAO();
    private StockInwardDetailDAO stockInwardDetailDAO = new StockInwardDetailDAO();
    private StockOutwardDAO stockOutwardDAO = new StockOutwardDAO();
    private StockOutwardDetailDAO stockOutwardDetailDAO = new StockOutwardDetailDAO();
    private PickRequestDAO pickRequestDAO = new PickRequestDAO();
    private PickRequestDetailDAO pickRequestDetailDAO = new PickRequestDetailDAO();
    private ProductDAO productDAO = new ProductDAO();
    private SupplierDAO supplierDAO = new SupplierDAO();
    private WarehouseDAO warehouseDAO = new WarehouseDAO();
    private InventoryDAO inventoryDAO = new InventoryDAO();
    private SalesOrderDAO salesOrderDAO = new SalesOrderDAO();
    private SalesOrderDetailDAO salesOrderDetailDAO = new SalesOrderDetailDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "dashboard";

        switch (action) {
            case "dashboard":
                showDashboard(request, response);
                break;
            case "stock-inward-list":
                showStockInwardList(request, response);
                break;
            case "stock-outward-list":
                showStockOutwardList(request, response);
                break;
            case "pick-request-list":
                showPickRequestList(request, response);
                break;
            case "create-stock-inward":
                showCreateStockInward(request, response);
                break;
            case "view-stock-inward":
                viewStockInward(request, response);
                break;
            case "create-pick-request":
                showCreatePickRequest(request, response);
                break;
            case "view-pick-request":
                viewPickRequest(request, response);
                break;
            case "perform-pick":
                showPerformPick(request, response);
                break;
            case "create-stock-outward":
                showCreateStockOutward(request, response);
                break;
            case "view-stock-outward":
                viewStockOutward(request, response);
                break;

            case "pending-sales-orders":
                showPendingSalesOrders(request, response);
                break;
            default:
                showDashboard(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "create-stock-inward":
                createStockInward(request, response);
                break;
            case "create-pick-request":
                createPickRequest(request, response);
                break;
            case "update-pick":
                updatePickQuantities(request, response);
                break;
            case "complete-pick":
                completePick(request, response);
                break;
            case "create-stock-outward":
                createStockOutward(request, response);
                break;
            default:
                response.sendRedirect("warehouse-staff");
                break;
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Dashboard statistics
        List<StockInward> recentInwards = stockInwardDAO.findAll();
        List<StockOutward> recentOutwards = stockOutwardDAO.findAll();
        List<PickRequest> pendingPicks = pickRequestDAO.findByStatus("pending");
        
        request.setAttribute("recentInwards", recentInwards.size() > 5 ? recentInwards.subList(0, 5) : recentInwards);
        request.setAttribute("recentOutwards", recentOutwards.size() > 5 ? recentOutwards.subList(0, 5) : recentOutwards);
        request.setAttribute("pendingPicksCount", pendingPicks.size());
        
        request.getRequestDispatcher("view/dashboard/warehouseStaff/dashboard.jsp").forward(request, response);
    }

    private void showStockInwardList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<StockInward> stockInwards = stockInwardDAO.findAll();
        request.setAttribute("stockInwards", stockInwards);
        request.getRequestDispatcher("view/dashboard/warehouseStaff/stock-inward/list.jsp").forward(request, response);
    }

    private void showStockOutwardList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<StockOutward> stockOutwards = stockOutwardDAO.findAll();
        request.setAttribute("stockOutwards", stockOutwards);
        request.getRequestDispatcher("view/dashboard/warehouseStaff/stock-outward/list.jsp").forward(request, response);
    }

    private void showPickRequestList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<PickRequest> pickRequests = pickRequestDAO.findAll();
        request.setAttribute("pickRequests", pickRequests);
        request.getRequestDispatcher("view/dashboard/warehouseStaff/pick-request/list.jsp").forward(request, response);
    }



    private void showPendingSalesOrders(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<SalesOrder> pendingOrders = salesOrderDAO.findByStatus("awaiting_shipment");
        
        // Load details for each sales order for modal display
        for (SalesOrder salesOrder : pendingOrders) {
            List<SalesOrderDetail> details = salesOrderDetailDAO.findBySalesOrderId(salesOrder.getSalesOrderId());
            salesOrder.setDetails(details);
        }
        
        request.setAttribute("salesOrders", pendingOrders);
        request.getRequestDispatcher("view/dashboard/warehouseStaff/sales-order/pending-list.jsp").forward(request, response);
    }

    private void showCreateStockInward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("view/dashboard/warehouseStaff/stock-inward/create.jsp").forward(request, response);
    }

    private void createStockInward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            String supplierIdStr = request.getParameter("supplierId");
            String warehouseIdStr = request.getParameter("warehouseId");
            String notes = request.getParameter("notes");
            
            // Tạo stock inward
            StockInward stockInward = StockInward.builder()
                    .inwardCode(stockInwardDAO.generateInwardCode())
                    .supplierId(supplierIdStr != null && !supplierIdStr.isEmpty() ? Integer.parseInt(supplierIdStr) : null)
                    .userId(currentUser.getUserId())
                    .warehouseId(warehouseIdStr != null && !warehouseIdStr.isEmpty() ? Integer.parseInt(warehouseIdStr) : null)
                    .inwardDate(Timestamp.valueOf(LocalDateTime.now()))
                    .notes(notes)
                    .build();
                    
            int stockInwardId = stockInwardDAO.insert(stockInward);
            
            if (stockInwardId > 0) {
                // Tạo stock inward details
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantityReceived");
                String[] prices = request.getParameterValues("unitPrice");
                
                List<StockInwardDetail> details = new ArrayList<>();
                for (int i = 0; i < productIds.length; i++) {
                    if (quantities[i] != null && !quantities[i].isEmpty() && Integer.parseInt(quantities[i]) > 0) {
                        StockInwardDetail detail = StockInwardDetail.builder()
                                .stockInwardId(stockInwardId)
                                .productId(Integer.parseInt(productIds[i]))
                                .quantityReceived(Integer.parseInt(quantities[i]))
                                .unitPurchasePrice(new BigDecimal(prices[i]))
                                .build();
                        details.add(detail);
                    }
                }
                
                if (stockInwardDetailDAO.insertDetails(details)) {
                    // Cập nhật inventory
                    for (StockInwardDetail detail : details) {
                        inventoryDAO.updateQuantityOnHand(detail.getProductId(), 
                                stockInward.getWarehouseId(), detail.getQuantityReceived(), "add");
                    }
                    
                    session.setAttribute("toastMessage", "Tạo phiếu nhập kho thành công!");
                    session.setAttribute("toastType", "success");
                }
            }
            
        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Có lỗi xảy ra: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect("warehouse-staff?action=stock-inward-list");
    }

    private void viewStockInward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            int id = Integer.parseInt(idStr);
            StockInward stockInward = stockInwardDAO.findById(id);
            List<StockInwardDetail> details = stockInwardDetailDAO.findByStockInwardId(id);
            request.setAttribute("stockInward", stockInward);
            request.setAttribute("stockInwardDetails", details);
        }
        request.getRequestDispatcher("view/dashboard/warehouseStaff/stock-inward/view.jsp").forward(request, response);
    }

    private void showCreatePickRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String salesOrderIdStr = request.getParameter("salesOrderId");
        if (salesOrderIdStr != null) {
            int salesOrderId = Integer.parseInt(salesOrderIdStr);
            SalesOrder salesOrder = salesOrderDAO.findById(salesOrderId);
            List<SalesOrderDetail> details = salesOrderDetailDAO.findBySalesOrderId(salesOrderId);
            request.setAttribute("salesOrder", salesOrder);
            request.setAttribute("salesOrderDetails", details);
        }
        
        List<Warehouse> warehouses = warehouseDAO.findAll();
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("view/dashboard/warehouseStaff/pick-request/create.jsp").forward(request, response);
    }

    private void createPickRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            // Kiểm tra user có tồn tại trong session không
            if (currentUser == null) {
                session.setAttribute("toastMessage", "Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("login.jsp");
                return;
            }
            
            String salesOrderIdStr = request.getParameter("salesOrderId");
            String warehouseIdStr = request.getParameter("warehouseId");
            String notes = request.getParameter("notes");
            
            // Validate input parameters
            if (salesOrderIdStr == null || salesOrderIdStr.isEmpty() || 
                warehouseIdStr == null || warehouseIdStr.isEmpty()) {
                session.setAttribute("toastMessage", "Vui lòng nhập đầy đủ thông tin!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("warehouse-staff?action=pick-request-list");
                return;
            }
            
            // Tạo pick request
            PickRequest pickRequest = PickRequest.builder()
                    .pickRequestCode(pickRequestDAO.generatePickRequestCode())
                    .salesOrderId(Integer.parseInt(salesOrderIdStr))
                    .userIdRequester(currentUser.getUserId())
                    .warehouseId(Integer.parseInt(warehouseIdStr))
                    .requestDate(Timestamp.valueOf(LocalDateTime.now()))
                    .status("pending")
                    .notes(notes)
                    .build();
                    
            int pickRequestId = pickRequestDAO.insert(pickRequest);
            
            if (pickRequestId > 0) {
                // Tạo pick request details từ sales order details
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantityRequested");
                
                List<PickRequestDetail> details = new ArrayList<>();
                for (int i = 0; i < productIds.length; i++) {
                    if (quantities[i] != null && !quantities[i].isEmpty() && Integer.parseInt(quantities[i]) > 0) {
                        PickRequestDetail detail = PickRequestDetail.builder()
                                .pickRequestId(pickRequestId)
                                .productId(Integer.parseInt(productIds[i]))
                                .quantityRequested(Integer.parseInt(quantities[i]))
                                .quantityPicked(0)
                                .location("A1-01-01") // Vị trí mặc định
                                .build();
                        details.add(detail);
                    }
                }
                
                if (pickRequestDetailDAO.insertDetails(details)) {
                    HttpSession session1 = request.getSession();
                    session1.setAttribute("toastMessage", "Tạo yêu cầu lấy hàng thành công!");
                    session1.setAttribute("toastType", "success");
                }
            }
            
        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Có lỗi xảy ra: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect("warehouse-staff?action=pick-request-list");
    }

    private void viewPickRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            int id = Integer.parseInt(idStr);
            PickRequest pickRequest = pickRequestDAO.findById(id);
            List<PickRequestDetail> details = pickRequestDetailDAO.findByPickRequestId(id);
            request.setAttribute("pickRequest", pickRequest);
            request.setAttribute("pickRequestDetails", details);
        }
        request.getRequestDispatcher("view/dashboard/warehouseStaff/pick-request/view.jsp").forward(request, response);
    }

    private void showPerformPick(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            int id = Integer.parseInt(idStr);
            PickRequest pickRequest = pickRequestDAO.findById(id);
            List<PickRequestDetail> details = pickRequestDetailDAO.findByPickRequestId(id);
            request.setAttribute("pickRequest", pickRequest);
            request.setAttribute("pickRequestDetails", details);
        }
        request.getRequestDispatcher("view/dashboard/warehouseStaff/pick-request/perform.jsp").forward(request, response);
    }

    private void updatePickQuantities(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String pickRequestIdStr = request.getParameter("pickRequestId");
            String[] detailIds = request.getParameterValues("detailId");
            String[] pickedQuantities = request.getParameterValues("quantityPicked");
            
            for (int i = 0; i < detailIds.length; i++) {
                PickRequestDetail detail = pickRequestDetailDAO.findById(Integer.parseInt(detailIds[i]));
                detail.setQuantityPicked(Integer.parseInt(pickedQuantities[i]));
                pickRequestDetailDAO.update(detail);
            }
            
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Cập nhật số lượng lấy hàng thành công!");
            session.setAttribute("toastType", "success");
            
        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Có lỗi xảy ra: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }
        
        String pickRequestId = request.getParameter("pickRequestId");
        response.sendRedirect("warehouse-staff?action=perform-pick&id=" + pickRequestId);
    }

    private void completePick(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String pickRequestIdStr = request.getParameter("pickRequestId");
            int pickRequestId = Integer.parseInt(pickRequestIdStr);
            
            // Cập nhật trạng thái pick request
            PickRequest pickRequest = pickRequestDAO.findById(pickRequestId);
            pickRequest.setStatus("completed");
            pickRequestDAO.update(pickRequest);
            
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Hoàn thành lấy hàng thành công!");
            session.setAttribute("toastType", "success");
            
        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Có lỗi xảy ra: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect("warehouse-staff?action=pick-request-list");
    }

    private void showCreateStockOutward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pickRequestIdStr = request.getParameter("pickRequestId");
        if (pickRequestIdStr != null) {
            int pickRequestId = Integer.parseInt(pickRequestIdStr);
            PickRequest pickRequest = pickRequestDAO.findById(pickRequestId);
            List<PickRequestDetail> details = pickRequestDetailDAO.findByPickRequestId(pickRequestId);
            request.setAttribute("pickRequest", pickRequest);
            request.setAttribute("pickRequestDetails", details);
        }
        
        List<Warehouse> warehouses = warehouseDAO.findAll();
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("view/dashboard/warehouseStaff/stock-outward/create.jsp").forward(request, response);
    }

    private void createStockOutward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            String pickRequestIdStr = request.getParameter("pickRequestId");
            String salesOrderIdStr = request.getParameter("salesOrderId");
            String warehouseIdStr = request.getParameter("warehouseId");
            String reason = request.getParameter("reason");
            String notes = request.getParameter("notes");
            
            // Tạo stock outward
            StockOutward stockOutward = StockOutward.builder()
                    .outwardCode(stockOutwardDAO.generateOutwardCode())
                    .salesOrderId(salesOrderIdStr != null && !salesOrderIdStr.isEmpty() ? Integer.parseInt(salesOrderIdStr) : null)
                    .userId(currentUser.getUserId())
                    .warehouseId(Integer.parseInt(warehouseIdStr))
                    .outwardDate(Timestamp.valueOf(LocalDateTime.now()))
                    .reason(reason)
                    .notes(notes)
                    .pickRequestId(pickRequestIdStr != null && !pickRequestIdStr.isEmpty() ? Integer.parseInt(pickRequestIdStr) : null)
                    .build();
                    
            int stockOutwardId = stockOutwardDAO.insert(stockOutward);
            
            if (stockOutwardId > 0) {
                // Tạo stock outward details
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantityShipped");
                
                List<StockOutwardDetail> details = new ArrayList<>();
                for (int i = 0; i < productIds.length; i++) {
                    if (quantities[i] != null && !quantities[i].isEmpty() && Integer.parseInt(quantities[i]) > 0) {
                        StockOutwardDetail detail = StockOutwardDetail.builder()
                                .stockOutwardId(stockOutwardId)
                                .productId(Integer.parseInt(productIds[i]))
                                .quantityShipped(Integer.parseInt(quantities[i]))
                                .build();
                        details.add(detail);
                    }
                }
                
                if (stockOutwardDetailDAO.insertDetails(details)) {
                    // Cập nhật inventory
                    for (StockOutwardDetail detail : details) {
                        inventoryDAO.updateQuantityOnHand(detail.getProductId(), 
                                stockOutward.getWarehouseId(), detail.getQuantityShipped(), "subtract");
                    }
                    
                    // Cập nhật trạng thái sales order nếu có
                    if (stockOutward.getSalesOrderId() != null) {
                        SalesOrder salesOrder = salesOrderDAO.findById(stockOutward.getSalesOrderId());
                        salesOrder.setStatus("shipped");
                        salesOrderDAO.update(salesOrder);
                    }
                    
                    session.setAttribute("toastMessage", "Tạo phiếu xuất kho thành công!");
                    session.setAttribute("toastType", "success");
                }
            }
            
        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Có lỗi xảy ra: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }
        
        response.sendRedirect("warehouse-staff?action=stock-outward-list");
    }

    private void viewStockOutward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            int id = Integer.parseInt(idStr);
            StockOutward stockOutward = stockOutwardDAO.findById(id);
            List<StockOutwardDetail> details = stockOutwardDetailDAO.findByStockOutwardId(id);
            request.setAttribute("stockOutward", stockOutward);
            request.setAttribute("stockOutwardDetails", details);
        }
        request.getRequestDispatcher("view/dashboard/warehouseStaff/stock-outward/view.jsp").forward(request, response);
    }
} 