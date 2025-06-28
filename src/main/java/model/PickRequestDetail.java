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
public class PickRequestDetail {
    private Integer pickDetailId;
    private Integer pickRequestId;
    private Integer productId;
    private Integer quantityRequested;
    private Integer quantityPicked;
    private String location;
    
    // Thông tin chi tiết để hiển thị (không có trong DB)
    private String productCode;
    private String productName;
    private String unit;
    private Integer availableQuantity;
} 