package model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.sql.Timestamp;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Product {
    private Integer productId;
    private String productCode;
    private String productName;
    private String description;
    private String unit;
    private Float purchasePrice;
    private Float salePrice;
    private Integer supplierId;
    private Integer lowStockThreshold;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Boolean isActive;
}
