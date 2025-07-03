package dao;

import context.DBContext;
import model.PurchaseRequest;
import model.PurchaseRequestDetail;
import model.Supplier;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.sql.Types;

public class PurchaseRequestDAO extends DBContext implements I_DAO<PurchaseRequest> {

    private static final Logger LOGGER = Logger.getLogger(PurchaseRequestDAO.class.getName());

    @Override
    public PurchaseRequest getFromResultSet(ResultSet rs) throws SQLException {
        // Create supplier object if supplier information is available
        Supplier supplier = null;
        if (rs.getObject("supplier_id") != null) {
            supplier = Supplier.builder()
                    .supplierId(rs.getInt("supplier_id"))
                    .supplierName(rs.getString("supplier_name"))
                    .contactPerson(rs.getString("contact_person"))
                    .phoneNumber(rs.getString("phone_number"))
                    .email(rs.getString("email"))
                    .address(rs.getString("address"))
                    .build();
        }
        
        return PurchaseRequest.builder()
                .requestId(rs.getInt("request_id"))
                .requestCode(rs.getString("request_code"))
                .userIdRequester(rs.getInt("user_id_requester"))
                .warehouseId(rs.getInt("warehouse_id"))
                .requestDate(rs.getTimestamp("request_date"))
                .status(rs.getString("status"))
                .notes(rs.getString("notes"))
                .createdAt(rs.getTimestamp("created_at"))
                // Thông tin join
                .requestedByName(rs.getString("requested_by_name"))
                .warehouseName(rs.getString("warehouse_name"))
                // Set default values for fields not in database
                .approvedByName(null) // Database chưa có trường này
                .approvedDate(null)   // Database chưa có trường này
                // Supplier information
                .supplier(supplier)
                .build();
    }

