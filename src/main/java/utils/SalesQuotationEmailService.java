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

        content.append("===== BAO GIA SAN PHAM =====\n");
        content.append("Ma Bao Gia: ").append(getQuotationCode(quotation)).append("\n");
        content.append("Kinh gui: ").append(customerName).append("\n\n");

        content.append("THONG TIN KHACH HANG:\n");
        content.append("- Ten khach hang: ").append(customerName).append("\n\n");

        content.append("THONG TIN BAO GIA:\n");
        content.append("- Ma Bao Gia: ").append(getQuotationCode(quotation)).append("\n");
        content.append("- Ngay tao: ").append(dateTimeFormat.format(getQuotationCreatedAt(quotation))).append("\n");
        content.append("- Hieu luc den: ").append(dateFormat.format(getQuotationValidUntil(quotation))).append("\n");

        String note = getQuotationNote(quotation);
        if (note != null && !note.trim().isEmpty()) {
            content.append("- Ghi chu: ").append(note).append("\n");
        }
        content.append("\n");

        content.append("DANH SACH SAN PHAM:\n");
        content.append("STT | Ma SP | Ten SP | Don vi | So luong | Don gia | Thanh tien\n");
        content.append("----+-------+--------+--------+----------+---------+------------\n");

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

                content.append(String.format("%3d | %5s | %6s | %6s | %8d | %7.0f | %10.0f\n",
                        index++,
                        getProductCode(product),
                        getProductName(product),
                        getProductUnit(product),
                        getQuotationDetailQuantity(detail),
                        getQuotationDetailUnitPrice(detail),
                        itemTotal));
            }
        }

        content.append("----+-------+--------+--------+----------+---------+------------\n");
        content.append(String.format("TONG CONG: %,.0f VND\n", totalAmount));
        content.append("\n");

        content.append("HANH DONG CUA KHACH HANG:\n");
        content.append("Quy khach vui long xac nhan don hang bang cach:\n");
        content.append("1. DONG Y: Nhan vao link ben duoi de xac nhan don hang\n");
        content.append("2. TU CHOI: Phan hoi email nay neu khong dong y\n\n");

        // Generate confirmation links
        content.append("=== LINK XAC NHAN DON HANG ===\n");
        content.append("DONG Y: ").append(generateCustomerResponseUrl(quotation.getQuotationId(), "confirm")).append("\n");
        content.append("TU CHOI: ").append(generateCustomerResponseUrl(quotation.getQuotationId(), "reject")).append("\n\n");

        content.append("LUU Y:\n");
        content.append("- Bao gia nay co hieu luc den ngay: ").append(dateFormat.format(getQuotationValidUntil(quotation))).append("\n");
        content.append("- Gia da bao gom VAT (neu co)\n");
        content.append("- Thoi gian giao hang: theo thoa thuan\n");
        content.append("- Dieu kien thanh toan: Theo thoa thuan\n");
        content.append("- Moi thac mac xin lien he truc tiep qua email hoac dien thoai\n\n");

        content.append("Chung toi mong nhan duoc phan hoi tu Quy khach trong thoi gian som nhat.\n");
        content.append("Xin cam on su quan tam cua Quy khach!\n\n");

        content.append("Tran trong,\n");
        content.append("He Thong Quan Ly Kho Hang\n");
        content.append("Email: he-thong-quan-ly-kho@company.com\n");
        content.append("=======================================\n");

        return content.toString();
    }

    /**
     * Generate customer response URL
     */
    private static String generateCustomerResponseUrl(int quotationId, String action) {
        String serverHost = "localhost";
        String serverPort = "8080";
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
