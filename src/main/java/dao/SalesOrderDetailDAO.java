package dao;

import context.DBContext;
import model.SalesOrderDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class SalesOrderDetailDAO extends DBContext implements I_DAO<SalesOrderDetail> {

    @Override
    public List<SalesOrderDetail> findAll() {
        List<SalesOrderDetail> list = new ArrayList<>();
        String sql = "SELECT order_detail_id, sales_order_id, product_id, quantity_ordered, unit_sale_price FROM salesorderdetails";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return list;
    }

    @Override
    public boolean update(SalesOrderDetail detail) {
        String sql = "UPDATE salesorderdetails SET sales_order_id = ?, product_id = ?, quantity_ordered = ?, unit_sale_price = ? WHERE order_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getSalesOrderId());
            statement.setInt(2, detail.getProductId());
            statement.setInt(3, detail.getQuantityOrdered());
            statement.setBigDecimal(4, detail.getUnitSalePrice());
            statement.setInt(5, detail.getOrderDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(SalesOrderDetail detail) {
        String sql = "DELETE FROM salesorderdetails WHERE order_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, detail.getOrderDetailId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public int insert(SalesOrderDetail detail) {
        String sql = "INSERT INTO salesorderdetails (sales_order_id, product_id, quantity_ordered, unit_sale_price) VALUES (?, ?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, detail.getSalesOrderId());
            statement.setInt(2, detail.getProductId());
            statement.setInt(3, detail.getQuantityOrdered());
            statement.setBigDecimal(4, detail.getUnitSalePrice());
            
            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating sales order detail failed, no rows affected.");
            }
            
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating sales order detail failed, no ID obtained.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public SalesOrderDetail getFromResultSet(ResultSet rs) throws SQLException {
        SalesOrderDetail detail = new SalesOrderDetail();
        detail.setOrderDetailId(rs.getInt("order_detail_id"));
        detail.setSalesOrderId(rs.getInt("sales_order_id"));
        detail.setProductId(rs.getInt("product_id"));
        detail.setQuantityOrdered(rs.getInt("quantity_ordered"));
        detail.setUnitSalePrice(rs.getBigDecimal("unit_sale_price"));
        return detail;
    }

    @Override
    public SalesOrderDetail findById(Integer id) {
        String sql = "SELECT order_detail_id, sales_order_id, product_id, quantity_ordered, unit_sale_price FROM salesorderdetails WHERE order_detail_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return null;
    }

    // Find details by sales order ID
    public List<SalesOrderDetail> findBySalesOrderId(Integer salesOrderId) {
        List<SalesOrderDetail> list = new ArrayList<>();
        String sql = "SELECT order_detail_id, sales_order_id, product_id, quantity_ordered, unit_sale_price FROM salesorderdetails WHERE sales_order_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, salesOrderId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return list;
    }

    // Delete all details by sales order ID
    public boolean deleteBySalesOrderId(Integer salesOrderId) {
        String sql = "DELETE FROM salesorderdetails WHERE sales_order_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, salesOrderId);
            return statement.executeUpdate() >= 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Insert multiple details for an order
    public boolean insertDetails(List<SalesOrderDetail> details) {
        String sql = "INSERT INTO salesorderdetails (sales_order_id, product_id, quantity_ordered, unit_sale_price) VALUES (?, ?, ?, ?)";
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            statement = conn.prepareStatement(sql);
            
            for (SalesOrderDetail detail : details) {
                statement.setInt(1, detail.getSalesOrderId());
                statement.setInt(2, detail.getProductId());
                statement.setInt(3, detail.getQuantityOrdered());
                statement.setBigDecimal(4, detail.getUnitSalePrice());
                statement.addBatch();
            }
            
            int[] results = statement.executeBatch();
            conn.commit();
            
            // Check if all inserts were successful
            for (int result : results) {
                if (result == Statement.EXECUTE_FAILED) {
                    return false;
                }
            }
            return true;
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            close();
        }
    }

    // Get details with product information
    public List<SalesOrderDetail> findBySalesOrderIdWithProductInfo(Integer salesOrderId) {
        List<SalesOrderDetail> list = new ArrayList<>();
        String sql = "SELECT sod.order_detail_id, sod.sales_order_id, sod.product_id, sod.quantity_ordered, sod.unit_sale_price " +
                     "FROM salesorderdetails sod " +
                     "INNER JOIN products p ON sod.product_id = p.product_id " +
                     "WHERE sod.sales_order_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, salesOrderId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return list;
    }

    // Get details with complete product information - Enhanced version
    public List<SalesOrderDetailWithProduct> findBySalesOrderIdWithCompleteProductInfo(Integer salesOrderId) {
        List<SalesOrderDetailWithProduct> list = new ArrayList<>();
        String sql = "SELECT sod.order_detail_id, sod.sales_order_id, sod.product_id, sod.quantity_ordered, sod.unit_sale_price, " +
                     "p.product_code, p.product_name, p.description, p.unit, p.quantity as stock_quantity, " +
                     "p.purchase_price, p.sale_price, p.is_active " +
                     "FROM salesorderdetails sod " +
                     "INNER JOIN products p ON sod.product_id = p.product_id " +
                     "WHERE sod.sales_order_id = ? " +
                     "ORDER BY sod.order_detail_id";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, salesOrderId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                SalesOrderDetailWithProduct detail = new SalesOrderDetailWithProduct();
                
                // Sales order detail information
                detail.setOrderDetailId(resultSet.getInt("order_detail_id"));
                detail.setSalesOrderId(resultSet.getInt("sales_order_id"));
                detail.setProductId(resultSet.getInt("product_id"));
                detail.setQuantityOrdered(resultSet.getInt("quantity_ordered"));
                detail.setUnitSalePrice(resultSet.getBigDecimal("unit_sale_price"));
                
                // Product information
                detail.setProductCode(resultSet.getString("product_code"));
                detail.setProductName(resultSet.getString("product_name"));
                detail.setDescription(resultSet.getString("description"));
                detail.setUnit(resultSet.getString("unit"));
                detail.setStockQuantity(resultSet.getInt("stock_quantity"));
                detail.setPurchasePrice(resultSet.getFloat("purchase_price"));
                detail.setSalePrice(resultSet.getFloat("sale_price"));
                detail.setIsActive(resultSet.getBoolean("is_active"));
                
                list.add(detail);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return list;
    }

    // Inner class to hold sales order detail with product information
    public static class SalesOrderDetailWithProduct {
        // Sales order detail fields
        private Integer orderDetailId;
        private Integer salesOrderId;
        private Integer productId;
        private Integer quantityOrdered;
        private BigDecimal unitSalePrice;
        
        // Product fields
        private String productCode;
        private String productName;
        private String description;
        private String unit;
        private Integer stockQuantity;
        private Float purchasePrice;
        private Float salePrice;
        private Boolean isActive;
        
        // Constructors
        public SalesOrderDetailWithProduct() {}
        
        // Getters and Setters
        public Integer getOrderDetailId() { return orderDetailId; }
        public void setOrderDetailId(Integer orderDetailId) { this.orderDetailId = orderDetailId; }
        
        public Integer getSalesOrderId() { return salesOrderId; }
        public void setSalesOrderId(Integer salesOrderId) { this.salesOrderId = salesOrderId; }
        
        public Integer getProductId() { return productId; }
        public void setProductId(Integer productId) { this.productId = productId; }
        
        public Integer getQuantityOrdered() { return quantityOrdered; }
        public void setQuantityOrdered(Integer quantityOrdered) { this.quantityOrdered = quantityOrdered; }
        
        public BigDecimal getUnitSalePrice() { return unitSalePrice; }
        public void setUnitSalePrice(BigDecimal unitSalePrice) { this.unitSalePrice = unitSalePrice; }
        
        public String getProductCode() { return productCode; }
        public void setProductCode(String productCode) { this.productCode = productCode; }
        
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        
        public String getUnit() { return unit; }
        public void setUnit(String unit) { this.unit = unit; }
        
        public Integer getStockQuantity() { return stockQuantity; }
        public void setStockQuantity(Integer stockQuantity) { this.stockQuantity = stockQuantity; }
        
        public Float getPurchasePrice() { return purchasePrice; }
        public void setPurchasePrice(Float purchasePrice) { this.purchasePrice = purchasePrice; }
        
        public Float getSalePrice() { return salePrice; }
        public void setSalePrice(Float salePrice) { this.salePrice = salePrice; }
        
        public Boolean getIsActive() { return isActive; }
        public void setIsActive(Boolean isActive) { this.isActive = isActive; }
        
        // Convenience methods
        public BigDecimal getTotalPrice() {
            if (quantityOrdered != null && unitSalePrice != null) {
                return unitSalePrice.multiply(BigDecimal.valueOf(quantityOrdered));
            }
            return BigDecimal.ZERO;
        }
        
        public boolean isStockSufficient() {
            if (stockQuantity != null && quantityOrdered != null) {
                return stockQuantity >= quantityOrdered;
            }
            return false;
        }
    }
} 