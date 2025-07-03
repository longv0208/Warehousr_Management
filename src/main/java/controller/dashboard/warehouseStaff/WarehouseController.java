package controller.dashboard.warehouseStaff;

import dao.InventoryDAO;
import dao.ProductDAO;
import dao.PurchaseOrderDAO;
import dao.PurchaseOrderDetailDAO;
import dao.RfqDAO;
import dao.StockInwardDAO;
import dao.StockInwardDetailDAO;
import dao.SupplierDAO;
import dao.WarehouseDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.PurchaseOrder;
import model.PurchaseOrderDetail;
import model.PurchaseOrderDetailView;
import model.Rfq;
import model.StockInward;
import model.StockInwardDetail;
import model.Supplier;
import model.User;
import model.Warehouse;
import model.Product;
import utils.SessionUtil;

@WebServlet(name = "WarehouseController", urlPatterns = {"/warehouse"})
public class WarehouseController extends HttpServlet {

    private final PurchaseOrderDAO purchaseOrderDAO = new PurchaseOrderDAO();
    private final PurchaseOrderDetailDAO purchaseOrderDetailDAO = new PurchaseOrderDetailDAO();
    private final StockInwardDAO stockInwardDAO = new StockInwardDAO();
    private final StockInwardDetailDAO stockInwardDetailDAO = new StockInwardDetailDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final WarehouseDAO warehouseDAO = new WarehouseDAO();
    private final RfqDAO rfqDAO = new RfqDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "default";
        }

        switch (action) {
            case "list-po-for-inward":
                handleListPoForInward(request, response);
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
            default:
                // Redirect to a default warehouse page or dashboard
                response.sendRedirect(request.getContextPath() + "/dashboard");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        switch (action) {
            case "create-stock-inward":
                handleCreateAndCompleteStockInward(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/dashboard");
                break;
        }
    }

    private void handleListPoForInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<PurchaseOrder> pendingPOs = purchaseOrderDAO.findByStatus("pending");
        request.setAttribute("pos", pendingPOs);
        request.setAttribute("suppliers", supplierDAO.findAll());
        request.setAttribute("warehouses", warehouseDAO.findAll());
        request.getRequestDispatcher("/view/dashboard/warehouseStaff/po-list-for-inward.jsp").forward(request, response);
    }

    private void handleShowCreateStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int poId = Integer.parseInt(request.getParameter("poId"));
            PurchaseOrder po = purchaseOrderDAO.findById(poId);
            if (po == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Purchase Order not found.");
                return;
            }

            List<PurchaseOrderDetail> poDetails = purchaseOrderDetailDAO.findByPoId(poId);
            Supplier supplier = supplierDAO.findById(po.getProviderId());
            Warehouse warehouse = warehouseDAO.findById(po.getWarehouseId());
            List<Product> allProducts = productDAO.findAll();
            
            List<PurchaseOrderDetailView> detailViews = new ArrayList<>();
            for (PurchaseOrderDetail detail : poDetails) {
                Product product = allProducts.stream()
                    .filter(p -> p.getProductId().equals(detail.getProductId()))
                    .findFirst()
                    .orElse(null);
                detailViews.add(new PurchaseOrderDetailView(detail, product));
            }

            request.setAttribute("po", po);
            request.setAttribute("poDetails", detailViews);
            request.setAttribute("supplier", supplier);
            request.setAttribute("warehouse", warehouse);

            request.getRequestDispatcher("/view/dashboard/warehouseStaff/create-stock-inward.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Purchase Order ID.");
        }
    }

    private void handleListStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<StockInward> stockInwards = stockInwardDAO.findAll();
        request.setAttribute("stockInwards", stockInwards);
        request.getRequestDispatcher("/view/dashboard/warehouseStaff/list-stock-inward.jsp").forward(request, response);
    }
    
    private void handleViewStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int inwardId = Integer.parseInt(request.getParameter("id"));
            StockInward stockInward = stockInwardDAO.findById(inwardId);
            if (stockInward == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Stock Inward record not found.");
                return;
            }
            
            List<StockInwardDetail> details = stockInwardDetailDAO.findByStockInwardId(inwardId);
            
            request.setAttribute("stockInward", stockInward);
            request.setAttribute("details", details);
            request.setAttribute("products", productDAO.findAll()); // To get product names
            
            request.getRequestDispatcher("/view/dashboard/warehouseStaff/view-stock-inward.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Stock Inward ID.");
        }
    }

    private void handleCreateAndCompleteStockInward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        try {
            User currentUser = SessionUtil.getUserFromSession(request);
            int poId = Integer.parseInt(request.getParameter("poId"));
            PurchaseOrder po = purchaseOrderDAO.findById(poId);
            Rfq rfq = rfqDAO.findById(po.getRfqId());

            StockInward stockInward = StockInward.builder()
                    .inwardCode(stockInwardDAO.generateInwardCode())
                    .supplierId(po.getProviderId())
                    .userId(currentUser.getUserId())
                    .warehouseId(po.getWarehouseId())
                    .poId(poId)
                    .inwardDate(LocalDateTime.now())
                    .notes(request.getParameter("description"))
                    .build();

            int stockInwardId = stockInwardDAO.insert(stockInward);

            if (stockInwardId > 0) {
                String[] productIds = request.getParameterValues("productId");
                String[] receivedQuantities = request.getParameterValues("actualReceivedQty");
                String[] unitPrices = request.getParameterValues("unitPrice");

                for (int i = 0; i < productIds.length; i++) {
                    int productId = Integer.parseInt(productIds[i]);
                    int quantity = Integer.parseInt(receivedQuantities[i]);
                    BigDecimal unitPrice = new BigDecimal(unitPrices[i]);

                    StockInwardDetail detail = StockInwardDetail.builder()
                            .stockInwardId(stockInwardId)
                            .productId(productId)
                            .quantityReceived(quantity)
                            .unitPurchasePrice(unitPrice)
                            .build();
                    stockInwardDetailDAO.insert(detail);

                    inventoryDAO.updateQuantityOnHand(productId, po.getWarehouseId(), quantity, "add");
                }

                po.setStatus("completed");
                purchaseOrderDAO.update(po);

                if (rfq != null) {
                    rfq.setStatus("completed");
                    rfqDAO.update(rfq);
                }

                session.setAttribute("toastMessage", "Import receipt created successfully and inventory updated.");
                session.setAttribute("toastType", "success");
                response.sendRedirect(request.getContextPath() + "/warehouse?action=list-po-for-inward");
            } else {
                throw new Exception("Failed to create stock inward record.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("toastMessage", "Error creating import receipt: " + e.getMessage());
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/warehouse?action=list-po-for-inward");
        }
    }

    @Override
    public String getServletInfo() {
        return "Warehouse Controller for handling stock inward and other warehouse operations.";
    }
} 