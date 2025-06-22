<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết thông báo</title>
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
                    <h1 class="h2">Chi tiết thông báo</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/admin/notifications" 
                           class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Quay lại danh sách
                        </a>
                    </div>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-triangle"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Notification Details -->
                <c:if test="${not empty notification}">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="card-title mb-0">
                                <i class="fas fa-bell"></i> Thông tin chi tiết
                            </h5>
                            <div class="badge ${notification.read ? 'bg-success' : 'bg-warning'}">
                                <i class="fas ${notification.read ? 'fa-check' : 'fa-clock'}"></i>
                                ${notification.read ? 'Đã đọc' : 'Chưa đọc'}
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <!-- Left Column -->
                                <div class="col-md-8">
                                    <!-- Title -->
                                    <div class="mb-4">
                                        <label class="form-label fw-bold">
                                            <i class="fas fa-heading text-primary"></i> Tiêu đề:
                                        </label>
                                        <div class="p-3 bg-light rounded">
                                            <h4 class="mb-0">${notification.title}</h4>
                                        </div>
                                    </div>

                                    <!-- Message -->
                                    <div class="mb-4">
                                        <label class="form-label fw-bold">
                                            <i class="fas fa-comment text-primary"></i> Nội dung:
                                        </label>
                                        <div class="p-3 bg-light rounded">
                                            <div style="white-space: pre-line;">${notification.message}</div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Right Column -->
                                <div class="col-md-4">
                                    <!-- Metadata -->
                                    <div class="card border-0 bg-light">
                                        <div class="card-body">
                                            <h6 class="card-title">
                                                <i class="fas fa-info-circle text-info"></i> Thông tin bổ sung
                                            </h6>
                                            
                                            <!-- ID -->
                                            <div class="mb-3">
                                                <small class="text-muted d-block">ID Thông báo:</small>
                                                <span class="badge bg-secondary">${notification.notificationId}</span>
                                            </div>

                                            <!-- Sender -->
                                            <div class="mb-3">
                                                <small class="text-muted d-block">Người gửi:</small>
                                                <div class="d-flex align-items-center">
                                                    <i class="fas fa-user-tie text-success me-2"></i>
                                                    <strong>${notification.senderName}</strong>
                                                </div>
                                            </div>

                                            <!-- Receiver -->
                                            <div class="mb-3">
                                                <small class="text-muted d-block">Người nhận:</small>
                                                <div class="d-flex align-items-center">
                                                    <i class="fas fa-user text-primary me-2"></i>
                                                    <strong>${notification.receiverName}</strong>
                                                </div>
                                            </div>

                                            <!-- Created Date -->
                                            <div class="mb-3">
                                                <small class="text-muted d-block">Thời gian gửi:</small>
                                                <div class="d-flex align-items-center">
                                                    <i class="fas fa-calendar-alt text-info me-2"></i>
                                                    <span>
                                                        <fmt:formatDate value="${notification.createdAt}" 
                                                                      pattern="dd/MM/yyyy"/>
                                                    </span>
                                                </div>
                                                <div class="d-flex align-items-center mt-1">
                                                    <i class="fas fa-clock text-warning me-2"></i>
                                                    <span>
                                                        <fmt:formatDate value="${notification.createdAt}" 
                                                                      pattern="HH:mm:ss"/>
                                                    </span>
                                                </div>
                                            </div>

                                            <!-- Status -->
                                            <div class="mb-0">
                                                <small class="text-muted d-block">Trạng thái:</small>
                                                <div class="d-flex align-items-center">
                                                    <c:choose>
                                                        <c:when test="${notification.read}">
                                                            <i class="fas fa-check-circle text-success me-2"></i>
                                                            <span class="text-success fw-bold">Đã được đọc</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="fas fa-clock text-warning me-2"></i>
                                                            <span class="text-warning fw-bold">Chưa được đọc</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card-footer text-end">
                            <a href="${pageContext.request.contextPath}/admin/notifications" 
                               class="btn btn-primary">
                                <i class="fas fa-list"></i> Về danh sách thông báo
                            </a>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 