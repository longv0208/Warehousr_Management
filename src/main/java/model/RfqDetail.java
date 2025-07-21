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
public class RfqDetail {
    private Integer rfqDetailId;
    private Integer rfqId;
    private Integer productId;
    private Integer quantity;
    private BigDecimal suggestPrice; // Giá mong muốn
    private BigDecimal actualPrice;  // Giá thực tế từ nhà cung cấp
    
    // Constructor cũ để tương thích
    public RfqDetail(Integer rfqDetailId, Integer rfqId, Integer productId, Integer quantity) {
        this.rfqDetailId = rfqDetailId;
        this.rfqId = rfqId;
        this.productId = productId;
        this.quantity = quantity;
        this.suggestPrice = BigDecimal.ZERO;
        this.actualPrice = BigDecimal.ZERO;
    }
} 