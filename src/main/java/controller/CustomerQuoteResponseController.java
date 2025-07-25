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
        
        String quotationIdStr = request.getParameter("quotationId");
        String action = request.getParameter("action");

        if (quotationIdStr == null || action == null) {
            request.setAttribute("error", "Thông tin không hợp lệ");
            request.getRequestDispatcher("/view/customer-response-error.jsp").forward(request, response);
            return;
        }

        try {
            int quotationId = Integer.parseInt(quotationIdStr);
            
            // Process the response directly in GET method
            doPost(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Mã báo giá không hợp lệ");
            request.getRequestDispatcher("/view/customer-response-error.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi hệ thống xảy ra. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/view/customer-response-error.jsp").forward(request, response);
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
            String newStatus;
            if ("confirm".equals(action)) {
                newStatus = "approved";
            } else if ("reject".equals(action)) {
                newStatus = "rejected";
            } else {
                request.setAttribute("error", "Hành động không hợp lệ");
                request.getRequestDispatcher("/view/customer-response-error.jsp").forward(request, response);
                return;
            }
            
            // Update status in database
            boolean updated = salesQuotationDAO.updateStatus(quotationId, newStatus);
            
            if (updated) {
                // Update quotation object for display
                quotation.setStatus(newStatus);
                
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
                request.setAttribute("action", action);
                request.getRequestDispatcher("/view/customer-response-success.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi xử lý phản hồi. Vui lòng thử lại.");
                request.setAttribute("quotation", quotation);
                request.getRequestDispatcher("/view/customer-response-error.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid parameters");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error: " + e.getMessage());
        }
    }
}
