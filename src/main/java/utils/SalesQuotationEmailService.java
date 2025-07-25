package utils;

import model.SalesQuotation;
import model.SalesQuotationDetail;
import model.Product;
import java.util.Date;
import java.util.List;
import java.text.SimpleDateFormat;

/**
 * Email service for sending Sales Quotations to customers
 */
public class SalesQuotationEmailService {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_USERNAME = "bangtxhe163986@fpt.edu.vn";
    private static final String EMAIL_PASSWORD = "bsjd uezf mhsy pzqw";
    private static final String FROM_EMAIL = "bangtxhe163986@fpt.edu.vn";
    private static final String FROM_NAME = "Hệ Thống Quản Lý Kho Hàng - Phòng Mua Hàng";

    /**
     * Send Sales Quotation email to customer (Mock implementation)
     */
    public static boolean sendQuotationToCustomer(String customerName, SalesQuotation quotation,
            List<SalesQuotationDetail> quotationDetails, List<Product> products, String email) {
        try {
            System.out.println("=== SENDING SALES QUOTATION EMAIL TO CUSTOMER ===");
            System.out.println("From: he-thong-quan-ly-kho@company.com");
            System.out.println("To: [Customer Email - To be configured]");
            System.out.println("Customer: " + customerName);
            System.out.println("Quotation Code: " + getQuotationCode(quotation));
            System.out.println("Subject: Bao Gia San Pham - " + getQuotationCode(quotation));

            // Create email content
            String emailContent = createQuotationEmailContent(customerName, quotation, quotationDetails, products);

            EmailUtil.sendMail(email, "Đơn báo giá", emailContent);
            return true;

        } catch (Exception e) {
            System.out.println("Error sending sales quotation email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Create email content for Sales Quotation
     */
    private static String createQuotationEmailContent(String customerName, SalesQuotation quotation,
            List<SalesQuotationDetail> quotationDetails, List<Product> products) {
        StringBuilder content = new StringBuilder();
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        // Start HTML content
        content.append("<!DOCTYPE html>\n");
        content.append("<html lang='vi'>\n");
        content.append("<head>\n");
        content.append("<meta charset='UTF-8'>\n");
        content.append("<meta name='viewport' content='width=device-width, initial-scale=1.0'>\n");
        content.append("<title>Báo Giá Sản Phẩm</title>\n");
        content.append("<style>\n");
        content.append("body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; }\n");
        content.append(".header { background: linear-gradient(135deg, #007bff, #0056b3); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }\n");
        content.append(".header h1 { margin: 0; font-size: 28px; }\n");
        content.append(".header .quotation-code { font-size: 18px; margin-top: 10px; opacity: 0.9; }\n");
        content.append(".content { background: white; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }\n");
        content.append(".section { margin-bottom: 30px; }\n");
        content.append(".section-title { color: #007bff; font-size: 18px; font-weight: bold; margin-bottom: 15px; border-bottom: 2px solid #007bff; padding-bottom: 5px; }\n");
        content.append(".info-row { margin-bottom: 8px; }\n");
        content.append(".info-label { font-weight: bold; color: #555; display: inline-block; width: 140px; }\n");
        content.append(".table { width: 100%; border-collapse: collapse; margin: 20px 0; }\n");
        content.append(".table th { background: #f8f9fa; color: #333; padding: 12px; text-align: left; border: 1px solid #dee2e6; font-weight: bold; }\n");
        content.append(".table td { padding: 10px 12px; border: 1px solid #dee2e6; }\n");
        content.append(".table tr:nth-child(even) { background: #f8f9fa; }\n");
        content.append(".table tr:hover { background: #e3f2fd; }\n");
        content.append(".total-row { background: #007bff !important; color: white; font-weight: bold; }\n");
        content.append(".total-row td { border-color: #0056b3; }\n");
        content.append(".action-buttons { text-align: center; margin: 30px 0; }\n");
        content.append(".btn { display: inline-block; padding: 12px 30px; margin: 0 10px; text-decoration: none; border-radius: 5px; font-weight: bold; transition: all 0.3s ease; }\n");
        content.append(".btn-success { background: #28a745; color: white; }\n");
        content.append(".btn-success:hover { background: #218838; }\n");
        content.append(".btn-danger { background: #dc3545; color: white; }\n");
        content.append(".btn-danger:hover { background: #c82333; }\n");
        content.append(".note-box { background: #f8f9fa; border-left: 4px solid #007bff; padding: 15px; margin: 20px 0; }\n");
        content.append(".footer { background: #f8f9fa; padding: 20px; text-align: center; border-radius: 0 0 10px 10px; margin-top: 30px; }\n");
        content.append(".footer .company-info { color: #666; font-size: 14px; }\n");
        content.append(".highlight { color: #007bff; font-weight: bold; }\n");
        content.append("</style>\n");
        content.append("</head>\n");
        content.append("<body>\n");

        // Header
        content.append("<div class='header'>\n");
        content.append("<h1>📋 BÁO GIÁ SẢN PHẨM</h1>\n");
        content.append("<div class='quotation-code'>Mã báo giá: <strong>").append(getQuotationCode(quotation)).append("</strong></div>\n");
        content.append("</div>\n");

        content.append("<div class='content'>\n");

        // Customer greeting
        content.append("<div class='section'>\n");
        content.append("<p>Kính chào <strong class='highlight'>").append(customerName).append("</strong>,</p>\n");
        content.append("<p>Cảm ơn Quý khách đã quan tâm đến sản phẩm của chúng tôi. Chúng tôi xin gửi báo giá chi tiết như sau:</p>\n");
        content.append("</div>\n");

        // Quotation information
        content.append("<div class='section'>\n");
        content.append("<div class='section-title'>📄 Thông tin báo giá</div>\n");
        content.append("<div class='info-row'><span class='info-label'>Mã báo giá:</span> <strong>").append(getQuotationCode(quotation)).append("</strong></div>\n");
        content.append("<div class='info-row'><span class='info-label'>Ngày tạo:</span> ").append(dateTimeFormat.format(getQuotationCreatedAt(quotation))).append("</div>\n");
        content.append("<div class='info-row'><span class='info-label'>Hiệu lực đến:</span> <span class='highlight'>").append(dateFormat.format(getQuotationValidUntil(quotation))).append("</span></div>\n");

        String note = getQuotationNote(quotation);
        if (note != null && !note.trim().isEmpty()) {
            content.append("<div class='info-row'><span class='info-label'>Ghi chú:</span> ").append(note).append("</div>\n");
        }
        content.append("</div>\n");

        // Products table
        content.append("<div class='section'>\n");
        content.append("<div class='section-title'>🛍️ Danh sách sản phẩm</div>\n");
        content.append("<table class='table'>\n");
        content.append("<thead>\n");
        content.append("<tr>\n");
        content.append("<th style='width: 50px;'>STT</th>\n");
        content.append("<th>Tên sản phẩm</th>\n");
        content.append("<th style='width: 80px;'>Đơn vị</th>\n");
        content.append("<th style='width: 100px;'>Số lượng</th>\n");
        content.append("<th style='width: 120px;'>Đơn giá</th>\n");
        content.append("<th style='width: 140px;'>Thành tiền</th>\n");
        content.append("</tr>\n");
        content.append("</thead>\n");
        content.append("<tbody>\n");

        int index = 1;
        double totalAmount = 0;
        for (SalesQuotationDetail detail : quotationDetails) {
            // Find product information
            Product product = null;
            for (Product p : products) {
                if (getProductId(p) == getQuotationDetailProductId(detail)) {
                    product = p;
                    break;
                }
            }

            if (product != null) {
                double itemTotal = getQuotationDetailQuantity(detail) * getQuotationDetailUnitPrice(detail);
                totalAmount += itemTotal;

                content.append("<tr>\n");
                content.append("<td style='text-align: center;'>").append(index++).append("</td>\n");
                content.append("<td><strong>").append(getProductName(product)).append("</strong></td>\n");
                content.append("<td style='text-align: center;'>").append(getProductUnit(product)).append("</td>\n");
                content.append("<td style='text-align: center;'>").append(String.format("%,d", getQuotationDetailQuantity(detail))).append("</td>\n");
                content.append("<td style='text-align: right;'>").append(String.format("%,.0f VNĐ", getQuotationDetailUnitPrice(detail))).append("</td>\n");
                content.append("<td style='text-align: right;'><strong>").append(String.format("%,.0f VNĐ", itemTotal)).append("</strong></td>\n");
                content.append("</tr>\n");
            }
        }

        content.append("<tr class='total-row'>\n");
        content.append("<td colspan='5' style='text-align: right; font-size: 16px;'>TỔNG CỘNG:</td>\n");
        content.append("<td style='text-align: right; font-size: 18px;'>").append(String.format("%,.0f VNĐ", totalAmount)).append("</td>\n");
        content.append("</tr>\n");
        content.append("</tbody>\n");
        content.append("</table>\n");
        content.append("</div>\n");

        // Action buttons
        content.append("<div class='section'>\n");
        content.append("<div class='section-title'>✅ Xác nhận đơn hàng</div>\n");
        content.append("<p style='text-align: center; margin-bottom: 20px;'>Quý khách vui lòng chọn một trong hai tùy chọn bên dưới:</p>\n");
        content.append("<div class='action-buttons'>\n");
        content.append("<a href='").append(generateCustomerResponseUrl(quotation.getQuotationId(), "confirm")).append("' class='btn btn-success'>✅ ĐỒNG Ý ĐẶT HÀNG</a>\n");
        content.append("<a href='").append(generateCustomerResponseUrl(quotation.getQuotationId(), "reject")).append("' class='btn btn-danger'>❌ TỪ CHỐI</a>\n");
        content.append("</div>\n");
        content.append("</div>\n");

        // Important notes
        content.append("<div class='note-box'>\n");
        content.append("<div class='section-title'>📝 Lưu ý quan trọng</div>\n");
        content.append("<ul style='margin: 10px 0; padding-left: 20px;'>\n");
        content.append("<li>Báo giá này có hiệu lực đến ngày: <strong class='highlight'>").append(dateFormat.format(getQuotationValidUntil(quotation))).append("</strong></li>\n");
        content.append("<li>Giá đã bao gồm VAT (nếu có)</li>\n");
        content.append("<li>Thời gian giao hàng: Theo thỏa thuận</li>\n");
        content.append("<li>Điều kiện thanh toán: Theo thỏa thuận</li>\n");
        content.append("<li>Mọi thắc mắc xin liên hệ trực tiếp qua email hoặc điện thoại</li>\n");
        content.append("</ul>\n");
        content.append("</div>\n");

        content.append("<div class='section'>\n");
        content.append("<p>Chúng tôi mong nhận được phản hồi từ Quý khách trong thời gian sớm nhất.</p>\n");
        content.append("<p><strong>Xin cảm ơn sự quan tâm của Quý khách!</strong></p>\n");
        content.append("</div>\n");

        content.append("</div>\n");

        // Footer
        content.append("<div class='footer'>\n");
        content.append("<div class='company-info'>\n");
        content.append("<strong>Hệ Thống Quản Lý Kho Hàng</strong><br>\n");
        content.append("📧 Email: he-thong-quan-ly-kho@company.com<br>\n");
        content.append("📞 Hotline: 1900-xxxx<br>\n");
        content.append("🌐 Website: www.company.com\n");
        content.append("</div>\n");
        content.append("</div>\n");

        content.append("</body>\n");
        content.append("</html>\n");

        return content.toString();
    }

    /**
     * Generate customer response URL
     */
    private static String generateCustomerResponseUrl(int quotationId, String action) {
        String serverHost = "localhost";
        String serverPort = "9999";
        String contextPath = "ClotheWareHouse";

        return String.format("http://%s:%s/%s/customer-quote-response?quotationId=%d&action=%s",
                serverHost, serverPort, contextPath, quotationId, action);
    }

    // Safe getter methods to avoid reflection issues
    private static String getQuotationCode(SalesQuotation quotation) {
        try {
            return quotation.getQuotationCode();
        } catch (Exception e) {
            return "UNKNOWN-QUOTATION";
        }
    }

    private static java.util.Date getQuotationCreatedAt(SalesQuotation quotation) {
        try {
            return quotation.getCreatedAt();
        } catch (Exception e) {
            return new java.util.Date();
        }
    }

    private static java.util.Date getQuotationValidUntil(SalesQuotation quotation) {
        try {
            return quotation.getValidUntil();
        } catch (Exception e) {
            return new java.util.Date();
        }
    }

    private static String getQuotationNote(SalesQuotation quotation) {
        try {
            return quotation.getNotes();
        } catch (Exception e) {
            return "";
        }
    }

    private static int getProductId(Product product) {
        try {
            return product.getProductId();
        } catch (Exception e) {
            return -1;
        }
    }

    private static String getProductCode(Product product) {
        try {
            return product.getProductCode();
        } catch (Exception e) {
            return "UNKNOWN";
        }
    }

    private static String getProductName(Product product) {
        try {
            return product.getProductName();
        } catch (Exception e) {
            return "Unknown Product";
        }
    }

    private static String getProductUnit(Product product) {
        try {
            return product.getUnit();
        } catch (Exception e) {
            return "Unit";
        }
    }

    private static int getQuotationDetailProductId(SalesQuotationDetail detail) {
        try {
            return detail.getProductId();
        } catch (Exception e) {
            return -1;
        }
    }

    private static int getQuotationDetailQuantity(SalesQuotationDetail detail) {
        try {
            return detail.getQuantity();
        } catch (Exception e) {
            return 0;
        }
    }

    private static double getQuotationDetailUnitPrice(SalesQuotationDetail detail) {
        try {
            return detail.getUnitPrice().doubleValue();
        } catch (Exception e) {
            return 0.0;
        }
    }
}
