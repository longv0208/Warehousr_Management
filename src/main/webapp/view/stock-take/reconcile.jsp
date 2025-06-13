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
    <title>Quản Lý Kho Hàng - Điều Chỉnh Tồn Kho</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
    <style>
        .reconcile-card {
            border-left: 4px solid #ffc107;
        }
        .discrepancy-item {
            border-left: 3px solid #dc3545;
            background-color: #fff5f5;
        }
        .positive-discrepancy {
            border-left-color: #28a745;
            background-color: #f8fff9;
        }
        .reconcile-summary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
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
                    <h3><i class="bi bi-clipboard-data"></i> Điều Chỉnh Tồn Kho</h3>
                    <p class="text-muted mb-0">Phiếu: ${stockTake.stockTakeCode} - Ngày: <fmt:formatDate value="${stockTake.stockTakeDate}" pattern="dd/MM/yyyy HH:mm" /></p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/stock-take?action=report&id=${stockTake.stockTakeId}" 
                       class="btn btn-info me-2">Xem báo cáo</a>
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
                    <div class="card reconcile-summary">
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
                                                <c:when test="${stockTake.status == 'reconciled'}">Đã đối soát</c:when>
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

            <!-- Thống kê chênh lệch -->
            <c:if test="${not empty statistics}">
                <c:forEach var="stat" items="${statistics}">
                    <div class="row mb-4">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header bg-warning text-dark">
                                    <h5 class="mb-0"><i class="bi bi-graph-up"></i> Thống kê chênh lệch</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row text-center">
                                        <div class="col-md-2">
                                            <div class="p-3 border rounded">
                                                <h4 class="text-primary">${stat[0]}</h4>
                                                <p class="mb-0">Tổng sản phẩm</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="p-3 border rounded">
                                                <h4 class="text-success">${stat[2]}</h4>
                                                <p class="mb-0">Thừa</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="p-3 border rounded">
                                                <h4 class="text-danger">${stat[3]}</h4>
                                                <p class="mb-0">Thiếu</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="p-3 border rounded">
                                                <h4 class="text-secondary">${stat[4]}</h4>
                                                <p class="mb-0">Khớp</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="p-3 border rounded">
                                                <c:set var="totalDiscrepancies" value="${stat[2] + stat[3]}" />
                                                <h4 class="text-warning">${totalDiscrepancies}</h4>
                                                <p class="mb-0">Có chênh lệch</p>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <div class="p-3 border rounded">
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

            <!-- Danh sách sản phẩm có chênh lệch cần điều chỉnh -->
            <c:if test="${not empty discrepancies}">
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="card reconcile-card">
                            <div class="card-header bg-warning text-dark d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="bi bi-exclamation-triangle"></i> Sản phẩm cần điều chỉnh tồn kho</h5>
                                <span class="badge bg-dark">${discrepancies.size()} sản phẩm</span>
                            </div>
                            <div class="card-body">
                                <div class="alert alert-info" role="alert">
                                    <i class="bi bi-info-circle"></i>
                                    <strong>Lưu ý:</strong> Khi thực hiện điều chỉnh, hệ thống sẽ cập nhật số lượng tồn kho trong bảng inventory thành số lượng kiểm đếm thực tế.
                                </div>
                                
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
                                                <th width="16%">Tác động</th>
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
                                                        <c:choose>
                                                            <c:when test="${diff > 0}">
                                                                <span class="text-success">
                                                                    <i class="bi bi-arrow-up-circle"></i> Tăng tồn kho
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-danger">
                                                                    <i class="bi bi-arrow-down-circle"></i> Giảm tồn kho
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
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

            <!-- Nút thực hiện điều chỉnh -->
            <c:if test="${stockTake.status == 'completed' && not empty discrepancies}">
                <div class="row">
                    <div class="col-12 text-center">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title text-warning">
                                    <i class="bi bi-gear-fill"></i> Thực hiện điều chỉnh tồn kho
                                </h5>
                                <p class="card-text">
                                    Bạn có chắc chắn muốn điều chỉnh tồn kho cho <strong>${discrepancies.size()}</strong> sản phẩm có chênh lệch?<br>
                                    <small class="text-muted">Hành động này sẽ cập nhật số lượng tồn kho trong hệ thống và không thể hoàn tác.</small>
                                </p>
                                <button type="button" class="btn btn-warning btn-lg" onclick="confirmReconcile()">
                                    <i class="bi bi-check-circle"></i> Xác nhận điều chỉnh
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${stockTake.status == 'reconciled'}">
                <div class="row">
                    <div class="col-12">
                        <div class="alert alert-success text-center" role="alert">
                            <i class="bi bi-check-circle-fill fs-1"></i>
                            <h4 class="mt-2">Đã hoàn tất điều chỉnh tồn kho</h4>
                            <p class="mb-0">Phiếu kiểm kê này đã được đối soát và số lượng tồn kho đã được cập nhật.</p>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty discrepancies && stockTake.status == 'completed'}">
                <div class="row">
                    <div class="col-12">
                        <div class="alert alert-info text-center" role="alert">
                            <i class="bi bi-check-circle-fill fs-1"></i>
                            <h4 class="mt-2">Không có chênh lệch</h4>
                            <p class="mb-0">Tất cả sản phẩm đều khớp với số lượng hệ thống. Không cần điều chỉnh tồn kho.</p>
                            <button type="button" class="btn btn-success mt-3" onclick="markAsReconciled()">
                                <i class="bi bi-check"></i> Đánh dấu đã đối soát
                            </button>
                        </div>
                    </div>
                </div>
            </c:if>
        </main>
    </div>
</div>

<!-- Form ẩn để thực hiện reconcile -->
<form id="reconcileForm" method="POST" action="${pageContext.request.contextPath}/stock-take" style="display: none;">
    <input type="hidden" name="action" value="reconcile">
    <input type="hidden" name="stockTakeId" value="${stockTake.stockTakeId}">
</form>

<!-- Form ẩn để đánh dấu đã đối soát -->
<form id="markReconciledForm" method="POST" action="${pageContext.request.contextPath}/stock-take" style="display: none;">
    <input type="hidden" name="action" value="update-status">
    <input type="hidden" name="stockTakeId" value="${stockTake.stockTakeId}">
    <input type="hidden" name="status" value="reconciled">
</form>

<script>
function confirmReconcile() {
    if (confirm('Bạn có chắc chắn muốn điều chỉnh tồn kho cho tất cả sản phẩm có chênh lệch?\n\nHành động này sẽ:\n- Cập nhật số lượng tồn kho trong hệ thống\n- Thay đổi trạng thái phiếu kiểm kê thành "Đã đối soát"\n- Không thể hoàn tác\n\nBấm OK để tiếp tục.')) {
        document.getElementById('reconcileForm').submit();
    }
}

function markAsReconciled() {
    if (confirm('Xác nhận đánh dấu phiếu kiểm kê này đã hoàn tất đối soát?')) {
        document.getElementById('markReconciledForm').submit();
    }
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
</body>
</html> 