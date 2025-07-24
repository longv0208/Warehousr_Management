package utils;

import model.*;
import java.util.List;
import java.text.SimpleDateFormat;

/**
 * Simple RFQ Email Service for testing without Jakarta Mail
 */
public class SimpleRfqEmailService {
    
    private static final boolean MOCK_MODE = true; // Set to true for testing
    
    /**
     * Send RFQ email to supplier (Mock implementation)
     */
    public static boolean sendRfqToSupplier(Supplier supplier, Rfq rfq, List<RfqDetail> rfqDetails, List<Product> products) {
        try {
            System.out.println("=== SENDING RFQ EMAIL TO SUPPLIER ===");
            System.out.println("From: he-thong-quan-ly-kho@company.com");
            System.out.println("To: " + getSupplierEmail(supplier));
            System.out.println("Supplier: " + getSupplierName(supplier));
            System.out.println("RFQ Code: " + getRfqCode(rfq));
            System.out.println("Subject: Yeu Cau Bao Gia - " + getRfqCode(rfq));
            
            // Create email content
            String emailContent = createRfqEmailContent(supplier, rfq, rfqDetails, products);
            System.out.println("\n=== EMAIL CONTENT ===");
            System.out.println(emailContent);
            System.out.println("=== END EMAIL CONTENT ===");
            
            System.out.println("\n=== RFQ EMAIL SENT SUCCESSFULLY ===");
            System.out.println("RFQ has been sent to supplier: " + getSupplierName(supplier));
            System.out.println("Email: " + getSupplierEmail(supplier));
            System.out.println("RFQ Code: " + getRfqCode(rfq));
            return true;
            
        } catch (Exception e) {
            System.out.println("Error sending RFQ email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Create email content for RFQ
     */
    private static String createRfqEmailContent(Supplier supplier, Rfq rfq, List<RfqDetail> rfqDetails, List<Product> products) {
        StringBuilder content = new StringBuilder();
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        
        content.append("===== YEU CAU BAO GIA =====\n");
        content.append("Ma YCB: ").append(getRfqCode(rfq)).append("\n");
        content.append("Kinh gui: ").append(getSupplierName(supplier)).append("\n\n");
        
        content.append("THONG TIN NHA CUNG CAP:\n");
        content.append("- Ten cong ty: ").append(getSupplierName(supplier)).append("\n");
        content.append("- Nguoi lien he: ").append(getSupplierContactPerson(supplier)).append("\n");
        content.append("- Email: ").append(getSupplierEmail(supplier)).append("\n");
        content.append("- So dien thoai: ").append(getSupplierPhoneNumber(supplier)).append("\n\n");
        
        content.append("THONG TIN YEU CAU BAO GIA:\n");
        content.append("- Ma YCB: ").append(getRfqCode(rfq)).append("\n");
        content.append("- Ngay tao: ").append(dateTimeFormat.format(getRfqCreatedAt(rfq))).append("\n");
        content.append("- Ngay giao hang du kien: ").append(dateFormat.format(getRfqExpectedDeliveryDate(rfq))).append("\n");
        
        String note = getRfqNote(rfq);
        if (note != null && !note.trim().isEmpty()) {
            content.append("- Ghi chu: ").append(note).append("\n");
        }
        content.append("\n");
        
        content.append("DANH SACH SAN PHAM CAN BAO GIA:\n");
        content.append("STT | Ma SP | Ten SP | Don vi | So luong | Don gia | Thanh tien\n");
        content.append("----+-------+--------+--------+----------+---------+------------\n");
        
        int index = 1;
        for (RfqDetail detail : rfqDetails) {
            // Find product information
            Product product = null;
            for (Product p : products) {
                if (getProductId(p) == getRfqDetailProductId(detail)) {
                    product = p;
                    break;
                }
            }
            
            if (product != null) {
                content.append(String.format("%3d | %5s | %6s | %6s | %8d | %7s | %10s\n",
                    index++,
                    getProductCode(product),
                    getProductName(product),
                    getProductUnit(product),
                    getRfqDetailQuantity(detail),
                    "______",
                    "________"));
            }
        }
        
        content.append("\nYEU CAU BAO GIA:\n");
        content.append("- Vui long dien day du don gia va thanh tien cho tung san pham\n");
        content.append("- Bao gia bao gom VAT (neu co)\n");
        content.append("- Thoi han bao gia: trong vong 3 ngay lam viec\n");
        content.append("- Thoi gian giao hang: ").append(dateFormat.format(getRfqExpectedDeliveryDate(rfq))).append("\n");
        content.append("- Dieu kien thanh toan: Theo thoa thuan\n");
        content.append("- Vui long gui lai bao gia qua email nay hoac lien he truc tiep\n\n");
        
        content.append("Chung toi mong nhan duoc bao gia tu Quy cong ty trong thoi gian som nhat.\n");
        content.append("Xin cam on su hop tac cua Quy cong ty!\n\n");
        
        content.append("Tran trong,\n");
        content.append("He Thong Quan Ly Kho Hang\n");
        content.append("Email: he-thong-quan-ly-kho@company.com\n");
        content.append("=======================================\n");
        
        return content.toString();
    }
    
    // Safe getter methods to avoid reflection issues
    private static String getSupplierName(Supplier supplier) {
        try {
            return supplier.getSupplierName();
        } catch (Exception e) {
            return "Unknown Supplier";
        }
    }
    
    private static String getSupplierEmail(Supplier supplier) {
        try {
            return supplier.getEmail();
        } catch (Exception e) {
            return "unknown@email.com";
        }
    }
    
    private static String getSupplierContactPerson(Supplier supplier) {
        try {
            return supplier.getContactPerson();
        } catch (Exception e) {
            return "Unknown Contact";
        }
    }
    
    private static String getSupplierPhoneNumber(Supplier supplier) {
        try {
            return supplier.getPhoneNumber();
        } catch (Exception e) {
            return "Unknown Phone";
        }
    }
    
    private static String getRfqCode(Rfq rfq) {
        try {
            return rfq.getRfqCode();
        } catch (Exception e) {
            return "UNKNOWN-RFQ";
        }
    }
    
    private static java.util.Date getRfqCreatedAt(Rfq rfq) {
        try {
            return rfq.getCreatedAt();
        } catch (Exception e) {
            return new java.util.Date();
        }
    }
    
    private static java.util.Date getRfqExpectedDeliveryDate(Rfq rfq) {
        try {
            return rfq.getExpectedDeliveryDate();
        } catch (Exception e) {
            return new java.util.Date();
        }
    }
    
    private static String getRfqNote(Rfq rfq) {
        try {
            return rfq.getNote();
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
    
    private static int getRfqDetailProductId(RfqDetail detail) {
        try {
            return detail.getProductId();
        } catch (Exception e) {
            return -1;
        }
    }
    
    private static int getRfqDetailQuantity(RfqDetail detail) {
        try {
            return detail.getQuantity();
        } catch (Exception e) {
            return 0;
        }
    }
}
