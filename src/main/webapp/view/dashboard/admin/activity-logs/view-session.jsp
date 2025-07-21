<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết Phiên - Warehouse Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            margin: 0;
            padding: 0;
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .main-content {
            margin-left: 250px;
            padding: 20px;
            min-height: 100vh;
        }
        .page-header {
            background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .activity-item {
            background: white;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #007bff;
        }
        .login-item { border-left-color: #28a745; }
        .logout-item { border-left-color: #dc3545; }
        .info-item { border-left-color: #17a2b8; }
        .warning-item { border-left-color: #ffc107; }
        .danger-item { border-left-color: #dc3545; }
    </style>
</head>
<body>
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>
    
    <div class="main-content">
        <div class="page-header">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="mb-2">
                        <i class="bi bi-info-circle"></i> Chi tiết Phiên hoạt động
                    </h1>
                    <p class="mb-0">
                        Người dùng: 
                        <c:set var="foundUser" value="${null}"/>
                        <c:forEach var="user" items="${users}">
                            <c:if test="${user.userId == sessionUserId}">
                                <c:set var="foundUser" value="${user}"/>
                            </c:if>
                        </c:forEach>
                        <strong>
                            ${foundUser != null ? foundUser.fullName : 'Không xác định'}
                        </strong>
                        <br>
                        Thời gian bắt đầu phiên: 
                        <strong>
                            <fmt:formatDate value="${sessionLoginTimestamp}" pattern="HH:mm:ss dd/MM/yyyy"/>
                        </strong>
                    </p>
                </div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb bg-transparent mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/dashboard" class="text-white-50">Dashboard</a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/admin/activity-log?action=login-history" class="text-white-50">Lịch sử đăng nhập</a>
                        </li>
                        <li class="breadcrumb-item active text-white">Chi tiết phiên</li>
                    </ol>
                </nav>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="bi bi-list-ul"></i> Nhật ký đăng nhập trong phiên
                </h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty sessionActivities}">
                        <c:forEach var="activity" items="${sessionActivities}">
                            <div class="activity-item 
                                <c:choose>
                                    <c:when test="${activity.actionType == 'LOGIN'}">login-item</c:when>
                                    <c:when test="${activity.actionType == 'LOGOUT'}">logout-item</c:when>
                                    <c:when test="${activity.actionType == 'INFO'}">info-item</c:when>
                                    <c:when test="${activity.actionType == 'WARNING'}">warning-item</c:when>
                                    <c:when test="${activity.actionType == 'ERROR'}">danger-item</c:when>
                                    <c:otherwise>info-item</c:otherwise>
                                </c:choose>
                            ">
                                <div class="row align-items-center">
                                    <div class="col-md-8">
                                        <div class="d-flex align-items-center mb-1">
                                            <span class="badge 
                                                <c:choose>
                                                    <c:when test="${activity.actionType == 'LOGIN'}">bg-success</c:when>
                                                    <c:when test="${activity.actionType == 'LOGOUT'}">bg-danger</c:when>
                                                    <c:when test="${activity.actionType == 'INFO'}">bg-info</c:when>
                                                    <c:when test="${activity.actionType == 'WARNING'}">bg-warning text-dark</c:when>
                                                    <c:when test="${activity.actionType == 'ERROR'}">bg-danger</c:when>
                                                    <c:otherwise>bg-secondary</c:otherwise>
                                                </c:choose>
                                                me-2">
                                                <c:choose>
                                                    <c:when test="${activity.actionType == 'LOGIN'}"><i class="bi bi-box-arrow-in-right"></i> Đăng nhập</c:when>
                                                    <c:when test="${activity.actionType == 'LOGOUT'}"><i class="bi bi-box-arrow-left"></i> Đăng xuất</c:when>
                                                    <c:when test="${activity.actionType == 'CREATE'}"><i class="bi bi-plus-circle"></i> Tạo</c:when>
                                                    <c:when test="${activity.actionType == 'UPDATE'}"><i class="bi bi-arrow-repeat"></i> Cập nhật</c:when>
                                                    <c:when test="${activity.actionType == 'DELETE'}"><i class="bi bi-trash"></i> Xóa</c:when>
                                                    <c:when test="${activity.actionType == 'VIEW'}"><i class="bi bi-eye"></i> Xem</c:when>
                                                    <c:when test="${activity.actionType == 'SEARCH'}"><i class="bi bi-search"></i> Tìm kiếm</c:when>
                                                    <c:when test="${activity.actionType == 'REPORT'}"><i class="bi bi-file-earmark-bar-graph"></i> Báo cáo</c:when>
                                                    <c:when test="${activity.actionType == 'STOCK_IN'}"><i class="bi bi-box-arrow-in-down"></i> Nhập kho</c:when>
                                                    <c:when test="${activity.actionType == 'STOCK_OUT'}"><i class="bi bi-box-arrow-up"></i> Xuất kho</c:when>
                                                    <c:when test="${activity.actionType == 'STOCK_TAKE'}"><i class="bi bi-clipboard-check"></i> Kiểm kê</c:when>
                                                    <c:otherwise><i class="bi bi-info-circle"></i> ${activity.actionType}</c:otherwise>
                                                </c:choose>
                                                ${activity.actionType}
                                            </span>
                                            <strong>
                                                <fmt:formatDate value="${activity.timestamp}" pattern="HH:mm:ss dd/MM/yyyy"/>
                                            </strong>
                                        </div>
                                        <p class="mb-1">
                                            <i class="bi bi-card-text text-muted"></i> 
                                            <strong>Thao tác:</strong> ${activity.note}
                                        </p>
                                        <c:if test="${not empty activity.entityType}">
                                            <p class="mb-1">
                                                <i class="bi bi-box text-muted"></i> 
                                                <strong>Đối tượng:</strong> ${activity.entityType} 
                                                <c:if test="${activity.entityId != null}">
                                                    (ID: ${activity.entityId})
                                                </c:if>
                                            </p>
                                        </c:if>
                                        <c:if test="${not empty activity.oldValue || not empty activity.newValue}">
                                            <p class="mb-0">
                                                <i class="bi bi-arrow-left-right text-muted"></i> 
                                                <strong>Thay đổi:</strong>
                                                <c:if test="${not empty activity.oldValue}">
                                                    Từ: ${activity.oldValue}
                                                </c:if>
                                                <c:if test="${not empty activity.newValue}">
                                                    Đến: ${activity.newValue}
                                                </c:if>
                                            </p>
                                        </c:if>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <small class="text-muted">ID Log: ${activity.id}</small>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5">
                            <i class="bi bi-info-circle text-muted mb-3" style="font-size: 4rem;"></i>
                            <h5 class="text-muted">Không tìm thấy hoạt động nào trong phiên này.</h5>
                            <p class="text-muted">Có thể phiên này chỉ bao gồm một sự kiện đăng nhập hoặc dữ liệu không đầy đủ.</p>
                            <div class="mt-3">
                                <a href="${pageContext.request.contextPath}/admin/activity-log?action=login-history" class="btn btn-primary">
                                    <i class="bi bi-arrow-left"></i> Quay lại lịch sử đăng nhập
                                </a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
