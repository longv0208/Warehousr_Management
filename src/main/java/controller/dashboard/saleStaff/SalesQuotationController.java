package controller.dashboard.saleStaff;

import dao.SalesQuotationDAO;
import dao.SalesQuotationDetailDAO;
import dao.ProductDAO;
import dao.WarehouseDAO;
import model.SalesQuotation;
import model.SalesQuotationDetail;
import model.Product;
import model.Warehouse;
import model.User;
import utils.SessionUtil;
import utils.SalesQuotationEmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "SalesQuotationController", urlPatterns = { "/sale-staff/sales-quotation" })
public class SalesQuotationController extends HttpServlet {

    private SalesQuotationDAO salesQuotationDAO;
    private SalesQuotationDetailDAO salesQuotationDetailDAO;
    private ProductDAO productDAO;
    private WarehouseDAO warehouseDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        salesQuotationDAO = new SalesQuotationDAO();
        salesQuotationDetailDAO = new SalesQuotationDetailDAO();
        productDAO = new ProductDAO();
        warehouseDAO = new WarehouseDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                handleListQuotations(request, response);
                break;
            case "create":
                handleShowCreateForm(request, response);
                break;
            case "view":
                handleViewQuotation(request, response);
                break;
            case "edit":
                handleShowEditForm(request, response);
                break;
            case "send":
                handleSendQuotation(request, response);
                break;
            default:
                handleListQuotations(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=list");
            return;
        }

