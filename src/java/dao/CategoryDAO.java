package dao;

import context.DBContext;
import model.Category;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO extends DBContext implements I_DAO<Category> {

    // Kiểm tra category name đã tồn tại chưa (trừ ID hiện tại)
    public boolean isCategoryNameExist(String categoryName, Integer excludeId) {
        String sql = "SELECT 1 FROM category WHERE name = ?";
        if (excludeId != null) {
            sql += " AND id != ?";
        }
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, categoryName);
            if (excludeId != null) {
                statement.setInt(2, excludeId);
            }
            resultSet = statement.executeQuery();
            return resultSet.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    // Kiểm tra category name đã tồn tại chưa
    public boolean isCategoryNameExist(String categoryName) {
        return isCategoryNameExist(categoryName, null);
    }

    // Tìm categories với filter và pagination
    public List<Category> findCategories(String searchTerm, int page, int pageSize) {
        List<Category> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM category WHERE 1=1");

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND name LIKE ?");
        }

        sql.append(" ORDER BY id DESC");
        sql.append(" LIMIT ? OFFSET ?");

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql.toString());

            int paramIndex = 1;
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                statement.setString(paramIndex++, "%" + searchTerm.trim() + "%");
            }

            statement.setInt(paramIndex++, pageSize);
            statement.setInt(paramIndex, (page - 1) * pageSize);

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                list.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    // Đếm tổng số categories với filter
    public int getTotalFilteredCategories(String searchTerm) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM category WHERE 1=1");

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND name LIKE ?");
        }

        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql.toString());

            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                statement.setString(1, "%" + searchTerm.trim() + "%");
            }

            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return 0;
    }

    // Kiểm tra category có được sử dụng trong products không
    public boolean isCategoryInUse(Integer categoryId) {
        String sql = "SELECT 1 FROM `category-product` WHERE category_id = ? LIMIT 1";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, String.valueOf(categoryId));
            resultSet = statement.executeQuery();
            return resultSet.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    // Thêm category mới
    public boolean add(Category category) {
        if (isCategoryNameExist(category.getCategoryName())) {
            System.out.println("Category name đã tồn tại, không thể thêm.");
            return false;
        }
        String sql = "INSERT INTO category (name, created_at) VALUES (?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            Timestamp now = new Timestamp(System.currentTimeMillis());
            statement.setString(1, category.getCategoryName());
            statement.setTimestamp(2, now);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    // Lấy category theo category_id
    public Category getCategoryById(int categoryId) {
        String sql = "SELECT * FROM category WHERE id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, categoryId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    // Cập nhật category
    @Override
    public boolean update(Category category) {
        String sql = "UPDATE category SET name = ? WHERE id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, category.getCategoryName());
            statement.setInt(2, category.getCategoryId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    // Tìm category theo name
    public Category findByCategoryName(String categoryName) {
        String sql = "SELECT * FROM category WHERE name = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, categoryName);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return null;
    }

    @Override
    public List<Category> findAll() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM category ORDER BY id";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Category c = getFromResultSet(resultSet);
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources();
        }
        return list;
    }

    @Override
    public boolean delete(Category category) {
        String sql = "DELETE FROM category WHERE id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, category.getCategoryId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    // Xóa category theo ID (convenience method)
    public boolean deleteCategory(int categoryId) {
        String sql = "DELETE FROM category WHERE id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, categoryId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources();
        }
    }

    @Override
    public int insert(Category category) {
        String sql = "INSERT INTO category (name, created_at) VALUES (?, CURRENT_TIMESTAMP)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, category.getCategoryName());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                return -1;
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                return -1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            closeResources();
        }
    }

    @Override
    public Category getFromResultSet(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setCategoryId(rs.getInt("id"));
        c.setCategoryName(rs.getString("name"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    }

    @Override
    public Category findById(Integer id) {
        String sql = "SELECT * FROM category WHERE id = ?";
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
            closeResources();
        }
        return null;
    }

    // Lấy tất cả categories - alias for findAll() for backward compatibility
    public List<Category> getAllCategories() {
        return findAll();
    }

    // Update category - alias for update() for backward compatibility
    public boolean updateCategory(Category category) {
        return update(category);
    }

    // Update category by ID - for backward compatibility
    public boolean updateCategory(int categoryId, Category newCategory) {
        newCategory.setCategoryId(categoryId);
        return update(newCategory);
    }

    // Add category - alias for insert() for backward compatibility
    public boolean addCategory(Category category) {
        return insert(category) > 0;
    }

    // Thêm method closeResources theo CursorRULE
    public void closeResources() {
        try {
            if (resultSet != null && !resultSet.isClosed()) {
                resultSet.close();
            }
            if (statement != null && !statement.isClosed()) {
                statement.close();
            }
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}
