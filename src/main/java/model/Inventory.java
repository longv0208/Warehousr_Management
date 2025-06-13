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
public class Inventory {
    private Integer inventoryId;
    private Integer productId;
    private Integer quantityOnHand;
    private Timestamp lastUpdated;
} 