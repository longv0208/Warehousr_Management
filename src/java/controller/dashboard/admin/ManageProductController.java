package controller.dashboard.admin;

import dao.ProductDAO;
import dao.SupplierDAO;
import dao.CategoryDAO;
import model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.Supplier;
import model.Category;
import java.util.ArrayList;
// Excel functionality imports
import java.io.OutputStream;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.io.BufferedReader;
import java.io.InputStreamReader;
// import javax.servlet.annotation.MultipartConfig;
// import javax.servlet.http.Part;

@WebServlet(name = "ManageProductController", urlPatterns = {"/admin/manage-product"})
// @MultipartConfig(maxFileSize = 10485760) // 10MB - Comment out until servlet API is properly configured
public class ManageProductController extends HttpServlet {

    private ProductDAO productDAO;
    private SupplierDAO supplierDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAO();
        supplierDAO = new SupplierDAO();
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list"; // Default action
        }

        switch (action) {
            case "list":
                listProducts(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            case "init-sample-data":
                initializeSampleData(request, response);
                break;
            case "export":
                exportToExcel(request, response);
                break;
            case "show-import":
                showImportForm(request, response);
                break;
            default:
                listProducts(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
            return;
        }

        switch (action) {
            case "create":
                createProduct(request, response);
                break;
            case "edit":
                updateProduct(request, response);
                break;
            case "import":
                importFromExcel(request, response);
                break;
            default:
                listProducts(request, response);
                break;
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Pagination and filtering parameters
        String searchTerm = request.getParameter("search");
        String supplierIdStr = request.getParameter("supplierId");
        String categoryIdStr = request.getParameter("categoryId");
        String isActiveStr = request.getParameter("isActive");
        String minPurchasePriceStr = request.getParameter("minPurchasePrice");
        String minSalePriceStr = request.getParameter("minSalePrice");
        String pageStr = request.getParameter("page");
        int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
        int pageSize = 10; // Or get from a config

        Integer supplierId = null;
        if (supplierIdStr != null && !supplierIdStr.isEmpty()) {
            try {
                supplierId = Integer.parseInt(supplierIdStr);
            } catch (NumberFormatException e) {
                // Handle error or log
            }
        }

        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (NumberFormatException e) {
                // Handle error or log
            }
        }

        Boolean isActive = null;
        if (isActiveStr != null && !isActiveStr.isEmpty()) {
            isActive = Boolean.parseBoolean(isActiveStr);
        }

        Float minPurchasePrice = null;
        if (minPurchasePriceStr != null && !minPurchasePriceStr.isEmpty()) {
            try {
                minPurchasePrice = Float.parseFloat(minPurchasePriceStr);
            } catch (NumberFormatException e) {
                // Handle error or log
            }
        }

        Float minSalePrice = null;
        if (minSalePriceStr != null && !minSalePriceStr.isEmpty()) {
            try {
                minSalePrice = Float.parseFloat(minSalePriceStr);
            } catch (NumberFormatException e) {
                // Handle error or log
            }
        }

        List<Product> products = productDAO.findProducts(searchTerm, supplierId, categoryId, isActive, minPurchasePrice, minSalePrice, page, pageSize);
        int totalProducts = productDAO.getTotalFilteredProducts(searchTerm, supplierId, categoryId, isActive, minPurchasePrice, minSalePrice);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        // Get all suppliers and categories for dropdown filters
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Category> categories = categoryDAO.findAll();
        
        // Create a map to store primary category for each product
        java.util.Map<Integer, Category> productCategoryMap = new java.util.HashMap<>();
        for (Product product : products) {
            Category primaryCategory = productDAO.getPrimaryCategoryForProduct(product.getProductId());
            if (primaryCategory != null) {
                productCategoryMap.put(product.getProductId(), primaryCategory);
            }
        }
        
        request.setAttribute("supplierDAO", supplierDAO);
        request.setAttribute("categoryDAO", categoryDAO);
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("categories", categories);
        request.setAttribute("products", products);
        request.setAttribute("productCategoryMap", productCategoryMap);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("searchTerm", searchTerm);
        request.setAttribute("supplierId", supplierIdStr); // Keep as string for form repopulation
        request.setAttribute("categoryId", categoryIdStr); // Keep as string for form repopulation
        request.setAttribute("isActive", isActiveStr); // Keep as string for form repopulation
        request.setAttribute("minPurchasePrice", minPurchasePriceStr);
        request.setAttribute("minSalePrice", minSalePriceStr);

        request.getRequestDispatcher("/view/dashboard/admin/product/product.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Add list of suppliers and categories for the dropdowns
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Category> categories = categoryDAO.findAll();
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/view/dashboard/admin/product/addProduct.jsp").forward(request, response);
    }

    private void createProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String productCode = request.getParameter("productCode");
            String productName = request.getParameter("productName");
            String description = request.getParameter("description");
            String unit = request.getParameter("unit");
            String quantity = request.getParameter("quantity");
            String purchasePriceStr = request.getParameter("purchasePrice");
            String salePriceStr = request.getParameter("salePrice");
            String lowStockThresholdStr = request.getParameter("lowStockThreshold");
            Integer supplierId = request.getParameter("supplierId") != null && !request.getParameter("supplierId").isEmpty() ? Integer.parseInt(request.getParameter("supplierId")) : null;
            Boolean isActive = Boolean.parseBoolean(request.getParameter("isActive"));

            // Validation
            StringBuilder errorMessages = new StringBuilder();
            
            if (productCode == null || productCode.trim().isEmpty()) {
                errorMessages.append("Mã sản phẩm không được để trống. ");
            } else if (productCode.trim().length() > 10) {
                errorMessages.append("Mã sản phẩm không được quá 10 ký tự. ");
            }
            
            if (productName == null || productName.trim().isEmpty()) {
                errorMessages.append("Tên sản phẩm không được để trống. ");
            } else if (productName.trim().length() > 10) {
                errorMessages.append("Tên sản phẩm không được quá 10 ký tự. ");
            }
            
            if (description == null || description.trim().isEmpty()) {
                errorMessages.append("Mô tả không được để trống. ");
            } else if (description.trim().length() > 100) {
                errorMessages.append("Mô tả không được quá 100 ký tự. ");
            }
            
            if (unit == null || unit.trim().isEmpty()) {
                errorMessages.append("Đơn vị tính không được để trống. ");
            }
            
            if (quantity == null || quantity.trim().isEmpty()) {
                errorMessages.append("Số lượng không được để trống. ");
            } else {
                try {
                    int quantityValue = Integer.parseInt(quantity.trim());
                    if (quantityValue < 0) {
                        errorMessages.append("Số lượng không được âm. ");
                    }
                } catch (NumberFormatException e) {
                    errorMessages.append("Số lượng phải là số nguyên hợp lệ. ");
                }
            }
            
            if (supplierId == null) {
                errorMessages.append("Nhà cung cấp không được để trống. ");
            }
            
            String categoryIdStr = request.getParameter("categoryId");
            if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
                errorMessages.append("Danh mục không được để trống. ");
            }
            
            Float purchasePrice = null;
            if (purchasePriceStr == null || purchasePriceStr.trim().isEmpty()) {
                errorMessages.append("Giá mua không được để trống. ");
            } else {
                purchasePrice = Float.parseFloat(purchasePriceStr);
                if (purchasePrice < 0) {
                    errorMessages.append("Giá mua không được âm. ");
                }
            }
            
            Float salePrice = null;
            if (salePriceStr == null || salePriceStr.trim().isEmpty()) {
                errorMessages.append("Giá bán không được để trống. ");
            } else {
                salePrice = Float.parseFloat(salePriceStr);
                if (salePrice < 0) {
                    errorMessages.append("Giá bán không được âm. ");
                }
            }
            
            Integer lowStockThreshold = null;
            if (lowStockThresholdStr == null || lowStockThresholdStr.trim().isEmpty()) {
                errorMessages.append("Ngưỡng tồn kho thấp không được để trống. ");
            } else {
                lowStockThreshold = Integer.parseInt(lowStockThresholdStr);
                if (lowStockThreshold < 10) {
                    errorMessages.append("Ngưỡng tồn kho thấp phải ít nhất là 10. ");
                }
            }
            
            if (errorMessages.length() > 0) {
                request.getSession().setAttribute("toastMessage", errorMessages.toString());
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=create");
                return;
            }

            Product product = Product.builder()
                    .productCode(productCode.trim())
                    .productName(productName.trim())
                    .description(description != null ? description.trim() : "")
                    .unit(unit)
                    .quantity(Integer.parseInt(quantity.trim()))
                    .purchasePrice(purchasePrice)
                    .salePrice(salePrice)
                    .supplierId(supplierId)
                    .lowStockThreshold(lowStockThreshold)
                    .isActive(isActive)
                    .build();

            int generatedId = productDAO.insert(product);
            if (generatedId > 0) {
                // Handle category assignment if provided
//                String categoryIdStr = request.getParameter("categoryId");
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    try {
                        Integer categoryId = Integer.parseInt(categoryIdStr);
                        List<Integer> categories = new ArrayList<>();
                        categories.add(categoryId);
                        productDAO.updateProductCategories(generatedId, categories);
                    } catch (NumberFormatException e) {
                        // Log error but don't fail the product creation
                    }
                }
                
                request.getSession().setAttribute("toastMessage", "Product created successfully!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Error creating product.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "Invalid number format for price or threshold.");
            request.getSession().setAttribute("toastType", "error");
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "An unexpected error occurred: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));
            Product product = productDAO.findById(productId);
            if (product != null) {
                request.setAttribute("product", product);
                // Add list of suppliers and categories for the dropdowns
                List<Supplier> suppliers = supplierDAO.findAll();
                List<Category> categories = categoryDAO.findAll();
                List<Category> productCategories = productDAO.getCategoriesForProduct(productId);
                request.setAttribute("suppliers", suppliers);
                request.setAttribute("categories", categories);
                request.setAttribute("productCategories", productCategories);
                request.getRequestDispatcher("/view/dashboard/admin/product/edit-product.jsp").forward(request, response);
            } else {
                request.getSession().setAttribute("toastMessage", "Product not found.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "Invalid product ID.");
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
        }
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            Integer productId = Integer.parseInt(request.getParameter("productId"));
            String productCode = request.getParameter("productCode");
            String productName = request.getParameter("productName");
            String description = request.getParameter("description");
            String unit = request.getParameter("unit");
            String quantity = request.getParameter("quantity");
            String purchasePriceStr = request.getParameter("purchasePrice");
            String salePriceStr = request.getParameter("salePrice");
            String lowStockThresholdStr = request.getParameter("lowStockThreshold");
            Integer supplierId = request.getParameter("supplierId") != null && !request.getParameter("supplierId").isEmpty() ? Integer.parseInt(request.getParameter("supplierId")) : null;
            Boolean isActive = Boolean.parseBoolean(request.getParameter("isActive"));

            // Validation
            StringBuilder errorMessages = new StringBuilder();
            
            if (productCode == null || productCode.trim().isEmpty()) {
                errorMessages.append("Mã sản phẩm không được để trống. ");
            } else if (productCode.trim().length() > 10) {
                errorMessages.append("Mã sản phẩm không được quá 10 ký tự. ");
            }
            
            if (productName == null || productName.trim().isEmpty()) {
                errorMessages.append("Tên sản phẩm không được để trống. ");
            } else if (productName.trim().length() > 10) {
                errorMessages.append("Tên sản phẩm không được quá 10 ký tự. ");
            }
            
            if (description == null || description.trim().isEmpty()) {
                errorMessages.append("Mô tả không được để trống. ");
            } else if (description.trim().length() > 100) {
                errorMessages.append("Mô tả không được quá 100 ký tự. ");
            }
            
            if (unit == null || unit.trim().isEmpty()) {
                errorMessages.append("Đơn vị tính không được để trống. ");
            }
            
            if (quantity == null || quantity.trim().isEmpty()) {
                errorMessages.append("Số lượng không được để trống. ");
            } else {
                try {
                    int quantityValue = Integer.parseInt(quantity.trim());
                    if (quantityValue < 0) {
                        errorMessages.append("Số lượng không được âm. ");
                    }
                } catch (NumberFormatException e) {
                    errorMessages.append("Số lượng phải là số nguyên hợp lệ. ");
                }
            }
            
            if (supplierId == null) {
                errorMessages.append("Nhà cung cấp không được để trống. ");
            }
            
            String categoryIdStr = request.getParameter("categoryId");
            if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
                errorMessages.append("Danh mục không được để trống. ");
            }
            
            Float purchasePrice = null;
            if (purchasePriceStr == null || purchasePriceStr.trim().isEmpty()) {
                errorMessages.append("Giá mua không được để trống. ");
            } else {
                purchasePrice = Float.parseFloat(purchasePriceStr);
                if (purchasePrice < 0) {
                    errorMessages.append("Giá mua không được âm. ");
                }
            }
            
            Float salePrice = null;
            if (salePriceStr == null || salePriceStr.trim().isEmpty()) {
                errorMessages.append("Giá bán không được để trống. ");
            } else {
                salePrice = Float.parseFloat(salePriceStr);
                if (salePrice < 0) {
                    errorMessages.append("Giá bán không được âm. ");
                }
            }
            
            Integer lowStockThreshold = null;
            if (lowStockThresholdStr == null || lowStockThresholdStr.trim().isEmpty()) {
                errorMessages.append("Ngưỡng tồn kho thấp không được để trống. ");
            } else {
                lowStockThreshold = Integer.parseInt(lowStockThresholdStr);
                if (lowStockThreshold < 10) {
                    errorMessages.append("Ngưỡng tồn kho thấp phải ít nhất là 10. ");
                }
            }
            
            if (errorMessages.length() > 0) {
                request.getSession().setAttribute("toastMessage", errorMessages.toString());
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=edit&id=" + productId);
                return;
            }

            Product product = Product.builder()
                    .productId(productId)
                    .productCode(productCode.trim())
                    .productName(productName.trim())
                    .description(description != null ? description.trim() : "")
                    .unit(unit)
                    .quantity(Integer.parseInt(quantity.trim()))
                    .purchasePrice(purchasePrice)
                    .salePrice(salePrice)
                    .supplierId(supplierId)
                    .lowStockThreshold(lowStockThreshold)
                    .isActive(isActive)
                    .build();

            boolean success = productDAO.update(product);
            if (success) {
                // Handle category updates
//                String categoryIdStr = request.getParameter("categoryId");
                List<Integer> categories = new ArrayList<>();
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    try {
                        Integer categoryId = Integer.parseInt(categoryIdStr);
                        categories.add(categoryId);
                    } catch (NumberFormatException e) {
                        // Log error but don't fail the product update
                    }
                }
                // Update categories (empty list will clear all categories)
                productDAO.updateProductCategories(productId, categories);
                
                request.getSession().setAttribute("toastMessage", "Product updated successfully!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Error updating product.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "Invalid number format for price or threshold.");
            request.getSession().setAttribute("toastType", "error");
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "An unexpected error occurred: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int productId = Integer.parseInt(request.getParameter("id"));
            boolean success = productDAO.delete(productId); // Assuming ProductDAO has a delete method by ID
            if (success) {
                request.getSession().setAttribute("toastMessage", "Product deleted successfully!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Error deleting product.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("toastMessage", "Invalid product ID.");
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
    }

    private void initializeSampleData(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            boolean success = productDAO.initializeSampleCategoryProductData();
            if (success) {
                request.getSession().setAttribute("toastMessage", "Sample category-product data initialized successfully!");
                request.getSession().setAttribute("toastType", "success");
            } else {
                request.getSession().setAttribute("toastMessage", "Error initializing sample data.");
                request.getSession().setAttribute("toastType", "error");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "An error occurred: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
    }

    private void exportToExcel(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get all products
            List<Product> products = productDAO.findProducts(null, null, null, null, null, null, 1, Integer.MAX_VALUE);
            
            // Set response headers for CSV download
            response.setContentType("text/csv; charset=UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=products_" + 
                new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".csv");
            
            // Write CSV content
            OutputStream out = response.getOutputStream();
            StringBuilder csvContent = new StringBuilder();
            
            // Add BOM for UTF-8
            csvContent.append("\uFEFF");
            
            // Add header row
            csvContent.append("Mã SP,Tên SP,Mô tả,Đơn vị,Số lượng,Giá mua,Giá bán,Ngưỡng tồn kho,Trạng thái,Nhà cung cấp\n");
            
            // Add data rows
            for (Product product : products) {
                csvContent.append("\"").append(escapeCSV(product.getProductCode())).append("\",");
                csvContent.append("\"").append(escapeCSV(product.getProductName())).append("\",");
                csvContent.append("\"").append(escapeCSV(product.getDescription())).append("\",");
                csvContent.append("\"").append(escapeCSV(product.getUnit())).append("\",");
                csvContent.append(product.getQuantity()).append(",");
                csvContent.append(product.getPurchasePrice()).append(",");
                csvContent.append(product.getSalePrice()).append(",");
                csvContent.append(product.getLowStockThreshold()).append(",");
                csvContent.append("\"").append(product.getIsActive() ? "Hoạt động" : "Không hoạt động").append("\",");
                
                // Get supplier name
                Supplier supplier = supplierDAO.findById(product.getSupplierId());
                csvContent.append("\"").append(escapeCSV(supplier != null ? supplier.getSupplierName() : "N/A")).append("\"");
                csvContent.append("\n");
            }
            
            out.write(csvContent.toString().getBytes("UTF-8"));
            out.close();
            
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "Lỗi khi xuất file CSV: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
        }
    }
    
    private String escapeCSV(String value) {
        if (value == null) return "";
        return value.replace("\"", "\"\"");
    }

    private void showImportForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get suppliers and categories for the form
        List<Supplier> suppliers = supplierDAO.findAll();
        List<Category> categories = categoryDAO.findAll();
        request.setAttribute("suppliers", suppliers);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/view/dashboard/admin/product/import-product.jsp").forward(request, response);
    }

    private void importFromExcel(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Check if the request is multipart
            String contentType = request.getContentType();
            if (contentType == null || !contentType.toLowerCase().startsWith("multipart/")) {
                request.getSession().setAttribute("toastMessage", "Vui lòng chọn file CSV để import.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=show-import");
                return;
            }

            // For now, show a message that this feature requires multipart support
            // In production, you would need to add Apache Commons FileUpload library
            // or ensure servlet container supports multipart
            request.getSession().setAttribute("toastMessage", "Chức năng import đã được triển khai. Tuy nhiên, cần cấu hình thêm MultipartConfig annotation và servlet API để upload file. Vui lòng liên hệ admin để kích hoạt.");
            request.getSession().setAttribute("toastType", "warning");
            response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
            return;

            /* 
            // Uncomment this section when multipart support is properly configured
            Part filePart = request.getPart("csvFile");
            if (filePart == null || filePart.getSize() == 0) {
                request.getSession().setAttribute("toastMessage", "Vui lòng chọn file CSV để import.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=show-import");
                return;
            }

            // Check file extension
            String fileName = filePart.getSubmittedFileName();
            if (fileName == null || !fileName.toLowerCase().endsWith(".csv")) {
                request.getSession().setAttribute("toastMessage", "Chỉ chấp nhận file CSV.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=show-import");
                return;
            }

            InputStream inputStream = filePart.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));
            
            String line;
            int lineNumber = 0;
            int successCount = 0;
            int errorCount = 0;
            StringBuilder errorMessages = new StringBuilder();
            
            // Skip the header line and BOM if present
            line = reader.readLine();
            if (line != null && line.startsWith("\uFEFF")) {
                line = line.substring(1); // Remove BOM
            }
            lineNumber++;
            
            // Process each data line
            while ((line = reader.readLine()) != null) {
                lineNumber++;
                if (line.trim().isEmpty()) continue;
                
                try {
                    // Parse CSV line (handle quoted fields)
                    String[] fields = parseCSVLine(line);
                    if (fields.length < 10) {
                        errorMessages.append("Dòng ").append(lineNumber).append(": Không đủ cột dữ liệu.\n");
                        errorCount++;
                        continue;
                    }
                    
                    // Extract data from CSV fields
                    String productCode = fields[0].trim();
                    String productName = fields[1].trim();
                    String description = fields[2].trim();
                    String unit = fields[3].trim();
                    String quantityStr = fields[4].trim();
                    String purchasePriceStr = fields[5].trim();
                    String salePriceStr = fields[6].trim();
                    String lowStockThresholdStr = fields[7].trim();
                    String statusStr = fields[8].trim();
                    String supplierName = fields[9].trim();
                    
                    // Validate required fields
                    if (productCode.isEmpty() || productName.isEmpty() || unit.isEmpty() || 
                        quantityStr.isEmpty() || purchasePriceStr.isEmpty() || salePriceStr.isEmpty() ||
                        lowStockThresholdStr.isEmpty() || supplierName.isEmpty()) {
                        errorMessages.append("Dòng ").append(lineNumber).append(": Thiếu dữ liệu bắt buộc.\n");
                        errorCount++;
                        continue;
                    }
                    
                    // Find supplier by name
                    Supplier supplier = supplierDAO.findBySupplierName(supplierName);
                    if (supplier == null) {
                        errorMessages.append("Dòng ").append(lineNumber).append(": Không tìm thấy nhà cung cấp '").append(supplierName).append("'.\n");
                        errorCount++;
                        continue;
                    }
                    
                    // Parse numeric fields
                    int quantity = Integer.parseInt(quantityStr);
                    float purchasePrice = Float.parseFloat(purchasePriceStr);
                    float salePrice = Float.parseFloat(salePriceStr);
                    int lowStockThreshold = Integer.parseInt(lowStockThresholdStr);
                    boolean isActive = "Hoạt động".equals(statusStr);
                    
                    // Validate values
                    if (quantity < 0 || purchasePrice < 0 || salePrice < 0 || lowStockThreshold < 10) {
                        errorMessages.append("Dòng ").append(lineNumber).append(": Giá trị không hợp lệ (số lượng, giá >= 0, ngưỡng tồn kho >= 10).\n");
                        errorCount++;
                        continue;
                    }
                    
                    // Check if product code already exists
                    if (productDAO.existsByProductCode(productCode)) {
                        errorMessages.append("Dòng ").append(lineNumber).append(": Mã sản phẩm '").append(productCode).append("' đã tồn tại.\n");
                        errorCount++;
                        continue;
                    }
                    
                    // Create product
                    Product product = Product.builder()
                            .productCode(productCode)
                            .productName(productName)
                            .description(description)
                            .unit(unit)
                            .quantity(quantity)
                            .purchasePrice(purchasePrice)
                            .salePrice(salePrice)
                            .supplierId(supplier.getSupplierId())
                            .lowStockThreshold(lowStockThreshold)
                            .isActive(isActive)
                            .build();
                    
                    int generatedId = productDAO.insert(product);
                    if (generatedId > 0) {
                        successCount++;
                    } else {
                        errorMessages.append("Dòng ").append(lineNumber).append(": Lỗi khi tạo sản phẩm.\n");
                        errorCount++;
                    }
                    
                } catch (NumberFormatException e) {
                    errorMessages.append("Dòng ").append(lineNumber).append(": Định dạng số không hợp lệ.\n");
                    errorCount++;
                } catch (Exception e) {
                    errorMessages.append("Dòng ").append(lineNumber).append(": Lỗi: ").append(e.getMessage()).append("\n");
                    errorCount++;
                }
            }
            
            reader.close();
            inputStream.close();
            
            // Set result message
            StringBuilder resultMessage = new StringBuilder();
            resultMessage.append("Import hoàn thành! ");
            resultMessage.append("Thành công: ").append(successCount).append(" sản phẩm. ");
            if (errorCount > 0) {
                resultMessage.append("Lỗi: ").append(errorCount).append(" dòng.\n");
                resultMessage.append(errorMessages.toString());
                request.getSession().setAttribute("toastType", "warning");
            } else {
                request.getSession().setAttribute("toastType", "success");
            }
            request.getSession().setAttribute("toastMessage", resultMessage.toString());
            */ // End of commented section
            
        } catch (Exception e) {
            request.getSession().setAttribute("toastMessage", "Lỗi khi import file CSV: " + e.getMessage());
            request.getSession().setAttribute("toastType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/manage-product?action=list");
    }
    
    /**
     * Parse a CSV line handling quoted fields
     */
    private String[] parseCSVLine(String line) {
        List<String> fields = new ArrayList<>();
        boolean inQuotes = false;
        StringBuilder currentField = new StringBuilder();
        
        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            
            if (c == '"') {
                if (inQuotes && i + 1 < line.length() && line.charAt(i + 1) == '"') {
                    // Double quote - escaped quote within field
                    currentField.append('"');
                    i++; // Skip next quote
                } else {
                    // Toggle quote mode
                    inQuotes = !inQuotes;
                }
            } else if (c == ',' && !inQuotes) {
                // Field separator
                fields.add(currentField.toString());
                currentField = new StringBuilder();
            } else {
                currentField.append(c);
            }
        }
        
        // Add the last field
        fields.add(currentField.toString());
        
        return fields.toArray(new String[0]);
    }


}
