package utils;

import dao.ActivityLogDAO;
import model.ActivityLog;
import java.sql.Timestamp;

public class ActivityLogger {

    private static final ActivityLogDAO activityLogDAO = new ActivityLogDAO();

    // Log CREATE action
    public static void logCreate(Integer userId, String entityType, Integer entityId, 
                               String newValue, String note) {
        ActivityLog log = new ActivityLog();
        log.setUserId(userId);
        log.setActionType("CREATE");
        log.setEntityType(entityType);
        log.setEntityId(entityId);
        log.setOldValue(null);
        log.setNewValue(newValue);
        log.setNote(note);
        log.setTimestamp(new Timestamp(System.currentTimeMillis()));
        
        activityLogDAO.insert(log);
    }

    // Log UPDATE action
    public static void logUpdate(Integer userId, String entityType, Integer entityId, 
                               String oldValue, String newValue, String note) {
        ActivityLog log = new ActivityLog();
        log.setUserId(userId);
        log.setActionType("UPDATE");
        log.setEntityType(entityType);
        log.setEntityId(entityId);
        log.setOldValue(oldValue);
        log.setNewValue(newValue);
        log.setNote(note);
        log.setTimestamp(new Timestamp(System.currentTimeMillis()));
        
        activityLogDAO.insert(log);
    }

    // Log DELETE action
    public static void logDelete(Integer userId, String entityType, Integer entityId, 
                               String oldValue, String note) {
        ActivityLog log = new ActivityLog();
        log.setUserId(userId);
        log.setActionType("DELETE");
        log.setEntityType(entityType);
        log.setEntityId(entityId);
        log.setOldValue(oldValue);
        log.setNewValue(null);
        log.setNote(note);
        log.setTimestamp(new Timestamp(System.currentTimeMillis()));
        
        activityLogDAO.insert(log);
    }

    // Log ADJUST action (for inventory adjustments)
    public static void logAdjust(Integer userId, String entityType, Integer entityId, 
                               String oldValue, String newValue, String note) {
        ActivityLog log = new ActivityLog();
        log.setUserId(userId);
        log.setActionType("ADJUST");
        log.setEntityType(entityType);
        log.setEntityId(entityId);
        log.setOldValue(oldValue);
        log.setNewValue(newValue);
        log.setNote(note);
        log.setTimestamp(new Timestamp(System.currentTimeMillis()));
        
        activityLogDAO.insert(log);
    }

    // Log LOGIN action
    public static void logLogin(Integer userId, String note) {
        ActivityLog log = new ActivityLog();
        log.setUserId(userId);
        log.setActionType("LOGIN");
        log.setEntityType("USER_SESSION");
        log.setEntityId(userId);
        log.setOldValue(null);
        log.setNewValue("LOGGED_IN");
        log.setNote(note);
        log.setTimestamp(new Timestamp(System.currentTimeMillis()));
        
        activityLogDAO.insert(log);
    }

    // Log LOGOUT action
    public static void logLogout(Integer userId, String note) {
        ActivityLog log = new ActivityLog();
        log.setUserId(userId);
        log.setActionType("LOGOUT");
        log.setEntityType("USER_SESSION");
        log.setEntityId(userId);
        log.setOldValue("LOGGED_IN");
        log.setNewValue("LOGGED_OUT");
        log.setNote(note);
        log.setTimestamp(new Timestamp(System.currentTimeMillis()));
        
        activityLogDAO.insert(log);
    }

    // Generic log method
    public static void log(Integer userId, String actionType, String entityType, Integer entityId,
                         String oldValue, String newValue, String note) {
        ActivityLog log = new ActivityLog();
        log.setUserId(userId);
        log.setActionType(actionType);
        log.setEntityType(entityType);
        log.setEntityId(entityId);
        log.setOldValue(oldValue);
        log.setNewValue(newValue);
        log.setNote(note);
        log.setTimestamp(new Timestamp(System.currentTimeMillis()));
        
        activityLogDAO.insert(log);
    }

    // Utility methods for common entity types
    public static void logProductAction(Integer userId, String actionType, Integer productId, 
                                      String oldValue, String newValue, String note) {
        log(userId, actionType, "PRODUCT", productId, oldValue, newValue, note);
    }

    public static void logInventoryAction(Integer userId, String actionType, Integer inventoryId, 
                                        String oldValue, String newValue, String note) {
        log(userId, actionType, "INVENTORY", inventoryId, oldValue, newValue, note);
    }

    public static void logStockTakeAction(Integer userId, String actionType, Integer stockTakeId, 
                                        String oldValue, String newValue, String note) {
        log(userId, actionType, "STOCK_TAKE", stockTakeId, oldValue, newValue, note);
    }

    public static void logSalesOrderAction(Integer userId, String actionType, Integer salesOrderId, 
                                         String oldValue, String newValue, String note) {
        log(userId, actionType, "SALES_ORDER", salesOrderId, oldValue, newValue, note);
    }

    public static void logPurchaseRequestAction(Integer userId, String actionType, Integer purchaseRequestId, 
                                              String oldValue, String newValue, String note) {
        log(userId, actionType, "PURCHASE_REQUEST", purchaseRequestId, oldValue, newValue, note);
    }

    public static void logUserAction(Integer userId, String actionType, Integer targetUserId, 
                                   String oldValue, String newValue, String note) {
        log(userId, actionType, "USER", targetUserId, oldValue, newValue, note);
    }

    public static void logSupplierAction(Integer userId, String actionType, Integer supplierId, 
                                       String oldValue, String newValue, String note) {
        log(userId, actionType, "SUPPLIER", supplierId, oldValue, newValue, note);
    }

    public static void logWarehouseAction(Integer userId, String actionType, Integer warehouseId, 
                                        String oldValue, String newValue, String note) {
        log(userId, actionType, "WAREHOUSE", warehouseId, oldValue, newValue, note);
    }

    public static void logCategoryAction(Integer userId, String actionType, Integer categoryId, 
                                       String oldValue, String newValue, String note) {
        log(userId, actionType, "CATEGORY", categoryId, oldValue, newValue, note);
    }
} 