package dao;

import context.DBContext;
import model.Warehouse;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WarehouseDAO extends DBContext implements I_DAO<Warehouse> {

    @Override
    public List<Warehouse> findAll() {
        List<Warehouse> list = new ArrayList<>();
        String sql = "SELECT * FROM warehouses ORDER BY warehouse_name";
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
    public boolean update(Warehouse warehouse) {
        String sql = "UPDATE warehouses SET warehouse_name = ?, address = ? WHERE warehouse_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, warehouse.getWarehouseName());
            statement.setString(2, warehouse.getAddress());
            statement.setInt(3, warehouse.getWarehouseId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(Warehouse warehouse) {
        String sql = "DELETE FROM warehouses WHERE warehouse_id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, warehouse.getWarehouseId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            close();
        }
    }

    @Override
    public int insert(Warehouse warehouse) {
        String sql = "INSERT INTO warehouses (warehouse_name, address) VALUES (?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, warehouse.getWarehouseName());
            statement.setString(2, warehouse.getAddress());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating warehouse failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating warehouse failed, no ID obtained.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public Warehouse getFromResultSet(ResultSet rs) throws SQLException {
        Warehouse warehouse = new Warehouse();
        warehouse.setWarehouseId(rs.getInt("warehouse_id"));
        warehouse.setWarehouseName(rs.getString("warehouse_name"));
        warehouse.setAddress(rs.getString("address"));
        warehouse.setCreatedAt(rs.getTimestamp("created_at"));
        return warehouse;
    }

    @Override
    public Warehouse findById(Integer id) {
        String sql = "SELECT * FROM warehouses WHERE warehouse_id = ?";
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
} 