package dao;

import context.DBContext;
import model.Supplier;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SupplierDAO extends DBContext implements I_DAO<Supplier> {

    // Kiểm tra supplier name đã tồn tại chưa
    public boolean isSupplierNameExist(String supplierName) {
        String sql = "SELECT 1 FROM suppliers WHERE supplier_name = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, supplierName);
            resultSet = statement.executeQuery();
            return resultSet.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Kiểm tra email đã tồn tại chưa
    public boolean isEmailExist(String email) {
        String sql = "SELECT 1 FROM suppliers WHERE email = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, email);
            resultSet = statement.executeQuery();
            return resultSet.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Thêm supplier mới
    public boolean add(Supplier supplier) {
        if (isSupplierNameExist(supplier.getSupplierName())) {
            System.out.println("Supplier name đã tồn tại, không thể thêm.");
            return false;
        }
        if (isEmailExist(supplier.getEmail())) {
            System.out.println("Email đã tồn tại, không thể thêm.");
            return false;
        }
        String sql = "INSERT INTO suppliers (supplier_name, contact_person, phone_number, email, address, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            Timestamp now = new Timestamp(System.currentTimeMillis());
            statement.setString(1, supplier.getSupplierName());
            statement.setString(2, supplier.getContactPerson());
            statement.setString(3, supplier.getPhoneNumber());
            statement.setString(4, supplier.getEmail());
            statement.setString(5, supplier.getAddress());
            statement.setTimestamp(6, now);
            statement.setTimestamp(7, now);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Lấy supplier theo supplier_id
    public Supplier getSupplierById(int supplierId) {
        String sql = "SELECT * FROM suppliers WHERE supplier_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, supplierId);
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

    // Cập nhật supplier
    @Override
    public boolean update(Supplier supplier) {
        String sql = "UPDATE suppliers SET supplier_name = ?, contact_person = ?, phone_number = ?, email = ?, address = ?, updated_at = CURRENT_TIMESTAMP WHERE supplier_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, supplier.getSupplierName());
            statement.setString(2, supplier.getContactPerson());
            statement.setString(3, supplier.getPhoneNumber());
            statement.setString(4, supplier.getEmail());
            statement.setString(5, supplier.getAddress());
            statement.setInt(6, supplier.getSupplierId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Tìm supplier theo name
    public Supplier findBySupplierName(String supplierName) {
        String sql = "SELECT * FROM suppliers WHERE supplier_name = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, supplierName);
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

    // Tìm supplier theo email
    public Supplier findByEmail(String email) {
        String sql = "SELECT * FROM suppliers WHERE email = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, email);
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

    @Override
    public List<Supplier> findAll() {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM suppliers ORDER BY supplier_id";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Supplier s = getFromResultSet(resultSet);
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return list;
    }

    @Override
    public boolean delete(Supplier supplier) {
        String sql = "DELETE FROM suppliers WHERE supplier_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, supplier.getSupplierId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    // Xóa supplier theo ID (convenience method)
    public boolean deleteSupplier(int id) {
        String sql = "DELETE FROM suppliers WHERE supplier_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public int insert(Supplier supplier) {
        String sql = "INSERT INTO suppliers (supplier_name, contact_person, phone_number, email, address, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, supplier.getSupplierName());
            statement.setString(2, supplier.getContactPerson());
            statement.setString(3, supplier.getPhoneNumber());
            statement.setString(4, supplier.getEmail());
            statement.setString(5, supplier.getAddress());

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
            close();
        }
    }

    @Override
    public Supplier getFromResultSet(ResultSet rs) throws SQLException {
        Supplier s = new Supplier();
        s.setSupplierId(rs.getInt("supplier_id"));
        s.setSupplierName(rs.getString("supplier_name"));
        s.setContactPerson(rs.getString("contact_person"));
        s.setPhoneNumber(rs.getString("phone_number"));
        s.setEmail(rs.getString("email"));
        s.setAddress(rs.getString("address"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setUpdatedAt(rs.getTimestamp("updated_at"));
        return s;
    }

    @Override
    public Supplier findById(Integer id) {
        String sql = "SELECT * FROM suppliers WHERE supplier_id = ?";
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

    // Lấy tất cả suppliers - alias for findAll() for backward compatibility
    public List<Supplier> getAllSuppliers() {
        return findAll();
    }

    // Update supplier - alias for update() for backward compatibility
    public boolean updateSupplier(Supplier supplier) {
        return update(supplier);
    }

    // Add supplier - alias for insert() for backward compatibility
    public boolean addSupplier(Supplier supplier) {
        return insert(supplier) > 0;
    }

    // Find suppliers with filters and pagination
    public List<Supplier> findSuppliers(String searchTerm, int page, int pageSize) {
        List<Supplier> suppliers = new ArrayList<>();
        StringBuilder sqlBuilder = new StringBuilder("SELECT * FROM suppliers WHERE 1=1");
        
        if (searchTerm != null && !searchTerm.isEmpty()) {
            sqlBuilder.append(" AND (supplier_name LIKE ? OR contact_person LIKE ? OR email LIKE ? OR address LIKE ?)");
        }
        
        sqlBuilder.append(" ORDER BY supplier_name LIMIT ? OFFSET ?");
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sqlBuilder.toString());
            int paramIndex = 1;
            
            if (searchTerm != null && !searchTerm.isEmpty()) {
                String likePattern = "%" + searchTerm + "%";
                statement.setString(paramIndex++, likePattern);
                statement.setString(paramIndex++, likePattern);
                statement.setString(paramIndex++, likePattern);
                statement.setString(paramIndex++, likePattern);
            }
            
            statement.setInt(paramIndex++, pageSize);
            statement.setInt(paramIndex++, (page - 1) * pageSize);
            
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                suppliers.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return suppliers;
    }
    
    // Get total count of filtered suppliers
    public int getTotalFilteredSuppliers(String searchTerm) {
        StringBuilder sqlBuilder = new StringBuilder("SELECT COUNT(*) FROM suppliers WHERE 1=1");
        
        if (searchTerm != null && !searchTerm.isEmpty()) {
            sqlBuilder.append(" AND (supplier_name LIKE ? OR contact_person LIKE ? OR email LIKE ? OR address LIKE ?)");
        }
        
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sqlBuilder.toString());
            int paramIndex = 1;
            
            if (searchTerm != null && !searchTerm.isEmpty()) {
                String likePattern = "%" + searchTerm + "%";
                statement.setString(paramIndex++, likePattern);
                statement.setString(paramIndex++, likePattern);
                statement.setString(paramIndex++, likePattern);
                statement.setString(paramIndex++, likePattern);
            }
            
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close();
        }
        return 0;
    }
    
    // Delete supplier by ID
    public boolean delete(int supplierId) {
        String sql = "DELETE FROM suppliers WHERE supplier_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, supplierId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }
}
