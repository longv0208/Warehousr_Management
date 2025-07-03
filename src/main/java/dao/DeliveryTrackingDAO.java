package dao;

import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.DeliveryTracking;
import model.SalesOrder;

public class DeliveryTrackingDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(DeliveryTrackingDAO.class.getName());
    private PreparedStatement statement = null;

    public int insert(DeliveryTracking tracking) {
        String sql = "INSERT INTO delivery_tracking (sales_order_id, status, note, updated_at) VALUES (?, ?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, tracking.getSalesOrderId());
            statement.setString(2, tracking.getStatus());
            statement.setString(3, tracking.getNotes());
            statement.setTimestamp(4, Timestamp.from(Instant.now()));

            int affectedRows = statement.executeUpdate();
            if (affectedRows > 0) {
                resultSet = statement.getGeneratedKeys();
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting delivery tracking", ex);
        } finally {
            close();
        }
        return -1;
    }

    public List<DeliveryTracking> findBySalesOrderId(int salesOrderId) {
        List<DeliveryTracking> history = new ArrayList<>();
        String sql = "SELECT * FROM delivery_tracking WHERE sales_order_id = ? ORDER BY updated_at DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, salesOrderId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                history.add(DeliveryTracking.builder()
                        .trackingId(resultSet.getInt("tracking_id"))
                        .salesOrderId(resultSet.getInt("sales_order_id"))
                        .status(resultSet.getString("status"))
                        .notes(resultSet.getString("note"))
                        .updatedAt(resultSet.getTimestamp("updated_at"))
                        .build());
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding delivery tracking by sales order ID", ex);
        } finally {
            close();
        }
        return history;
    }

    public List<DeliveryTracking> findAllWithSalesOrderDetails() {
        List<DeliveryTracking> deliveries = new ArrayList<>();
        // Get the latest tracking entry for each sales order that is currently being shipped or has failed
        String sql = "WITH LatestTracking AS ("
                + "    SELECT dt.*, ROW_NUMBER() OVER(PARTITION BY dt.sales_order_id ORDER BY dt.updated_at DESC) as rn"
                + "    FROM delivery_tracking dt"
                + ")"
                + "SELECT lt.*, so.order_code, so.customer_name "
                + "FROM LatestTracking lt "
                + "JOIN salesorders so ON lt.sales_order_id = so.sales_order_id "
                + "WHERE lt.rn = 1 AND (so.status = 'shipped' OR so.status = 'failed' OR so.status = 'completed') "
                + "ORDER BY lt.updated_at DESC";

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                SalesOrder so = SalesOrder.builder()
                        .orderCode(resultSet.getString("order_code"))
                        .customerName(resultSet.getString("customer_name"))
                        .build();
                
                DeliveryTracking dt = DeliveryTracking.builder()
                        .trackingId(resultSet.getInt("tracking_id"))
                        .salesOrderId(resultSet.getInt("sales_order_id"))
                        .status(resultSet.getString("status"))
                        .notes(resultSet.getString("note"))
                        .updatedAt(resultSet.getTimestamp("updated_at"))
                        .salesOrder(so) // Embed sales order info
                        .build();
                
                deliveries.add(dt);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding all deliveries with details", e);
        } finally {
            close();
        }
        return deliveries;
    }
} 