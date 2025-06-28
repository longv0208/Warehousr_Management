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
public class StockOutward {
    private Integer stockOutwardId;
    private String outwardCode;
    private Integer salesOrderId;
    private Integer userId;
    private Integer warehouseId;
    private Timestamp outwardDate;
    private String reason; // sale, internal_transfer, damage, loss, other
    private String notes;
    private Timestamp createdAt;
    private Integer pickRequestId; // Liên kết với pick request
    
    // Thông tin chi tiết để hiển thị (không có trong DB)
    private String userFullName;
    private String warehouseName;
    private String salesOrderCode;
    private String customerName;
    private String pickRequestCode;
} 