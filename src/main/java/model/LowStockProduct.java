package model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class LowStockProduct {
    private Integer productId;
    private String productCode;
    private String productName;
    private String description;
    private String unit;
    private Float purchasePrice;
    private Float salePrice;
    private Integer lowStockThreshold;
    private Integer quantityOnHand;
    private String supplierName;
    private String status; // "LOW_STOCK" hoặc "OUT_OF_STOCK"
    
    public String getStatusDisplay() {
        if (quantityOnHand == null || quantityOnHand <= 0) {
            return "Hết hàng";
        } else if (quantityOnHand <= lowStockThreshold) {
            return "Sắp hết hàng";
        }
        return "Đủ hàng";
    }
    
    public String getStatusClass() {
        if (quantityOnHand == null || quantityOnHand <= 0) {
            return "bg-danger";
        } else if (quantityOnHand <= lowStockThreshold) {
            return "bg-warning";
        }
        return "bg-success";
    }
} 