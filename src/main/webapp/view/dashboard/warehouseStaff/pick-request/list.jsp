<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Yêu Cầu Lấy Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <div class="d-flex">
        <!-- Sidebar -->
        <jsp:include page="../../../common/sidebar.jsp" />
        
        <!-- Main Content -->
        <div class="main-content" style="margin-left: 250px; padding: 20px; width: calc(100% - 250px);">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="mb-1">Quản Lý Yêu Cầu Lấy Hàng</h2>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/warehouse-staff">Dashboard</a></li>
                            <li class="breadcrumb-item active">Yêu Cầu Lấy Hàng</li>
                        </ol>
                    </nav>
                </div>
                <a href="${pageContext.request.contextPath}/warehouse-staff?action=pending-sales-orders" 
                   class="btn btn-primary">
                    <i class="bi bi-plus-circle me-2"></i>Tạo Yêu Cầu Mới
                </a>
            </div>

            <!-- Statistics Cards -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card bg-warning text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${pendingCount != null ? pendingCount : 0}</h4>
                                    <p class="mb-0">Chờ Xử Lý</p>
                                </div>
                                <i class="bi bi-hourglass-split fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card bg-info text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${inProgressCount != null ? inProgressCount : 0}</h4>
                                    <p class="mb-0">Đang Thực Hiện</p>
                                </div>
                                <i class="bi bi-arrow-repeat fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card bg-success text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${completedCount != null ? completedCount : 0}</h4>
                                    <p class="mb-0">Hoàn Thành</p>
                                </div>
                                <i class="bi bi-check-circle fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card bg-primary text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${pickRequests.size()}</h4>
                                    <p class="mb-0">Tổng Số</p>
                                </div>
                                <i class="bi bi-list-check fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pick Requests List -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Danh Sách Yêu Cầu Lấy Hàng</h5>
                    <span class="badge bg-primary">${pickRequests.size()} yêu cầu</span>
                </div>
                <div class="card-body">
                    <c:if test="${empty pickRequests}">
                        <div class="text-center py-4">
                            <i class="bi bi-inbox fs-1 text-muted"></i>
                            <p class="text-muted mt-2">Chưa có yêu cầu lấy hàng nào</p>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty pickRequests}">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>STT</th>
                                        <th>Mã Pick Request</th>
                                        <th>Mã Đơn Hàng</th>
                                        <th>Kho</th>
                                        <th>Ngày Tạo</th>
                                        <th>Người Tạo</th>
                                        <th>Trạng Thái</th>
                                        <th>Tiến Độ</th>
                                        <th>Hành Động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="pickRequest" items="${pickRequests}" varStatus="status">
                                        <tr>
                                            <td>${status.index + 1}</td>
                                            <td>
                                                <span class="fw-bold text-primary">${pickRequest.pickRequestCode}</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty pickRequest.salesOrder}">
                                                        <span class="fw-bold">${pickRequest.salesOrder.orderCode}</span>
                                                        <br><small class="text-muted">${pickRequest.salesOrder.customerName}</small>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Không xác định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty pickRequest.warehouse}">
                                                        ${pickRequest.warehouse.warehouseName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Không xác định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${pickRequest.requestDate}" pattern="dd/MM/yyyy"/>
                                                <br><small class="text-muted">
                                                    <fmt:formatDate value="${pickRequest.requestDate}" pattern="HH:mm"/>
                                                </small>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty pickRequest.requester}">
                                                        ${pickRequest.requester.fullName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Không xác định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${pickRequest.status == 'pending'}">
                                                        <span class="badge bg-warning">Chờ xử lý</span>
                                                    </c:when>
                                                    <c:when test="${pickRequest.status == 'in_progress'}">
                                                        <span class="badge bg-info">Đang thực hiện</span>
                                                    </c:when>
                                                    <c:when test="${pickRequest.status == 'completed'}">
                                                        <span class="badge bg-success">Hoàn thành</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${pickRequest.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:if test="${pickRequest.totalItems != null && pickRequest.totalItems > 0}">
                                                    <div class="progress" style="height: 20px;">
                                                        <div class="progress-bar" role="progressbar" 
                                                             style="width: ${(pickRequest.pickedItems / pickRequest.totalItems) * 100}%">
                                                            ${pickRequest.pickedItems}/${pickRequest.totalItems}
                                                        </div>
                                                    </div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <c:choose>
                                                        <c:when test="${pickRequest.status == 'pending'}">
                                                            <a href="${pageContext.request.contextPath}/warehouse-staff?action=perform-pick&id=${pickRequest.pickRequestId}" 
                                                               class="btn btn-sm btn-primary" title="Bắt đầu lấy hàng">
                                                                <i class="bi bi-play-circle"></i>
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${pickRequest.status == 'in_progress'}">
                                                            <a href="${pageContext.request.contextPath}/warehouse-staff?action=perform-pick&id=${pickRequest.pickRequestId}" 
                                                               class="btn btn-sm btn-warning" title="Tiếp tục lấy hàng">
                                                                <i class="bi bi-arrow-repeat"></i>
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${pickRequest.status == 'completed'}">
                                                            <a href="${pageContext.request.contextPath}/warehouse-staff?action=create-stock-outward&pickRequestId=${pickRequest.pickRequestId}" 
                                                               class="btn btn-sm btn-success" title="Tạo phiếu xuất kho">
                                                                <i class="bi bi-box-arrow-up"></i>
                                                            </a>
                                                        </c:when>
                                                    </c:choose>
                                                    <a href="${pageContext.request.contextPath}/warehouse-staff?action=view-pick-request&id=${pickRequest.pickRequestId}" 
                                                       class="btn btn-sm btn-outline-info" title="Xem chi tiết">
                                                        <i class="bi bi-eye"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto refresh every 30 seconds for real-time updates
        setTimeout(function() {
            location.reload();
        }, 30000);
    </script>
</body>
</html> 