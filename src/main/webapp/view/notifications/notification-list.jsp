<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông báo của tôi</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .notification-item {
            transition: all 0.3s ease;
            border-left: 4px solid transparent;
        }
        .notification-item:hover {
            transform: translateX(5px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .notification-item.unread {
            border-left-color: #ffc107;
            background-color: #fff8e1;
        }
        .notification-item.read {
            border-left-color: #28a745;
            background-color: #f8f9fa;
        }
        .notification-title {
            font-weight: 600;
            color: #333;
        }
        .notification-meta {
            font-size: 0.875rem;
            color: #6c757d;
        }
        .notification-preview {
            color: #666;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp"/>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">
                        <i class="fas fa-bell"></i> Thông báo của tôi
                        <c:if test="${unreadCount > 0}">
                            <span class="badge bg-warning ms-2">${unreadCount} chưa đọc</span>
                        </c:if>
                    </h1>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-triangle"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle"></i> ${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Notifications -->
                <div class="row">
                    <div class="col-12">
                        <c:choose>
                            <c:when test="${empty notifications}">
                                <div class="text-center py-5">
                                    <i class="fas fa-bell-slash fa-5x text-muted mb-4"></i>
                                    <h3 class="text-muted">Chưa có thông báo nào</h3>
                                    <p class="text-muted">Bạn sẽ nhận được thông báo khi có cập nhật mới từ hệ thống.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <!-- Notifications Summary -->
                                <div class="row mb-4">
                                    <div class="col-md-6">
                                        <div class="card bg-primary text-white">
                                            <div class="card-body">
                                                <div class="d-flex align-items-center">
                                                    <i class="fas fa-envelope fa-2x me-3"></i>
                                                    <div>
                                                        <h5 class="card-title mb-0">Tổng thông báo</h5>
                                                        <h2 class="mb-0">${notifications.size()}</h2>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="card bg-warning text-dark">
                                            <div class="card-body">
                                                <div class="d-flex align-items-center">
                                                    <i class="fas fa-exclamation-circle fa-2x me-3"></i>
                                                    <div>
                                                        <h5 class="card-title mb-0">Chưa đọc</h5>
                                                        <h2 class="mb-0">${unreadCount}</h2>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Notifications List -->
                                <div class="notifications-container">
                                    <c:forEach var="notification" items="${notifications}">
                                        <div class="card notification-item ${notification.read ? 'read' : 'unread'} mb-3">
                                            <div class="card-body">
                                                <div class="row align-items-center">
                                                    <div class="col-md-8">
                                                        <div class="d-flex align-items-start">
                                                            <div class="me-3">
                                                                <c:choose>
                                                                    <c:when test="${notification.read}">
                                                                        <i class="fas fa-envelope-open text-success fa-lg"></i>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <i class="fas fa-envelope text-warning fa-lg"></i>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                            <div class="flex-grow-1">
                                                                <h5 class="notification-title mb-1">${notification.title}</h5>
                                                                <div class="notification-preview mb-2">
                                                                    ${notification.message}
                                                                </div>
                                                                <div class="notification-meta">
                                                                    <i class="fas fa-user text-primary"></i> 
                                                                    Từ: <strong>${notification.senderName}</strong> |
                                                                    <i class="fas fa-clock text-info"></i>
                                                                    <fmt:formatDate value="${notification.createdAt}" 
                                                                                  pattern="dd/MM/yyyy HH:mm"/>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4 text-end">
                                                        <div class="btn-group-vertical gap-2">
                                                            <a href="${pageContext.request.contextPath}/notifications?action=view&id=${notification.notificationId}" 
                                                               class="btn btn-primary btn-sm">
                                                                <i class="fas fa-eye"></i> Xem chi tiết
                                                            </a>
                                                            <c:if test="${!notification.read}">
                                                                <a href="${pageContext.request.contextPath}/notifications?action=markRead&id=${notification.notificationId}" 
                                                                   class="btn btn-outline-success btn-sm">
                                                                    <i class="fas fa-check"></i> Đánh dấu đã đọc
                                                                </a>
                                                            </c:if>
                                                            <c:if test="${notification.read}">
                                                                <span class="badge bg-success">
                                                                    <i class="fas fa-check-circle"></i> Đã đọc
                                                                </span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto refresh every 30 seconds to check for new notifications
        setTimeout(() => {
            location.reload();
        }, 30000);
    </script>
</body>
</html> 