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
public class SalesQuotationDetail {
    private Integer quotationDetailId;
    private Integer quotationId;
    private Integer productId;
    private Integer quantity;
    private BigDecimal unitPrice;
    
    // Thông tin chi tiết sản phẩm (để hiển thị - không có trong DB)
    private Product product; // Product information for display
}
