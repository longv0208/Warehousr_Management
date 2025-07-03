package model;

import lombok.*;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

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

    public String getFormattedOrderDate() {
        if (orderDate == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        return orderDate.format(formatter);
    }
} 