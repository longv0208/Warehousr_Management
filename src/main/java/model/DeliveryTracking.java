package model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.sql.Timestamp;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeliveryTracking {
    private Integer trackingId;
    private int salesOrderId;
    private String status;
    private String location;
    private String notes;
    private Integer updatedBy;
    private Timestamp updateTime;
} 