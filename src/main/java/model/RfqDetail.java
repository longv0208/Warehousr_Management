package model;

import lombok.*;

@ToString
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class RfqDetail {
    private Integer rfqDetailId;
    private Integer rfqId;
    private Integer productId;
    private Integer quantity;
} 