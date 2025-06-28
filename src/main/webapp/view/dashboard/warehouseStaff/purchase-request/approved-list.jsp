<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu Cầu Nhập Hàng Đã Duyệt</title>
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
                    <h2 class="mb-1">Yêu Cầu Nhập Hàng Đã Duyệt</h2>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/warehouse-staff">Dashboard</a></li>
                            <li class="breadcrumb-item active">YC Nhập Hàng Đã Duyệt</li>
                        </ol>
                    </nav>
                </div>
            </div>

            <!-- Purchase Requests List -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Danh Sách Yêu Cầu Đã Duyệt</h5>
                    <span class="badge bg-success">${purchaseRequests.size()} yêu cầu</span>
                </div>
                <div class="card-body">
                    <c:if test="${empty purchaseRequests}">
                        <div class="text-center py-4">
                            <i class="bi bi-inbox fs-1 text-muted"></i>
                            <p class="text-muted mt-2">Chưa có yêu cầu nhập hàng đã duyệt nào</p>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty purchaseRequests}">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>STT</th>
                                        <th>Mã YC</th>
                                        <th>Nhà Cung Cấp</th>
                                        <th>Ngày Tạo</th>
                                        <th>Ngày Duyệt</th>
                                        <th>Người Duyệt</th>
                                        <th>Trạng Thái</th>
                                        <th>Hành Động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="request" items="${purchaseRequests}" varStatus="status">
                                        <tr>
                                            <td>${status.index + 1}</td>
                                            <td>
                                                <span class="fw-bold text-primary">${request.requestCode}</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty request.supplier}">
                                                        ${request.supplier.supplierName}
                                                        <br><small class="text-muted">${request.supplier.contactPerson}</small>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Không xác định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${request.requestDate}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${request.approvedDate}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty request.approvedBy}">
                                                        ${request.approvedBy.fullName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Không xác định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="badge bg-success">Đã duyệt</span>
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <a href="${pageContext.request.contextPath}/warehouse-staff?action=create-stock-inward&purchaseRequestId=${request.requestId}" 
                                                       class="btn btn-sm btn-primary" title="Tạo phiếu nhập kho">
                                                        <i class="bi bi-plus-circle me-1"></i>Tạo Phiếu Nhập
                                                    </a>
                                                    <button type="button" class="btn btn-sm btn-outline-info" 
                                                            data-bs-toggle="modal" data-bs-target="#detailModal${request.requestId}"
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

    <!-- Detail Modals -->
    <c:forEach var="request" items="${purchaseRequests}">
        <div class="modal fade" id="detailModal${request.requestId}" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Chi Tiết Yêu Cầu: ${request.requestCode}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Nhà cung cấp:</strong><br>
                                <c:choose>
                                    <c:when test="${not empty request.supplier}">
                                        ${request.supplier.supplierName}
                                        <br><small class="text-muted">${request.supplier.contactPerson}</small>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Không xác định</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="col-md-6">
                                <strong>Ngày duyệt:</strong><br>
                                <fmt:formatDate value="${request.approvedDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-12">
                                <strong>Ghi chú:</strong><br>
                                ${request.notes != null ? request.notes : 'Không có ghi chú'}
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th>Số lượng yêu cầu</th>
                                        <th>Đơn giá dự kiến</th>
                                        <th>Thành tiền</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="detail" items="${request.details}">
                                        <tr>
                                            <td>
                                                ${detail.productName}
                                                <br><small class="text-muted">${detail.productCode}</small>
                                            </td>
                                            <td>${detail.requestedQuantity} ${detail.unit}</td>
                                            <td>
                                                <fmt:formatNumber value="${detail.purchasePrice}" type="currency" 
                                                                currencySymbol="₫" groupingUsed="true"/>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${detail.requestedQuantity * detail.purchasePrice}" 
                                                                type="currency" currencySymbol="₫" groupingUsed="true"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <a href="${pageContext.request.contextPath}/warehouse-staff?action=create-stock-inward&purchaseRequestId=${request.requestId}" 
                           class="btn btn-primary">
                            <i class="bi bi-plus-circle me-1"></i>Tạo Phiếu Nhập Kho
                        </a>
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>
    </c:forEach>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 