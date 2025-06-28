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
public class StockOutwardDetail {
    private Integer outwardDetailId;
    private Integer stockOutwardId;
    private Integer productId;
    private Integer quantityShipped;
    
    // Thông tin chi tiết để hiển thị (không có trong DB)
    private String productCode;
    private String productName;
    private String unit;
} 