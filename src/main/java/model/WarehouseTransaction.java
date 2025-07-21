package model;

import java.time.LocalDateTime;

public class WarehouseTransaction {
    private String transactionId;
    private String transactionCode;
    private String transactionType; // "inward" or "outward"
    private String productCode;
    private String productName;
    private int quantity;
    private int remainingQuantity;
    private String unit;
    private LocalDateTime transactionDate;
    private String notes;

    // Constructors
    public WarehouseTransaction() {
    }

    public WarehouseTransaction(String transactionId, String transactionCode, String transactionType,
            String productCode, String productName, int quantity, int remainingQuantity,
            String unit, LocalDateTime transactionDate, String notes) {
        this.transactionId = transactionId;
        this.transactionCode = transactionCode;
        this.transactionType = transactionType;
        this.productCode = productCode;
        this.productName = productName;
        this.quantity = quantity;
        this.remainingQuantity = remainingQuantity;
        this.unit = unit;
        this.transactionDate = transactionDate;
        this.notes = notes;
    }

    // Getters and Setters
    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getTransactionCode() {
        return transactionCode;
    }

    public void setTransactionCode(String transactionCode) {
        this.transactionCode = transactionCode;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public String getProductCode() {
        return productCode;
    }

    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getRemainingQuantity() {
        return remainingQuantity;
    }

    public void setRemainingQuantity(int remainingQuantity) {
        this.remainingQuantity = remainingQuantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public LocalDateTime getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(LocalDateTime transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
