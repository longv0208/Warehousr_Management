package model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.math.BigDecimal;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class SalesOrderDetail {
    private Integer orderDetailId;
    private Integer salesOrderId;
    private Integer productId;
    private Integer quantityOrdered;
    private BigDecimal unitSalePrice;
    
    // Additional properties for JSP compatibility
    private Product product; // Product information for display
    
    // Convenience getters for JSP compatibility
    public Integer getQuantity() {
        return quantityOrdered;
    }
    
    public BigDecimal getUnitPrice() {
        return unitSalePrice;
    }
    
    // Direct access to product properties for JSP compatibility
    public String getProductCode() {
        return product != null ? product.getProductCode() : null;
    }
    
    public String getProductName() {
        return product != null ? product.getProductName() : null;
    }
    
    public String getUnit() {
        return product != null ? product.getUnit() : null;
    }
    
    public String getDescription() {
        return product != null ? product.getDescription() : null;
    }
    
    public Float getPurchasePrice() {
        return product != null ? product.getPurchasePrice() : null;
    }
    
    public Float getSalePrice() {
        return product != null ? product.getSalePrice() : null;
    }
    
    public Integer getAvailableQuantity() {
        return product != null ? product.getStockQuantity() : 0;
    }
    
    public Integer getStockQuantity() {
        return product != null ? product.getStockQuantity() : 0;
    }
    
    public Boolean getIsActive() {
        return product != null ? product.getIsActive() : true;
    }
} 