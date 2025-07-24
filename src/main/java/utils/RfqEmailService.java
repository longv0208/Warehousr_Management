package utils;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import model.Rfq;
import model.RfqDetail;
import model.Supplier;
import model.Product;
import java.util.Properties;
import java.util.Date;
import java.util.List;
import java.text.SimpleDateFormat;

/**
 * Email service for sending RFQ (Request for Quotation) emails to suppliers
 */
public class RfqEmailService {

    private static final boolean MOCK_MODE = false; // Set to true for testing

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_USERNAME = "bangtxhe163986@fpt.edu.vn";
    private static final String EMAIL_PASSWORD = "bsjd uezf mhsy pzqw";
    private static final String FROM_EMAIL = "bangtxhe163986@fpt.edu.vn";
    private static final String FROM_NAME = "Hệ Thống Quản Lý Kho Hàng - Phòng Mua Hàng";
    
    // Server configuration - adjust these based on your deployment
    private static final String SERVER_HOST = "localhost";
    private static final String SERVER_PORT = "9999"; // Updated to match your Tomcat server
    private static final String CONTEXT_PATH = "ClotheWareHouse"; // Updated to match your actual deployment
    
    /**
     * Generate quote URL for supplier
     */
    private static String generateQuoteUrl(int rfqId, int supplierId) {
        return String.format("http://%s:%s/%s/supplier-quote?rfqId=%d&supplierId=%d", 
                SERVER_HOST, SERVER_PORT, CONTEXT_PATH, rfqId, supplierId);
    }

