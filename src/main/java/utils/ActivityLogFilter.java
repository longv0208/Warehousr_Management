package utils;

import dao.UserDAO;
import model.User;
import context.DBContext;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebFilter("/*")
public class ActivityLogFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        
        // Get current user from session
        User currentUser = SessionUtil.getUserFromSession(httpRequest);
        
        if (currentUser != null) {
            // Set the current user ID in database session variable for triggers
            setCurrentUserIdInDatabase(currentUser.getUserId());
        }
        
        // Continue with the request
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }

    private void setCurrentUserIdInDatabase(int userId) {
        DBContext dbContext = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            dbContext = new DBContext();
            conn = dbContext.getConnection();
            
            // Set the session variable that triggers can use
            String sql = "SET @current_user_id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.executeUpdate();
            
        } catch (SQLException e) {
            // Log the error but don't break the application flow
            System.err.println("Error setting current user ID in database: " + e.getMessage());
        } finally {
            // Clean up resources
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {
                    System.err.println("Error closing statement: " + e.getMessage());
                }
            }
            if (dbContext != null) {
                dbContext.close();
            }
        }
    }
} 