package model;

import java.sql.Timestamp;
import java.sql.Date;

public class StockTake {
    private Integer stockTakeId;
    private String stockTakeCode;
    private Integer userId;
    private Date stockTakeDate;
    private String status; // 'pending','in_progress','completed','reconciled'
    private String notes;
    private Timestamp createdAt;
    
    // Additional fields for display purposes
    private String userFullName;
    private Integer totalProducts;
    private Integer completedProducts;

    // Constructors
    public StockTake() {}

    public StockTake(Integer stockTakeId, String stockTakeCode, Integer userId, Date stockTakeDate, 
                    String status, String notes, Timestamp createdAt) {
        this.stockTakeId = stockTakeId;
        this.stockTakeCode = stockTakeCode;
        this.userId = userId;
        this.stockTakeDate = stockTakeDate;
        this.status = status;
        this.notes = notes;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Integer getStockTakeId() { return stockTakeId; }
    public void setStockTakeId(Integer stockTakeId) { this.stockTakeId = stockTakeId; }

    public String getStockTakeCode() { return stockTakeCode; }
    public void setStockTakeCode(String stockTakeCode) { this.stockTakeCode = stockTakeCode; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Date getStockTakeDate() { return stockTakeDate; }
    public void setStockTakeDate(Date stockTakeDate) { this.stockTakeDate = stockTakeDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserFullName() { return userFullName; }
    public void setUserFullName(String userFullName) { this.userFullName = userFullName; }

    public Integer getTotalProducts() { return totalProducts; }
    public void setTotalProducts(Integer totalProducts) { this.totalProducts = totalProducts; }

    public Integer getCompletedProducts() { return completedProducts; }
    public void setCompletedProducts(Integer completedProducts) { this.completedProducts = completedProducts; }
} 