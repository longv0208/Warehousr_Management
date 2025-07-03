package model;

import lombok.*;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDateTime;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class PurchaseOrder {
    private Integer poId;
    private Integer rfqId;
    private String poCode;
    private Integer providerId;
    private Integer warehouseId;
    private LocalDateTime orderDate;
    private Date expectedDeliveryDate;
    private String status; // pending, approved, completed, cancelled
    private Timestamp createdAt;
} 