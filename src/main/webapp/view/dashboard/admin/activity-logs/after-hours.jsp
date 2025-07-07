<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập ngoài giờ - Warehouse Management</title>
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
            background: linear-gradient(135deg, #fd7e14 0%, #ffc107 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .alert-item {
            background: white;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #fd7e14;
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
                        <i class="bi bi-moon-stars"></i> Đăng nhập ngoài giờ
                    </h1>
                    <p class="mb-0">Các phiên đăng nhập được ghi lại ngoài giờ làm việc (8h-18h)</p>
                </div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb bg-transparent mb-0">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/dashboard" class="text-white-50">Dashboard</a>
                        </li>
                        <li class="breadcrumb-item active text-white">Đăng nhập ngoài giờ</li>
                    </ol>
                </nav>
            </div>
        </div>

        <!-- Date Filter -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="bi bi-calendar-range"></i> Lọc theo ngày
                </h5>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/activity-log" method="GET">
                    <input type="hidden" name="action" value="after-hours">
                    <div class="row">
                        <div class="col-md-5">
                            <label for="startDate" class="form-label">Từ ngày</label>
                            <input type="date" class="form-control" id="startDate" name="startDate" value="${startDate}">
                        </div>
                        <div class="col-md-5">
                            <label for="endDate" class="form-label">Đến ngày</label>
                            <input type="date" class="form-control" id="endDate" name="endDate" value="${endDate}">
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <button type="submit" class="btn btn-warning w-100">
                                <i class="bi bi-search"></i> Lọc
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- After Hours Logins List -->
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="bi bi-list-ul"></i> Danh sách đăng nhập ngoài giờ
                </h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty afterHoursLogins}">
                        <div class="list-group">
                            <c:forEach var="activity" items="${afterHoursLogins}">
                                <div class="list-group-item list-group-item-action flex-column align-items-start alert-item">
                                    <div class="d-flex w-100 justify-content-between">
                                        <h5 class="mb-1">
                                            <i class="bi bi-person-circle text-warning"></i>
                                            <c:forEach var="user" items="${users}">
                                                <c:if test="${user.userId == activity.userId}">
                                                    ${user.fullName}
                                                </c:if>
                                            </c:forEach>
                                        </h5>
                                        <small class="text-muted"><fmt:formatDate value="${activity.timestamp}" pattern="dd/MM/yyyy HH:mm:ss"/></small>
                                    </div>
                                    <p class="mb-1">${activity.note}</p>
                                    <small class="text-muted">ID người dùng: ${activity.userId}</small>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5">
                            <i class="bi bi-check-circle-fill text-success" style="font-size: 4rem;"></i>
                            <h5 class="mt-3">Không có hoạt động ngoài giờ</h5>
                            <p class="text-muted">Không tìm thấy lần đăng nhập nào ngoài giờ làm việc trong khoảng thời gian đã chọn.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="card-footer">
                    <nav aria-label="Page navigation">
                        <ul class="pagination justify-content-center mb-0">
                            <%-- Previous Button --%>
                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=after-hours&page=${currentPage - 1}&startDate=${startDate}&endDate=${endDate}">Previous</a>
                                </li>
                            </c:if>

                            <%-- Pagination Window Logic --%>
                            <c:set var="maxVisiblePages" value="5"/>
                            <c:set var="startPage" value="1"/>
                            <c:set var="endPage" value="${totalPages}"/>

                            <c:if test="${totalPages > maxVisiblePages}">
                                <c:set var="startPage" value="${currentPage - 2}"/>
                                <c:set var="endPage" value="${currentPage + 2}"/>
                                <c:if test="${startPage < 1}">
                                    <c:set var="startPage" value="1"/>
                                    <c:set var="endPage" value="${maxVisiblePages}"/>
                                </c:if>
                                <c:if test="${endPage > totalPages}">
                                    <c:set var="endPage" value="${totalPages}"/>
                                    <c:set var="startPage" value="${totalPages - maxVisiblePages + 1}"/>
                                </c:if>
                            </c:if>

                            <%-- First Page and Ellipsis --%>
                            <c:if test="${startPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=after-hours&page=1&startDate=${startDate}&endDate=${endDate}">1</a>
                                </li>
                                <c:if test="${startPage > 2}">
                                    <li class="page-item disabled"><span class="page-link">...</span></li>
                                </c:if>
                            </c:if>

                            <%-- Page Numbers --%>
                            <c:forEach begin="${startPage}" end="${endPage}" var="i">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=after-hours&page=${i}&startDate=${startDate}&endDate=${endDate}">${i}</a>
                                </li>
                            </c:forEach>

                            <%-- Last Page and Ellipsis --%>
                            <c:if test="${endPage < totalPages}">
                                <c:if test="${endPage < totalPages - 1}">
                                    <li class="page-item disabled"><span class="page-link">...</span></li>
                                </c:if>
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=after-hours&page=${totalPages}&startDate=${startDate}&endDate=${endDate}">${totalPages}</a>
                                </li>
                            </c:if>

                            <%-- Next Button --%>
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/activity-log?action=after-hours&page=${currentPage + 1}&startDate=${startDate}&endDate=${endDate}">Next</a>
                                </li>
                            </c:if>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 