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
public class SalesQuotation {
    private Integer quotationId;
    private String quotationCode;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String customerAddress;
    private Integer userId;
    private Date quotationDate;
    private Date validUntil;
    private String status; // draft, sent, approved, rejected
    private String notes;
    private Integer warehouseId;
    private Timestamp createdAt;
}
