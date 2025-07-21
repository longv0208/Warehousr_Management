<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử Đăng nhập / Đăng xuất - Warehouse Management</title>
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
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .auth-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #28a745;
        }
        
        .login-item {
            background: white;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #28a745;
        }
        
        .logout-item {
            background: white;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #dc3545;
        }
        
        .session-active {
            border-left-color: #28a745;
        }
        
        .session-ended {
            border-left-color: #6c757d;
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
                        <i class="bi bi-clock-history"></i> Lịch sử Đăng nhập / Đăng xuất
                    </h1>
                    <p class="mb-0">Theo dõi các phiên đăng nhập và đăng xuất của người dùng</p>
                </div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb bg-transparent mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/dashboard" class="text-white-50">Dashboard</a>
                        </li>
                        <li class="breadcrumb-item active text-white">Lịch sử đăng nhập</li>
                    </ol>
                </nav>
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
                    <input type="hidden" name="action" value="login-history">
                    <div class="row">
                        <div class="col-md-3">
                            <label for="startDate" class="form-label">Từ ngày</label>
                            <input type="date" class="form-control" id="startDate" name="startDate" 
                                   value="${selectedStartDate}">
                        </div>
                        <div class="col-md-3">
                            <label for="endDate" class="form-label">Đến ngày</label>
                            <input type="date" class="form-control" id="endDate" name="endDate" 
                                   value="${selectedEndDate}">
                        </div>
                        <div class="col-md-3">
                            <label for="userId" class="form-label">Người dùng</label>
                            <select class="form-select" id="userId" name="userId">
                                <option value="">Tất cả người dùng</option>
                                <c:forEach var="user" items="${users}">
                                    <option value="${user.userId}" <c:if test="${selectedUserId == user.userId}">selected</c:if>>
                                        ${user.fullName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">&nbsp;</label>
                            <button type="submit" class="btn btn-success w-100">
                                <i class="bi bi-search"></i> Tìm kiếm
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="auth-card text-primary">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Tổng phiên đăng nhập</h6>
                            <h3 class="mb-0">
                                <c:set var="loginCount" value="0"/>
                                <c:forEach var="activity" items="${loginHistory}">
                                    <c:if test="${activity.actionType == 'LOGIN'}">
                                        <c:set var="loginCount" value="${loginCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${loginCount}
                            </h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-box-arrow-in-right" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="auth-card text-success">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Đăng xuất bình thường</h6>
                            <h3 class="mb-0">
                                <c:set var="logoutCount" value="0"/>
                                <c:forEach var="activity" items="${loginHistory}">
                                    <c:if test="${activity.actionType == 'LOGOUT'}">
                                        <c:set var="logoutCount" value="${logoutCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${logoutCount}
                            </h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-box-arrow-left" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="auth-card text-warning">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Phiên chưa kết thúc</h6>
                            <h3 class="mb-0">${loginCount - logoutCount}</h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-exclamation-triangle" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="auth-card text-info">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Người dùng riêng biệt</h6>
                            <h3 class="mb-0">
                                <c:set var="uniqueUsers" value="${java.util.LinkedHashSet()}"/>
                                <c:forEach var="activity" items="${loginHistory}">
                                    <c:set var="added" value="${uniqueUsers.add(activity.userId)}"/>
                                </c:forEach>
                                ${uniqueUsers.size()}
                            </h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-people" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Security Notice -->
        <div class="card mb-4">
            <div class="card-header bg-warning text-dark">
                <h5 class="card-title mb-0">
                    <i class="bi bi-shield-exclamation"></i> Lưu ý bảo mật
                </h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-4">
                        <h6><i class="bi bi-check-circle text-success"></i> Dấu hiệu bình thường:</h6>
                        <ul class="list-unstyled">
                            <li><i class="bi bi-dot"></i> Đăng nhập trong giờ làm việc</li>
                            <li><i class="bi bi-dot"></i> Có phiên đăng xuất tương ứng</li>
                            <li><i class="bi bi-dot"></i> Thời gian phiên hợp lý</li>
                        </ul>
                    </div>
                    <div class="col-md-4">
                        <h6><i class="bi bi-exclamation-triangle text-warning"></i> Cần chú ý:</h6>
                        <ul class="list-unstyled">
                            <li><i class="bi bi-dot"></i> Đăng nhập ngoài giờ</li>
                            <li><i class="bi bi-dot"></i> Phiên không có đăng xuất</li>
                            <li><i class="bi bi-dot"></i> Đăng nhập liên tiếp</li>
                        </ul>
                    </div>
                    <div class="col-md-4">
                        <h6><i class="bi bi-shield-slash text-danger"></i> Đáng nghi:</h6>
                        <ul class="list-unstyled">
                            <li><i class="bi bi-dot"></i> Nhiều lần đăng nhập thất bại</li>
                            <li><i class="bi bi-dot"></i> Đăng nhập từ nhiều vị trí</li>
                            <li><i class="bi bi-dot"></i> Phiên quá dài hoặc quá ngắn</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <!-- Login History List -->
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="bi bi-list-ul"></i> Danh sách lịch sử đăng nhập
                </h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty loginHistory}">
                        <c:forEach var="activity" items="${loginHistory}">
                            <div class="${activity.actionType == 'LOGIN' ? 'login-item' : 'logout-item'}">
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="d-flex align-items-center mb-2">
                                            <c:choose>
                                                <c:when test="${activity.actionType == 'LOGIN'}">
                                                    <span class="badge bg-success me-2">
                                                        <i class="bi bi-box-arrow-in-right"></i> Đăng nhập
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger me-2">
                                                        <i class="bi bi-box-arrow-left"></i> Đăng xuất
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                            <strong>
                                                <c:forEach var="user" items="${users}">
                                                    <c:if test="${user.userId == activity.userId}">
                                                        ${user.fullName}
                                                    </c:if>
                                                </c:forEach>
                                            </strong>
                                        </div>
                                        
                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="mb-1">
                                                    <i class="bi bi-calendar-event text-primary"></i>
                                                    <strong>Thời gian:</strong> 
                                                    <fmt:formatDate value="${activity.timestamp}" pattern="dd/MM/yyyy"/>
                                                </div>
                                                <div class="mb-1">
                                                    <i class="bi bi-clock text-success"></i>
                                                    <strong>Giờ:</strong> 
                                                    <fmt:formatDate value="${activity.timestamp}" pattern="HH:mm:ss"/>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <c:if test="${not empty activity.note}">
                                                    <div class="mb-1">
                                                        <i class="bi bi-info-circle text-info"></i>
                                                        <strong>Chi tiết:</strong> ${activity.note}
                                                    </div>
                                                </c:if>
                                                <div class="mb-1">
                                                    <fmt:formatDate value="${activity.timestamp}" pattern="EEEE" var="dayOfWeek"/>
                                                    <fmt:formatDate value="${activity.timestamp}" pattern="HH" var="hour"/>
                                                    <i class="bi bi-calendar text-muted"></i>
                                                    <small class="text-muted">${dayOfWeek}</small>
                                                    <c:if test="${hour < 8 || hour >= 18}">
                                                        <span class="badge bg-warning text-dark ms-2">Ngoài giờ</span>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="d-grid gap-2">
                                            <c:if test="${activity.actionType == 'LOGIN'}">
                                                <a href="${pageContext.request.contextPath}/admin/activity-log?action=view-session&userId=${activity.userId}&timestamp=${activity.timestamp.time}" 
                                                   class="btn btn-outline-primary btn-sm">
                                                    <i class="bi bi-eye"></i> Xem session
                                                </a>
                                            </c:if>
                                            <small class="text-muted text-center">
                                                ID: ${activity.userId}
                                            </small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5">
                            <i class="bi bi-clock-history text-muted mb-3" style="font-size: 4rem;"></i>
                            <h5 class="text-muted">Không có lịch sử đăng nhập</h5>
                            <p class="text-muted">Không tìm thấy hoạt động đăng nhập/đăng xuất nào trong khoảng thời gian này.</p>
                            <div class="mt-3">
                                <a href="${pageContext.request.contextPath}/admin/activity-log?action=list&actionType=LOGIN" 
                                   class="btn btn-success me-2">
                                    <i class="bi bi-box-arrow-in-right"></i> Tất cả đăng nhập
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/activity-log?action=list" 
                                   class="btn btn-primary">
                                    <i class="bi bi-list"></i> Tất cả logs
                                </a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="card-footer bg-light">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center mb-0">
                        <%-- Logic for smart pagination --%>
                        <c:set var="currentPage" value="${requestScope.currentPage}" />
                        <c:set var="totalPages" value="${requestScope.totalPages}" />
                        <c:set var="maxPagesToShow" value="5" />
                        <c:set var="halfPages" value="${maxPagesToShow / 2}" />

                        <c:set var="startPage" value="${currentPage - halfPages}" />
                        <c:set var="endPage" value="${currentPage + halfPages}" />

                        <c:if test="${startPage < 1}">
                            <c:set var="startPage" value="1" />
                            <c:set var="endPage" value="${totalPages < maxPagesToShow ? totalPages : maxPagesToShow}" />
                        </c:if>

                        <c:if test="${endPage > totalPages}">
                            <c:set var="endPage" value="${totalPages}" />
                            <c:set var="startPage" value="${totalPages - maxPagesToShow + 1 < 1 ? 1 : totalPages - maxPagesToShow + 1}" />
                        </c:if>

                        <%-- Previous Page Link --%>
                        <c:if test="${currentPage > 1}">
                            <li class="page-item">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=login-history&page=1&userId=${selectedUserId}&startDate=${selectedStartDate}&endDate=${selectedEndDate}">Trang đầu</a>
                            </li>
                            <li class="page-item">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=login-history&page=${currentPage - 1}&userId=${selectedUserId}&startDate=${selectedStartDate}&endDate=${selectedEndDate}" aria-label="Previous">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>
                        </c:if>

                        <%-- Ellipsis at the beginning --%>
                        <c:if test="${startPage > 1}">
                            <li class="page-item disabled"><a class="page-link" href="#">...</a></li>
                        </c:if>

                        <%-- Page Number Links --%>
                        <c:forEach begin="${startPage}" end="${endPage}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=login-history&page=${i}&userId=${selectedUserId}&startDate=${selectedStartDate}&endDate=${selectedEndDate}">${i}</a>
                            </li>
                        </c:forEach>

                        <%-- Ellipsis at the end --%>
                        <c:if test="${endPage < totalPages}">
                            <li class="page-item disabled"><a class="page-link" href="#">...</a></li>
                        </c:if>

                        <%-- Next Page Link --%>
                        <c:if test="${currentPage < totalPages}">
                            <li class="page-item">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=login-history&page=${currentPage + 1}&userId=${selectedUserId}&startDate=${selectedStartDate}&endDate=${selectedEndDate}" aria-label="Next">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                             <li class="page-item">
                                <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=login-history&page=${totalPages}&userId=${selectedUserId}&startDate=${selectedStartDate}&endDate=${selectedEndDate}">Trang cuối</a>
                            </li>
                        </c:if>
                    </ul>
                </nav>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set default dates to last 7 days
        document.addEventListener('DOMContentLoaded', function() {
            const startDate = document.getElementById('startDate');
            const endDate = document.getElementById('endDate');
            
            if (!startDate.value) {
                const date = new Date();
                date.setDate(date.getDate() - 7);
                startDate.value = date.toISOString().split('T')[0];
            }
            
            if (!endDate.value) {
                const today = new Date();
                endDate.value = today.toISOString().split('T')[0];
            }
        });

        // Real-time clock
        function updateTime() {
            const now = new Date();
            const timeString = now.toLocaleTimeString('vi-VN');
            const dateString = now.toLocaleDateString('vi-VN');
            
            // Add to header if there's a clock element
            const clockElement = document.getElementById('current-time');
            if (clockElement) {
                clockElement.textContent = `${dateString} ${timeString}`;
            }
        }
        
        // Update time every second
        setInterval(updateTime, 1000);
        updateTime(); // Initial call
    </script>
</body>
</html>
