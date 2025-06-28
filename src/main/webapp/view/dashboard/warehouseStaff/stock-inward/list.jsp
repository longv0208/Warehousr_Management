<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Nhập Kho</title>
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
                    <h2 class="mb-1">Quản Lý Nhập Kho</h2>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/warehouse-staff">Dashboard</a></li>
                            <li class="breadcrumb-item active">Nhập Kho</li>
                        </ol>
                    </nav>
                </div>
                <a href="${pageContext.request.contextPath}/warehouse-staff?action=approved-purchase-requests" 
                   class="btn btn-primary">
                    <i class="bi bi-plus-circle me-2"></i>Tạo Phiếu Nhập Kho
                </a>
            </div>

            <!-- Search and Filter -->
            <div class="card mb-4">
                <div class="card-body">
                    <form class="row g-3" method="GET" action="${pageContext.request.contextPath}/warehouse-staff">
                        <input type="hidden" name="action" value="stock-inward-list">
                        <div class="col-md-3">
                            <label class="form-label">Mã Phiếu Nhập</label>
                            <input type="text" class="form-control" name="inwardCode" 
                                   value="${param.inwardCode}" placeholder="SI000001">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Nhà Cung Cấp</label>
                            <select class="form-select" name="supplierId">
                                <option value="">Tất cả</option>
                                <c:forEach var="supplier" items="${suppliers}">
                                    <option value="${supplier.supplierId}" 
                                            ${param.supplierId == supplier.supplierId ? 'selected' : ''}>
                                        ${supplier.supplierName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Kho</label>
                            <select class="form-select" name="warehouseId">
                                <option value="">Tất cả</option>
                                <c:forEach var="warehouse" items="${warehouses}">
                                    <option value="${warehouse.warehouseId}" 
                                            ${param.warehouseId == warehouse.warehouseId ? 'selected' : ''}>
                                        ${warehouse.warehouseName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-3 d-flex align-items-end">
                            <button type="submit" class="btn btn-outline-primary me-2">
                                <i class="bi bi-search"></i> Tìm kiếm
                            </button>
                            <a href="${pageContext.request.contextPath}/warehouse-staff?action=stock-inward-list" 
                               class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-clockwise"></i> Làm mới
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Statistics Cards -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card bg-primary text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${totalInwards != null ? totalInwards : 0}</h4>
                                    <p class="mb-0">Tổng Phiếu Nhập</p>
                                </div>
                                <i class="bi bi-arrow-down-circle fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card bg-success text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${todayInwards != null ? todayInwards : 0}</h4>
                                    <p class="mb-0">Nhập Hôm Nay</p>
                                </div>
                                <i class="bi bi-calendar-day fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card bg-info text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${thisMonthInwards != null ? thisMonthInwards : 0}</h4>
                                    <p class="mb-0">Nhập Tháng Này</p>
                                </div>
                                <i class="bi bi-calendar-month fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
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
            </div>

            <!-- Stock Inward List -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Danh Sách Phiếu Nhập Kho</h5>
                    <span class="badge bg-primary">${stockInwards.size()} phiếu</span>
                </div>
                <div class="card-body">
                    <c:if test="${empty stockInwards}">
                        <div class="text-center py-4">
                            <i class="bi bi-inbox fs-1 text-muted"></i>
                            <p class="text-muted mt-2">Chưa có phiếu nhập kho nào</p>
                            <a href="${pageContext.request.contextPath}/warehouse-staff?action=approved-purchase-requests" 
                               class="btn btn-primary">
                                <i class="bi bi-plus-circle me-2"></i>Tạo Phiếu Nhập Đầu Tiên
                            </a>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty stockInwards}">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>STT</th>
                                        <th>Mã Phiếu</th>
                                        <th>Nhà Cung Cấp</th>
                                        <th>Kho</th>
                                        <th>Ngày Nhập</th>
                                        <th>Người Tạo</th>
                                        <th>Ghi Chú</th>
                                        <th>Hành Động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="stockInward" items="${stockInwards}" varStatus="status">
                                        <tr>
                                            <td>${status.index + 1}</td>
                                            <td>
                                                <span class="fw-bold text-primary">${stockInward.inwardCode}</span>
                                                <c:if test="${stockInward.purchaseRequestId != null}">
                                                    <br><small class="text-muted">YC: ${stockInward.purchaseRequestId}</small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty stockInward.supplier}">
                                                        ${stockInward.supplier.supplierName}
                                                        <br><small class="text-muted">${stockInward.supplier.contactPerson}</small>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Không xác định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty stockInward.warehouse}">
                                                        ${stockInward.warehouse.warehouseName}
                                                        <br><small class="text-muted">${stockInward.warehouse.location}</small>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Không xác định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${stockInward.inwardDate}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty stockInward.user}">
                                                        ${stockInward.user.fullName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Không xác định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty stockInward.notes}">
                                                        ${stockInward.notes}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <a href="${pageContext.request.contextPath}/warehouse-staff?action=view-stock-inward&id=${stockInward.stockInwardId}" 
                                                       class="btn btn-sm btn-outline-primary" title="Xem chi tiết">
                                                        <i class="bi bi-eye"></i>
                                                    </a>
                                                    <button type="button" class="btn btn-sm btn-outline-success" 
                                                            title="In phiếu" onclick="printInward(${stockInward.stockInwardId})">
                                                        <i class="bi bi-printer"></i>
                                                    </button>
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

    <!-- Toast Container -->
    <div class="toast-container position-fixed bottom-0 end-0 p-3">
        <c:if test="${not empty sessionScope.toastMessage}">
            <div class="toast show" role="alert">
                <div class="toast-header">
                    <strong class="me-auto">
                        <c:choose>
                            <c:when test="${sessionScope.toastType == 'success'}">
                                <i class="bi bi-check-circle-fill text-success"></i> Thành công
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-exclamation-triangle-fill text-danger"></i> Lỗi
                            </c:otherwise>
                        </c:choose>
                    </strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
                </div>
                <div class="toast-body">
                    ${sessionScope.toastMessage}
                </div>
            </div>
            <c:remove var="toastMessage" scope="session"/>
            <c:remove var="toastType" scope="session"/>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function printInward(inwardId) {
            window.open('${pageContext.request.contextPath}/warehouse-staff?action=print-stock-inward&id=' + inwardId, 
                       '_blank', 'width=800,height=600');
        }
        
        // Auto hide toast after 5 seconds
        setTimeout(function() {
            var toasts = document.querySelectorAll('.toast');
            toasts.forEach(function(toast) {
                var bsToast = new bootstrap.Toast(toast);
                bsToast.hide();
            });
        }, 5000);
    </script>
</body>
</html> 