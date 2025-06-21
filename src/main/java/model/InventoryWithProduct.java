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
public class InventoryWithProduct {
    // Thông tin inventory
    private Integer inventoryId;
    private Integer productId;
    private Integer quantityOnHand;
    private Timestamp lastUpdated;
    private Integer warehouseId;
    
    // Thông tin product
    private String productName;
    private String productCode;
    private String unit;
    
    // Thông tin warehouse
    private String warehouseName;
} 