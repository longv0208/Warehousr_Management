package model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class SalesOrder {
    private Integer salesOrderId;
    private String orderCode;
    private String customerName;
    private String customerPhone; // Customer phone number
    private Integer userId;
    private Date orderDate;
    private String status; // 'pending_stock_check','awaiting_shipment','shipped','completed','cancelled'
    private String priority; // 'high', 'medium', 'low' - order priority
    private String notes;
    private Timestamp createdAt;
    
    // Thông tin chi tiết (để hiển thị - không có trong DB)
    private User user; // User information for display
    private List<SalesOrderDetail> details; // Order details for modal display
} 