<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hoạt động đáng nghi - Warehouse Management</title>
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
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .warning-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #ffc107;
        }
        
        .alert-item {
            background: white;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #dc3545;
        }
        
        .severity-high {
            border-left-color: #dc3545;
        }
        
        .severity-medium {
            border-left-color: #ffc107;
        }
        
        .severity-low {
            border-left-color: #28a745;
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
                        <i class="bi bi-exclamation-triangle"></i> Hoạt động đáng nghi
                    </h1>
                    <p class="mb-0">Phát hiện và cảnh báo các hoạt động bất thường trong hệ thống</p>
                </div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb bg-transparent mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/dashboard" class="text-white-50">Dashboard</a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/activity-logs" class="text-white-50">Activity Logs</a>
                        </li>
                        <li class="breadcrumb-item active text-white">Hoạt động đáng nghi</li>
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
                                <a href="${pageContext.request.contextPath}/activity-logs?action=list" 
                                   class="btn btn-outline-primary w-100 mb-2">
                                    <i class="bi bi-list"></i> Tất cả logs
                                </a>
                            </div>
                            <div class="col-md-3">
                                <a href="${pageContext.request.contextPath}/activity-logs?action=statistics" 
                                   class="btn btn-outline-info w-100 mb-2">
                                    <i class="bi bi-chart-bar"></i> Thống kê
                                </a>
                            </div>
                            <div class="col-md-3">
                                <a href="${pageContext.request.contextPath}/activity-logs?action=suspicious" 
                                   class="btn btn-warning w-100 mb-2">
                                    <i class="bi bi-exclamation-triangle"></i> Hoạt động đáng nghi
                                </a>
                            </div>
                            <div class="col-md-3">
                                <a href="${pageContext.request.contextPath}/activity-logs?action=login-history" 
                                   class="btn btn-outline-success w-100 mb-2">
                                    <i class="bi bi-clock-history"></i> Lịch sử đăng nhập
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Date Filter -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="bi bi-calendar"></i> Bộ lọc thời gian
                </h5>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/activity-logs" method="GET">
                    <input type="hidden" name="action" value="suspicious">
                    <div class="row">
                        <div class="col-md-4">
                            <label for="startDate" class="form-label">Từ ngày</label>
                            <input type="date" class="form-control" id="startDate" name="startDate" 
                                   value="${startDate}">
                        </div>
                        <div class="col-md-4">
                            <label for="endDate" class="form-label">Đến ngày</label>
                            <input type="date" class="form-control" id="endDate" name="endDate" 
                                   value="${endDate}">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">&nbsp;</label>
                            <button type="submit" class="btn btn-warning w-100">
                                <i class="bi bi-search"></i> Kiểm tra hoạt động đáng nghi
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Alert Summary -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="warning-card text-danger">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Tổng cảnh báo</h6>
                            <h3 class="mb-0">${suspiciousActivities.size()}</h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-shield-exclamation" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="warning-card text-warning">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Điều chỉnh kho bất thường</h6>
                            <h3 class="mb-0">${suspiciousActivities.size()}</h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-gear-wide-connected" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="warning-card text-info">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Người dùng có hoạt động đáng nghi</h6>
                            <h3 class="mb-0">
                                <c:set var="uniqueUsers" value="${java.util.LinkedHashSet()}"/>
                                <c:forEach var="activity" items="${suspiciousActivities}">
                                    <c:set var="added" value="${uniqueUsers.add(activity[0])}"/>
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

        <!-- Security Guidelines -->
        <div class="card mb-4">
            <div class="card-header bg-warning text-dark">
                <h5 class="card-title mb-0">
                    <i class="bi bi-info-circle"></i> Hướng dẫn an ninh
                </h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <h6><i class="bi bi-shield-check text-success"></i> Tiêu chí phát hiện:</h6>
                        <ul class="list-unstyled">
                            <li><i class="bi bi-dot"></i> Hơn 5 lần điều chỉnh kho trong 1 ngày</li>
                            <li><i class="bi bi-dot"></i> Hoạt động ngoài giờ làm việc (8h-18h)</li>
                            <li><i class="bi bi-dot"></i> Thay đổi số lượng lớn bất thường</li>
                        </ul>
                    </div>
                    <div class="col-md-6">
                        <h6><i class="bi bi-exclamation-triangle text-warning"></i> Khuyến nghị:</h6>
                        <ul class="list-unstyled">
                            <li><i class="bi bi-dot"></i> Xem xét lại quyền truy cập của nhân viên</li>
                            <li><i class="bi bi-dot"></i> Kiểm tra log chi tiết của hoạt động</li>
                            <li><i class="bi bi-dot"></i> Liên hệ trực tiếp với nhân viên để xác minh</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <!-- Suspicious Activities List -->
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="bi bi-list-ul"></i> Danh sách hoạt động đáng nghi
                </h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty suspiciousActivities}">
                        <c:forEach var="activity" items="${suspiciousActivities}">
                            <div class="alert-item severity-high">
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="d-flex align-items-center mb-2">
                                            <div class="badge bg-danger me-2">
                                                <i class="bi bi-exclamation-triangle"></i> Mức độ cao
                                            </div>
                                            <strong class="text-danger">Quá nhiều điều chỉnh kho</strong>
                                        </div>
                                        <div class="mb-2">
                                            <i class="bi bi-person-circle text-primary"></i>
                                            <strong>Nhân viên:</strong> ${activity[0]}
                                        </div>
                                        <div class="mb-2">
                                            <i class="bi bi-calendar text-success"></i>
                                            <strong>Ngày:</strong> ${startDate}
                                        </div>
                                        <div class="mb-2">
                                            <i class="bi bi-gear text-warning"></i>
                                            <strong>Số lần điều chỉnh:</strong> 
                                            <span class="badge bg-warning text-dark">${activity[1]} lần</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="d-grid gap-2">
                                            <a href="${pageContext.request.contextPath}/activity-logs?action=list&actionType=ADJUST&startDate=${startDate}&endDate=${endDate}" 
                                               class="btn btn-outline-primary btn-sm">
                                                <i class="bi bi-eye"></i> Xem chi tiết
                                            </a>
                                            <a href="${pageContext.request.contextPath}/activity-logs?action=list" 
                                               class="btn btn-outline-info btn-sm">
                                                <i class="bi bi-person"></i> Tất cả hoạt động
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5">
                            <i class="bi bi-shield-check text-success mb-3" style="font-size: 4rem;"></i>
                            <h5 class="text-success">Không phát hiện hoạt động đáng nghi</h5>
                            <p class="text-muted">Tất cả hoạt động trong khoảng thời gian này đều bình thường.</p>
                            <div class="mt-3">
                                <a href="${pageContext.request.contextPath}/activity-logs?action=list" 
                                   class="btn btn-primary">
                                    <i class="bi bi-list"></i> Xem tất cả logs
                                </a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Additional Security Checks -->
        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h6 class="card-title mb-0">
                            <i class="bi bi-clock"></i> Hoạt động ngoài giờ
                        </h6>
                    </div>
                    <div class="card-body">
                        <p class="text-muted">Kiểm tra các hoạt động diễn ra ngoài giờ làm việc (8h-18h)</p>
                        <a href="${pageContext.request.contextPath}/activity-logs?action=after-hours" 
                           class="btn btn-outline-warning w-100">
                            <i class="bi bi-moon"></i> Xem hoạt động ngoài giờ
                        </a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h6 class="card-title mb-0">
                            <i class="bi bi-graph-up"></i> Phân tích xu hướng
                        </h6>
                    </div>
                    <div class="card-body">
                        <p class="text-muted">Xem thống kê và xu hướng hoạt động của nhân viên</p>
                        <a href="${pageContext.request.contextPath}/activity-logs?action=statistics" 
                           class="btn btn-outline-info w-100">
                            <i class="bi bi-chart-line"></i> Xem thống kê
                        </a>
                    </div>
                </div>
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
    </script>
</body>
</html> 