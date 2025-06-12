package model;

import java.math.BigDecimal;

public class SalesOrderDetail {
    private Integer orderDetailId;
    private Integer salesOrderId;
    private Integer productId;
    private Integer quantityOrdered;
    private BigDecimal unitSalePrice;

    // Default constructor
    public SalesOrderDetail() {
    }

    // Constructor with all parameters
    public SalesOrderDetail(Integer orderDetailId, Integer salesOrderId, Integer productId, 
                           Integer quantityOrdered, BigDecimal unitSalePrice) {
        this.orderDetailId = orderDetailId;
        this.salesOrderId = salesOrderId;
        this.productId = productId;
        this.quantityOrdered = quantityOrdered;
        this.unitSalePrice = unitSalePrice;
    }

    // Getters and Setters
    public Integer getOrderDetailId() {
        return orderDetailId;
    }

    public void setOrderDetailId(Integer orderDetailId) {
        this.orderDetailId = orderDetailId;
    }

    public Integer getSalesOrderId() {
        return salesOrderId;
    }

    public void setSalesOrderId(Integer salesOrderId) {
        this.salesOrderId = salesOrderId;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }

    public Integer getQuantityOrdered() {
        return quantityOrdered;
    }

    public void setQuantityOrdered(Integer quantityOrdered) {
        this.quantityOrdered = quantityOrdered;
    }

    public BigDecimal getUnitSalePrice() {
        return unitSalePrice;
    }

    public void setUnitSalePrice(BigDecimal unitSalePrice) {
        this.unitSalePrice = unitSalePrice;
    }

    @Override
    public String toString() {
        return "SalesOrderDetail{" +
                "orderDetailId=" + orderDetailId +
                ", salesOrderId=" + salesOrderId +
                ", productId=" + productId +
                ", quantityOrdered=" + quantityOrdered +
                ", unitSalePrice=" + unitSalePrice +
                '}';
    }
} 