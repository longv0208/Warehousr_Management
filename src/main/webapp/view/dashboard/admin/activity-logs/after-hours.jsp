<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hoạt động ngoài giờ - Warehouse Management</title>
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
            background: linear-gradient(135deg, #4a00e0 0%, #8e2de2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .night-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #6f42c1;
        }
        
        .activity-item {
            background: white;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #6f42c1;
        }
        
        .time-early {
            border-left-color: #dc3545; /* Red for very early */
        }
        
        .time-late {
            border-left-color: #fd7e14; /* Orange for late night */
        }
        
        .time-weekend {
            border-left-color: #6f42c1; /* Purple for weekend */
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
                        <i class="bi bi-moon"></i> Hoạt động ngoài giờ
                    </h1>
                    <p class="mb-0">Theo dõi các hoạt động diễn ra ngoài giờ làm việc (8:00 - 18:00)</p>
                </div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb bg-transparent mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/dashboard" class="text-white-50">Dashboard</a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/activity-logs" class="text-white-50">Activity Logs</a>
                        </li>
                        <li class="breadcrumb-item active text-white">Hoạt động ngoài giờ</li>
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
                                   class="btn btn-outline-warning w-100 mb-2">
                                    <i class="bi bi-exclamation-triangle"></i> Hoạt động đáng nghi
                                </a>
                            </div>
                            <div class="col-md-3">
                                <a href="${pageContext.request.contextPath}/activity-logs?action=after-hours" 
                                   class="btn btn-secondary w-100 mb-2">
                                    <i class="bi bi-moon"></i> Hoạt động ngoài giờ
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
                    <input type="hidden" name="action" value="after-hours">
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
                            <button type="submit" class="btn btn-secondary w-100">
                                <i class="bi bi-search"></i> Tìm hoạt động ngoài giờ
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Summary Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="night-card text-primary">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Tổng hoạt động</h6>
                            <h3 class="mb-0">${afterHoursActivities.size()}</h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-clock" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="night-card text-danger">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Sáng sớm (0h-8h)</h6>
                            <h3 class="mb-0">
                                <c:set var="earlyCount" value="0"/>
                                <c:forEach var="activity" items="${afterHoursActivities}">
                                    <fmt:formatDate value="${activity.createdAt}" pattern="HH" var="hour"/>
                                    <c:if test="${hour >= 0 && hour < 8}">
                                        <c:set var="earlyCount" value="${earlyCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${earlyCount}
                            </h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-sunrise" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="night-card text-warning">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Tối muộn (18h-24h)</h6>
                            <h3 class="mb-0">
                                <c:set var="lateCount" value="0"/>
                                <c:forEach var="activity" items="${afterHoursActivities}">
                                    <fmt:formatDate value="${activity.createdAt}" pattern="HH" var="hour"/>
                                    <c:if test="${hour >= 18 && hour <= 23}">
                                        <c:set var="lateCount" value="${lateCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${lateCount}
                            </h3>
                        </div>
                        <div class="align-self-center">
                            <i class="bi bi-moon-stars" style="font-size: 2rem;"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="night-card text-info">
                    <div class="d-flex justify-content-between">
                        <div>
                            <h6>Người dùng riêng biệt</h6>
                            <h3 class="mb-0">
                                <c:set var="uniqueUsers" value="${java.util.LinkedHashSet()}"/>
                                <c:forEach var="activity" items="${afterHoursActivities}">
                                    <c:set var="added" value="${uniqueUsers.add(activity.username)}"/>
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

        <!-- Working Hours Info -->
        <div class="card mb-4">
            <div class="card-header bg-info text-white">
                <h5 class="card-title mb-0">
                    <i class="bi bi-info-circle"></i> Thông tin giờ làm việc
                </h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-4">
                        <div class="text-center">
                            <i class="bi bi-sun text-warning" style="font-size: 2rem;"></i>
                            <h6 class="mt-2">Giờ làm việc</h6>
                            <p class="text-muted">8:00 - 18:00 (Thứ 2 - Thứ 6)</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="text-center">
                            <i class="bi bi-moon text-primary" style="font-size: 2rem;"></i>
                            <h6 class="mt-2">Ngoài giờ</h6>
                            <p class="text-muted">18:00 - 8:00 & Cuối tuần</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="text-center">
                            <i class="bi bi-shield-check text-success" style="font-size: 2rem;"></i>
                            <h6 class="mt-2">Mục đích</h6>
                            <p class="text-muted">Kiểm soát bảo mật và audit</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- After Hours Activities List -->
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="bi bi-list-ul"></i> Danh sách hoạt động ngoài giờ
                </h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty afterHoursActivities}">
                        <c:forEach var="activity" items="${afterHoursActivities}">
                            <fmt:formatDate value="${activity.createdAt}" pattern="HH" var="hour"/>
                            <fmt:formatDate value="${activity.createdAt}" pattern="u" var="dayOfWeek"/>
                            
                            <div class="activity-item 
                                <c:choose>
                                    <c:when test="${hour >= 0 && hour < 8}">time-early</c:when>
                                    <c:when test="${hour >= 18 && hour <= 23}">time-late</c:when>
                                    <c:when test="${dayOfWeek == 6 || dayOfWeek == 7}">time-weekend</c:when>
                                </c:choose>">
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="d-flex align-items-center mb-2">
                                            <c:choose>
                                                <c:when test="${hour >= 0 && hour < 8}">
                                                    <span class="badge bg-danger me-2">
                                                        <i class="bi bi-sunrise"></i> Sáng sớm
                                                    </span>
                                                </c:when>
                                                <c:when test="${hour >= 18 && hour <= 23}">
                                                    <span class="badge bg-warning me-2">
                                                        <i class="bi bi-moon"></i> Tối muộn
                                                    </span>
                                                </c:when>
                                                <c:when test="${dayOfWeek == 6 || dayOfWeek == 7}">
                                                    <span class="badge bg-secondary me-2">
                                                        <i class="bi bi-calendar-x"></i> Cuối tuần
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-primary me-2">
                                                        <i class="bi bi-clock"></i> Ngoài giờ
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                            <strong>${activity.actionType}</strong>
                                        </div>
                                        
                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="mb-1">
                                                    <i class="bi bi-person-circle text-primary"></i>
                                                    <strong>Người dùng:</strong> ${activity.username}
                                                </div>
                                                <div class="mb-1">
                                                    <i class="bi bi-calendar text-success"></i>
                                                    <strong>Thời gian:</strong> 
                                                    <fmt:formatDate value="${activity.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="mb-1">
                                                    <i class="bi bi-tag text-info"></i>
                                                    <strong>Đối tượng:</strong> ${activity.entityType}
                                                </div>
                                                <c:if test="${not empty activity.description}">
                                                    <div class="mb-1">
                                                        <i class="bi bi-chat-left-text text-muted"></i>
                                                        <strong>Mô tả:</strong> ${activity.description}
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="d-grid gap-2">
                                            <a href="${pageContext.request.contextPath}/activity-logs?action=list&userId=${activity.userId}&startDate=${activity.createdAt}&endDate=${activity.createdAt}" 
                                               class="btn btn-outline-primary btn-sm">
                                                <i class="bi bi-eye"></i> Xem chi tiết
                                            </a>
                                            <small class="text-muted">
                                                <fmt:formatDate value="${activity.createdAt}" pattern="EEEE"/>
                                            </small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5">
                            <i class="bi bi-moon-stars text-muted mb-3" style="font-size: 4rem;"></i>
                            <h5 class="text-muted">Không có hoạt động ngoài giờ</h5>
                            <p class="text-muted">Tất cả hoạt động đều diễn ra trong giờ làm việc bình thường.</p>
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