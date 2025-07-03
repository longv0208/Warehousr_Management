package controller.dashboard.warehouseStaff;

import context.DBContext;
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
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "WarehouseController", urlPatterns = {"/warehouse"})
public class WarehouseController extends HttpServlet {

    private SalesOrderDAO salesOrderDAO;
    private SalesOrderDetailDAO salesOrderDetailDAO;
    private StockOutwardDAO stockOutwardDAO;
    private StockOutwardDetailDAO stockOutwardDetailDAO;
    private InventoryDAO inventoryDAO;
    private DeliveryTrackingDAO deliveryTrackingDAO;
    private UserDAO userDAO;
    private WarehouseDAO warehouseDAO;
    private ProductDAO productDAO;

    @Override
    public void init() {
        salesOrderDAO = new SalesOrderDAO();
        salesOrderDetailDAO = new SalesOrderDetailDAO();
        stockOutwardDAO = new StockOutwardDAO();
        stockOutwardDetailDAO = new StockOutwardDetailDAO();
        inventoryDAO = new InventoryDAO();
        deliveryTrackingDAO = new DeliveryTrackingDAO();
        userDAO = new UserDAO();
        warehouseDAO = new WarehouseDAO();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list-sales-orders";
        }

        switch (action) {
            case "list-sales-orders":
                listSalesOrders(request, response);
                break;
            case "view-sales-order":
                viewSalesOrder(request, response);
                break;
            case "confirm-stock":
                confirmStock(request, response);
                break;
            case "create-outward-form":
                showCreateOutwardForm(request, response);
                break;
            case "list-outwards":
                listStockOutwards(request, response);
                break;
            default:
                listSalesOrders(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/warehouse?action=list-sales-orders");
            return;
        }

        switch (action) {
            case "create-stock-outward":
                createStockOutward(request, response);
                break;
            case "complete-order":
                completeOrder(request, response);
                break;
            default:
                listSalesOrders(request, response);
                break;
        }
    }

    private void listSalesOrders(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String[] statuses = {"pending_stock_check", "awaiting_shipment", "shipped"};
        List<SalesOrder> orders = new ArrayList<>();
        for (String status : statuses) {
            orders.addAll(salesOrderDAO.findByStatus(status));
        }
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/view/dashboard/warehouseStaff/sales/list.jsp").forward(request, response);
    }

    private void viewSalesOrder(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int orderId = Integer.parseInt(request.getParameter("id"));
        SalesOrder order = salesOrderDAO.findById(orderId);
        List<SalesOrderDetailDAO.SalesOrderDetailWithProduct> details = salesOrderDetailDAO.findBySalesOrderIdWithCompleteProductInfo(orderId);
        User creator = userDAO.findById(order.getUserId());
        Warehouse warehouse = warehouseDAO.findById(order.getWarehouseId());

        Map<Integer, Integer> inventoryInfo = new HashMap<>();
        for (SalesOrderDetailDAO.SalesOrderDetailWithProduct detail : details) {
            int stock = inventoryDAO.getQuantityByProductIdAndWarehouse(detail.getProductId(), order.getWarehouseId());
            inventoryInfo.put(detail.getProductId(), stock);
        }

        request.setAttribute("order", order);
        request.setAttribute("details", details);
        request.setAttribute("inventoryInfo", inventoryInfo);
        request.setAttribute("creator", creator);
        request.setAttribute("warehouse", warehouse);
        request.getRequestDispatcher("/view/dashboard/warehouseStaff/sales/view.jsp").forward(request, response);
    }

