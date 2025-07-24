package controller.dashboard.purchasingStaff;

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
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "PurchasingController", urlPatterns = { "/purchasing" })
public class PurchasingController extends HttpServlet {

    private RfqDAO rfqDAO;
    private RfqDetailDAO rfqDetailDAO;
    private PurchaseOrderDAO purchaseOrderDAO;
    private PurchaseOrderDetailDAO purchaseOrderDetailDAO;
    private ProductDAO productDAO;
    private SupplierDAO supplierDAO;
    private WarehouseDAO warehouseDAO;
    private StockInwardDAO stockInwardDAO;
    private StockInwardDetailDAO stockInwardDetailDAO;
    private InventoryDAO inventoryDAO;

    @Override
    public void init() throws ServletException {
        rfqDAO = new RfqDAO();
        rfqDetailDAO = new RfqDetailDAO();
        purchaseOrderDAO = new PurchaseOrderDAO();
        purchaseOrderDetailDAO = new PurchaseOrderDetailDAO();
        productDAO = new ProductDAO();
        supplierDAO = new SupplierDAO();
        warehouseDAO = new WarehouseDAO();
        stockInwardDAO = new StockInwardDAO();
        stockInwardDetailDAO = new StockInwardDetailDAO();
        inventoryDAO = new InventoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list-rfq";
        }

        switch (action) {
            case "inventory-list":
                handleInventoryList(request, response);
                break;
            case "list-rfq":
                handleListRfq(request, response);
                break;
            case "create-rfq":
                handleShowCreateRfq(request, response);
                break;
            case "view-rfq":
                handleViewRfq(request, response);
                break;
            case "edit-rfq":
                handleShowEditRfq(request, response);
                break;
            case "create-po-from-rfq":
                handleShowCreatePoFromRfq(request, response);
                break;
            case "list-po":
                handleListPo(request, response);
                break;
            case "view-po":
                handleViewPo(request, response);
                break;
            case "edit-po":
                handleShowEditPo(request, response);
                break;
            case "create-stock-inward":
                handleShowCreateStockInward(request, response);
                break;
            case "list-stock-inward":
                handleListStockInward(request, response);
                break;
            case "view-stock-inward":
                handleViewStockInward(request, response);
                break;
            case "list-po-for-stock-inward":
                handleListPOForStockInward(request, response);
                break;
            default:
                handleListRfq(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        switch (action) {
            case "create-rfq":
                handleCreateRfq(request, response);
                break;
            case "update-rfq":
                handleUpdateRfq(request, response);
                break;
            case "send-rfq":
                handleSendRfq(request, response);
                break;
            case "create-po":
                handleCreatePo(request, response);
                break;
            case "update-po":
                handleUpdatePo(request, response);
                break;
            case "create-stock-inward":
                handleCreateStockInward(request, response);
                break;
            case "create-and-complete-stock-inward":
                handleCreateAndCompleteStockInward(request, response);
                break;
            default:
                response.sendRedirect("purchasing?action=list-rfq");
                break;
        }
    }

    // RFQ Management Methods
    private void handleListRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = SessionUtil.getUserFromSession(request);

        List<Rfq> rfqs = rfqDAO.findByUserId(currentUser.getUserId());
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();

        request.setAttribute("rfqs", rfqs);
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("view/dashboard/purchasingStaff/rfq/rfq-list.jsp").forward(request, response);
    }

    private void handleShowCreateRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();
        List<Product> products = productDAO.findAll();

