package model;

import lombok.*;
import java.math.BigDecimal;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class WarehouseProductStatus {
    private Integer productId;
    private String productCode;
    private String productName;
    private String unit;
    private Integer onHand;        // Số lượng có sẵn trong kho (inventory - outgoing)
    private Integer outgoing;      // Số lượng chuẩn bị được bán ra (từ sales orders đã confirm)
    private Integer incoming;      // Số lượng sắp nhập (từ purchase orders pending)
    private Integer totalInventory; // Tổng số lượng trong inventory
    private BigDecimal unitPrice;   // Giá bán
    private Boolean isActive;
    
    // Constructor for convenience
    public WarehouseProductStatus(Integer productId, String productCode, String productName, 
                                String unit, Integer totalInventory, Integer outgoing, Integer incoming,
                                BigDecimal unitPrice, Boolean isActive) {
        this.productId = productId;
        this.productCode = productCode;
        this.productName = productName;
        this.unit = unit;
        this.totalInventory = totalInventory;
        this.outgoing = outgoing != null ? outgoing : 0;
        this.incoming = incoming != null ? incoming : 0;
        this.onHand = totalInventory - this.outgoing;
        this.unitPrice = unitPrice;
        this.isActive = isActive;
    }
    
    // Calculate on hand when values change
    public void setTotalInventory(Integer totalInventory) {
        this.totalInventory = totalInventory;
        calculateOnHand();
    }
    
    public void setOutgoing(Integer outgoing) {
        this.outgoing = outgoing != null ? outgoing : 0;
        calculateOnHand();
    }
    
    private void calculateOnHand() {
        if (totalInventory != null && outgoing != null) {
            this.onHand = totalInventory - outgoing;
        }
    }
}
