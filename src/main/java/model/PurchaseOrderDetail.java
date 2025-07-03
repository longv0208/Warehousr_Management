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
public class PurchaseOrderDetail {
    private Integer poDetailId;
    private Integer poId;
    private Integer productId;
    private Integer quantity;
    private BigDecimal unitPrice;
} 