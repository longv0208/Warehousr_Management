package controller.dashboard.admin;

import dao.WarehouseDAO;
import dao.InventoryDAO;
import dao.StockInwardDAO;
import dao.StockOutwardDAO;
import dao.StockInwardDetailDAO;
import dao.StockOutwardDetailDAO;
import dao.ProductDAO;
import model.Warehouse;
import model.User;
import model.StockInward;
import model.StockOutward;
import model.StockInwardDetail;
import model.StockOutwardDetail;
import model.Product;
import model.WarehouseTransaction;
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
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;

@WebServlet(name = "ManageWarehouseController", urlPatterns = { "/admin/manage-warehouse" })
public class ManageWarehouseController extends HttpServlet {

    private WarehouseDAO warehouseDAO;
    private StockInwardDAO stockInwardDAO;
    private StockOutwardDAO stockOutwardDAO;
    private StockInwardDetailDAO stockInwardDetailDAO;
    private StockOutwardDetailDAO stockOutwardDetailDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        warehouseDAO = new WarehouseDAO();
        stockInwardDAO = new StockInwardDAO();
        stockOutwardDAO = new StockOutwardDAO();
        stockInwardDetailDAO = new StockInwardDetailDAO();
        stockOutwardDetailDAO = new StockOutwardDetailDAO();
        productDAO = new ProductDAO();
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
        if (!action.equals("list") && !action.equals("view") &&
                !"admin".equals(userRole) && !"warehouse_manager".equals(userRole)) {
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
                viewWarehouseHistory(request, response);
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

    private void viewWarehouseHistory(HttpServletRequest request, HttpServletResponse response)
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
            String transactionType = request.getParameter("transactionType");
            String fromDateStr = request.getParameter("fromDate");
            String toDateStr = request.getParameter("toDate");

            // Create list to hold all transactions
            List<WarehouseTransaction> transactions = new ArrayList<>();

            // Get stock inward transactions with details
            List<StockInward> stockInwards = stockInwardDAO.findAll();
            for (StockInward inward : stockInwards) {
                if (inward.getWarehouseId() == warehouseId) {
                    List<StockInwardDetail> details = stockInwardDetailDAO
                            .findByStockInwardId(inward.getStockInwardId());
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
                            transaction.setQuantity(
                                    detail.getQuantityReceived() != null ? detail.getQuantityReceived() : 0);
                            transaction.setRemainingQuantity(
                                    detail.getQuantityReceived() != null ? detail.getQuantityReceived() : 0);
                            transaction.setUnit(product.getUnit() != null ? product.getUnit() : "-");
                            transaction.setTransactionDate(inward.getInwardDate());
                            transaction.setNotes(inward.getNotes() != null ? inward.getNotes() : "-");
                            transactions.add(transaction);
                        }
                    }
                }
            }

            // Get stock outward transactions with details
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
                            transaction
                                    .setQuantity(detail.getQuantityShipped() != null ? detail.getQuantityShipped() : 0);
                            transaction.setRemainingQuantity(0); // For outward, remaining quantity will be calculated
                                                                 // separately if needed
                            transaction.setUnit(product.getUnit() != null ? product.getUnit() : "-");
                            // Handle Timestamp to LocalDateTime conversion
                            if (outward.getOutwardDate() instanceof java.sql.Timestamp) {
                                transaction.setTransactionDate(
                                        ((java.sql.Timestamp) outward.getOutwardDate()).toLocalDateTime());
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
                            .filter(t -> {
                                LocalDate transactionDateOnly = t.getTransactionDate().toLocalDate();
                                return transactionDateOnly.isEqual(fromDate) || transactionDateOnly.isAfter(fromDate);
                            })
                            .collect(Collectors.toList());
                } catch (DateTimeParseException e) {
                    // Invalid date format, ignore filter
                }
            }

            if (toDateStr != null && !toDateStr.trim().isEmpty()) {
                try {
                    LocalDate toDate = LocalDate.parse(toDateStr);
                    transactions = transactions.stream()
                            .filter(t -> {
                                LocalDate transactionDateOnly = t.getTransactionDate().toLocalDate();
                                return transactionDateOnly.isEqual(toDate) || transactionDateOnly.isBefore(toDate);
                            })
                            .collect(Collectors.toList());
                } catch (DateTimeParseException e) {
                    // Invalid date format, ignore filter
                }
            }

            if (productCode != null && !productCode.trim().isEmpty()) {
                String searchCode = productCode.trim().toLowerCase();
                transactions = transactions.stream()
                        .filter(t -> t.getProductCode().toLowerCase().contains(searchCode) ||
                                t.getTransactionCode().toLowerCase().contains(searchCode))
                        .collect(Collectors.toList());
            }

            // Sort by transaction date descending
            transactions.sort((t1, t2) -> t2.getTransactionDate().compareTo(t1.getTransactionDate()));

            request.setAttribute("warehouse", warehouse);
            request.setAttribute("transactions", transactions);

            // Pass filter parameters back to JSP to maintain form state
            request.setAttribute("filterProductCode", productCode);
            request.setAttribute("filterTransactionType", transactionType);
            request.setAttribute("filterFromDate", fromDateStr);
            request.setAttribute("filterToDate", toDateStr);

            request.getRequestDispatcher("/view/dashboard/admin/warehouse/warehouse-history.jsp").forward(request,
                    response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-warehouse?action=list");
        }
    }
}