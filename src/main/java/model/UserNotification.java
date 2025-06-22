package model;

import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Data;
import java.sql.Timestamp;

@NoArgsConstructor
@AllArgsConstructor
@Builder
@Data
public class UserNotification {
    private int notificationId;
    private int senderId;
    private int receiverId;
    private String title;
    private String message;
    private boolean isRead;
    private Timestamp createdAt;
    
    // Additional fields for display purposes
    private String senderName;
    private String receiverName;
} 