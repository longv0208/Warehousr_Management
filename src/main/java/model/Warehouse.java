package model;

import java.sql.Timestamp;

public class Warehouse {
    private Integer warehouseId;
    private String warehouseName;
    private String address;
    private Timestamp createdAt;

    // Constructors
    public Warehouse() {}

    public Warehouse(Integer warehouseId, String warehouseName, String address, Timestamp createdAt) {
        this.warehouseId = warehouseId;
        this.warehouseName = warehouseName;
        this.address = address;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Integer getWarehouseId() {
        return warehouseId;
    }

    public void setWarehouseId(Integer warehouseId) {
        this.warehouseId = warehouseId;
    }

    public String getWarehouseName() {
        return warehouseName;
    }

    public void setWarehouseName(String warehouseName) {
        this.warehouseName = warehouseName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Warehouse{" +
                "warehouseId=" + warehouseId +
                ", warehouseName='" + warehouseName + '\'' +
                ", address='" + address + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
} 