    @Override
    public List<PurchaseRequest> findAll() {
        List<PurchaseRequest> requests = new ArrayList<>();
        String sql = "SELECT pr.request_id, pr.request_code, pr.user_id_requester, pr.warehouse_id, " +
                     "pr.request_date, pr.status, pr.notes, pr.created_at, " +
                     "MAX(u.full_name) as requested_by_name, " +
                     "MAX(w.warehouse_name) as warehouse_name, " +
                     "MAX(s.supplier_id) as supplier_id, MAX(s.supplier_name) as supplier_name, " +
                     "MAX(s.contact_person) as contact_person, MAX(s.phone_number) as phone_number, " +
                     "MAX(s.email) as email, MAX(s.address) as address " +
                     "FROM purchaserequests pr " +
                     "LEFT JOIN users u ON pr.user_id_requester = u.user_id " +
                     "LEFT JOIN warehouses w ON pr.warehouse_id = w.warehouse_id " +
                     "LEFT JOIN purchaserequestdetails prd ON pr.request_id = prd.request_id " +
                     "LEFT JOIN suppliers s ON prd.supplier_id_suggested = s.supplier_id " +
                     "GROUP BY pr.request_id " +
                     "ORDER BY pr.created_at DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                requests.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all purchase requests, SQL Error Code: " + ex.getErrorCode() + 
                      ", SQL State: " + ex.getSQLState() + ", Message: " + ex.getMessage(), ex);
            throw new RuntimeException("Error fetching all purchase requests", ex);
        } finally {
            close();
        }
        return requests;
    }

    @Override
    public int insert(PurchaseRequest request) {
        String sql = "INSERT INTO purchaserequests (request_code, user_id_requester, warehouse_id, request_date, status, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, request.getRequestCode());
            statement.setInt(2, request.getUserIdRequester());
            statement.setInt(3, request.getWarehouseId());
            statement.setTimestamp(4, request.getRequestDate());
            statement.setString(5, request.getStatus());
            statement.setString(6, request.getNotes());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating purchase request failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating purchase request failed, no ID obtained.");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting purchase request: " + request.toString() + 
                      ", SQL Error Code: " + ex.getErrorCode() + 
                      ", SQL State: " + ex.getSQLState() + ", Message: " + ex.getMessage(), ex);
            throw new RuntimeException("Error inserting purchase request", ex);
        } finally {
            close();
        }
    }

    @Override
    public boolean update(PurchaseRequest request) {
        String sql = "UPDATE purchaserequests SET status = ?, notes = ? WHERE request_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, request.getStatus());
            statement.setString(2, request.getNotes());
            statement.setInt(3, request.getRequestId());

            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating purchase request: " + request.toString() + 
                      ", SQL Error Code: " + ex.getErrorCode() + 
                      ", SQL State: " + ex.getSQLState() + ", Message: " + ex.getMessage(), ex);
            throw new RuntimeException("Error updating purchase request", ex);
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(PurchaseRequest request) {
        String sql = "DELETE FROM purchaserequests WHERE request_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, request.getRequestId());
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting purchase request: " + request.getRequestId() + 
                      ", SQL Error Code: " + ex.getErrorCode() + 
                      ", SQL State: " + ex.getSQLState() + ", Message: " + ex.getMessage(), ex);
            throw new RuntimeException("Error deleting purchase request", ex);
        } finally 
                {
            close();
        }
    }

    @Override
    public PurchaseRequest findById(Integer id) {
        String sql = "SELECT pr.request_id, pr.request_code, pr.user_id_requester, pr.warehouse_id, " +
                     "pr.request_date, pr.status, pr.notes, pr.created_at, " +
                     "MAX(u.full_name) as requested_by_name, " +
                     "MAX(w.warehouse_name) as warehouse_name, " +
                     "MAX(s.supplier_id) as supplier_id, MAX(s.supplier_name) as supplier_name, " +
                     "MAX(s.contact_person) as contact_person, MAX(s.phone_number) as phone_number, " +
                     "MAX(s.email) as email, MAX(s.address) as address " +
                     "FROM purchaserequests pr " +
                     "LEFT JOIN users u ON pr.user_id_requester = u.user_id " +
                     "LEFT JOIN warehouses w ON pr.warehouse_id = w.warehouse_id " +
                     "LEFT JOIN purchaserequestdetails prd ON pr.request_id = prd.request_id " +
                     "LEFT JOIN suppliers s ON prd.supplier_id_suggested = s.supplier_id " +
                     "WHERE pr.request_id = ? " +
                     "GROUP BY pr.request_id";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding purchase request by ID: " + id + 
                      ", SQL Error Code: " + ex.getErrorCode() + 
                      ", SQL State: " + ex.getSQLState() + ", Message: " + ex.getMessage(), ex);
            throw new RuntimeException("Error finding purchase request by ID", ex);
        } finally {
            close();
        }
        return null;
    }

    // Tìm kiếm theo trạng thái
    public List<PurchaseRequest> findByStatus(String status) {
        List<PurchaseRequest> requests = new ArrayList<>();
        String sql = "SELECT pr.request_id, pr.request_code, pr.user_id_requester, pr.warehouse_id, " +
                     "pr.request_date, pr.status, pr.notes, pr.created_at, " +
                     "MAX(u.full_name) as requested_by_name, " +
                     "MAX(w.warehouse_name) as warehouse_name, " +
                     "MAX(s.supplier_id) as supplier_id, MAX(s.supplier_name) as supplier_name, " +
                     "MAX(s.contact_person) as contact_person, MAX(s.phone_number) as phone_number, " +
                     "MAX(s.email) as email, MAX(s.address) as address " +
                     "FROM purchaserequests pr " +
                     "LEFT JOIN users u ON pr.user_id_requester = u.user_id " +
                     "LEFT JOIN warehouses w ON pr.warehouse_id = w.warehouse_id " +
                     "LEFT JOIN purchaserequestdetails prd ON pr.request_id = prd.request_id " +
                     "LEFT JOIN suppliers s ON prd.supplier_id_suggested = s.supplier_id " +
                     "WHERE pr.status = ? " +
                     "GROUP BY pr.request_id " +
                     "ORDER BY pr.created_at DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, status);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                requests.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding purchase requests by status: " + status + 
                      ", SQL Error Code: " + ex.getErrorCode() + 
                      ", SQL State: " + ex.getSQLState() + ", Message: " + ex.getMessage(), ex);
            throw new RuntimeException("Error finding purchase requests by status", ex);
        } finally {
            close();
        }
        return requests;
    }

    // Tìm kiếm theo user ID
    public List<PurchaseRequest> findByRequestedBy(Integer userId) {
        if (userId == null || userId <= 0) {
            LOGGER.log(Level.WARNING, "Invalid user ID provided: " + userId);
            return new ArrayList<>();
        }
        List<PurchaseRequest> requests = new ArrayList<>();
        String sql = "SELECT pr.request_id, pr.request_code, pr.user_id_requester, pr.warehouse_id, " +
                     "pr.request_date, pr.status, pr.notes, pr.created_at, " +
                     "MAX(u.full_name) as requested_by_name, " +
                     "MAX(w.warehouse_name) as warehouse_name, " +
                     "MAX(s.supplier_id) as supplier_id, MAX(s.supplier_name) as supplier_name, " +
                     "MAX(s.contact_person) as contact_person, MAX(s.phone_number) as phone_number, " +
                     "MAX(s.email) as email, MAX(s.address) as address " +
                     "FROM purchaserequests pr " +
                     "LEFT JOIN users u ON pr.user_id_requester = u.user_id " +
                     "LEFT JOIN warehouses w ON pr.warehouse_id = w.warehouse_id " +
                     "LEFT JOIN purchaserequestdetails prd ON pr.request_id = prd.request_id " +
                     "LEFT JOIN suppliers s ON prd.supplier_id_suggested = s.supplier_id " +
                     "WHERE pr.user_id_requester = ? " +
                     "GROUP BY pr.request_id " +
                     "ORDER BY pr.created_at DESC";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, userId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                requests.add(getFromResultSet(resultSet));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding purchase requests by user ID: " + userId + 
                      ", SQL Error Code: " + ex.getErrorCode() + 
                      ", SQL State: " + ex.getSQLState() + ", Message: " + ex.getMessage(), ex);
            throw new RuntimeException("Error fetching purchase requests by user ID", ex);
        } finally {
            close();
        }
        return requests;
    }

    // Tạo mã yêu cầu tự động
    public String generateRequestCode() {
        String prefix = "PR";
        String sql = "SELECT COUNT(*) + 1 as next_num FROM purchaserequests";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                int nextNum = resultSet.getInt("next_num");
                return prefix + String.format("%06d", nextNum);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error generating request code, SQL Error Code: " + ex.getErrorCode() + 
                      ", SQL State: " + ex.getSQLState() + ", Message: " + ex.getMessage(), ex);
            throw new RuntimeException("Error generating request code", ex);
        } finally {
            close();
        }
        return prefix + "000001";
    }
}