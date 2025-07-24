package controller.dashboard.admin;

import dao.WarehouseDAO;
import dao.InventoryDAO;
import dao.StockInwardDAO;
import dao.StockOutwardDAO;
import dao.StockInwardDetailDAO;
import dao.StockOutwardDetailDAO;
import dao.ProductDAO;
import dao.SalesOrderDAO;
import dao.SalesOrderDetailDAO;
import dao.PurchaseOrderDAO;
import dao.PurchaseOrderDetailDAO;
import model.Warehouse;
import model.User;
import model.StockInward;
import model.StockOutward;
import model.StockInwardDetail;
import model.StockOutwardDetail;
import model.Product;
import model.WarehouseTransaction;
import model.WarehouseProductStatus;
import model.SalesOrder;
import model.SalesOrderDetail;
import model.PurchaseOrder;
import model.PurchaseOrderDetail;
import utils.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;

@WebServlet(name = "ManageWarehouseController", urlPatterns = {"/admin/manage-warehouse"})
public class ManageWarehouseController extends HttpServlet {

    private WarehouseDAO warehouseDAO;
    private StockInwardDAO stockInwardDAO;
    private StockOutwardDAO stockOutwardDAO;
    private StockInwardDetailDAO stockInwardDetailDAO;
    private StockOutwardDetailDAO stockOutwardDetailDAO;
    private ProductDAO productDAO;
    private InventoryDAO inventoryDAO;
    private SalesOrderDAO salesOrderDAO;
    private SalesOrderDetailDAO salesOrderDetailDAO;
    private PurchaseOrderDAO purchaseOrderDAO;
    private PurchaseOrderDetailDAO purchaseOrderDetailDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        warehouseDAO = new WarehouseDAO();
        stockInwardDAO = new StockInwardDAO();
        stockOutwardDAO = new StockOutwardDAO();
        stockInwardDetailDAO = new StockInwardDetailDAO();
        stockOutwardDetailDAO = new StockOutwardDetailDAO();
        productDAO = new ProductDAO();
        inventoryDAO = new InventoryDAO();
        salesOrderDAO = new SalesOrderDAO();
        salesOrderDetailDAO = new SalesOrderDetailDAO();
        purchaseOrderDAO = new PurchaseOrderDAO();
        purchaseOrderDetailDAO = new PurchaseOrderDetailDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list"; // Default action
        }

        // Check permissions - allow both admin and warehouse manager
        String userRole = currentUser.getRoleId();
        if (!action.equals("list") && !action.equals("view")
                && !"admin".equals(userRole) && !"warehouse_manager".equals(userRole)) {
            request.getSession().setAttribute("toastMessage", "Bạn không có quyền thực hiện thao tác này!");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        switch (action) {
            case "list":
                listWarehouses(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteWarehouse(request, response);
                break;
            case "view":
                viewWarehouse(request, response);
                break;
            case "history":
                viewWarehouseProductStatus(request, response);
                break;
            case "export_history":
                exportWarehouseProductStatusToExcel(request, response);
                break;
            default:
                listWarehouses(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Check permissions - allow both admin and warehouse manager
        String userRole = currentUser.getRoleId();
        if (!"admin".equals(userRole) && !"warehouse_manager".equals(userRole)) {
            request.getSession().setAttribute("toastMessage", "Bạn không có quyền thực hiện thao tác này!");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        switch (action) {
            case "create":
                createWarehouse(request, response);
                break;
            case "edit":
                updateWarehouse(request, response);
                break;
            default:
                listWarehouses(request, response);
                break;
        }
    }

    private void listWarehouses(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchTerm = request.getParameter("search");
        List<Warehouse> warehouses;

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            warehouses = warehouseDAO.searchWarehouses(searchTerm.trim());
        } else {
            warehouses = warehouseDAO.findAll();
        }

        // Get current user for permission checking in JSP
        User currentUser = SessionUtil.getUserFromSession(request);
        String userRole = (currentUser != null) ? currentUser.getRoleId() : "";

        request.setAttribute("warehouses", warehouses);
        request.setAttribute("searchTerm", searchTerm);
        request.setAttribute("userRole", userRole);
        request.getRequestDispatcher("/view/dashboard/admin/warehouse/warehouse.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
    }

    private void createWarehouse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String warehouseName = request.getParameter("warehouseName");
        String address = request.getParameter("address");

        // Validation
        if (warehouseName == null || warehouseName.trim().isEmpty()) {
            request.setAttribute("error", "Tên kho hàng không được để trống!");
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
            return;
        }

        if (address == null || address.trim().isEmpty()) {
            request.setAttribute("error", "Địa chỉ không được để trống!");
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
            return;
        }

        // Check if warehouse name already exists
        if (warehouseDAO.isWarehouseNameExists(warehouseName.trim())) {
            request.setAttribute("error", "Tên kho hàng đã tồn tại!");
            request.setAttribute("warehouseName", warehouseName);
            request.setAttribute("address", address);
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
            return;
        }

        Warehouse warehouse = new Warehouse();
        warehouse.setWarehouseName(warehouseName.trim());
        warehouse.setAddress(address.trim());

        int result = warehouseDAO.insert(warehouse);
        if (result > 0) {
            request.getSession().setAttribute("toastMessage", "Thêm kho hàng thành công!");
            request.getSession().setAttribute("toastType", "success");
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        } else {
            request.setAttribute("error", "Có lỗi xảy ra khi thêm kho hàng!");
            request.setAttribute("warehouseName", warehouseName);
            request.setAttribute("address", address);
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/addWarehouse.jsp").forward(request, response);
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        try {
            int warehouseId = Integer.parseInt(idStr);
            Warehouse warehouse = warehouseDAO.findById(warehouseId);
            if (warehouse == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy kho hàng!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            request.setAttribute("warehouse", warehouse);
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request,
                    response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        }
    }

    private void updateWarehouse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("warehouseId");
        String warehouseName = request.getParameter("warehouseName");
        String address = request.getParameter("address");

        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        try {
            int warehouseId = Integer.parseInt(idStr);
            Warehouse currentWarehouse = warehouseDAO.findById(warehouseId);

            if (currentWarehouse == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy kho hàng!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            // Validation
            if (warehouseName == null || warehouseName.trim().isEmpty()) {
                request.setAttribute("error", "Tên kho hàng không được để trống!");
                request.setAttribute("warehouse", currentWarehouse);
                request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request,
                        response);
                return;
            }

            if (address == null || address.trim().isEmpty()) {
                request.setAttribute("error", "Địa chỉ không được để trống!");
                request.setAttribute("warehouse", currentWarehouse);
                request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request,
                        response);
                return;
            }

            // Check if warehouse name already exists (excluding current warehouse)
            if (warehouseDAO.isWarehouseNameExistsExcluding(warehouseName.trim(), warehouseId)) {
                request.setAttribute("error", "Tên kho hàng đã tồn tại!");
                currentWarehouse.setWarehouseName(warehouseName);
                currentWarehouse.setAddress(address);
                request.setAttribute("warehouse", currentWarehouse);
                request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request,
                        response);
                return;
            }

            Warehouse warehouse = new Warehouse();
            warehouse.setWarehouseId(warehouseId);
            warehouse.setWarehouseName(warehouseName.trim());
            warehouse.setAddress(address.trim());

            boolean result = warehouseDAO.update(warehouse);
            if (result) {
                request.getSession().setAttribute("toastMessage", "Cập nhật kho hàng thành công!");
                request.getSession().setAttribute("toastType", "success");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi cập nhật kho hàng!");
                request.setAttribute("warehouse", warehouse);
                request.getRequestDispatcher("/view/dashboard/admin/warehouse/edit-warehouse.jsp").forward(request,
                        response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        }
    }

    private void deleteWarehouse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        try {
            int warehouseId = Integer.parseInt(idStr);
            Warehouse warehouse = warehouseDAO.findById(warehouseId);

            if (warehouse == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy kho hàng!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            // Check if warehouse is being used in inventory or other relations
            if (warehouseDAO.isWarehouseInUse(warehouseId)) {
                request.getSession().setAttribute("toastMessage",
                        "Không thể xóa kho hàng này vì đang được sử dụng trong hệ thống!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            boolean result = warehouseDAO.delete(warehouse);
            if (result) {
                request.getSession().setAttribute("toastMessage", "Xóa kho hàng thành công!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Có lỗi xảy ra khi xóa kho hàng!");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "ID kho hàng không hợp lệ!");
            request.getSession().setAttribute("toastType", "error");
        }

        response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
    }

    private void viewWarehouse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        try {
            int warehouseId = Integer.parseInt(idStr);
            Warehouse warehouse = warehouseDAO.findById(warehouseId);
            if (warehouse == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy kho hàng!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            InventoryDAO inventoryDAO = new InventoryDAO();
            List<model.InventoryWithProduct> productsInWarehouse = inventoryDAO
                    .findAllWithProductInfoByWarehouseId(warehouseId);

            request.setAttribute("warehouse", warehouse);
            request.setAttribute("productsInWarehouse", productsInWarehouse);
            request.getRequestDispatcher("/view/dashboard/admin/warehouse/view-warehouse.jsp").forward(request,
                    response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        }
    }

    private void viewWarehouseProductStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        try {
            int warehouseId = Integer.parseInt(idStr);
            Warehouse warehouse = warehouseDAO.findById(warehouseId);
            if (warehouse == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy kho hàng!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            // Get filter parameters
            String productCode = request.getParameter("productCode");
            String statusFilter = request.getParameter("statusFilter"); // new, low, out_of_stock

            // Get all products that have inventory in this warehouse
            List<model.InventoryWithProduct> inventoryProducts = inventoryDAO
                    .findAllWithProductInfoByWarehouseId(warehouseId);

            // Create list to hold product status information
            List<WarehouseProductStatus> productStatusList = new ArrayList<>();

            for (model.InventoryWithProduct inventoryItem : inventoryProducts) {
                Integer productId = inventoryItem.getProductId();
                Product product = productDAO.findById(productId);

                if (product == null) {
                    continue;
                }

                // Calculate outgoing quantity (từ sales orders đã confirm stock availability)
                Integer outgoingQuantity = calculateOutgoingQuantity(productId, warehouseId);

                // Calculate incoming quantity (từ purchase orders pending)
                Integer incomingQuantity = calculateIncomingQuantity(productId, warehouseId);

                // Create product status object
                WarehouseProductStatus productStatus = new WarehouseProductStatus(
                        productId,
                        product.getProductCode(),
                        product.getProductName(),
                        product.getUnit(),
                        inventoryItem.getQuantityOnHand(),
                        outgoingQuantity,
                        incomingQuantity,
                        product.getSalePrice() != null ? new java.math.BigDecimal(product.getSalePrice().toString()) : java.math.BigDecimal.ZERO,
                        product.getIsActive()
                );

                productStatusList.add(productStatus);
            }

            // Apply filters
            if (productCode != null && !productCode.trim().isEmpty()) {
                String searchCode = productCode.trim().toLowerCase();
                productStatusList = productStatusList.stream()
                        .filter(p -> p.getProductCode().toLowerCase().contains(searchCode)
                        || p.getProductName().toLowerCase().contains(searchCode))
                        .collect(Collectors.toList());
            }

            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                switch (statusFilter) {
                    case "low_stock":
                        productStatusList = productStatusList.stream()
                                .filter(p -> p.getOnHand() > 0 && p.getOnHand() <= 10) // Assume low stock threshold is 10
                                .collect(Collectors.toList());
                        break;
                    case "out_of_stock":
                        productStatusList = productStatusList.stream()
                                .filter(p -> p.getOnHand() <= 0)
                                .collect(Collectors.toList());
                        break;
                    case "available":
                        productStatusList = productStatusList.stream()
                                .filter(p -> p.getOnHand() > 10)
                                .collect(Collectors.toList());
                        break;
                }
            }

            // Sort by product code
            productStatusList.sort((p1, p2) -> p1.getProductCode().compareTo(p2.getProductCode()));

            request.setAttribute("warehouse", warehouse);
            request.setAttribute("productStatusList", productStatusList);

            // Pass filter parameters back to JSP to maintain form state
            request.setAttribute("filterProductCode", productCode);
            request.setAttribute("filterStatusFilter", statusFilter);

            request.getRequestDispatcher("/view/dashboard/admin/warehouse/warehouse-product-status.jsp").forward(request,
                    response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        }
    }

    private void exportWarehouseProductStatusToExcel(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
            return;
        }

        try {
            int warehouseId = Integer.parseInt(idStr);
            Warehouse warehouse = warehouseDAO.findById(warehouseId);
            if (warehouse == null) {
                request.getSession().setAttribute("toastMessage", "Không tìm thấy kho hàng!");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
                return;
            }

            String productCode = request.getParameter("productCode");
            String statusFilter = request.getParameter("statusFilter");

            // Get product status data
            List<model.InventoryWithProduct> inventoryProducts = inventoryDAO
                    .findAllWithProductInfoByWarehouseId(warehouseId);

            List<WarehouseProductStatus> productStatusList = new ArrayList<>();
            for (model.InventoryWithProduct inventoryItem : inventoryProducts) {
                Integer productId = inventoryItem.getProductId();
                Product product = productDAO.findById(productId);

                if (product == null) {
                    continue;
                }

                Integer outgoingQuantity = calculateOutgoingQuantity(productId, warehouseId);
                Integer incomingQuantity = calculateIncomingQuantity(productId, warehouseId);

                WarehouseProductStatus productStatus = new WarehouseProductStatus(
                        productId,
                        product.getProductCode(),
                        product.getProductName(),
                        product.getUnit(),
                        inventoryItem.getQuantityOnHand(),
                        outgoingQuantity,
                        incomingQuantity,
                        product.getSalePrice() != null ? new java.math.BigDecimal(product.getSalePrice().toString()) : java.math.BigDecimal.ZERO,
                        product.getIsActive()
                );

                productStatusList.add(productStatus);
            }

            // Apply filters
            if (productCode != null && !productCode.trim().isEmpty()) {
                String searchCode = productCode.trim().toLowerCase();
                productStatusList = productStatusList.stream()
                        .filter(p -> p.getProductCode().toLowerCase().contains(searchCode)
                        || p.getProductName().toLowerCase().contains(searchCode))
                        .collect(Collectors.toList());
            }

            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                switch (statusFilter) {
                    case "low_stock":
                        productStatusList = productStatusList.stream()
                                .filter(p -> p.getOnHand() > 0 && p.getOnHand() <= 10)
                                .collect(Collectors.toList());
                        break;
                    case "out_of_stock":
                        productStatusList = productStatusList.stream()
                                .filter(p -> p.getOnHand() <= 0)
                                .collect(Collectors.toList());
                        break;
                    case "available":
                        productStatusList = productStatusList.stream()
                                .filter(p -> p.getOnHand() > 10)
                                .collect(Collectors.toList());
                        break;
                }
            }

            response.setContentType("text/csv; charset=UTF-8");
            String fileName = "TrangThaiSanPham_" + warehouse.getWarehouseName().replaceAll("\\s+", "_") + "_"
                    + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".csv";
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

            try (OutputStream out = response.getOutputStream()) {
                StringBuilder csvContent = new StringBuilder();
                csvContent.append("\uFEFF"); // UTF-8 BOM

                // Header
                csvContent.append(
                        "\"Mã Sản Phẩm\",\"Tên Sản Phẩm\",\"Đơn Vị\",\"On Hand\",\"Outgoing\",\"Incoming\",\"Tổng Tồn Kho\",\"Đơn Giá\",\"Trạng Thái\"\n");

                // Data
                for (WarehouseProductStatus product : productStatusList) {
                    csvContent.append("\"").append(escapeCSV(product.getProductCode())).append("\",");
                    csvContent.append("\"").append(escapeCSV(product.getProductName())).append("\",");
                    csvContent.append("\"").append(escapeCSV(product.getUnit())).append("\",");
                    csvContent.append(product.getOnHand()).append(",");
                    csvContent.append(product.getOutgoing()).append(",");
                    csvContent.append(product.getIncoming()).append(",");
                    csvContent.append(product.getTotalInventory()).append(",");
                    csvContent.append(product.getUnitPrice()).append(",");

                    String status = product.getOnHand() <= 0 ? "Hết Hàng"
                            : product.getOnHand() <= 10 ? "Sắp Hết" : "Có Sẵn";
                    csvContent.append("\"").append(escapeCSV(status)).append("\"\n");
                }

                out.write(csvContent.toString().getBytes("UTF-8"));
                out.flush();
            }

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "ID kho hàng không hợp lệ!");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        }
    }

    private String escapeCSV(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\"", "\"\"");
    }

    private List<WarehouseTransaction> getFilteredWarehouseTransactions(int warehouseId, String productCode,
            String transactionType, String fromDateStr, String toDateStr) {
        // This method refactors the data fetching and filtering logic from
        // viewWarehouseHistory
        List<WarehouseTransaction> transactions = new ArrayList<>();

        // Get stock inward transactions
        List<StockInward> stockInwards = stockInwardDAO.findAll();
        for (StockInward inward : stockInwards) {
            if (inward.getWarehouseId() == warehouseId) {
                List<StockInwardDetail> details = stockInwardDetailDAO.findByStockInwardId(inward.getStockInwardId());
                for (StockInwardDetail detail : details) {
                    Product product = productDAO.findById(detail.getProductId());
                    if (product != null) {
                        WarehouseTransaction transaction = new WarehouseTransaction();
                        transaction.setTransactionId(
                                "SI-" + inward.getStockInwardId() + "-" + detail.getInwardDetailId());
                        transaction.setTransactionCode(inward.getInwardCode());
                        transaction.setTransactionType("inward");
                        transaction.setProductCode(product.getProductCode());
                        transaction.setProductName(product.getProductName());
                        transaction.setQuantity(detail.getQuantityReceived() != null ? detail.getQuantityReceived() : 0);
                        transaction
                                .setRemainingQuantity(detail.getQuantityReceived() != null ? detail.getQuantityReceived() : 0);
                        transaction.setUnit(product.getUnit() != null ? product.getUnit() : "-");
                        transaction.setTransactionDate(inward.getInwardDate());
                        transaction.setNotes(inward.getNotes() != null ? inward.getNotes() : "-");
                        transactions.add(transaction);
                    }
                }
            }
        }

        // Get stock outward transactions
        List<StockOutward> stockOutwards = stockOutwardDAO.findAll();
        for (StockOutward outward : stockOutwards) {
            if (outward.getWarehouseId() == warehouseId) {
                List<StockOutwardDetail> details = stockOutwardDetailDAO
                        .findByStockOutwardId(outward.getStockOutwardId());
                for (StockOutwardDetail detail : details) {
                    Product product = productDAO.findById(detail.getProductId());
                    if (product != null) {
                        WarehouseTransaction transaction = new WarehouseTransaction();
                        transaction.setTransactionId(
                                "SO-" + outward.getStockOutwardId() + "-" + detail.getOutwardDetailId());
                        transaction.setTransactionCode(outward.getOutwardCode());
                        transaction.setTransactionType("outward");
                        transaction.setProductCode(product.getProductCode());
                        transaction.setProductName(product.getProductName());
                        transaction.setQuantity(detail.getQuantityShipped() != null ? detail.getQuantityShipped() : 0);
                        transaction.setRemainingQuantity(0);
                        transaction.setUnit(product.getUnit() != null ? product.getUnit() : "-");
                        if (outward.getOutwardDate() instanceof java.sql.Timestamp) {
                            transaction
                                    .setTransactionDate(((java.sql.Timestamp) outward.getOutwardDate()).toLocalDateTime());
                        } else {
                            transaction.setTransactionDate(LocalDateTime.now());
                        }
                        transaction.setNotes(outward.getNotes() != null ? outward.getNotes() : "-");
                        transactions.add(transaction);
                    }
                }
            }
        }

        // Apply filters
        if (transactionType != null && !transactionType.trim().isEmpty()) {
            transactions = transactions.stream()
                    .filter(t -> t.getTransactionType().equals(transactionType))
                    .collect(Collectors.toList());
        }
        if (fromDateStr != null && !fromDateStr.trim().isEmpty()) {
            try {
                LocalDate fromDate = LocalDate.parse(fromDateStr);
                transactions = transactions.stream()
                        .filter(t -> !t.getTransactionDate().toLocalDate().isBefore(fromDate))
                        .collect(Collectors.toList());
            } catch (DateTimeParseException e) {
                /* Ignore */
            }
        }
        if (toDateStr != null && !toDateStr.trim().isEmpty()) {
            try {
                LocalDate toDate = LocalDate.parse(toDateStr);
                transactions = transactions.stream()
                        .filter(t -> !t.getTransactionDate().toLocalDate().isAfter(toDate))
                        .collect(Collectors.toList());
            } catch (DateTimeParseException e) {
                /* Ignore */
            }
        }
        if (productCode != null && !productCode.trim().isEmpty()) {
            String searchCode = productCode.trim().toLowerCase();
            transactions = transactions.stream()
                    .filter(t -> t.getProductCode().toLowerCase().contains(searchCode)
                    || t.getTransactionCode().toLowerCase().contains(searchCode))
                    .collect(Collectors.toList());
        }

        // Sort by transaction date descending
        transactions.sort((t1, t2) -> t2.getTransactionDate().compareTo(t1.getTransactionDate()));

        return transactions;
    }

    /**
     * Calculate outgoing quantity from confirmed sales orders
     */
    private Integer calculateOutgoingQuantity(Integer productId, Integer warehouseId) {
        int totalOutgoing = 0;
        try {
            // Get sales orders that are confirmed (status = 'pending_stock_check' or 'awaiting_shipment')
            List<SalesOrder> confirmedOrders = salesOrderDAO.findByStatus("awaiting_shipment");
            List<SalesOrder> pendingOrders = salesOrderDAO.findByStatus("pending_stock_check");

            List<SalesOrder> allRelevantOrders = new ArrayList<>();
            allRelevantOrders.addAll(confirmedOrders);
            allRelevantOrders.addAll(pendingOrders);

            for (SalesOrder order : allRelevantOrders) {
                if (order.getWarehouseId() != null && order.getWarehouseId().equals(warehouseId)) {
                    List<SalesOrderDetail> orderDetails = salesOrderDetailDAO.findBySalesOrderId(order.getSalesOrderId());
                    for (SalesOrderDetail detail : orderDetails) {
                        if (detail.getProductId().equals(productId)) {
                            totalOutgoing += detail.getQuantityOrdered();
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return totalOutgoing;
    }

    /**
     * Calculate incoming quantity from pending purchase orders
     */
    private Integer calculateIncomingQuantity(Integer productId, Integer warehouseId) {
        int totalIncoming = 0;
        try {
            // Get purchase orders that are pending but not yet approved
            List<PurchaseOrder> pendingOrders = purchaseOrderDAO.findByStatus("pending");

            for (PurchaseOrder order : pendingOrders) {
                if (order.getWarehouseId() != null && order.getWarehouseId().equals(warehouseId)) {
                    List<PurchaseOrderDetail> orderDetails = purchaseOrderDetailDAO.findByPoId(order.getPoId());
                    for (PurchaseOrderDetail detail : orderDetails) {
                        if (detail.getProductId().equals(productId)) {
                            totalIncoming += detail.getQuantity();
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return totalIncoming;
    }
}
