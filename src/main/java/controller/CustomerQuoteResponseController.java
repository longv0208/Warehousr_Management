package controller;

import dao.SalesQuotationDAO;
import dao.SalesQuotationDetailDAO;
import dao.ProductDAO;
import model.SalesQuotation;
import model.SalesQuotationDetail;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

@WebServlet("/customer-quote-response")
public class CustomerQuoteResponseController extends HttpServlet {
    
    private SalesQuotationDAO salesQuotationDAO = new SalesQuotationDAO();
    private SalesQuotationDetailDAO salesQuotationDetailDAO = new SalesQuotationDetailDAO();
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int quotationId = Integer.parseInt(request.getParameter("quotationId"));
            String action = request.getParameter("action");
            
            // Get quotation information
            SalesQuotation quotation = salesQuotationDAO.findById(quotationId);
            if (quotation == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Quotation not found");
                return;
            }
            
            // Check if quotation is still valid and in sent status
            if (!"sent".equals(quotation.getStatus())) {
                request.setAttribute("errorMessage", "Báo giá này đã được xử lý hoặc không còn hợp lệ.");
                request.getRequestDispatcher("/view/customer-quote-error.jsp").forward(request, response);
                return;
            }
            
            // Check if quotation is still within valid period
            java.util.Date now = new java.util.Date();
            if (quotation.getValidUntil().before(now)) {
                request.setAttribute("errorMessage", "Báo giá này đã hết hạn.");
                request.getRequestDispatcher("/view/customer-quote-error.jsp").forward(request, response);
                return;
            }
            
            // Get quotation details
            List<SalesQuotationDetail> quotationDetails = salesQuotationDetailDAO.findByQuotationId(quotationId);
            
            // Get product information for each detail
            List<Product> products = new ArrayList<>();
            for (SalesQuotationDetail detail : quotationDetails) {
                Product product = productDAO.findById(detail.getProductId());
                if (product != null) {
                    products.add(product);
                }
            }
            
            // Set attributes for JSP
            request.setAttribute("quotation", quotation);
            request.setAttribute("quotationDetails", quotationDetails);
            request.setAttribute("products", products);
            request.setAttribute("action", action);
            
            // Forward to customer response page
            request.getRequestDispatcher("/view/customer-quote-response.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid parameters");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int quotationId = Integer.parseInt(request.getParameter("quotationId"));
            String action = request.getParameter("action");
            
            // Get quotation information
            SalesQuotation quotation = salesQuotationDAO.findById(quotationId);
            if (quotation == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Quotation not found");
                return;
            }
            
            // Update quotation status based on customer response
            if ("confirm".equals(action)) {
                quotation.setStatus("approved");
                request.setAttribute("successMessage", "Cảm ơn bạn đã xác nhận báo giá! Chúng tôi sẽ liên hệ với bạn để xử lý đơn hàng.");
            } else if ("reject".equals(action)) {
                quotation.setStatus("rejected");
                request.setAttribute("successMessage", "Cảm ơn bạn đã phản hồi. Chúng tôi sẽ ghi nhận và cải thiện dịch vụ.");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                return;
            }
            
            // Update in database
            boolean updated = salesQuotationDAO.update(quotation);
            
            if (updated) {
                // Log the customer response
                System.out.println("=== CUSTOMER QUOTE RESPONSE ===");
                System.out.println("Quotation ID: " + quotationId);
                System.out.println("Quotation Code: " + quotation.getQuotationCode());
                System.out.println("Customer: " + quotation.getCustomerName());
                System.out.println("Action: " + action.toUpperCase());
                System.out.println("Status: " + quotation.getStatus());
                System.out.println("Response time: " + new java.util.Date());
                System.out.println("===============================");
                
                request.setAttribute("quotation", quotation);
                request.getRequestDispatcher("/view/customer-quote-success.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Có lỗi xảy ra khi xử lý phản hồi. Vui lòng thử lại.");
                request.getRequestDispatcher("/view/customer-quote-error.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid parameters");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error: " + e.getMessage());
        }
    }
}
