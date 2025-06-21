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
public class PurchaseRequestDetail {
    private Integer requestDetailId; // Khớp với DB: request_detail_id
    private Integer requestId;
    private Integer productId;
    private Integer requestedQuantity; // Khớp với DB: requested_quantity
    private Integer suggestedSupplierId; // Khớp với DB: suggested_supplier_id
    private String notes; // Khớp với DB: notes
    
    // Thông tin chi tiết (để hiển thị - không có trong DB)
    private String productName;
    private String productCode;
    private String unit;
    private Float purchasePrice;
    private String supplierName;
} 