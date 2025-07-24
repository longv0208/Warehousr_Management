package controller;

import dao.RfqDAO;
import dao.RfqDetailDAO;
import dao.SupplierDAO;
import dao.ProductDAO;
import model.Rfq;
import model.RfqDetail;
import model.Supplier;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.ArrayList;

@WebServlet("/supplier-quote")
public class SupplierQuoteController extends HttpServlet {
    
    private RfqDAO rfqDAO = new RfqDAO();
    private RfqDetailDAO rfqDetailDAO = new RfqDetailDAO();
    private SupplierDAO supplierDAO = new SupplierDAO();
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int rfqId = Integer.parseInt(request.getParameter("rfqId"));
            int supplierId = Integer.parseInt(request.getParameter("supplierId"));
            
            // Get RFQ information
            Rfq rfq = rfqDAO.getRfqById(rfqId);
            if (rfq == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "RFQ not found");
                return;
            }
            
            // Get supplier information
            Supplier supplier = supplierDAO.getSupplierById(supplierId);
            if (supplier == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Supplier not found");
                return;
            }
            
            // Get RFQ details
            List<RfqDetail> rfqDetails = rfqDetailDAO.getRfqDetailsByRfqId(rfqId);
            
            // Get product information for each detail
            List<Product> products = new ArrayList<>();
            for (RfqDetail detail : rfqDetails) {
                Product product = productDAO.getProductById(detail.getProductId());
                if (product != null) {
                    products.add(product);
                }
            }
            
            // Set attributes for JSP
            request.setAttribute("rfq", rfq);
            request.setAttribute("supplier", supplier);
            request.setAttribute("rfqDetails", rfqDetails);
            request.setAttribute("products", products);
            
            // Forward to quote page
            request.getRequestDispatcher("/view/supplier-quote.jsp").forward(request, response);
            
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
            int rfqId = Integer.parseInt(request.getParameter("rfqId"));
            int supplierId = Integer.parseInt(request.getParameter("supplierId"));
            
            // Get RFQ details
            List<RfqDetail> rfqDetails = rfqDetailDAO.getRfqDetailsByRfqId(rfqId);
            
            boolean hasErrors = false;
            StringBuilder errorMessage = new StringBuilder();
            
            // Process price updates
            for (RfqDetail detail : rfqDetails) {
                String priceParam = request.getParameter("price_" + detail.getRfqDetailId());
                
                if (priceParam != null && !priceParam.trim().isEmpty()) {
                    try {
                        BigDecimal price = new BigDecimal(priceParam.trim());
                        
                        if (price.compareTo(BigDecimal.ZERO) <= 0) {
                            hasErrors = true;
                            errorMessage.append("Gia phai lon hon 0 cho san pham ID ").append(detail.getProductId()).append(". ");
                            continue;
                        }
                        
                        // Update price in rfq_details
                        detail.setPrice(price.doubleValue());
                        boolean updated = rfqDetailDAO.updateRfqDetailPrice(detail.getRfqDetailId(), price.doubleValue());
                        
                        if (!updated) {
                            hasErrors = true;
                            errorMessage.append("Khong the cap nhat gia cho san pham ID ").append(detail.getProductId()).append(". ");
                        }
                        
                    } catch (NumberFormatException e) {
                        hasErrors = true;
                        errorMessage.append("Gia khong hop le cho san pham ID ").append(detail.getProductId()).append(". ");
                    }
                }
            }
            
            if (hasErrors) {
                request.setAttribute("errorMessage", errorMessage.toString());
                doGet(request, response); // Reload the form with error
                return;
            }
            
            // Success - redirect to success page
            response.sendRedirect("view/quote-success.jsp");
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid parameters");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Co loi xay ra khi cap nhat bao gia: " + e.getMessage());
            doGet(request, response);
        }
    }
}
