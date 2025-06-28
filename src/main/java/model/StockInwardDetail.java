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
public class StockInwardDetail {
    private Integer inwardDetailId;
    private Integer stockInwardId;
    private Integer productId;
    private Integer quantityReceived;
    private BigDecimal unitPurchasePrice;
    
    // Thông tin chi tiết để hiển thị (không có trong DB)
    private String productCode;
    private String productName;
    private String unit;
} 