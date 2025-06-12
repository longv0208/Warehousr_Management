package model;

import java.sql.Date;
import java.sql.Timestamp;

public class SalesOrder {
    private Integer salesOrderId;
    private String orderCode;
    private String customerName;
    private Integer userId;
    private Date orderDate;
    private String status; // 'pending_stock_check','awaiting_shipment','shipped','completed','cancelled'
    private String notes;
    private Timestamp createdAt;

    // Default constructor
    public SalesOrder() {
    }

    // Constructor with all parameters
    public SalesOrder(Integer salesOrderId, String orderCode, String customerName, 
                     Integer userId, Date orderDate, String status, String notes, Timestamp createdAt) {
        this.salesOrderId = salesOrderId;
        this.orderCode = orderCode;
        this.customerName = customerName;
        this.userId = userId;
        this.orderDate = orderDate;
        this.status = status;
        this.notes = notes;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Integer getSalesOrderId() {
        return salesOrderId;
    }

    public void setSalesOrderId(Integer salesOrderId) {
        this.salesOrderId = salesOrderId;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "SalesOrder{" +
                "salesOrderId=" + salesOrderId +
                ", orderCode='" + orderCode + '\'' +
                ", customerName='" + customerName + '\'' +
                ", userId=" + userId +
                ", orderDate=" + orderDate +
                ", status='" + status + '\'' +
                ", notes='" + notes + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
} 