    private void confirmStock(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        int orderId = Integer.parseInt(request.getParameter("id"));
        SalesOrder order = salesOrderDAO.findById(orderId);

        if (order == null) {
            session.setAttribute("toastMessage", "Không tìm thấy đơn hàng!");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/warehouse?action=list-sales-orders");
            return;
        }

        // Ensure order is in the correct state to be confirmed
        if (!"pending_stock_check".equals(order.getStatus())) {
            session.setAttribute("toastMessage", "Đơn hàng không ở trạng thái 'Chờ kiểm tra kho' nên không thể xác nhận.");
            session.setAttribute("toastType", "warning");
            response.sendRedirect(request.getContextPath() + "/warehouse?action=view-sales-order&id=" + orderId);
            return;
        }

        List<SalesOrderDetail> orderDetails = salesOrderDetailDAO.findBySalesOrderId(orderId);
        StringBuilder insufficientStockMessage = new StringBuilder();

        for (SalesOrderDetail detail : orderDetails) {
            int availableQuantity = inventoryDAO.getQuantityByProductIdAndWarehouse(detail.getProductId(), order.getWarehouseId());
            if (detail.getQuantityOrdered() > availableQuantity) {
                Product product = productDAO.findById(detail.getProductId());
                if (insufficientStockMessage.length() > 0) {
                    insufficientStockMessage.append("<br>");
                }
                insufficientStockMessage.append("Không đủ tồn kho cho sản phẩm: <b>")
                        .append(product.getProductName()).append(" (").append(product.getProductCode()).append(")</b>")
                        .append(". Yêu cầu: ").append(detail.getQuantityOrdered())
                        .append(", Tồn kho: ").append(availableQuantity);
            }
        }

        if (insufficientStockMessage.length() > 0) {
            session.setAttribute("toastMessage", insufficientStockMessage.toString());
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/warehouse?action=view-sales-order&id=" + orderId);
            return;
        }

        boolean updated = salesOrderDAO.updateStatus(orderId, "awaiting_shipment");
        if (updated) {
            session.setAttribute("toastMessage", "Xác nhận tồn kho thành công. Đơn hàng đã chuyển sang trạng thái Chờ giao hàng.");
            session.setAttribute("toastType", "success");
        } else {
            session.setAttribute("toastMessage", "Lỗi khi cập nhật trạng thái đơn hàng.");
            session.setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/warehouse?action=view-sales-order&id=" + orderId);
    }

    private void showCreateOutwardForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int orderId = Integer.parseInt(request.getParameter("id"));
        SalesOrder order = salesOrderDAO.findById(orderId);
        Warehouse warehouse = warehouseDAO.findById(order.getWarehouseId());
        List<SalesOrderDetailDAO.SalesOrderDetailWithProduct> details = salesOrderDetailDAO.findBySalesOrderIdWithCompleteProductInfo(orderId);

        request.setAttribute("order", order);
        request.setAttribute("details", details);
        request.setAttribute("warehouse", warehouse);
        request.getRequestDispatcher("/view/dashboard/warehouseStaff/sales/create-outward.jsp").forward(request, response);
    }

    private void createStockOutward(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User currentUser = SessionUtil.getUserFromSession(request);
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        SalesOrder order = salesOrderDAO.findById(orderId);
        List<SalesOrderDetail> details = salesOrderDetailDAO.findBySalesOrderId(orderId);
        Connection conn = null;

        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            StockOutward stockOutward = StockOutward.builder()
                    .outwardCode(stockOutwardDAO.generateOutwardCode())
                    .salesOrderId(orderId)
                    .userId(currentUser.getUserId())
                    .warehouseId(order.getWarehouseId())
                    .outwardDate(Timestamp.from(Instant.now()))
                    .reason("sale")
                    .notes("Xuất kho cho đơn hàng " + order.getOrderCode())
                    .build();

            int stockOutwardId = stockOutwardDAO.insert(stockOutward);

            for (SalesOrderDetail detail : details) {
                StockOutwardDetail sod = new StockOutwardDetail(null, stockOutwardId, detail.getProductId(), detail.getQuantityOrdered(), null, null, null);
                stockOutwardDetailDAO.insert(sod);
                inventoryDAO.decreaseQuantity(detail.getProductId(), order.getWarehouseId(), detail.getQuantityOrdered());
            }

            boolean statusUpdated = salesOrderDAO.updateStatus(orderId, "shipped");

            if (stockOutwardId != -1 && statusUpdated) {
                DeliveryTracking tracking = DeliveryTracking.builder()
                        .salesOrderId(orderId)
                        .status("shipped")
                        .notes("Đơn hàng đã được xuất kho và đang trên đường vận chuyển.")
                        .build();
                deliveryTrackingDAO.insert(tracking);
                conn.commit();
                session.setAttribute("toastMessage", "Tạo phiếu xuất kho thành công!");
                session.setAttribute("toastType", "success");
            } else {
                conn.rollback();
                session.setAttribute("toastMessage", "Tạo phiếu xuất kho thất bại.");
                session.setAttribute("toastType", "error");
            }
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            session.setAttribute("toastMessage", "Lỗi hệ thống khi tạo phiếu xuất.");
            session.setAttribute("toastType", "error");
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/warehouse?action=list-sales-orders");
    }

    private void completeOrder(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int orderId = Integer.parseInt(request.getParameter("id"));
        salesOrderDAO.updateStatus(orderId, "completed");
        response.sendRedirect(request.getContextPath() + "/warehouse?action=view-sales-order&id=" + orderId);
    }
    
    private void listStockOutwards(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = currentUser.getRoleId();
        Integer userIdFilter = null;
        if ("warehouse_staff".equals(role)) {
            userIdFilter = currentUser.getUserId();
        }

        int page = 1;
        int pageSize = 10;
        if (request.getParameter("page") != null) {
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        List<StockOutward> outwards = stockOutwardDAO.findWithFilters(userIdFilter, null, page, pageSize);
        int totalOutwards = stockOutwardDAO.countWithFilters(userIdFilter, null);
        int totalPages = (int) Math.ceil((double) totalOutwards / pageSize);

        request.setAttribute("outwards", outwards);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOutwards", totalOutwards);

        request.getRequestDispatcher("/view/dashboard/warehouseStaff/outward/list.jsp").forward(request, response);
    }
}