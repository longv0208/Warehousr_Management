<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thống kê hoạt động - Warehouse Management</title>
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
        
        .stats-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #007bff;
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
                        <i class="bi bi-chart-bar"></i> Thống kê hoạt động
                    </h1>
                    <p class="mb-0">Phân tích và báo cáo các hoạt động trong hệ thống</p>
                </div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb bg-transparent mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/dashboard" class="text-white-50">Dashboard</a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/activity-logs" class="text-white-50">Activity Logs</a>
                        </li>
                        <li class="breadcrumb-item active text-white">Thống kê</li>
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
                                   class="btn btn-primary w-100 mb-2">
                                    <i class="bi bi-chart-bar"></i> Thống kê
                                </a>
                            </div>
                            <div class="col-md-3">
                                <a href="${pageContext.request.contextPath}/activity-logs?action=suspicious" 
                                   class="btn btn-outline-warning w-100 mb-2">
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
                    <input type="hidden" name="action" value="statistics">
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
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="bi bi-search"></i> Lọc dữ liệu
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="stats-card text-primary">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Tổng hoạt động</h6>
                            <h3 class="mb-0">${statistics.size()}</h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-activity" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card text-success">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Hoạt động tạo mới</h6>
                            <h3 class="mb-0">
                                <c:set var="createCount" value="0"/>
                                <c:forEach var="stat" items="${statistics}">
                                    <c:if test="${stat[1] == 'CREATE'}">
                                        <c:set var="createCount" value="${createCount + stat[2]}"/>
                                    </c:if>
                                </c:forEach>
                                ${createCount}
                            </h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-plus-circle" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card text-warning">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Hoạt động điều chỉnh</h6>
                            <h3 class="mb-0">
                                <c:set var="adjustCount" value="0"/>
                                <c:forEach var="stat" items="${statistics}">
                                    <c:if test="${stat[1] == 'ADJUST'}">
                                        <c:set var="adjustCount" value="${adjustCount + stat[2]}"/>
                                    </c:if>
                                </c:forEach>
                                ${adjustCount}
                            </h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-gear" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card text-info">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Lượt đăng nhập</h6>
                            <h3 class="mb-0">
                                <c:set var="loginCount" value="0"/>
                                <c:forEach var="stat" items="${statistics}">
                                    <c:if test="${stat[1] == 'LOGIN'}">
                                        <c:set var="loginCount" value="${loginCount + stat[2]}"/>
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
        </div>

        <!-- Statistics Table -->
        <div class="chart-container">
            <h5 class="card-title mb-4">
                <i class="bi bi-table"></i> Chi tiết thống kê theo người dùng và loại hoạt động
            </h5>
            
            <c:choose>
                <c:when test="${not empty statistics}">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Người dùng</th>
                                    <th>Loại hoạt động</th>
                                    <th>Số lượng</th>
                                    <th>Tỷ lệ</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:set var="totalActions" value="0"/>
                                <c:forEach var="stat" items="${statistics}">
                                    <c:set var="totalActions" value="${totalActions + stat[2]}"/>
                                </c:forEach>
                                
                                <c:forEach var="stat" items="${statistics}">
                                    <tr>
                                        <td>
                                            <i class="bi bi-person-circle me-2"></i>
                                            ${stat[0]}
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${stat[1] == 'CREATE'}">
                                                    <span class="badge bg-success">${stat[1]}</span>
                                                </c:when>
                                                <c:when test="${stat[1] == 'UPDATE'}">
                                                    <span class="badge bg-primary">${stat[1]}</span>
                                                </c:when>
                                                <c:when test="${stat[1] == 'DELETE'}">
                                                    <span class="badge bg-danger">${stat[1]}</span>
                                                </c:when>
                                                <c:when test="${stat[1] == 'ADJUST'}">
                                                    <span class="badge bg-warning">${stat[1]}</span>
                                                </c:when>
                                                <c:when test="${stat[1] == 'LOGIN'}">
                                                    <span class="badge bg-info">${stat[1]}</span>
                                                </c:when>
                                                <c:when test="${stat[1] == 'LOGOUT'}">
                                                    <span class="badge bg-secondary">${stat[1]}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-dark">${stat[1]}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <strong>${stat[2]}</strong>
                                        </td>
                                        <td>
                                            <fmt:formatNumber value="${(stat[2] / totalActions) * 100}" 
                                                              maxFractionDigits="1"/>%
                                            <div class="progress mt-1" style="height: 5px;">
                                                <div class="progress-bar" 
                                                     style="width: ${(stat[2] / totalActions) * 100}%"></div>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="bi bi-inbox fa-3x text-muted mb-3" style="font-size: 3rem;"></i>
                        <h5 class="text-muted">Không có dữ liệu thống kê</h5>
                        <p class="text-muted">Hãy thử thay đổi bộ lọc thời gian để xem dữ liệu.</p>
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
                const firstDayOfMonth = new Date();
                firstDayOfMonth.setDate(1);
                startDate.value = firstDayOfMonth.toISOString().split('T')[0];
            }
            
            if (!endDate.value) {
                const today = new Date();
                endDate.value = today.toISOString().split('T')[0];
            }
        });
    </script>
</body>
</html> 