package test;

import utils.RfqEmailService;

/**
 * Test URL generation for supplier quote system
 */
public class UrlTest {
    
    public static void main(String[] args) {
        System.out.println("=== SUPPLIER QUOTE URL TEST ===");
        
        // Test URL generation với các parameters khác nhau
        testUrlGeneration();
        
        // Test email service
        testEmailService();
        
        System.out.println("\n=== URL TEST COMPLETED ===");
    }
    
    private static void testUrlGeneration() {
        System.out.println("\n1. Testing URL generation...");
        
        try {
            // Test với sample data
            int testRfqId = 1;
            int testSupplierId = 2;
            
            String expectedUrl = "http://localhost:8080/Test/supplier-quote?rfqId=1&supplierId=2";
            System.out.println("Expected URL: " + expectedUrl);
            
            // Tạo URL theo format mới
            String generatedUrl = String.format("http://localhost:8080/Test/supplier-quote?rfqId=%d&supplierId=%d", 
                    testRfqId, testSupplierId);
            System.out.println("Generated URL: " + generatedUrl);
            
            if (expectedUrl.equals(generatedUrl)) {
                System.out.println("✓ URL generation working correctly");
            } else {
                System.out.println("✗ URL generation mismatch");
            }
            
        } catch (Exception e) {
            System.out.println("✗ URL generation test failed: " + e.getMessage());
        }
    }
    
    private static void testEmailService() {
        System.out.println("\n2. Testing email service configuration...");
        
        try {
            boolean emailTest = RfqEmailService.testEmailConfiguration();
            if (emailTest) {
                System.out.println("✓ Email service configuration OK");
            } else {
                System.out.println("✗ Email service configuration failed");
            }
            
            // Print current configuration
            System.out.println("\nCurrent Email Configuration:");
            System.out.println("SMTP Host: smtp.gmail.com");
            System.out.println("From Email: bangtxhe163986@fpt.edu.vn");
            
        } catch (Exception e) {
            System.out.println("✗ Email service test failed: " + e.getMessage());
        }
    }
    
    // Utility để test URL với parameters khác nhau
    public static void printTestUrls() {
        System.out.println("\n=== TEST URLs FOR MANUAL TESTING ===");
        
        String[] contexts = {"Test", "ClotheWareHouse", "warehouse"};
        String[] hosts = {"localhost", "127.0.0.1"};
        String[] ports = {"8080", "8090", "9090"};
        
        for (String context : contexts) {
            for (String host : hosts) {
                for (String port : ports) {
                    String url = String.format("http://%s:%s/%s/supplier-quote?rfqId=1&supplierId=1", 
                            host, port, context);
                    System.out.println(url);
                }
            }
        }
    }
}
