package dao;

import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.DeliveryTracking;

public class DeliveryTrackingDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(DeliveryTrackingDAO.class.getName());

    public static class DeliveryTrackingInfo {
        private int salesOrderId;
        private String orderCode;
        private String customerName;
        private String lastStatus;
        private Timestamp lastUpdateTime;
        private String lastLocation;

        // Getters and Setters
        public int getSalesOrderId() { return salesOrderId; }
        public void setSalesOrderId(int salesOrderId) { this.salesOrderId = salesOrderId; }
        public String getOrderCode() { return orderCode; }
        public void setOrderCode(String orderCode) { this.orderCode = orderCode; }
        public String getCustomerName() { return customerName; }
        public void setCustomerName(String customerName) { this.customerName = customerName; }
        public String getLastStatus() { return lastStatus; }
        public void setLastStatus(String lastStatus) { this.lastStatus = lastStatus; }
        public Timestamp getLastUpdateTime() { return lastUpdateTime; }
        public void setLastUpdateTime(Timestamp lastUpdateTime) { this.lastUpdateTime = lastUpdateTime; }
        public String getLastLocation() { return lastLocation; }
        public void setLastLocation(String lastLocation) { this.lastLocation = lastLocation; }
    }

    public boolean insert(DeliveryTracking tracking) {
        String sql = "INSERT INTO delivery_tracking (sales_order_id, status, location, notes, updated_by, update_time) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, tracking.getSalesOrderId());
            statement.setString(2, tracking.getStatus());
            statement.setString(3, tracking.getLocation());
            statement.setString(4, tracking.getNotes());
            if (tracking.getUpdatedBy() != null) {
                statement.setInt(5, tracking.getUpdatedBy());
            } else {
                statement.setNull(5, java.sql.Types.INTEGER);
            }

            if (tracking.getUpdateTime() != null) {
                statement.setTimestamp(6, tracking.getUpdateTime());
            } else {
                statement.setTimestamp(6, Timestamp.from(Instant.now()));
            }
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting delivery tracking", ex);
            return false;
        } finally {
            close();
        }
    }

    public List<DeliveryTracking> findBySalesOrderId(int salesOrderId) {
        List<DeliveryTracking> history = new ArrayList<>();
        String sql = "SELECT * FROM delivery_tracking WHERE sales_order_id = ? ORDER BY update_time DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, salesOrderId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                history.add(new DeliveryTracking(
                        resultSet.getInt("tracking_id"),
                        resultSet.getInt("sales_order_id"),
                        resultSet.getString("status"),
                        resultSet.getString("location"),
                        resultSet.getString("notes"),
                        (Integer) resultSet.getObject("updated_by"),
                        resultSet.getTimestamp("update_time")
                ));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding delivery tracking by sales order ID", ex);
        } finally {
            close();
        }
        return history;
    }

    public List<DeliveryTrackingInfo> getAllDeliveryTrackingInfo() {
        List<DeliveryTrackingInfo> list = new ArrayList<>();
        String sql = "WITH LatestTracking AS ( " +
                     "    SELECT *, ROW_NUMBER() OVER(PARTITION BY sales_order_id ORDER BY update_time DESC) as rn " +
                     "    FROM delivery_tracking " +
                     ") " +
                     "SELECT so.sales_order_id, so.order_code, so.customer_name, lt.status, lt.update_time, lt.location " +
                     "FROM salesorders so " +
                     "JOIN LatestTracking lt ON so.sales_order_id = lt.sales_order_id " +
                     "WHERE lt.rn = 1 " +
                     "ORDER BY lt.update_time DESC";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DeliveryTrackingInfo info = new DeliveryTrackingInfo();
                info.setSalesOrderId(rs.getInt("sales_order_id"));
                info.setOrderCode(rs.getString("order_code"));
                info.setCustomerName(rs.getString("customer_name"));
                info.setLastStatus(rs.getString("status"));
                info.setLastUpdateTime(rs.getTimestamp("update_time"));
                info.setLastLocation(rs.getString("location"));
                list.add(info);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
} 