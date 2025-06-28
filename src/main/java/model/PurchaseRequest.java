package model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.sql.Timestamp;
import java.util.List;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class PurchaseRequest {
    private Integer requestId;
    private String requestCode;
    private Integer userIdRequester; // Khớp với DB: user_id_requester
    private Integer warehouseId; // Kho nhập hàng
    private Timestamp requestDate;
    private String status; // pending_approval, approved, rejected, ordered, partially_received, received
    private String notes;
    private Timestamp createdAt;
    
    // Thông tin chi tiết (để hiển thị - không có trong DB)
    private String requestedByName;
    private String warehouseName;
    private String approvedByName; // Tên người duyệt
    private Timestamp approvedDate; // Ngày duyệt
    
    // Thông tin nhà cung cấp chính (từ detail đầu tiên)
    private Supplier supplier;
    
    // Chi tiết yêu cầu mua hàng
    private List<PurchaseRequestDetail> details;
} 