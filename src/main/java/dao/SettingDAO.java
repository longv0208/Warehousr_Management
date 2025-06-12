package dao;

import context.DBContext;
import dao.I_DAO;
import model.Setting;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SettingDAO extends DBContext implements I_DAO<Setting> {

    @Override
    public List<Setting> findAll() {
        List<Setting> settings = new ArrayList<>();
        String sql = "SELECT * FROM setting";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                settings.add(getFromResultSet(resultSet));
            }
        } catch (SQLException e) {
            System.out.println("Error getting all settings: " + e.getMessage());
        } finally {
            close();
        }
        return settings;
    }

    @Override
    public Setting findById(Integer id) {
        String sql = "SELECT * FROM setting WHERE id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException e) {
            System.out.println("Error getting setting by ID: " + e.getMessage());
        } finally {
            close();
        }
        return null;
    }

    @Override
    public int insert(Setting setting) {
        String sql = "INSERT INTO setting (`key`, `value`) VALUES (?, ?)";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            statement.setString(1, setting.getKey());
            statement.setString(2, setting.getValue());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating setting failed, no rows affected.");
            }

            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                throw new SQLException("Creating setting failed, no ID obtained.");
            }
        } catch (SQLException e) {
            System.out.println("Error inserting setting: " + e.getMessage());
            return -1;
        } finally {
            close();
        }
    }

    @Override
    public boolean update(Setting setting) {
        String sql = "UPDATE setting SET `key` = ?, `value` = ? WHERE id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, setting.getKey());
            statement.setString(2, setting.getValue());
            statement.setInt(3, setting.getId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error updating setting: " + e.getMessage());
            return false;
        } finally {
            close();
        }
    }

    @Override
    public boolean delete(Setting setting) {
        if (setting == null || setting.getId() == null) {
            System.out.println("Error deleting setting: Setting object or ID is null.");
            return false;
        }
        String sql = "DELETE FROM setting WHERE id = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setInt(1, setting.getId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error deleting setting: " + e.getMessage());
            return false;
        } finally {
            close();
        }
    }

    @Override
    public Setting getFromResultSet(ResultSet resultSet) throws SQLException {
        return Setting.builder()
                .id(resultSet.getInt("id"))
                .key(resultSet.getString("key"))
                .value(resultSet.getString("value"))
                .build();
    }

    // Additional method to find setting by key
    public Setting findByKey(String key) {
        String sql = "SELECT * FROM setting WHERE `key` = ?";
        try {
            conn = getConnection();
            statement = conn.prepareStatement(sql);
            statement.setString(1, key);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return getFromResultSet(resultSet);
            }
        } catch (SQLException e) {
            System.out.println("Error getting setting by key: " + e.getMessage());
        } finally {
            close();
        }
        return null;
    }

    // Convenience method to get setting value by key
    public String getValueByKey(String key) {
        Setting setting = findByKey(key);
        return setting != null ? setting.getValue() : null;
    }

    // Convenience method to update setting value by key
    public boolean updateValueByKey(String key, String value) {
        Setting setting = findByKey(key);
        if (setting != null) {
            setting.setValue(value);
            return update(setting);
        } else {
            // If setting doesn't exist, create new one
            Setting newSetting = Setting.builder()
                    .key(key)
                    .value(value)
                    .build();
            return insert(newSetting) > 0;
        }
    }

    public static void main(String[] args) {
        SettingDAO settingDAO = new SettingDAO();
        List<Setting> settings = settingDAO.findAll();
        for (Setting setting : settings) {
            System.out.println(setting);
        }
    }
}
