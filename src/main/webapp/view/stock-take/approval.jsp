<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.StockTake" %>
<%@ page import="model.StockTakeDetail" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Quản Lý Kho Hàng - Duyệt Đơn Kiểm Kê</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
    <style>
        .approval-card {
            border-left: 4px solid #007bff;
        }
        .discrepancy-item {
            border-left: 3px solid #dc3545;
            background-color: #fff5f5;
        }
        .positive-discrepancy {
            border-left-color: #28a745;
            background-color: #f8fff9;
        }
        .approval-summary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
        }
        .stat-card {
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
    </style>
</head>
<body>
<jsp:include page="../common/sidebar.jsp" />

<div class="container-fluid">
    <div class="row">
        <main class="col-md-12 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3><i class="bi bi-clipboard-check"></i> Duyệt Đơn Kiểm Kê</h3>
                    <p class="text-muted mb-0">Phiếu: ${stockTake.stockTakeCode} - Ngày: <fmt:formatDate value="${stockTake.stockTakeDate}" pattern="dd/MM/yyyy HH:mm" /></p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/stock-take" class="btn btn-secondary">Quay lại</a>
                </div>
            </div>

            <!-- Hiển thị thông báo -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <!-- Thông tin phiếu kiểm kê -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card approval-summary">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-3">
                                    <h6 class="text-light">Mã phiếu:</h6>
                                    <h5>${stockTake.stockTakeCode}</h5>
                                </div>
                                <div class="col-md-3">
                                    <h6 class="text-light">Người kiểm kê:</h6>
                                    <h5>${stockTake.userFullName}</h5>
                                </div>
                                <div class="col-md-3">
                                    <h6 class="text-light">Trạng thái:</h6>
                                    <h5>
                                        <span class="badge bg-success fs-6">
                                            <c:choose>
                                                <c:when test="${stockTake.status == 'completed'}">Hoàn thành</c:when>
                                                <c:otherwise>${stockTake.status}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </h5>
                                </div>
                                <div class="col-md-3">
                                    <h6 class="text-light">Ghi chú:</h6>
                                    <h5>${stockTake.notes != null ? stockTake.notes : 'Không có'}</h5>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Thống kê tổng quan -->
            <c:if test="${not empty statistics}">
                <c:forEach var="stat" items="${statistics}">
                    <div class="row mb-4">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header bg-info text-white">
                                    <h5 class="mb-0"><i class="bi bi-graph-up"></i> Thống kê tổng quan</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row text-center">
                                        <div class="col-md-2">
                                            <div class="stat-card p-3 border rounded">
                                                <h4 class="text-primary">${stat[0]}</h4>
                                                <p class="mb-0">Tổng sản phẩm</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="stat-card p-3 border rounded">
                                                <h4 class="text-success">${stat[1]}</h4>
                                                <p class="mb-0">Đã kiểm đếm</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="stat-card p-3 border rounded">
                                                <h4 class="text-success">${stat[2]}</h4>
                                                <p class="mb-0">Thừa</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="stat-card p-3 border rounded">
                                                <h4 class="text-danger">${stat[3]}</h4>
                                                <p class="mb-0">Thiếu</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="stat-card p-3 border rounded">
                                                <h4 class="text-secondary">${stat[4]}</h4>
                                                <p class="mb-0">Khớp</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="stat-card p-3 border rounded">
                                                <c:set var="accuracyRate" value="${stat[4] * 100 / stat[0]}" />
                                                <h4 class="text-info">
                                                    <fmt:formatNumber value="${accuracyRate}" maxFractionDigits="1" />%
                                                </h4>
                                                <p class="mb-0">Độ chính xác</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:if>

            <!-- Danh sách sản phẩm có chênh lệch -->
            <c:if test="${not empty discrepancies}">
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="card approval-card">
                            <div class="card-header bg-warning text-dark d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="bi bi-exclamation-triangle"></i> Sản phẩm có chênh lệch</h5>
                                <span class="badge bg-dark">${discrepancies.size()} sản phẩm</span>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-bordered">
                                        <thead class="table-dark">
                                            <tr>
                                                <th width="10%">Mã SP</th>
                                                <th width="30%">Tên sản phẩm</th>
                                                <th width="8%">Đơn vị</th>
                                                <th width="12%">SL Hệ thống</th>
                                                <th width="12%">SL Kiểm đếm</th>
                                                <th width="12%">Chênh lệch</th>
                                                <th width="16%">Tỷ lệ</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="detail" items="${discrepancies}">
                                                <c:set var="diff" value="${detail.countedQuantity - detail.systemQuantity}" />
                                                <tr class="${diff > 0 ? 'positive-discrepancy' : 'discrepancy-item'}">
                                                    <td><strong>${detail.productCode}</strong></td>
                                                    <td>${detail.productName}</td>
                                                    <td class="text-center">${detail.unit}</td>
                                                    <td class="text-center">
                                                        <span class="badge bg-secondary">${detail.systemQuantity}</span>
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="badge bg-primary">${detail.countedQuantity}</span>
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="badge ${diff > 0 ? 'bg-success' : 'bg-danger'} fs-6">
                                                            ${diff > 0 ? '+' : ''}${diff}
                                                        </span>
                                                    </td>
                                                    <td class="text-center">
                                                        <c:if test="${detail.systemQuantity > 0}">
                                                            <c:set var="percentage" value="${diff * 100 / detail.systemQuantity}" />
                                                            <span class="badge ${Math.abs(percentage) > 10 ? 'bg-danger' : 'bg-warning'}">
                                                                <fmt:formatNumber value="${percentage}" maxFractionDigits="1" />%
                                                            </span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- Phần quyết định duyệt/từ chối -->
            <div class="row">
                <div class="col-md-6">
                    <div class="card border-success">
                        <div class="card-header bg-success text-white">
                            <h5 class="mb-0"><i class="bi bi-check-circle"></i> Duyệt đơn kiểm kê</h5>
                        </div>
                        <div class="card-body">
                            <form id="approveForm" method="POST" action="${pageContext.request.contextPath}/stock-take">
                                <input type="hidden" name="action" value="approve">
                                <input type="hidden" name="stockTakeId" value="${stockTake.stockTakeId}">
                                
                                <div class="mb-3">
                                    <label for="approvalNotes" class="form-label">Ghi chú duyệt (tùy chọn):</label>
                                    <textarea class="form-control" name="approvalNotes" id="approvalNotes" rows="3" 
                                              placeholder="Nhập ghi chú về việc duyệt đơn..."></textarea>
                                </div>
                                
                                <div class="d-grid">
                                    <button type="button" class="btn btn-success btn-lg" onclick="confirmApprove()">
                                        <i class="bi bi-check-circle"></i> Duyệt đơn
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="card border-danger">
                        <div class="card-header bg-danger text-white">
                            <h5 class="mb-0"><i class="bi bi-x-circle"></i> Từ chối đơn kiểm kê</h5>
                        </div>
                        <div class="card-body">
                            <form id="rejectForm" method="POST" action="${pageContext.request.contextPath}/stock-take">
                                <input type="hidden" name="action" value="reject">
                                <input type="hidden" name="stockTakeId" value="${stockTake.stockTakeId}">
                                
                                <div class="mb-3">
                                    <label for="rejectionReason" class="form-label">Lý do từ chối <span class="text-danger">*</span>:</label>
                                    <textarea class="form-control" name="rejectionReason" id="rejectionReason" rows="3" 
                                              placeholder="Nhập lý do từ chối đơn kiểm kê..." required></textarea>
                                </div>
                                
                                <div class="d-grid">
                                    <button type="button" class="btn btn-danger btn-lg" onclick="confirmReject()">
                                        <i class="bi bi-x-circle"></i> Từ chối đơn
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <c:if test="${empty discrepancies}">
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="alert alert-success text-center" role="alert">
                            <i class="bi bi-check-circle-fill fs-1"></i>
                            <h4 class="mt-2">Kiểm kê chính xác 100%</h4>
                            <p class="mb-0">Tất cả sản phẩm đều khớp với số lượng hệ thống. Đây là một kết quả kiểm kê tuyệt vời!</p>
                        </div>
                    </div>
                </div>
            </c:if>
        </main>
    </div>
</div>

<script>
function confirmApprove() {
    if (confirm('Bạn có chắc chắn muốn duyệt đơn kiểm kê này?\n\nSau khi duyệt, đơn sẽ được chuyển sang trạng thái "Đã duyệt" và có thể thực hiện điều chỉnh tồn kho.')) {
        document.getElementById('approveForm').submit();
    }
}

function confirmReject() {
    const reason = document.getElementById('rejectionReason').value.trim();
    if (!reason) {
        alert('Vui lòng nhập lý do từ chối!');
        document.getElementById('rejectionReason').focus();
        return;
    }
    
    if (confirm('Bạn có chắc chắn muốn từ chối đơn kiểm kê này?\n\nLý do: ' + reason + '\n\nSau khi từ chối, warehouse staff sẽ cần chỉnh sửa và gửi lại.')) {
        document.getElementById('rejectForm').submit();
    }
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
</body>
</html> 