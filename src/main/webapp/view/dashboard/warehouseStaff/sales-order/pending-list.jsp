<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Hàng Chờ Xử Lý</title>
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
                    <h2 class="mb-1">Đơn Hàng Chờ Xử Lý</h2>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/warehouse-staff">Dashboard</a></li>
                            <li class="breadcrumb-item active">Đơn Hàng Chờ Xử Lý</li>
                        </ol>
                    </nav>
                </div>
            </div>

            <!-- Statistics Cards -->
            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="card bg-warning text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${salesOrders.size()}</h4>
                                    <p class="mb-0">Đơn Chờ Xử Lý</p>
                                </div>
                                <i class="bi bi-hourglass-split fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-info text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${urgentOrders != null ? urgentOrders : 0}</h4>
                                    <p class="mb-0">Ưu Tiên Cao</p>
                                </div>
                                <i class="bi bi-exclamation-triangle fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-success text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="mb-1">${processedToday != null ? processedToday : 0}</h4>
                                    <p class="mb-0">Xử Lý Hôm Nay</p>
                                </div>
                                <i class="bi bi-check-circle fs-1"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sales Orders List -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Đơn Hàng Cần Xử Lý</h5>
                    <span class="badge bg-warning">${salesOrders.size()} đơn hàng</span>
                </div>
                <div class="card-body">
                    <c:if test="${empty salesOrders}">
                        <div class="text-center py-4">
                            <i class="bi bi-check-circle fs-1 text-success"></i>
                            <p class="text-muted mt-2">Tuyệt vời! Không có đơn hàng nào cần xử lý</p>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty salesOrders}">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>STT</th>
                                        <th>Mã Đơn Hàng</th>
                                        <th>Khách Hàng</th>
                                        <th>Ngày Tạo</th>
                                        <th>Nhân Viên</th>
                                        <th>Trạng Thái</th>
                                        <th>Ưu Tiên</th>
                                        <th>Hành Động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="order" items="${salesOrders}" varStatus="status">
                                        <tr class="${order.priority == 'high' ? 'table-warning' : ''}">
                                            <td>${status.index + 1}</td>
                                            <td>
                                                <span class="fw-bold text-primary">${order.orderCode}</span>
                                            </td>
                                            <td>
                                                <div>
                                                    <strong>${order.customerName}</strong>
                                                    <c:if test="${not empty order.customerPhone}">
                                                        <br><small class="text-muted">
                                                            <i class="bi bi-telephone"></i> ${order.customerPhone}
                                                        </small>
                                                    </c:if>
                                                </div>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy"/>
                                                <br><small class="text-muted">
                                                    <fmt:formatDate value="${order.orderDate}" pattern="HH:mm"/>
                                                </small>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty order.user}">
                                                        ${order.user.fullName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Không xác định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="badge bg-warning">Chờ xuất kho</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${order.priority == 'high'}">
                                                        <span class="badge bg-danger">
                                                            <i class="bi bi-exclamation-triangle"></i> Cao
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${order.priority == 'medium'}">
                                                        <span class="badge bg-warning">Trung bình</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">Thấp</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <a href="${pageContext.request.contextPath}/warehouse-staff?action=create-pick-request&salesOrderId=${order.salesOrderId}" 
                                                       class="btn btn-sm btn-primary" title="Tạo yêu cầu lấy hàng">
                                                        <i class="bi bi-plus-circle me-1"></i>Tạo Pick Request
                                                    </a>
                                                    <button type="button" class="btn btn-sm btn-outline-info" 
                                                            data-bs-toggle="modal" data-bs-target="#orderModal${order.salesOrderId}"
                                                            title="Xem chi tiết">
                                                        <i class="bi bi-eye"></i>
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

    <!-- Order Detail Modals -->
    <c:forEach var="order" items="${salesOrders}">
        <div class="modal fade" id="orderModal${order.salesOrderId}" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Chi Tiết Đơn Hàng: ${order.orderCode}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Khách hàng:</strong><br>
                                ${order.customerName}
                                <c:if test="${not empty order.customerPhone}">
                                    <br><small class="text-muted">
                                        <i class="bi bi-telephone"></i> ${order.customerPhone}
                                    </small>
                                </c:if>
                            </div>
                            <div class="col-md-6">
                                <strong>Ngày tạo:</strong><br>
                                <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Nhân viên bán hàng:</strong><br>
                                ${order.user.fullName}
                            </div>
                            <div class="col-md-6">
                                <strong>Ưu tiên:</strong><br>
                                <c:choose>
                                    <c:when test="${order.priority == 'high'}">
                                        <span class="badge bg-danger">Cao</span>
                                    </c:when>
                                    <c:when test="${order.priority == 'medium'}">
                                        <span class="badge bg-warning">Trung bình</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">Thấp</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-12">
                                <strong>Ghi chú:</strong><br>
                                ${order.notes != null ? order.notes : 'Không có ghi chú'}
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th>Số lượng</th>
                                        <th>Đơn giá</th>
                                        <th>Thành tiền</th>
                                        <th>Tồn kho</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="detail" items="${order.details}">
                                        <tr>
                                            <td>
                                                ${detail.product.productName}
                                                <br><small class="text-muted">${detail.product.productCode}</small>
                                            </td>
                                            <td>${detail.quantity} ${detail.product.unit}</td>
                                            <td>
                                                <fmt:formatNumber value="${detail.unitPrice}" type="currency" 
                                                                currencySymbol="₫" groupingUsed="true"/>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${detail.quantity * detail.unitPrice}" 
                                                                type="currency" currencySymbol="₫" groupingUsed="true"/>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${detail.product.stockQuantity >= detail.quantity}">
                                                        <span class="badge bg-success">${detail.product.stockQuantity}</span>
                                                    </c:when>
                                                    <c:when test="${detail.product.stockQuantity > 0}">
                                                        <span class="badge bg-warning">${detail.product.stockQuantity}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-danger">0</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <a href="${pageContext.request.contextPath}/warehouse-staff?action=create-pick-request&salesOrderId=${order.salesOrderId}" 
                           class="btn btn-primary">
                            <i class="bi bi-plus-circle me-1"></i>Tạo Yêu Cầu Lấy Hàng
                        </a>
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>
    </c:forEach>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto refresh every 5 minutes to check for new orders
        setTimeout(function() {
            location.reload();
        }, 300000);
        
        // Priority order sorting
        document.addEventListener('DOMContentLoaded', function() {
            const table = document.querySelector('table tbody');
            if (table) {
                const rows = Array.from(table.querySelectorAll('tr'));
                rows.sort((a, b) => {
                    const priorityA = a.querySelector('.badge').textContent.trim();
                    const priorityB = b.querySelector('.badge').textContent.trim();
                    
                    if (priorityA.includes('Cao')) return -1;
                    if (priorityB.includes('Cao')) return 1;
                    if (priorityA.includes('Trung bình')) return -1;
                    if (priorityB.includes('Trung bình')) return 1;
                    return 0;
                });
                
                rows.forEach(row => table.appendChild(row));
            }
        });
    </script>
</body>
</html> 