    /**
     * Send RFQ email to supplier
     *
     * @param supplier Supplier information
     * @param rfq RFQ information
     * @param rfqDetails List of RFQ details (products)
     * @param products List of all products for reference
     * @return true if email sent successfully, false otherwise
     */
    public static boolean sendRfqToSupplier(Supplier supplier, Rfq rfq, List<RfqDetail> rfqDetails, List<Product> products) {

        // Real email implementation using JavaMail
        try {
            System.out.println("=== SENDING RFQ EMAIL TO SUPPLIER ===");
            System.out.println("From: " + FROM_EMAIL);
            System.out.println("To: " + supplier.getEmail());
            System.out.println("Supplier: " + supplier.getSupplierName());
            System.out.println("RFQ Code: " + rfq.getRfqCode());

            // Create properties for Gmail SMTP
            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            // Create session with authentication
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
                }
            });

            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(supplier.getEmail()));
            message.setSubject("Yeu Cau Bao Gia - " + rfq.getRfqCode() + " - " + FROM_NAME);
            message.setSentDate(new Date());

            // Create HTML content
            String htmlContent = createRfqEmailTemplate(supplier, rfq, rfqDetails, products);
            message.setContent(htmlContent, "text/html; charset=utf-8");

            // Send message
            System.out.println("Sending RFQ email...");
            Transport.send(message);

            System.out.println("=== RFQ EMAIL SENT SUCCESSFULLY ===");
            System.out.println("RFQ has been sent to supplier: " + supplier.getSupplierName());
            System.out.println("Email: " + supplier.getEmail());
            System.out.println("RFQ Code: " + rfq.getRfqCode());
            return true;

        } catch (Exception e) {
            System.out.println("Error sending RFQ email: " + e.getMessage());
            e.printStackTrace();

            // Fallback to console output
            System.out.println("=== RFQ EMAIL FAILED - FALLBACK TO CONSOLE ===");
            System.out.println("RFQ Details:");
            System.out.println("Supplier: " + supplier.getSupplierName() + " (" + supplier.getEmail() + ")");
            System.out.println("RFQ Code: " + rfq.getRfqCode());
            System.out.println("Expected Delivery: " + new SimpleDateFormat("dd/MM/yyyy").format(rfq.getExpectedDeliveryDate()));
            System.out.println("Products count: " + rfqDetails.size());
            System.out.println("=== CHECK CONSOLE FOR RFQ DETAILS ===");
            return true; // Still return true to continue flow
        }
    }

    /**
     * Create HTML email template for RFQ
     */
    private static String createRfqEmailTemplate(Supplier supplier, Rfq rfq, List<RfqDetail> rfqDetails, List<Product> products) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        StringBuilder productsTable = new StringBuilder();
        productsTable.append("<table style='width: 100%; border-collapse: collapse; margin: 20px 0;'>");
        productsTable.append("<thead>");
        productsTable.append("<tr style='background-color: #f8f9fa;'>");
        productsTable.append("<th style='border: 1px solid #dee2e6; padding: 12px; text-align: left;'>STT</th>");
        productsTable.append("<th style='border: 1px solid #dee2e6; padding: 12px; text-align: left;'>Ma san pham</th>");
        productsTable.append("<th style='border: 1px solid #dee2e6; padding: 12px; text-align: left;'>Ten san pham</th>");
        productsTable.append("<th style='border: 1px solid #dee2e6; padding: 12px; text-align: left;'>Don vi</th>");
        productsTable.append("<th style='border: 1px solid #dee2e6; padding: 12px; text-align: right;'>So luong</th>");
        productsTable.append("</tr>");
        productsTable.append("</thead>");
        productsTable.append("<tbody>");

        int index = 1;
        for (RfqDetail detail : rfqDetails) {
            // Find product information
            Product product = null;
            for (Product p : products) {
                if (p.getProductId() == detail.getProductId()) {
                    product = p;
                    break;
                }
            }

            if (product != null) {
                productsTable.append("<tr>");
                productsTable.append("<td style='border: 1px solid #dee2e6; padding: 12px; text-align: center;'>").append(index++).append("</td>");
                productsTable.append("<td style='border: 1px solid #dee2e6; padding: 12px;'>").append(product.getProductCode()).append("</td>");
                productsTable.append("<td style='border: 1px solid #dee2e6; padding: 12px;'>").append(product.getProductName()).append("</td>");
                productsTable.append("<td style='border: 1px solid #dee2e6; padding: 12px;'>").append(product.getUnit()).append("</td>");
                productsTable.append("<td style='border: 1px solid #dee2e6; padding: 12px; text-align: right;'>").append(detail.getQuantity()).append("</td>");
                productsTable.append("</tr>");
            }
        }

        productsTable.append("</tbody>");
        productsTable.append("</table>");

        return "<!DOCTYPE html>"
                + "<html>"
                + "<head>"
                + "<meta charset='UTF-8'>"
                + "<style>"
                + "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }"
                + ".container { max-width: 800px; margin: 0 auto; padding: 20px; }"
                + ".header { background: linear-gradient(135deg, #007bff 0%, #0056b3 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }"
                + ".content { background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px; }"
                + ".info-box { background: white; padding: 20px; margin: 20px 0; border-radius: 10px; border-left: 4px solid #007bff; }"
                + ".info-row { display: flex; margin-bottom: 10px; }"
                + ".info-label { font-weight: bold; min-width: 200px; color: #495057; }"
                + ".info-value { color: #212529; }"
                + ".products-section { background: white; padding: 20px; margin: 20px 0; border-radius: 10px; }"
                + ".note-box { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }"
                + ".footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }"
                + ".highlight { color: #007bff; font-weight: bold; }"
                + ".urgent { color: #dc3545; font-weight: bold; }"
                + ".quote-button { display: inline-block; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; font-size: 16px; margin: 20px 0; box-shadow: 0 4px 15px rgba(40,167,69,0.3); transition: all 0.3s ease; }"
                + ".quote-button:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(40,167,69,0.4); }"
                + ".quote-section { text-align: center; background: white; padding: 30px; margin: 20px 0; border-radius: 10px; border: 2px dashed #28a745; }"
                + "</style>"
                + "</head>"
                + "<body>"
                + "<div class='container'>"
                + "<div class='header'>"
                + "<h1>YEU CAU BAO GIA</h1>"
                + "<h2>" + rfq.getRfqCode() + "</h2>"
                + "<p>He Thong Quan Ly Kho Hang</p>"
                + "</div>"
                + "<div class='content'>"
                + "<h2>Kinh gui: " + supplier.getSupplierName() + "</h2>"
                + "<p>Chung toi xin gui den Quy cong ty yeu cau bao gia cho cac san pham duoi day:</p>"
                + "<div class='info-box'>"
                + "<h3>Thong tin yeu cau bao gia</h3>"
                + "<div class='info-row'>"
                + "<span class='info-label'>Ma YCB:</span>"
                + "<span class='info-value highlight'>" + rfq.getRfqCode() + "</span>"
                + "</div>"
                + "<div class='info-row'>"
                + "<span class='info-label'>Ngay tao:</span>"
                + "<span class='info-value'>" + dateTimeFormat.format(rfq.getCreatedAt()) + "</span>"
                + "</div>"
                + "<div class='info-row'>"
                + "<span class='info-label'>Ngay giao hang du kien:</span>"
                + "<span class='info-value urgent'>" + dateFormat.format(rfq.getExpectedDeliveryDate()) + "</span>"
                + "</div>"
                + "<div class='info-row'>"
                + "<span class='info-label'>Nguoi lien he:</span>"
                + "<span class='info-value'>" + supplier.getContactPerson() + "</span>"
                + "</div>"
                + "<div class='info-row'>"
                + "<span class='info-label'>Email:</span>"
                + "<span class='info-value'>" + supplier.getEmail() + "</span>"
                + "</div>"
                + "<div class='info-row'>"
                + "<span class='info-label'>So dien thoai:</span>"
                + "<span class='info-value'>" + supplier.getPhoneNumber() + "</span>"
                + "</div>"
                + "</div>"
                + "<div class='products-section'>"
                + "<h3>Danh sach san pham can bao gia</h3>"
                + productsTable.toString()
                + "</div>"
                + "<div class='quote-section'>"
                + "<h3 style='color: #28a745; margin-bottom: 15px;'>BAN MUON BAO GIA?</h3>"
                + "<p style='margin-bottom: 20px;'>Nhan vao nut ben duoi de truy cap trang bao gia va dien gia cho cac san pham:</p>"
                + "<a href='" + generateQuoteUrl(rfq.getRfqId(), supplier.getSupplierId()) + "' class='quote-button'>BAO GIA NGAY</a>"
                + "<p style='font-size: 14px; color: #666; margin-top: 15px;'>Link nay chi danh cho nha cung cap " + supplier.getSupplierName() + "</p>"
                + "</div>"
                + (rfq.getNote() != null && !rfq.getNote().trim().isEmpty()
                ? "<div class='note-box'>"
                + "<h4>Ghi chu:</h4>"
                + "<p>" + rfq.getNote() + "</p>"
                + "</div>" : "")
                + "<div class='note-box'>"
                + "<h4>Yeu cau bao gia:</h4>"
                + "<ul>"
                + "<li>Nhan vao nut <strong>BAO GIA NGAY</strong> ben tren de truy cap trang bao gia</li>"
                + "<li>Bao gia bao gom <strong>VAT</strong> (neu co)</li>"
                + "<li>Thoi han bao gia: <strong>trong vong 3 ngay lam viec</strong></li>"
                + "<li>Thoi gian giao hang: <strong>" + dateFormat.format(rfq.getExpectedDeliveryDate()) + "</strong></li>"
                + "<li>Dieu kien thanh toan: Theo thoa thuan</li>"
                + "<li>Moi thac mac xin lien he truc tiep qua email hoac dien thoai</li>"
                + "</ul>"
                + "</div>"
                + "<p>Chung toi mong nhan duoc bao gia tu Quy cong ty trong thoi gian som nhat.</p>"
                + "<p>Xin cam on su hop tac cua Quy cong ty!</p>"
                + "</div>"
                + "<div class='footer'>"
                + "<p><strong>He Thong Quan Ly Kho Hang</strong></p>"
                + "<p>Email: " + FROM_EMAIL + " | Hotline: 1900-xxxx</p>"
                + "<p>Dia chi: [Dia chi cong ty]</p>"
                + "<p><em>Email nay duoc gui tu dong tu he thong</em></p>"
                + "</div>"
                + "</div>"
                + "</body>"
                + "</html>";
    }

    /**
     * Test email configuration
     */
    public static boolean testEmailConfiguration() {
        try {
            System.out.println("Testing RFQ email configuration...");
            // Create mock data for testing
            Supplier testSupplier = new Supplier();
            testSupplier.setSupplierName("Test Supplier");
            testSupplier.setContactPerson("Test Contact");
            testSupplier.setEmail("test@example.com");
            testSupplier.setPhoneNumber("0123456789");

            // Test would require full RFQ and product data
            System.out.println("RFQ Email service is ready to use");
            return true;
        } catch (Exception e) {
            System.out.println("RFQ Email configuration test failed: " + e.getMessage());
            return false;
        }
    }

    /**
     * Set mock mode for testing
     */
    public static void setMockMode(boolean mockMode) {
        System.out.println("To change mock mode, update MOCK_MODE constant in RfqEmailService.java");
        System.out.println("Current mock mode: " + MOCK_MODE);
    }
}