        switch (action) {
            case "create":
                handleCreateQuotation(request, response);
                break;
            case "update":
                handleUpdateQuotation(request, response);
                break;
            default:
                handleListQuotations(request, response);
                break;
        }
    }

    // List all quotations created by current user
    private void handleListQuotations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = SessionUtil.getUserFromSession(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<SalesQuotation> quotations = salesQuotationDAO.findByUserId(currentUser.getUserId());
        
        request.setAttribute("quotations", quotations);
        request.getRequestDispatcher("/view/dashboard/saleStaff/salesQuotation/quotationList.jsp").forward(request, response);
    }

    // Show create quotation form
    private void handleShowCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> products = productDAO.findActiveProducts();
        List<Warehouse> warehouses = warehouseDAO.findAll();

        request.setAttribute("products", products);
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("/view/dashboard/saleStaff/salesQuotation/createQuotation.jsp").forward(request, response);
    }

    // Create new quotation
    private void handleCreateQuotation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = SessionUtil.getUserFromSession(request);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Create Sales Quotation
            SalesQuotation quotation = SalesQuotation.builder()
                    .quotationCode(salesQuotationDAO.generateQuotationCode())
                    .customerName(request.getParameter("customerName"))
                    .customerEmail(request.getParameter("customerEmail"))
                    .customerPhone(request.getParameter("customerPhone"))
                    .customerAddress(request.getParameter("customerAddress"))
                    .userId(currentUser.getUserId())
                    .quotationDate(Date.valueOf(request.getParameter("quotationDate")))
                    .validUntil(Date.valueOf(request.getParameter("validUntil")))
                    .status("draft")
                    .notes(request.getParameter("notes"))
                    .warehouseId(Integer.parseInt(request.getParameter("warehouseId")))
                    .build();

            int quotationId = salesQuotationDAO.insert(quotation);

            if (quotationId > 0) {
                // Create Quotation Details
                String[] productIds = request.getParameterValues("productId[]");
                String[] quantities = request.getParameterValues("quantity[]");
                String[] unitPrices = request.getParameterValues("unitPrice[]");

                if (productIds != null && quantities != null && unitPrices != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (productIds[i] != null && !productIds[i].isEmpty() &&
                            quantities[i] != null && !quantities[i].isEmpty() &&
                            unitPrices[i] != null && !unitPrices[i].isEmpty()) {

                            SalesQuotationDetail detail = SalesQuotationDetail.builder()
                                    .quotationId(quotationId)
                                    .productId(Integer.parseInt(productIds[i]))
                                    .quantity(Integer.parseInt(quantities[i]))
                                    .unitPrice(new BigDecimal(unitPrices[i]))
                                    .build();

                            salesQuotationDetailDAO.insert(detail);
                        }
                    }
                }

                session.setAttribute("toastMessage", "Tạo báo giá thành công!");
                session.setAttribute("toastType", "success");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=list");
            } else {
                session.setAttribute("toastMessage", "Tạo báo giá thất bại. Vui lòng thử lại.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=create");
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            e.printStackTrace();
            session.setAttribute("toastMessage", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=create");
        }
    }

    // View quotation details
    private void handleViewQuotation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int quotationId = Integer.parseInt(request.getParameter("id"));
        SalesQuotation quotation = salesQuotationDAO.findById(quotationId);
        List<SalesQuotationDetail> quotationDetails = salesQuotationDetailDAO.findByQuotationId(quotationId);

        // Get products for details
        for (SalesQuotationDetail detail : quotationDetails) {
            Product product = productDAO.findById(detail.getProductId());
            detail.setProduct(product);
        }

        request.setAttribute("quotation", quotation);
        request.setAttribute("quotationDetails", quotationDetails);
        request.getRequestDispatcher("/view/dashboard/saleStaff/salesQuotation/viewQuotation.jsp").forward(request, response);
    }

    // Show edit quotation form
    private void handleShowEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int quotationId = Integer.parseInt(request.getParameter("id"));
        SalesQuotation quotation = salesQuotationDAO.findById(quotationId);
        
        // Only allow editing if status is draft
        if (!"draft".equals(quotation.getStatus())) {
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Chỉ có thể chỉnh sửa báo giá ở trạng thái nháp!");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=view&id=" + quotationId);
            return;
        }

        List<SalesQuotationDetail> quotationDetails = salesQuotationDetailDAO.findByQuotationId(quotationId);
        List<Product> products = productDAO.findActiveProducts();
        List<Warehouse> warehouses = warehouseDAO.findAll();

        // Get products for details
        for (SalesQuotationDetail detail : quotationDetails) {
            Product product = productDAO.findById(detail.getProductId());
            detail.setProduct(product);
        }

        request.setAttribute("quotation", quotation);
        request.setAttribute("quotationDetails", quotationDetails);
        request.setAttribute("products", products);
        request.setAttribute("warehouses", warehouses);
        request.getRequestDispatcher("/view/dashboard/saleStaff/salesQuotation/createQuotation.jsp").forward(request, response);
    }

    // Update quotation
    private void handleUpdateQuotation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = SessionUtil.getUserFromSession(request);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            int quotationId = Integer.parseInt(request.getParameter("quotationId"));
            SalesQuotation existingQuotation = salesQuotationDAO.findById(quotationId);

            if (existingQuotation == null) {
                session.setAttribute("toastMessage", "Không tìm thấy báo giá!");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=list");
                return;
            }

            // Update quotation information
            SalesQuotation quotation = SalesQuotation.builder()
                    .quotationId(quotationId)
                    .quotationCode(existingQuotation.getQuotationCode()) // Keep original code
                    .customerName(request.getParameter("customerName"))
                    .customerEmail(request.getParameter("customerEmail"))
                    .customerPhone(request.getParameter("customerPhone"))
                    .customerAddress(request.getParameter("customerAddress"))
                    .userId(currentUser.getUserId())
                    .quotationDate(existingQuotation.getQuotationDate()) // Keep original date
                    .validUntil(Date.valueOf(request.getParameter("validUntil")))
                    .status("draft") // Keep status as draft
                    .notes(request.getParameter("notes"))
                    .warehouseId(Integer.parseInt(request.getParameter("warehouseId")))
                    .build();

            boolean success = salesQuotationDAO.update(quotation);

            if (success) {
                // Delete existing quotation details
                salesQuotationDetailDAO.deleteByQuotationId(quotationId);

                // Create new quotation details
                String[] productIds = request.getParameterValues("productId[]");
                String[] quantities = request.getParameterValues("quantity[]");
                String[] unitPrices = request.getParameterValues("unitPrice[]");

                if (productIds != null && quantities != null && unitPrices != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        if (productIds[i] != null && !productIds[i].isEmpty() &&
                            quantities[i] != null && !quantities[i].isEmpty() &&
                            unitPrices[i] != null && !unitPrices[i].isEmpty()) {

                            SalesQuotationDetail detail = SalesQuotationDetail.builder()
                                    .quotationId(quotationId)
                                    .productId(Integer.parseInt(productIds[i]))
                                    .quantity(Integer.parseInt(quantities[i]))
                                    .unitPrice(new BigDecimal(unitPrices[i]))
                                    .build();

                            salesQuotationDetailDAO.insert(detail);
                        }
                    }
                }

                session.setAttribute("toastMessage", "Cập nhật báo giá thành công!");
                session.setAttribute("toastType", "success");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=view&id=" + quotationId);
            } else {
                session.setAttribute("toastMessage", "Cập nhật báo giá thất bại!");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=edit&id=" + quotationId);
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            e.printStackTrace();
            session.setAttribute("toastMessage", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=list");
        }
    }

    // Send quotation to customer
    private void handleSendQuotation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int quotationId = Integer.parseInt(request.getParameter("id"));
        SalesQuotation quotation = salesQuotationDAO.findById(quotationId);

        if (quotation != null && "draft".equals(quotation.getStatus())) {
            quotation.setStatus("sent");
            boolean success = salesQuotationDAO.update(quotation);

            HttpSession session = request.getSession();
            if (success) {
                // Send email to customer
                try {
                    List<SalesQuotationDetail> quotationDetails = salesQuotationDetailDAO.findByQuotationId(quotationId);
                    List<Product> products = productDAO.findAll();
                    
                    boolean emailSent = SalesQuotationEmailService.sendQuotationToCustomer(
                        quotation.getCustomerName(), 
                        quotation, 
                        quotationDetails, 
                        products,
                        quotation.getCustomerEmail()
                    );
                    
                    if (emailSent) {
                        session.setAttribute("toastMessage", 
                            "Gửi báo giá thành công! Email đã được gửi đến khách hàng: " + quotation.getCustomerName());
                        session.setAttribute("toastType", "success");
                        
                        // Log thông tin gửi email thành công
                        System.out.println("=== SALES QUOTATION EMAIL SENT SUCCESSFULLY ===");
                        System.out.println("Quotation ID: " + quotationId);
                        System.out.println("Quotation Code: " + quotation.getQuotationCode());
                        System.out.println("Customer Name: " + quotation.getCustomerName());
                        System.out.println("Email sent at: " + new java.util.Date());
                        System.out.println("=====================================");
                    } else {
                        session.setAttribute("toastMessage", 
                            "Gửi báo giá thành công nhưng không thể gửi email đến khách hàng!");
                        session.setAttribute("toastType", "warning");
                    }
                } catch (Exception e) {
                    System.err.println("Error sending sales quotation email: " + e.getMessage());
                    e.printStackTrace();
                    session.setAttribute("toastMessage", 
                        "Gửi báo giá thành công nhưng có lỗi khi gửi email: " + e.getMessage());
                    session.setAttribute("toastType", "warning");
                }
            } else {
                session.setAttribute("toastMessage", "Gửi báo giá thất bại!");
                session.setAttribute("toastType", "error");
            }
        }

        response.sendRedirect(request.getContextPath() + "/sale-staff/sales-quotation?action=view&id=" + quotationId);
    }
}
