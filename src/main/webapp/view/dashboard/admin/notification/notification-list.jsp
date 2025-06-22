<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý thông báo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp"/>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Quản lý thông báo</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/admin/notifications?action=create" 
                           class="btn btn-primary">
                            <i class="fas fa-plus"></i> Tạo thông báo mới
                        </a>
                    </div>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        ${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Notifications Table -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Danh sách thông báo đã gửi</h5>
                    </div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty notifications}">
                                <div class="text-center py-5">
                                    <i class="fas fa-bell-slash fa-3x text-muted mb-3"></i>
                                    <p class="text-muted">Chưa có thông báo nào được gửi</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="table-dark">
                                            <tr>
                                                <th>ID</th>
                                                <th>Tiêu đề</th>
                                                <th>Người gửi</th>
                                                <th>Người nhận</th>
                                                <th>Trạng thái</th>
                                                <th>Thời gian gửi</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="notification" items="${notifications}">
                                                <tr>
                                                    <td>${notification.notificationId}</td>
                                                    <td>
                                                        <div class="text-truncate" style="max-width: 200px;" 
                                                             title="${notification.title}">
                                                            ${notification.title}
                                                        </div>
                                                    </td>
                                                    <td>${notification.senderName}</td>
                                                    <td>${notification.receiverName}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${notification.read}">
                                                                <span class="badge bg-success">
                                                                    <i class="fas fa-check"></i> Đã đọc
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-warning">
                                                                    <i class="fas fa-clock"></i> Chưa đọc
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${notification.createdAt}" 
                                                                      pattern="dd/MM/yyyy HH:mm"/>
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/admin/notifications?action=view&id=${notification.notificationId}" 
                                                           class="btn btn-sm btn-outline-primary">
                                                            <i class="fas fa-eye"></i> Xem
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 