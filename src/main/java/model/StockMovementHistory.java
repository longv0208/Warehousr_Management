package model;

import lombok.*;
import java.math.BigDecimal;
import java.sql.Timestamp;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class StockMovementHistory {
    private Integer movementId;
    private Integer productId;
    private Integer warehouseId;
    private String movementType; // INWARD, OUTWARD
    private Integer quantity;
    private BigDecimal unitPrice;
    private String referenceCode; // Mã phiếu nhập/xuất
    private String referenceType; // STOCK_INWARD, STOCK_OUTWARD, STOCK_TAKE
    private Integer createdBy;
    private Timestamp movementDate;
    private String notes;
    
    // Thông tin bổ sung để hiển thị
    private String productName;
    private String productCode;
    private String warehouseName;
    private String createdByName;
}
