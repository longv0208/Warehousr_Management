<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phê Duyệt Yêu Cầu Nhập Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp"/>
            
            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">
                        <i class="fas fa-clipboard-check me-2"></i>Phê Duyệt Yêu Cầu Nhập Hàng
                        <c:if test="${not empty purchaseRequest}">
                            <small class="text-muted">${purchaseRequest.requestCode}</small>
                        </c:if>
                    </h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/admin/purchase-management/requests" 
                           class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-1"></i>Quay lại
                        </a>
                    </div>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        ${sessionScope.successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>

                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        ${sessionScope.errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <c:choose>
                    <c:when test="${not empty purchaseRequest}">
                        <!-- Request Summary -->
                        <div class="row mb-4">
                            <div class="col-md-8">
                                <div class="card">
                                    <div class="card-header bg-primary text-white">
                                        <h5 class="card-title mb-0">
                                            <i class="fas fa-info-circle me-2"></i>Thông tin yêu cầu
                                        </h5>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <p class="mb-2">
                                                    <strong>Mã yêu cầu:</strong> 
                                                    <span class="text-primary">${purchaseRequest.requestCode}</span>
                                                </p>
                                                <p class="mb-2">
                                                    <strong>Người yêu cầu:</strong> 
                                                    <c:choose>
                                                        <c:when test="${not empty purchaseRequest.requestedByName}">
                                                            ${purchaseRequest.requestedByName}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">N/A</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </p>
                                                <p class="mb-2">
                                                    <strong>Ngày tạo:</strong> 
                                                    <c:if test="${not empty purchaseRequest.requestDate}">
                                                        <fmt:formatDate value="${purchaseRequest.requestDate}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </c:if>
                                                </p>
                                            </div>
                                            <div class="col-md-6">
                                                <p class="mb-2">
                                                    <strong>Trạng thái hiện tại:</strong>
                                                    <span class="badge bg-warning fs-6">Chờ duyệt</span>
                                                </p>
                                                <c:if test="${not empty purchaseRequest.warehouseName}">
                                                    <p class="mb-2">
                                                        <strong>Kho:</strong> ${purchaseRequest.warehouseName}
                                                    </p>
                                                </c:if>
                                            </div>
                                        </div>
                                        <c:if test="${not empty purchaseRequest.notes}">
                                            <hr>
                                            <p class="mb-0">
                                                <strong>Lý do yêu cầu:</strong><br>
                                                <div class="bg-light p-3 rounded mt-2">
                                                    ${purchaseRequest.notes}
                                                </div>
                                            </p>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card">
                                    <div class="card-header bg-info text-white">
                                        <h5 class="card-title mb-0">
                                            <i class="fas fa-chart-bar me-2"></i>Thống kê
                                        </h5>
                                    </div>
                                    <div class="card-body text-center">
                                        <h3 class="text-primary">
                                            ${not empty requestDetails ? requestDetails.size() : 0}
                                        </h3>
                                        <p class="text-muted mb-3">Sản phẩm yêu cầu</p>
                                        
                                        <c:set var="totalQuantity" value="0"/>
                                        <c:forEach var="detail" items="${requestDetails}">
                                            <c:set var="totalQuantity" value="${totalQuantity + detail.requestedQuantity}"/>
                                        </c:forEach>
                                        <h4 class="text-info">${totalQuantity}</h4>
                                        <p class="text-muted mb-0">Tổng số lượng</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Request Details -->
                        <div class="card mb-4">
                            <div class="card-header">
                                <h5 class="card-title mb-0">
                                    <i class="fas fa-list me-2"></i>Chi tiết sản phẩm yêu cầu
                                </h5>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${not empty requestDetails}">
                                        <div class="table-responsive">
                                            <table class="table table-striped table-hover">
                                                <thead class="table-dark">
                                                    <tr>
                                                        <th width="5%">STT</th>
                                                        <th width="15%">Mã sản phẩm</th>
                                                        <th width="30%">Tên sản phẩm</th>
                                                        <th width="10%">Đơn vị</th>
                                                        <th width="10%">Số lượng</th>
                                                        <th width="20%">Nhà cung cấp đề xuất</th>
                                                        <th width="10%">Ghi chú</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="detail" items="${requestDetails}" varStatus="status">
                                                        <tr>
                                                            <td>${status.index + 1}</td>
                                                            <td>
                                                                <code>${detail.productCode}</code>
                                                            </td>
                                                            <td>
                                                                <strong>${detail.productName}</strong>
                                                            </td>
                                                            <td>
                                                                <span class="badge bg-light text-dark">${detail.unit}</span>
                                                            </td>
                                                            <td>
                                                                <span class="badge bg-primary fs-6">
                                                                    ${detail.requestedQuantity}
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty detail.supplierName}">
                                                                        ${detail.supplierName}
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted fst-italic">Chưa chọn</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty detail.notes}">
                                                                        <span class="text-muted">${detail.notes}</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted fst-italic">Không có</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-4">
                                            <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                                            <p class="text-muted">Không có sản phẩm nào trong yêu cầu này</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Approval Actions -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="card border-success">
                                    <div class="card-header bg-success text-white">
                                        <h5 class="card-title mb-0">
                                            <i class="fas fa-check me-2"></i>Phê duyệt yêu cầu
                                        </h5>
                                    </div>
                                    <div class="card-body">
                                        <form method="POST" action="${pageContext.request.contextPath}/admin/purchase-management/requests">
                                            <input type="hidden" name="action" value="approve">
                                            <input type="hidden" name="requestId" value="${purchaseRequest.requestId}">
                                            
                                            <div class="mb-3">
                                                <label for="approvalNotes" class="form-label">Ghi chú phê duyệt (tùy chọn)</label>
                                                <textarea class="form-control" id="approvalNotes" name="approvalNotes" 
                                                          rows="4" placeholder="Nhập ghi chú khi phê duyệt (nếu có)..."></textarea>
                                                <div class="form-text">Ghi chú này sẽ được thêm vào yêu cầu và thông báo cho người tạo.</div>
                                            </div>
                                            
                                            <div class="d-grid">
                                                <button type="submit" class="btn btn-success btn-lg">
                                                    <i class="fas fa-check me-2"></i>Phê duyệt yêu cầu
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="card border-danger">
                                    <div class="card-header bg-danger text-white">
                                        <h5 class="card-title mb-0">
                                            <i class="fas fa-times me-2"></i>Từ chối yêu cầu
                                        </h5>
                                    </div>
                                    <div class="card-body">
                                        <form method="POST" action="${pageContext.request.contextPath}/admin/purchase-management/requests">
                                            <input type="hidden" name="action" value="reject">
                                            <input type="hidden" name="requestId" value="${purchaseRequest.requestId}">
                                            
                                            <div class="mb-3">
                                                <label for="rejectionReason" class="form-label">Lý do từ chối <span class="text-danger">*</span></label>
                                                <textarea class="form-control" id="rejectionReason" name="rejectionReason" 
                                                          rows="4" required placeholder="Nhập lý do từ chối yêu cầu này..."></textarea>
                                                <div class="form-text">Lý do từ chối sẽ được gửi thông báo cho người tạo yêu cầu.</div>
                                            </div>
                                            
                                            <div class="d-grid">
                                                <button type="submit" class="btn btn-danger btn-lg">
                                                    <i class="fas fa-times me-2"></i>Từ chối yêu cầu
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Navigation Buttons -->
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="d-flex justify-content-between">
                                    <a href="${pageContext.request.contextPath}/admin/purchase-management/requests" 
                                       class="btn btn-outline-secondary">
                                        <i class="fas fa-arrow-left me-1"></i>Quay lại danh sách
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/purchase-management/requests?action=view&id=${purchaseRequest.requestId}" 
                                       class="btn btn-outline-info">
                                        <i class="fas fa-eye me-1"></i>Xem chi tiết
                                    </a>
                                </div>
                            </div>
                        </div>

                    </c:when>
                    <c:otherwise>
                        <!-- Request not found -->
                        <div class="card">
                            <div class="card-body text-center py-5">
                                <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                                <h4>Không tìm thấy yêu cầu</h4>
                                <p class="text-muted">Yêu cầu nhập hàng này không tồn tại hoặc đã bị xóa.</p>
                                <a href="${pageContext.request.contextPath}/admin/purchase-management/requests" 
                                   class="btn btn-primary">
                                    <i class="fas fa-arrow-left me-1"></i>Quay lại danh sách
                                </a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Confirmation Script -->
    <script>
        // Confirmation for approval
        document.querySelector('form[action*="approve"]').addEventListener('submit', function(e) {
            if (!confirm('Bạn có chắc chắn muốn phê duyệt yêu cầu này không?')) {
                e.preventDefault();
            }
        });
        
        // Confirmation for rejection
        document.querySelector('form[action*="reject"]').addEventListener('submit', function(e) {
            const reason = document.getElementById('rejectionReason').value.trim();
            if (!reason) {
                alert('Vui lòng nhập lý do từ chối!');
                e.preventDefault();
                return;
            }
            
            if (!confirm('Bạn có chắc chắn muốn từ chối yêu cầu này không?')) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html> 