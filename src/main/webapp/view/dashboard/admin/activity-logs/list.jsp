<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhật ký hoạt động - Warehouse Management</title>
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .chart-container {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>
    
    <div class="main-content">
        <div class="page-header">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="mb-2">
                        <i class="bi bi-clock-history"></i> Nhật ký hoạt động
                    </h1>
                    <p class="mb-0">Theo dõi và quản lý tất cả các hoạt động trong hệ thống</p>
                </div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb bg-transparent mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/dashboard" class="text-white-50">Dashboard</a>
                        </li>
                        <li class="breadcrumb-item active text-white">Nhật ký hoạt động</li>
                    </ol>
                </nav>
            </div>
        </div>

        <!-- Quick Navigation -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3">
                                <a href="${pageContext.request.contextPath}/admin/activity-log?action=list" 
                                   class="btn btn-primary w-100 mb-2">
                                    <i class="bi bi-list"></i> Tất cả logs
                                </a>
                            </div>
                            <div class="col-md-3">
                                <a href="${pageContext.request.contextPath}/admin/activity-log?action=statistics" 
                                   class="btn btn-outline-info w-100 mb-2">
                                    <i class="bi bi-chart-bar"></i> Thống kê
                                </a>
                            </div>
                            <div class="col-md-3">
                                <a href="${pageContext.request.contextPath}/admin/activity-log?action=suspicious" 
                                   class="btn btn-outline-warning w-100 mb-2">
                                    <i class="bi bi-exclamation-triangle"></i> Hoạt động đáng nghi
                                </a>
                            </div>
                            <div class="col-md-3">
                                <a href="${pageContext.request.contextPath}/admin/activity-log?action=login-history" 
                                   class="btn btn-outline-success w-100 mb-2">
                                    <i class="bi bi-clock-history"></i> Lịch sử đăng nhập
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filter Form -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="bi bi-funnel"></i> Bộ lọc
                </h5>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/activity-log" method="GET">
                    <input type="hidden" name="action" value="list">
                    <div class="row">
                        <div class="col-md-2">
                            <label for="userId" class="form-label">Người dùng</label>
                            <select class="form-select" id="userId" name="userId">
                                <option value="">Tất cả người dùng</option>
                                                <c:forEach var="user" items="${users}">
                                                    <option value="${user.userId}" 
                                                            ${selectedUserId == user.userId ? 'selected' : ''}>
                                                        ${user.fullName}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                        <div class="col-md-2">
                            <label for="actionType" class="form-label">Loại hành động</label>
                            <select class="form-select" id="actionType" name="actionType">
                                <option value="">Tất cả hành động</option>
                                <option value="CREATE" ${selectedActionType == 'CREATE' ? 'selected' : ''}>Tạo mới</option>
                                <option value="UPDATE" ${selectedActionType == 'UPDATE' ? 'selected' : ''}>Cập nhật</option>
                                <option value="DELETE" ${selectedActionType == 'DELETE' ? 'selected' : ''}>Xóa</option>
                                <option value="ADJUST" ${selectedActionType == 'ADJUST' ? 'selected' : ''}>Điều chỉnh</option>
                                <option value="LOGIN" ${selectedActionType == 'LOGIN' ? 'selected' : ''}>Đăng nhập</option>
                                <option value="LOGOUT" ${selectedActionType == 'LOGOUT' ? 'selected' : ''}>Đăng xuất</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label for="entityType" class="form-label">Loại đối tượng</label>
                            <select class="form-select" id="entityType" name="entityType">
                                <option value="">Tất cả loại</option>
                                <option value="PRODUCT" ${selectedEntityType == 'PRODUCT' ? 'selected' : ''}>Sản phẩm</option>
                                <option value="INVENTORY" ${selectedEntityType == 'INVENTORY' ? 'selected' : ''}>Tồn kho</option>
                                <option value="STOCK_TAKE" ${selectedEntityType == 'STOCK_TAKE' ? 'selected' : ''}>Kiểm kê</option>
                                <option value="SALES_ORDER" ${selectedEntityType == 'SALES_ORDER' ? 'selected' : ''}>Đơn bán hàng</option>
    
                                <option value="USER" ${selectedEntityType == 'USER' ? 'selected' : ''}>Người dùng</option>
                                <option value="USER_SESSION" ${selectedEntityType == 'USER_SESSION' ? 'selected' : ''}>Phiên đăng nhập</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label for="startDate" class="form-label">Từ ngày</label>
                            <input type="date" class="form-control" id="startDate" name="startDate" 
                                   value="${selectedStartDate}">
                        </div>
                        <div class="col-md-2">
                            <label for="endDate" class="form-label">Đến ngày</label>
                            <input type="date" class="form-control" id="endDate" name="endDate" 
                                   value="${selectedEndDate}">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">&nbsp;</label>
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="bi bi-search"></i> Lọc
                            </button>
                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

        <!-- Results Summary -->
        <div class="row mb-3">
            <div class="col-12">
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i>
                    Hiển thị ${totalLogs} nhật ký hoạt động
                </div>
            </div>
        </div>

        <!-- Activity Logs Table -->
        <div class="chart-container">
            <h5 class="card-title mb-4">
                <i class="bi bi-table"></i> Danh sách nhật ký hoạt động
            </h5>
            
            <c:choose>
                <c:when test="${not empty activityLogs}">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Người dùng</th>
                                    <th>Hành động</th>
                                    <th>Đối tượng</th>
                                    <th>ID đối tượng</th>
                                    <th>Thay đổi</th>
                                    <th>Ghi chú</th>
                                    <th>Thời gian</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="log" items="${activityLogs}">
                                    <tr>
                                        <td>${log.id}</td>
                                        <td>
                                            <i class="bi bi-person-circle text-primary me-1"></i>
                                            <c:forEach var="user" items="${users}">
                                                <c:if test="${user.userId == log.userId}">
                                                    ${user.fullName}
                                                </c:if>
                                            </c:forEach>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.actionType == 'CREATE'}">
                                                    <span class="badge bg-success">Tạo mới</span>
                                                </c:when>
                                                <c:when test="${log.actionType == 'UPDATE'}">
                                                    <span class="badge bg-primary">Cập nhật</span>
                                                </c:when>
                                                <c:when test="${log.actionType == 'DELETE'}">
                                                    <span class="badge bg-danger">Xóa</span>
                                                </c:when>
                                                <c:when test="${log.actionType == 'ADJUST'}">
                                                    <span class="badge bg-warning">Điều chỉnh</span>
                                                </c:when>
                                                <c:when test="${log.actionType == 'LOGIN'}">
                                                    <span class="badge bg-info">Đăng nhập</span>
                                                </c:when>
                                                <c:when test="${log.actionType == 'LOGOUT'}">
                                                    <span class="badge bg-secondary">Đăng xuất</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-dark">${log.actionType}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <i class="bi bi-tag text-info me-1"></i>
                                            ${log.entityType}
                                        </td>
                                        <td>${log.entityId}</td>
                                        <td>
                                            <c:if test="${not empty log.oldValue}">
                                                <small class="text-muted">Trước:</small> ${log.oldValue}<br>
                                            </c:if>
                                            <c:if test="${not empty log.newValue}">
                                                <small class="text-success">Sau:</small> ${log.newValue}
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty log.note}">
                                                <i class="bi bi-chat-left-text text-muted me-1"></i>
                                                ${log.note}
                                            </c:if>
                                        </td>
                                        <td>
                                            <i class="bi bi-clock text-muted me-1"></i>
                                            <fmt:formatDate value="${log.timestamp}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                                            </table>
                                        </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <nav aria-label="Phân trang nhật ký hoạt động" class="mt-4">
                            <ul class="pagination justify-content-center">
                                <c:url value="/admin/activity-log" var="paginationUrl">
                                    <c:param name="action" value="list" />
                                    <c:if test="${not empty selectedUserId}">
                                        <c:param name="userId" value="${selectedUserId}" />
                                    </c:if>
                                    <c:if test="${not empty selectedActionType}">
                                        <c:param name="actionType" value="${selectedActionType}" />
                                    </c:if>
                                    <c:if test="${not empty selectedEntityType}">
                                        <c:param name="entityType" value="${selectedEntityType}" />
                                    </c:if>
                                    <c:if test="${not empty selectedStartDate}">
                                        <c:param name="startDate" value="${selectedStartDate}" />
                                    </c:if>
                                    <c:if test="${not empty selectedEndDate}">
                                        <c:param name="endDate" value="${selectedEndDate}" />
                                    </c:if>
                                </c:url>

                                <c:if test="${currentPage > 1}">
                                    <li class="page-item">
                                        <a class="page-link" href="${paginationUrl}&page=${currentPage - 1}">
                                            <i class="bi bi-chevron-left"></i> Trước
                                        </a>
                                    </li>
                                </c:if>

                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="${paginationUrl}&page=${i}">${i}</a>
                                    </li>
                                </c:forEach>

                                <c:if test="${currentPage < totalPages}">
                                    <li class="page-item">
                                        <a class="page-link" href="${paginationUrl}&page=${currentPage + 1}">
                                            Sau <i class="bi bi-chevron-right"></i>
                                        </a>
                                    </li>
                                </c:if>
                            </ul>
                        </nav>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="bi bi-inbox text-muted mb-3" style="font-size: 4rem;"></i>
                        <h5 class="text-muted">Không tìm thấy nhật ký hoạt động</h5>
                        <p class="text-muted">Thử điều chỉnh tiêu chí lọc của bạn.</p>
                        <div class="mt-3">
                            <a href="${pageContext.request.contextPath}/admin/activity-log?action=list" 
                               class="btn btn-primary">
                                <i class="bi bi-arrow-clockwise"></i> Làm mới
                            </a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set default dates if not set
        document.addEventListener('DOMContentLoaded', function() {
            const startDate = document.getElementById('startDate');
            const endDate = document.getElementById('endDate');
            
            if (!startDate.value) {
                const date = new Date();
                date.setDate(date.getDate() - 30); // Default to last 30 days
                startDate.value = date.toISOString().split('T')[0];
            }
            
            if (!endDate.value) {
                const today = new Date();
                endDate.value = today.toISOString().split('T')[0];
            }
        });
    </script>
</body>
</html> 