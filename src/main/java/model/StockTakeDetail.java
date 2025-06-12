package model;

import java.sql.Timestamp;

public class StockTakeDetail {
    private Integer stockTakeDetailId;
    private Integer stockTakeId;
    private Integer productId;
    private Integer systemQuantity;
    private Integer countedQuantity;
    private Integer discrepancy; // counted_quantity - system_quantity
    
    // Additional fields for display purposes
    private String productCode;
    private String productName;
    private String unit;

    // Constructors
    public StockTakeDetail() {}

    public StockTakeDetail(Integer stockTakeDetailId, Integer stockTakeId, Integer productId, 
                          Integer systemQuantity, Integer countedQuantity, Integer discrepancy) {
        this.stockTakeDetailId = stockTakeDetailId;
        this.stockTakeId = stockTakeId;
        this.productId = productId;
        this.systemQuantity = systemQuantity;
        this.countedQuantity = countedQuantity;
        this.discrepancy = discrepancy;
    }

    // Getters and Setters
    public Integer getStockTakeDetailId() { return stockTakeDetailId; }
    public void setStockTakeDetailId(Integer stockTakeDetailId) { this.stockTakeDetailId = stockTakeDetailId; }

    public Integer getStockTakeId() { return stockTakeId; }
    public void setStockTakeId(Integer stockTakeId) { this.stockTakeId = stockTakeId; }

    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }

    public Integer getSystemQuantity() { return systemQuantity; }
    public void setSystemQuantity(Integer systemQuantity) { this.systemQuantity = systemQuantity; }

    public Integer getCountedQuantity() { return countedQuantity; }
    public void setCountedQuantity(Integer countedQuantity) { this.countedQuantity = countedQuantity; }

    public Integer getDiscrepancy() { return discrepancy; }
    public void setDiscrepancy(Integer discrepancy) { this.discrepancy = discrepancy; }

    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
} 