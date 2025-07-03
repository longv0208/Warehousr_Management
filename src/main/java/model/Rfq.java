package model;

import lombok.*;
import java.sql.Date;
import java.sql.Timestamp;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Rfq {
    private Integer rfqId;
    private String rfqCode;
    private Date expectedDeliveryDate;
    private Integer providerId;
    private Integer warehouseId;
    private Integer userIdRequester;
    private String status; // pending, sent, approved, rejected, completed
    private String note;
    private Timestamp createdAt;
} 