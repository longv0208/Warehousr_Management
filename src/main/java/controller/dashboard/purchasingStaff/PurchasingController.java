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
import java.util.List;

@WebServlet(name = "PurchasingController", urlPatterns = {"/purchasing"})
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
        HttpSession session = request.getSession();
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

                session.setAttribute("toastMessage", "RFQ created successfully!");
                session.setAttribute("toastType", "success");
            } else {
                session.setAttribute("toastMessage", "Failed to create RFQ!");
                session.setAttribute("toastType", "error");
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Error creating RFQ: " + e.getMessage());
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

        request.setAttribute("rfq", rfq);
        request.setAttribute("rfqDetails", rfqDetails);
        request.setAttribute("supplier", supplier);
        request.setAttribute("warehouse", warehouse);
        request.setAttribute("existingPO", existingPO);
        request.setAttribute("products", productDAO.findAll());
        
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
                session.setAttribute("toastMessage", "RFQ sent successfully!");
                session.setAttribute("toastType", "success");
            } else {
                session.setAttribute("toastMessage", "Failed to send RFQ!");
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
        
        Supplier supplier = supplierDAO.findById(rfq.getProviderId());
        Warehouse warehouse = warehouseDAO.findById(rfq.getWarehouseId());
        List<Product> products = productDAO.findAll();

        request.setAttribute("rfq", rfq);
        request.setAttribute("rfqDetails", rfqDetails);
        request.setAttribute("supplier", supplier);
        request.setAttribute("warehouse", warehouse);
        request.setAttribute("products", products);
        
        request.getRequestDispatcher("view/dashboard/purchasingStaff/po/create-po.jsp").forward(request, response);
    }

    private void handleCreatePo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int rfqId = Integer.parseInt(request.getParameter("rfqId"));
            Rfq rfq = rfqDAO.findById(rfqId);

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
                // Create PO Details with prices from form
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantity");
                String[] unitPrices = request.getParameterValues("unitPrice");

                if (productIds != null && quantities != null && unitPrices != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (!productIds[i].isEmpty() && !quantities[i].isEmpty() && !unitPrices[i].isEmpty()) {
                            PurchaseOrderDetail detail = PurchaseOrderDetail.builder()
                                    .poId(poId)
                                    .productId(Integer.valueOf(productIds[i]))
                                    .quantity(Integer.valueOf(quantities[i]))
                                    .unitPrice(new BigDecimal(unitPrices[i]))
                                    .build();
                            purchaseOrderDetailDAO.insert(detail);
                        }
                    }
                }

                // Update RFQ status
                rfq.setStatus("approved");
                rfqDAO.update(rfq);

                HttpSession session = request.getSession();
                session.setAttribute("toastMessage", "Purchase Order created successfully!");
                session.setAttribute("toastType", "success");
                
                response.sendRedirect("purchasing?action=view-po&id=" + poId);
                return;
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Error creating PO: " + e.getMessage());
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
        
        request.getRequestDispatcher("view/dashboard/purchasingStaff/po/view-po.jsp").forward(request, response);
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
        
        request.getRequestDispatcher("view/dashboard/purchasingStaff/stock-inward/create-stock-inward.jsp").forward(request, response);
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

                session.setAttribute("toastMessage", "Stock Inward created successfully!");
                session.setAttribute("toastType", "success");
                
                response.sendRedirect("purchasing?action=view-stock-inward&id=" + stockInwardId);
                return;
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Error creating Stock Inward: " + e.getMessage());
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

                session.setAttribute("toastMessage", "Stock Inward created and completed successfully! Inventory updated.");
                session.setAttribute("toastType", "success");
                
                response.sendRedirect("purchasing?action=view-stock-inward&id=" + stockInwardId);
                return;
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Error creating and completing Stock Inward: " + e.getMessage());
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
        request.getRequestDispatcher("view/dashboard/purchasingStaff/stock-inward/stock-inward-list.jsp").forward(request, response);
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
        
        request.getRequestDispatcher("view/dashboard/purchasingStaff/stock-inward/view-stock-inward.jsp").forward(request, response);
    }

    // Other required methods...
    private void handleShowEditRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for editing RFQ
        response.sendRedirect("purchasing?action=list-rfq");
    }

    private void handleUpdateRfq(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for updating RFQ
        response.sendRedirect("purchasing?action=list-rfq");
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
        // List POs that are completed and ready for stock inward creation
        List<PurchaseOrder> completedPOs = purchaseOrderDAO.findByStatus("completed");
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();

        request.setAttribute("purchaseOrders", completedPOs);
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("view/dashboard/purchasingStaff/purchase-order/po-list-for-stock-inward.jsp").forward(request, response);
    }

    // Inventory Management Methods
    private void handleInventoryList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> products = productDAO.findAll();
        List<Warehouse> warehouses = warehouseDAO.findAll();
        
        request.setAttribute("products", products);
        request.setAttribute("warehouses", warehouses);
        request.setAttribute("inventoryDAO", inventoryDAO);
        request.getRequestDispatcher("view/dashboard/purchasingStaff/inventory-list.jsp").forward(request, response);
    }
} 