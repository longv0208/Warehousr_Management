package model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.sql.Timestamp;
import java.time.LocalDateTime;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class StockInward {
    private Integer stockInwardId;
    private String inwardCode;
    private Integer supplierId;
    private Integer userId;
    private Integer warehouseId;
    private Integer purchaseRequestId;
    private LocalDateTime inwardDate;
    private String notes;
    private Timestamp createdAt;
    private Integer poId;
    
    // Thông tin chi tiết để hiển thị (không có trong DB)
    private String supplierName;
    private String userFullName;
    private String warehouseName;
} 