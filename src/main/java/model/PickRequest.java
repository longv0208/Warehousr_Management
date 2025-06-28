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
public class PickRequest {
    private Integer pickRequestId;
    private String pickRequestCode;
    private Integer salesOrderId;
    private Integer userIdRequester;
    private Integer warehouseId;
    private Timestamp requestDate;
    private String status; // pending, in_progress, completed, cancelled
    private String notes;
    private Timestamp createdAt;
    
    // Thông tin chi tiết để hiển thị (không có trong DB)
    private String requestedByName;
    private String warehouseName;
    private String salesOrderCode;
    private String customerName;
} 