        request.setAttribute("suppliers", suppliers);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("products", products);
        request.getRequestDispatcher("view/dashboard/purchasingStaff/rfq/create-rfq.jsp").forward(request, response);
    }

    private void handleCreateRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = SessionUtil.getUserFromSession(request);

            // Create RFQ
            Rfq rfq = Rfq.builder()
                    .rfqCode(rfqDAO.generateRfqCode())
                    .expectedDeliveryDate(Date.valueOf(request.getParameter("expectedDeliveryDate")))
                    .providerId(Integer.valueOf(request.getParameter("providerId")))
                    .warehouseId(Integer.valueOf(request.getParameter("warehouseId")))
                    .userIdRequester(currentUser.getUserId())
                    .status("pending")
                    .note(request.getParameter("note"))
                    .build();

            int rfqId = rfqDAO.insert(rfq);

            if (rfqId > 0) {
                // Create RFQ Details
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantity");

                if (productIds != null && quantities != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (!productIds[i].isEmpty() && !quantities[i].isEmpty()) {
                            RfqDetail detail = RfqDetail.builder()
                                    .rfqId(rfqId)
                                    .productId(Integer.valueOf(productIds[i]))
                                    .quantity(Integer.valueOf(quantities[i]))
                                    .build();
                            rfqDetailDAO.insert(detail);
                        }
                    }
                }

                session.setAttribute("toastMessage", "Tạo yêu cầu báo giá thành công!");
                session.setAttribute("toastType", "success");
            } else {
                session.setAttribute("toastMessage", "Tạo yêu cầu báo giá thất bại!");
                session.setAttribute("toastType", "error");
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Lỗi khi tạo yêu cầu báo giá: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }

        response.sendRedirect("purchasing?action=list-rfq");
    }

    private void handleViewRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int rfqId = Integer.parseInt(request.getParameter("id"));
        Rfq rfq = rfqDAO.findById(rfqId);
        List<RfqDetail> rfqDetails = rfqDetailDAO.findByRfqId(rfqId);

        // Get related data
        Supplier supplier = supplierDAO.findById(rfq.getProviderId());
        Warehouse warehouse = warehouseDAO.findById(rfq.getWarehouseId());

        // Get products for details
        for (RfqDetail detail : rfqDetails) {
            Product product = productDAO.findById(detail.getProductId());
            detail.setProductId(product.getProductId()); // This will help in JSP
        }

        // Check if PO exists for this RFQ
        PurchaseOrder existingPO = purchaseOrderDAO.findByRfqId(rfqId);

        // Check if all products have quoted prices
        boolean allProductsHavePrice = true;
        for (RfqDetail detail : rfqDetails) {
            if (detail.getPrice() == null || detail.getPrice() <= 0) {
                allProductsHavePrice = false;
                break;
            }
        }

        request.setAttribute("rfq", rfq);
        request.setAttribute("rfqDetails", rfqDetails);
        request.setAttribute("supplier", supplier);
        request.setAttribute("warehouse", warehouse);
        request.setAttribute("existingPO", existingPO);
        request.setAttribute("products", productDAO.findAll());
        request.setAttribute("allProductsHavePrice", allProductsHavePrice);

        request.getRequestDispatcher("view/dashboard/purchasingStaff/rfq/view-rfq.jsp").forward(request, response);
    }

    private void handleSendRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int rfqId = Integer.parseInt(request.getParameter("id"));
        Rfq rfq = rfqDAO.findById(rfqId);

        if (rfq != null && "pending".equals(rfq.getStatus())) {
            rfq.setStatus("sent");
            boolean success = rfqDAO.update(rfq);

            HttpSession session = request.getSession();
            if (success) {
                // Gửi email cho nhà cung cấp
                try {
                    Supplier supplier = supplierDAO.findById(rfq.getProviderId());
                    List<RfqDetail> rfqDetails = rfqDetailDAO.findByRfqId(rfqId);
                    List<Product> products = productDAO.findAll();
                    
                    boolean emailSent = utils.RfqEmailService.sendRfqToSupplier(supplier, rfq, rfqDetails, products);
                    
                    if (emailSent) {
                        session.setAttribute("toastMessage", 
                            "Gửi yêu cầu báo giá thành công! Email đã được gửi đến nhà cung cấp: " + supplier.getSupplierName());
                        session.setAttribute("toastType", "success");
                        
                        // Log thông tin gửi email thành công
                        System.out.println("=== RFQ EMAIL SENT SUCCESSFULLY ===");
                        System.out.println("RFQ ID: " + rfqId);
                        System.out.println("RFQ Code: " + rfq.getRfqCode());
                        System.out.println("Supplier ID: " + supplier.getSupplierId());
                        System.out.println("Supplier Name: " + supplier.getSupplierName());
                        System.out.println("Supplier Email: " + supplier.getEmail());
                        System.out.println("Email sent at: " + new java.util.Date());
                        System.out.println("=====================================");
                    } else {
                        session.setAttribute("toastMessage", 
                            "Gửi yêu cầu báo giá thành công nhưng không thể gửi email đến nhà cung cấp!");
                        session.setAttribute("toastType", "warning");
                    }
                } catch (Exception e) {
                    System.err.println("Error sending RFQ email: " + e.getMessage());
                    e.printStackTrace();
                    session.setAttribute("toastMessage", 
                        "Gửi yêu cầu báo giá thành công nhưng có lỗi khi gửi email: " + e.getMessage());
                    session.setAttribute("toastType", "warning");
                }
            } else {
                session.setAttribute("toastMessage", "Gửi yêu cầu báo giá thất bại!");
                session.setAttribute("toastType", "error");
            }
        }

        response.sendRedirect("purchasing?action=view-rfq&id=" + rfqId);
    }

    // Purchase Order Management Methods
    private void handleShowCreatePoFromRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int rfqId = Integer.parseInt(request.getParameter("rfqId"));
        Rfq rfq = rfqDAO.findById(rfqId);
        List<RfqDetail> rfqDetails = rfqDetailDAO.findByRfqId(rfqId);

        // Check if all products have quoted prices
        boolean allProductsHavePrice = true;
        for (RfqDetail detail : rfqDetails) {
            if (detail.getPrice() == null || detail.getPrice() <= 0) {
                allProductsHavePrice = false;
                break;
            }
        }

        Supplier supplier = supplierDAO.findById(rfq.getProviderId());
        Warehouse warehouse = warehouseDAO.findById(rfq.getWarehouseId());
        List<Product> products = productDAO.findAll();

        request.setAttribute("rfq", rfq);
        request.setAttribute("rfqDetails", rfqDetails);
        request.setAttribute("supplier", supplier);
        request.setAttribute("warehouse", warehouse);
        request.setAttribute("products", products);
        request.setAttribute("allProductsHavePrice", allProductsHavePrice);

        if (!allProductsHavePrice) {
            request.setAttribute("errorMessage", "Không thể tạo đơn PO. Vui lòng đợi nhà cung cấp báo giá đầy đủ cho tất cả sản phẩm.");
        }

        request.getRequestDispatcher("view/dashboard/purchasingStaff/po/create-po.jsp").forward(request, response);
    }

    private void handleCreatePo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int rfqId = Integer.parseInt(request.getParameter("rfqId"));
            Rfq rfq = rfqDAO.findById(rfqId);
            List<RfqDetail> rfqDetails = rfqDetailDAO.findByRfqId(rfqId);

            // Validate that all products have quoted prices
            for (RfqDetail detail : rfqDetails) {
                if (detail.getPrice() == null || detail.getPrice() <= 0) {
                    HttpSession session = request.getSession();
                    session.setAttribute("toastMessage", "Không thể tạo đơn PO! Một số sản phẩm chưa có báo giá từ nhà cung cấp.");
                    session.setAttribute("toastType", "error");
                    response.sendRedirect("purchasing?action=create-po-from-rfq&rfqId=" + rfqId);
                    return;
                }
            }

            // Create Purchase Order
            PurchaseOrder po = PurchaseOrder.builder()
                    .rfqId(rfqId)
                    .poCode(purchaseOrderDAO.generatePoCode())
                    .providerId(rfq.getProviderId())
                    .warehouseId(rfq.getWarehouseId())
                    .orderDate(LocalDateTime.now())
                    .expectedDeliveryDate(rfq.getExpectedDeliveryDate())
                    .status("pending")
                    .build();

            int poId = purchaseOrderDAO.insert(po);

            if (poId > 0) {
                // Create PO Details using prices from RFQ details (supplier quotes)
                for (RfqDetail rfqDetail : rfqDetails) {
                    PurchaseOrderDetail detail = PurchaseOrderDetail.builder()
                            .poId(poId)
                            .productId(rfqDetail.getProductId())
                            .quantity(rfqDetail.getQuantity())
                            .unitPrice(BigDecimal.valueOf(rfqDetail.getPrice()))
                            .build();
                    purchaseOrderDetailDAO.insert(detail);
                }

                // Update RFQ status
                rfq.setStatus("approved");
                rfqDAO.update(rfq);

                HttpSession session = request.getSession();
                session.setAttribute("toastMessage", "Tạo đơn mua hàng thành công!");
                session.setAttribute("toastType", "success");

                response.sendRedirect("purchasing?action=view-po&id=" + poId);
                return;
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Lỗi khi tạo đơn mua hàng: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }

        response.sendRedirect("purchasing?action=list-rfq");
    }

    private void handleListPo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<PurchaseOrder> pos = purchaseOrderDAO.findAll();
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();

        request.setAttribute("pos", pos);
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("view/dashboard/purchasingStaff/po/po-list.jsp").forward(request, response);
    }

    private void handleViewPo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int poId = Integer.parseInt(request.getParameter("id"));
        PurchaseOrder po = purchaseOrderDAO.findById(poId);
        List<PurchaseOrderDetail> poDetails = purchaseOrderDetailDAO.findByPoId(poId);

        Supplier supplier = supplierDAO.findById(po.getProviderId());
        Warehouse warehouse = warehouseDAO.findById(po.getWarehouseId());
        List<Product> products = productDAO.findAll();

        // Check if Stock Inward exists for this PO
        StockInward existingStockInward = stockInwardDAO.findByPoId(poId);

        request.setAttribute("po", po);
        request.setAttribute("poDetails", poDetails);
        request.setAttribute("supplier", supplier);
        request.setAttribute("warehouse", warehouse);
        request.setAttribute("products", products);
        request.setAttribute("existingStockInward", existingStockInward);

        request.getRequestDispatcher("view/dashboard/purchasingStaff/purchase-order/view-po.jsp").forward(request,
                response);
    }

    // Stock Inward Management Methods
    private void handleShowCreateStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int poId = Integer.parseInt(request.getParameter("poId"));
        PurchaseOrder po = purchaseOrderDAO.findById(poId);
        List<PurchaseOrderDetail> poDetails = purchaseOrderDetailDAO.findByPoId(poId);

        Supplier supplier = supplierDAO.findById(po.getProviderId());
        Warehouse warehouse = warehouseDAO.findById(po.getWarehouseId());
        List<Product> products = productDAO.findAll();

        request.setAttribute("po", po);
        request.setAttribute("poDetails", poDetails);
        request.setAttribute("supplier", supplier);
        request.setAttribute("warehouse", warehouse);
        request.setAttribute("products", products);

        request.getRequestDispatcher("view/dashboard/purchasingStaff/stock-inward/create-stock-inward.jsp")
                .forward(request, response);
    }

    private void handleCreateStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = SessionUtil.getUserFromSession(request);

            int poId = Integer.parseInt(request.getParameter("poId"));
            PurchaseOrder po = purchaseOrderDAO.findById(poId);

            // Create Stock Inward
            StockInward stockInward = StockInward.builder()
                    .inwardCode(stockInwardDAO.generateInwardCode())
                    .supplierId(po.getProviderId())
                    .userId(currentUser.getUserId())
                    .warehouseId(po.getWarehouseId())
                    .poId(poId)
                    .inwardDate(LocalDateTime.now())
                    .notes(request.getParameter("notes"))
                    .build();

            int stockInwardId = stockInwardDAO.insert(stockInward);

            if (stockInwardId > 0) {
                // Create Stock Inward Details
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantityReceived");
                String[] unitPrices = request.getParameterValues("unitPrice");

                if (productIds != null && quantities != null && unitPrices != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (!productIds[i].isEmpty() && !quantities[i].isEmpty() && !unitPrices[i].isEmpty()) {
                            StockInwardDetail detail = StockInwardDetail.builder()
                                    .stockInwardId(stockInwardId)
                                    .productId(Integer.valueOf(productIds[i]))
                                    .quantityReceived(Integer.valueOf(quantities[i]))
                                    .unitPurchasePrice(new BigDecimal(unitPrices[i]))
                                    .build();
                            stockInwardDetailDAO.insert(detail);
                        }
                    }
                }

                session.setAttribute("toastMessage", "Tạo nhập kho thành công!");
                session.setAttribute("toastType", "success");

                response.sendRedirect("purchasing?action=view-stock-inward&id=" + stockInwardId);
                return;
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Lỗi khi tạo nhập kho: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }

        response.sendRedirect("purchasing?action=list-po");
    }

    private void handleCreateAndCompleteStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = SessionUtil.getUserFromSession(request);

            int poId = Integer.parseInt(request.getParameter("poId"));
            PurchaseOrder po = purchaseOrderDAO.findById(poId);
            Rfq rfq = rfqDAO.findById(po.getRfqId());

            // Create Stock Inward
            StockInward stockInward = StockInward.builder()
                    .inwardCode(stockInwardDAO.generateInwardCode())
                    .supplierId(po.getProviderId())
                    .userId(currentUser.getUserId())
                    .warehouseId(po.getWarehouseId())
                    .poId(poId)
                    .inwardDate(LocalDateTime.now())
                    .notes(request.getParameter("notes"))
                    .build();

            int stockInwardId = stockInwardDAO.insert(stockInward);

            if (stockInwardId > 0) {
                // Create Stock Inward Details and update inventory
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantityReceived");
                String[] unitPrices = request.getParameterValues("unitPrice");

                if (productIds != null && quantities != null && unitPrices != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (!productIds[i].isEmpty() && !quantities[i].isEmpty() && !unitPrices[i].isEmpty()) {
                            StockInwardDetail detail = StockInwardDetail.builder()
                                    .stockInwardId(stockInwardId)
                                    .productId(Integer.valueOf(productIds[i]))
                                    .quantityReceived(Integer.valueOf(quantities[i]))
                                    .unitPurchasePrice(new BigDecimal(unitPrices[i]))
                                    .build();
                            stockInwardDetailDAO.insert(detail);

                            // Update inventory
                            inventoryDAO.updateQuantityOnHand(Integer.valueOf(productIds[i]),
                                    po.getWarehouseId(),
                                    Integer.valueOf(quantities[i]),
                                    "add");
                        }
                    }
                }

                // Update all statuses to completed
                rfq.setStatus("completed");
                rfqDAO.update(rfq);

                po.setStatus("completed");
                purchaseOrderDAO.update(po);

                session.setAttribute("toastMessage",
                        "Tạo và hoàn thành nhập kho thành công! Tồn kho đã được cập nhật.");
                session.setAttribute("toastType", "success");

                response.sendRedirect("purchasing?action=view-stock-inward&id=" + stockInwardId);
                return;
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Lỗi khi tạo và hoàn thành nhập kho: " + e.getMessage());
            session.setAttribute("toastType", "error");
        }

        response.sendRedirect("purchasing?action=list-po");
    }

    private void handleListStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<StockInward> stockInwards = stockInwardDAO.findAll();
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();

        request.setAttribute("stockInwards", stockInwards);
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("view/dashboard/purchasingStaff/stock-inward/stock-inward-list.jsp")
                .forward(request, response);
    }

    private void handleViewStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int stockInwardId = Integer.parseInt(request.getParameter("id"));
        StockInward stockInward = stockInwardDAO.findById(stockInwardId);
        List<StockInwardDetail> stockInwardDetails = stockInwardDetailDAO.findByStockInwardId(stockInwardId);

        Supplier supplier = supplierDAO.findById(stockInward.getSupplierId());
        Warehouse warehouse = warehouseDAO.findById(stockInward.getWarehouseId());
        List<Product> products = productDAO.findAll();

        request.setAttribute("stockInward", stockInward);
        request.setAttribute("stockInwardDetails", stockInwardDetails);
        request.setAttribute("supplier", supplier);
        request.setAttribute("warehouse", warehouse);
        request.setAttribute("products", products);

        request.getRequestDispatcher("view/dashboard/purchasingStaff/stock-inward/view-stock-inward.jsp")
                .forward(request, response);
    }

    // Other required methods...
    private void handleShowEditRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int rfqId = Integer.parseInt(request.getParameter("id"));
            Rfq rfq = rfqDAO.findById(rfqId);

            if (rfq == null) {
                HttpSession session = request.getSession();
                session.setAttribute("toastMessage", "Không tìm thấy yêu cầu báo giá!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("purchasing?action=list-rfq");
                return;
            }

            // Check if RFQ can be edited (only pending status)
            if (!"pending".equals(rfq.getStatus())) {
                HttpSession session = request.getSession();
                session.setAttribute("toastMessage", "YCB chỉ có thể chỉnh sửa khi trạng thái là CHỜ XỬ LÝ!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("purchasing?action=view-rfq&id=" + rfqId);
                return;
            }

            // Check if current user is the requester
            User currentUser = SessionUtil.getUserFromSession(request);
            if (currentUser == null || !rfq.getUserIdRequester().equals(currentUser.getUserId())) {
                HttpSession session = request.getSession();
                session.setAttribute("toastMessage", "Bạn chỉ có thể chỉnh sửa YCB của chính mình!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("purchasing?action=list-rfq");
                return;
            }

            List<RfqDetail> rfqDetails = rfqDetailDAO.findByRfqId(rfqId);
            List<Supplier> suppliers = supplierDAO.findAll();
            List<Warehouse> warehouses = warehouseDAO.findAll();
            List<Product> products = productDAO.findAll();

            request.setAttribute("rfq", rfq);
            request.setAttribute("rfqDetails", rfqDetails);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("warehouses", warehouses);
            request.setAttribute("products", products);

            request.getRequestDispatcher("view/dashboard/purchasingStaff/rfq/edit-rfq.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Mã YCB không hợp lệ!");
            session.setAttribute("toastType", "error");
            response.sendRedirect("purchasing?action=list-rfq");
        }
    }

    private void handleUpdateRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = SessionUtil.getUserFromSession(request);

            int rfqId = Integer.parseInt(request.getParameter("rfqId"));
            Rfq existingRfq = rfqDAO.findById(rfqId);

            if (existingRfq == null) {
                session.setAttribute("toastMessage", "Không tìm thấy yêu cầu báo giá!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("purchasing?action=list-rfq");
                return;
            }

            // Check if RFQ can be edited (only pending status)
            if (!"pending".equals(existingRfq.getStatus())) {
                session.setAttribute("toastMessage", "YCB chỉ có thể chỉnh sửa khi trạng thái là CHỜ XỬ LÝ!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("purchasing?action=view-rfq&id=" + rfqId);
                return;
            }

            // Check if current user is the requester
            if (currentUser == null || !existingRfq.getUserIdRequester().equals(currentUser.getUserId())) {
                session.setAttribute("toastMessage", "Bạn chỉ có thể chỉnh sửa YCB của chính mình!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("purchasing?action=list-rfq");
                return;
            }

            // Update RFQ
            Rfq rfq = Rfq.builder()
                    .rfqId(rfqId)
                    .rfqCode(existingRfq.getRfqCode()) // Keep original code
                    .expectedDeliveryDate(Date.valueOf(request.getParameter("expectedDeliveryDate")))
                    .providerId(Integer.valueOf(request.getParameter("providerId")))
                    .warehouseId(Integer.valueOf(request.getParameter("warehouseId")))
                    .userIdRequester(currentUser.getUserId())
                    .status("pending") // Keep status as pending
                    .note(request.getParameter("note"))
                    .build();

            boolean success = rfqDAO.update(rfq);

            if (success) {
                // Delete existing RFQ details
                rfqDetailDAO.deleteByRfqId(rfqId);

                // Create new RFQ Details
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantity");

                if (productIds != null && quantities != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (!productIds[i].isEmpty() && !quantities[i].isEmpty()) {
                            RfqDetail detail = RfqDetail.builder()
                                    .rfqId(rfqId)
                                    .productId(Integer.valueOf(productIds[i]))
                                    .quantity(Integer.valueOf(quantities[i]))
                                    .build();
                            rfqDetailDAO.insert(detail);
                        }
                    }
                }

                session.setAttribute("toastMessage", "Cập nhật yêu cầu báo giá thành công!");
                session.setAttribute("toastType", "success");
                response.sendRedirect("purchasing?action=view-rfq&id=" + rfqId);
            } else {
                session.setAttribute("toastMessage", "Cập nhật yêu cầu báo giá thất bại!");
                session.setAttribute("toastType", "error");
                response.sendRedirect("purchasing?action=edit-rfq&id=" + rfqId);
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Lỗi khi cập nhật YCB: " + e.getMessage());
            session.setAttribute("toastType", "error");
            response.sendRedirect("purchasing?action=list-rfq");
        }
    }

    private void handleShowEditPo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for editing PO
        response.sendRedirect("purchasing?action=list-po");
    }

    private void handleUpdatePo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for updating PO
        response.sendRedirect("purchasing?action=list-po");
    }

    private void handleListPOForStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // List POs that are approved and ready for stock inward creation
        List<PurchaseOrder> approvedPOs = purchaseOrderDAO.findByStatus("approved");
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();

        request.setAttribute("purchaseOrders", approvedPOs);
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("view/dashboard/purchasingStaff/purchase-order/po-list-for-stock-inward.jsp")
                .forward(request, response);
    }

    // Inventory Management Methods
    private void handleInventoryList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> products = productDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();

        // Pre-compute inventory data to avoid calling DAO in JSP
        List<Map<String, Object>> inventoryData = new ArrayList<>();

        for (Product product : products) {
            for (Warehouse warehouse : warehouses) {
                Integer quantity = inventoryDAO.getQuantityOnHand(product.getProductId(), warehouse.getWarehouseId());

                Map<String, Object> inventoryItem = new HashMap<>();
                inventoryItem.put("productCode", product.getProductCode());
                inventoryItem.put("productName", product.getProductName());
                inventoryItem.put("warehouseName", warehouse.getWarehouseName());
                inventoryItem.put("quantity", quantity);
                inventoryItem.put("unit", product.getUnit());
                inventoryItem.put("lowStockThreshold", product.getLowStockThreshold());

                // Determine status
                String status;
                String statusClass;
                if (quantity <= product.getLowStockThreshold()) {
                    status = "Low Stock";
                    statusClass = "bg-danger";
                } else {
                    status = "In Stock";
                    statusClass = "bg-success";
                }
                inventoryItem.put("status", status);
                inventoryItem.put("statusClass", statusClass);

                inventoryData.add(inventoryItem);
            }
        }

        request.setAttribute("inventoryData", inventoryData);
        request.setAttribute("warehouses", warehouses); // Add warehouse list for filter
        request.getRequestDispatcher("view/dashboard/purchasingStaff/inventory-list.jsp").forward(request, response);
    }

}
