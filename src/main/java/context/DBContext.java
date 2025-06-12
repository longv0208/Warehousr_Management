package context;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    private static final String URL = "jdbc:mysql://localhost:3306/swp391_quanlykhohang";
    private static final String USER = "root";
    private static final String PASSWORD = "123456";

    protected Connection conn;
    protected ResultSet resultSet;
    protected PreparedStatement statement;

    public DBContext() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    public Connection getConnection() {
        return new DBContext().conn;

    }

    public void close() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
            if (statement != null) {
                statement.close();
            }
            if (resultSet != null) {
                resultSet.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Main method để test kết nối
    public static void main(String[] args) {
        System.out.println("Testing MySQL database connection...");

        try {
            DBContext dbContext = new DBContext();
            Connection conn = dbContext.getConnection();

            if (conn != null && !conn.isClosed()) {
                System.out.println("✓ Kết nối database thành công!");
                System.out.println("Database URL: " + URL);
                System.out.println("User: " + USER);

                // Test một query đơn giản
                try {
                    conn.createStatement().executeQuery("SELECT 1");
                    System.out.println("✓ Test query thành công!");
                } catch (SQLException e) {
                    System.out.println("✗ Lỗi khi thực hiện test query: " + e.getMessage());
                }

                dbContext.close();
                System.out.println("✓ Đóng kết nối thành công!");
            } else {
                System.out.println("✗ Kết nối database thất bại!");
            }

        } catch (SQLException e) {
            System.out.println("✗ Lỗi kết nối database:");
            System.out.println("   - " + e.getMessage());
            System.out.println("\nKiểm tra lại:");
            System.out.println("   1. MySQL server đã chạy chưa?");
            System.out.println("   2. Database 'swp391_quanlykhohang' đã tồn tại chưa?");
            System.out.println("   3. Username/password có đúng không?");
            System.out.println("   4. MySQL JDBC Driver đã được thêm vào project chưa?");
        }
    }
}
