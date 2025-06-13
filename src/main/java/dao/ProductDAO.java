package dao;

import context.DBContext;
import dao.I_DAO;
import model.Product;
import model.Category;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ProductDAO extends DBContext implements I_DAO<Product> {

    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());

    @Override
    public Product getFromResultSet(ResultSet rs) throws SQLException {
        return Product.builder()
                .productId(rs.getInt("product_id"))
                .productCode(rs.getString("product_code"))
                .productName(rs.getString("product_name"))
                .description(rs.getString("description"))
                .unit(rs.getString("unit"))
                .purchasePrice(rs.getFloat("purchase_price"))
                .salePrice(rs.getFloat("sale_price"))
                .supplierId(rs.getObject("supplier_id") != null ? rs.getInt("supplier_id") : null)
                .lowStockThreshold(rs.getInt("low_stock_threshold"))
                .createdAt(rs.getTimestamp("created_at"))
                .updatedAt(rs.getTimestamp("updated_at"))
                .isActive(rs.getBoolean("is_active"))
                .build();
    }

    public List<Product> findAll() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products";
        try {
            conn = getConnection(); // Rule: always open conn
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                products.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all products", ex);
        } finally {
            close(); // Rule: always close conn
        }
        return products;
    }

    public List<Product> findActiveProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE is_active = true ORDER BY product_name";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                products.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting active products", ex);
        } finally {
            close();
        }
        return products;
    }

    @Override
    public int insert(Product product) {
        String sql = "INSERT INTO products (product_code, product_name, description, unit, purchase_price, "
                + "sale_price, supplier_id, low_stock_threshold, is_active, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, product.getProductCode());
            statement.setString(2, product.getProductName());
            statement.setString(3, product.getDescription());
            statement.setString(4, product.getUnit());
            statement.setFloat(5, product.getPurchasePrice());
            statement.setFloat(6, product.getSalePrice());
            if (product.getSupplierId() != null) {
                statement.setInt(7, product.getSupplierId());
            } else {
                statement.setNull(7, Types.INTEGER);
            }
            statement.setInt(8, product.getLowStockThreshold());
            statement.setBoolean(9, product.getIsActive());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating product failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1); // Return generated product_id
            } else {
                throw new SQLException("Creating product failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting product: " + product.toString(), ex);
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(Product product) {
        String sql = "UPDATE products SET product_code = ?, product_name = ?, description = ?, unit = ?, "
                + "purchase_price = ?, sale_price = ?, supplier_id = ?, low_stock_threshold = ?, "
                + "is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, product.getProductCode());
            statement.setString(2, product.getProductName());
            statement.setString(3, product.getDescription());
            statement.setString(4, product.getUnit());
            statement.setFloat(5, product.getPurchasePrice());
            statement.setFloat(6, product.getSalePrice());
            if (product.getSupplierId() != null) {
                statement.setInt(7, product.getSupplierId());
            } else {
                statement.setNull(7, Types.INTEGER);
            }
            statement.setInt(8, product.getLowStockThreshold());
            statement.setBoolean(9, product.getIsActive());
            statement.setInt(10, product.getProductId());

            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating product: " + product.toString(), ex);
            return false;
        } finally {
            close();
        }
    }

    public boolean delete(int productId) {
        // This is a hard delete. Consider soft delete (is_active = false) if needed.
        String sql = "DELETE FROM products WHERE product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, productId);
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting product ID: " + productId, ex);
            return false;
        } finally {
            close();
        }
    }

    public List<Product> findProducts(String searchTerm, Integer supplierId, Integer categoryId, Boolean isActive, Float minPurchasePrice, Float minSalePrice, int page, int pageSize) {
        List<Product> products = new ArrayList<>();
        StringBuilder sqlBuilder = new StringBuilder("SELECT DISTINCT p.* FROM products p");
        
        // Join with category-product table if categoryId filter is used
        if (categoryId != null) {
            sqlBuilder.append(" LEFT JOIN `category-product` cp ON p.product_id = cp.product_id");
        }
        
        sqlBuilder.append(" WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (searchTerm != null && !searchTerm.isEmpty()) {
            sqlBuilder.append(" AND (p.product_name LIKE ? OR p.product_code LIKE ? OR p.description LIKE ?)");
            String likePattern = "%" + searchTerm + "%";
            params.add(likePattern);
            params.add(likePattern);
            params.add(likePattern);
        }
        if (supplierId != null) {
            sqlBuilder.append(" AND p.supplier_id = ?");
            params.add(supplierId);
        }
        if (categoryId != null) {
            sqlBuilder.append(" AND cp.category_id = ?");
            params.add(categoryId.toString());
        }
        if (isActive != null) {
            sqlBuilder.append(" AND p.is_active = ?");
            params.add(isActive);
        }
        if (minPurchasePrice != null) {
            sqlBuilder.append(" AND p.purchase_price >= ?");
            params.add(minPurchasePrice);
        }
        if (minSalePrice != null) {
            sqlBuilder.append(" AND p.sale_price >= ?");
            params.add(minSalePrice);
        }

        sqlBuilder.append(" ORDER BY p.product_name LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sqlBuilder.toString());
            int paramIndex = 1;
            if (searchTerm != null && !searchTerm.isEmpty()) {
                String likePattern = "%" + searchTerm + "%";
                statement.setString(paramIndex++, likePattern);
                statement.setString(paramIndex++, likePattern);
                statement.setString(paramIndex++, likePattern);
            }
            if (supplierId != null) {
                statement.setInt(paramIndex++, supplierId);
            }
            if (categoryId != null) {
                statement.setString(paramIndex++, categoryId.toString());
            }
            if (isActive != null) {
                statement.setBoolean(paramIndex++, isActive);
            }
            if (minPurchasePrice != null) {
                statement.setFloat(paramIndex++, minPurchasePrice);
            }
            if (minSalePrice != null) {
                statement.setFloat(paramIndex++, minSalePrice);
            }
            // For LIMIT and OFFSET, which are at the end of params list
            statement.setInt(paramIndex++, pageSize);
            statement.setInt(paramIndex++, (page - 1) * pageSize);

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                products.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding products with filters", ex);
        } finally {
            close();
        }
        return products;
    }

    public int getTotalFilteredProducts(String searchTerm, Integer supplierId, Integer categoryId, Boolean isActive, Float minPurchasePrice, Float minSalePrice) {
        StringBuilder sqlBuilder = new StringBuilder("SELECT COUNT(DISTINCT p.product_id) FROM products p");
        
        // Join with category-product table if categoryId filter is used
        if (categoryId != null) {
            sqlBuilder.append(" LEFT JOIN `category-product` cp ON p.product_id = cp.product_id");
        }
        
        sqlBuilder.append(" WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (searchTerm != null && !searchTerm.isEmpty()) {
            sqlBuilder.append(" AND (p.product_name LIKE ? OR p.product_code LIKE ? OR p.description LIKE ?)");
            String likePattern = "%" + searchTerm + "%";
            params.add(likePattern);
            params.add(likePattern);
            params.add(likePattern);
        }
        if (supplierId != null) {
            sqlBuilder.append(" AND p.supplier_id = ?");
            params.add(supplierId);
        }
        if (categoryId != null) {
            sqlBuilder.append(" AND cp.category_id = ?");
            params.add(categoryId.toString());
        }
        if (isActive != null) {
            sqlBuilder.append(" AND p.is_active = ?");
            params.add(isActive);
        }
        if (minPurchasePrice != null) {
            sqlBuilder.append(" AND p.purchase_price >= ?");
            params.add(minPurchasePrice);
        }
        if (minSalePrice != null) {
            sqlBuilder.append(" AND p.sale_price >= ?");
            params.add(minSalePrice);
        }

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sqlBuilder.toString());
            int paramIndexCount = 1;
            if (searchTerm != null && !searchTerm.isEmpty()) {
                String likePattern = "%" + searchTerm + "%";
                statement.setString(paramIndexCount++, likePattern);
                statement.setString(paramIndexCount++, likePattern);
                statement.setString(paramIndexCount++, likePattern);
            }
            if (supplierId != null) {
                statement.setInt(paramIndexCount++, supplierId);
            }
            if (categoryId != null) {
                statement.setString(paramIndexCount++, categoryId.toString());
            }
            if (isActive != null) {
                statement.setBoolean(paramIndexCount++, isActive);
            }
            if (minPurchasePrice != null) {
                statement.setFloat(paramIndexCount++, minPurchasePrice);
            }
            if (minSalePrice != null) {
                statement.setFloat(paramIndexCount++, minSalePrice);
            }

            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting total filtered products count", ex);
        } finally {
            close();
        }
        return 0;
    }

    @Override
    public boolean delete(Product t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public Product findById(Integer id) {
        String sql = "SELECT * FROM products WHERE product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding product by ID: " + id, ex);
        } finally {
            close();
        }
        return null;
    }

    // Method to get categories for a specific product
    public List<Category> getCategoriesForProduct(int productId) {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT c.* FROM category c " +
                    "JOIN `category-product` cp ON c.id = cp.category_id " +
                    "WHERE cp.product_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, String.valueOf(productId));
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Category category = new Category();
                category.setCategoryId(resultSet.getInt("id"));
                category.setCategoryName(resultSet.getString("name"));
                category.setCreatedAt(resultSet.getTimestamp("created_at"));
                categories.add(category);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting categories for product ID: " + productId, ex);
        } finally {
            close();
        }
        return categories;
    }

    // Method to get next available ID for category-product table
    private int getNextCategoryProductId() {
        String sql = "SELECT COALESCE(MAX(id), 0) + 1 FROM `category-product`";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting next category-product ID", ex);
        } finally {
            close();
        }
        return 1; // Default to 1 if no records found
    }

    // Overloaded method to get next available ID using existing connection (for transactions)
    private int getNextCategoryProductId(java.sql.Connection existingConn) throws SQLException {
        String sql = "SELECT COALESCE(MAX(id), 0) + 1 FROM `category-product`";
        try (java.sql.PreparedStatement stmt = existingConn.prepareStatement(sql);
             java.sql.ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 1; // Default to 1 if no records found
    }

    // Method to add product to category
    public boolean addProductToCategory(int productId, int categoryId) {
        String sql = "INSERT INTO `category-product` (id, product_id, category_id) VALUES (?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, getNextCategoryProductId());
            statement.setString(2, String.valueOf(productId));
            statement.setString(3, String.valueOf(categoryId));
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error adding product to category", ex);
            return false;
        } finally {
            close();
        }
    }

    // Method to remove product from category
    public boolean removeProductFromCategory(int productId, int categoryId) {
        String sql = "DELETE FROM `category-product` WHERE product_id = ? AND category_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, String.valueOf(productId));
            statement.setString(2, String.valueOf(categoryId));
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error removing product from category", ex);
            return false;
        } finally {
            close();
        }
    }

    // Method to update product categories (remove all and add new ones)
    public boolean updateProductCategories(int productId, List<Integer> categoryIds) {
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // First remove all existing categories for this product
            String deleteSql = "DELETE FROM `category-product` WHERE product_id = ?";
            statement = conn.prepareStatement(deleteSql);
            statement.setString(1, String.valueOf(productId));
            statement.executeUpdate();
            
            // Then add new categories
            if (categoryIds != null && !categoryIds.isEmpty()) {
                // Get starting ID for batch insert using existing connection
                int startId = getNextCategoryProductId(conn);
                String insertSql = "INSERT INTO `category-product` (id, product_id, category_id) VALUES (?, ?, ?)";
                statement = conn.prepareStatement(insertSql);
                
                int idCounter = 0;
                for (Integer categoryId : categoryIds) {
                    statement.setInt(1, startId + idCounter);
                    statement.setString(2, String.valueOf(productId));
                    statement.setString(3, String.valueOf(categoryId));
                    statement.addBatch();
                    idCounter++;
                }
                statement.executeBatch();
            }
            
            conn.commit();
            return true;
        } catch (SQLException ex) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", rollbackEx);
            }
            LOGGER.log(Level.SEVERE, "Error updating product categories", ex);
            return false;
        } finally {
            try {
                if (conn != null && !conn.isClosed()) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error resetting auto commit", ex);
            } finally {
                close();
            }
        }
    }

    // Method to get the primary category for a product (first category if multiple)
    public Category getPrimaryCategoryForProduct(int productId) {
        String sql = "SELECT c.* FROM category c " +
                    "JOIN `category-product` cp ON c.id = cp.category_id " +
                    "WHERE cp.product_id = ? LIMIT 1";
        
        LOGGER.info("Getting primary category for product ID: " + productId);
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, String.valueOf(productId));
            
            LOGGER.info("Executing SQL: " + sql + " with product_id: " + productId);
            
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                Category category = new Category();
                category.setCategoryId(resultSet.getInt("id"));
                category.setCategoryName(resultSet.getString("name"));
                category.setCreatedAt(resultSet.getTimestamp("created_at"));
                
                LOGGER.info("Found category: " + category.getCategoryName() + " for product " + productId);
                return category;
            } else {
                LOGGER.info("No category found for product " + productId);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting primary category for product ID: " + productId, ex);
            ex.printStackTrace(); // Add this for debugging
        } finally {
            close();
        }
        return null;
    }

    // Test method to check if category-product relationships exist
    public boolean testCategoryProductData() {
        String sql = "SELECT COUNT(*) FROM `category-product`";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                int count = resultSet.getInt(1);
                LOGGER.info("Total category-product relationships: " + count);
                return count > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking category-product data", ex);
        } finally {
            close();
        }
        return false;
    }

    // Method to initialize sample data for category-product relationships
    public boolean initializeSampleCategoryProductData() {
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Sample data from ag.sql
            String[][] sampleData = {
                {"1", "21", "1"}, // Product 21 -> Category 1 (Áo)
                {"2", "22", "1"}, // Product 22 -> Category 1 (Áo)
                {"3", "23", "2"}, // Product 23 -> Category 2 (Quần)
                {"4", "24", "3"}, // Product 24 -> Category 3 (Váy)
                {"5", "25", "1"}, // Product 25 -> Category 1 (Áo)
                {"6", "26", "2"}, // Product 26 -> Category 2 (Quần)
                {"7", "27", "1"}, // Product 27 -> Category 1 (Áo)
                {"8", "28", "1"}, // Product 28 -> Category 1 (Áo)
                {"9", "29", "3"}, // Product 29 -> Category 3 (Váy)
                {"10", "30", "1"}, // Product 30 -> Category 1 (Áo)
                {"11", "31", "4"}, // Product 31 -> Category 4 (Bộ đồ)
                {"12", "32", "1"}, // Product 32 -> Category 1 (Áo)
                {"13", "33", "2"}, // Product 33 -> Category 2 (Quần)
                {"14", "34", "1"}, // Product 34 -> Category 1 (Áo)
                {"15", "35", "5"}, // Product 35 -> Category 5 (Phụ kiện)
                {"16", "36", "5"}, // Product 36 -> Category 5 (Phụ kiện)
                {"17", "37", "5"}, // Product 37 -> Category 5 (Phụ kiện)
                {"18", "38", "1"}, // Product 38 -> Category 1 (Áo)
                {"19", "39", "2"}, // Product 39 -> Category 2 (Quần)
                {"20", "40", "1"}, // Product 40 -> Category 1 (Áo)
                {"21", "45", "5"}  // Product 45 -> Category 5 (Phụ kiện)
            };
            
            // First, clear existing data
            String deleteSql = "DELETE FROM `category-product`";
            statement = conn.prepareStatement(deleteSql);
            statement.executeUpdate();
            
            // Insert sample data
            String insertSql = "INSERT INTO `category-product` (id, product_id, category_id) VALUES (?, ?, ?)";
            statement = conn.prepareStatement(insertSql);
            
            for (String[] data : sampleData) {
                statement.setInt(1, Integer.parseInt(data[0]));     // id
                statement.setString(2, data[1]);                   // product_id
                statement.setString(3, data[2]);                   // category_id
                statement.addBatch();
            }
            
            statement.executeBatch();
            conn.commit();
            LOGGER.info("Sample category-product data initialized successfully");
            return true;
            
        } catch (SQLException ex) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", rollbackEx);
            }
            LOGGER.log(Level.SEVERE, "Error initializing sample data", ex);
            return false;
        } finally {
            try {
                if (conn != null && !conn.isClosed()) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error resetting auto commit", ex);
            } finally {
                close();
            }
        }
    }

    // Method to check if product code already exists
    public boolean existsByProductCode(String productCode) {
        String sql = "SELECT 1 FROM products WHERE product_code = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, productCode);
            resultSet = statement.executeQuery();
            return resultSet.next();
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking if product code exists: " + productCode, ex);
            return false;
        } finally {
            close();
        }
    }

}
