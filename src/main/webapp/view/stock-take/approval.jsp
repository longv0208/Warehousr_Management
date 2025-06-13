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
    <title>Quản Lý Kho Hàng - Xem Đơn Kiểm Kê</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
    <style>
        .view-card {
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
        .view-summary {
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
        <div class="col-md-2"></div> <!-- Space for sidebar -->
        <main class="col-md-10 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3><i class="bi bi-clipboard-check"></i> Xem Đơn Kiểm Kê</h3>
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
                    <div class="card view-summary">
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
                                                <c:when test="${stockTake.status == 'reconciled'}">Đã điều chỉnh</c:when>
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
                        <div class="card view-card">
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

            <!-- Phần điều chỉnh tồn kho -->
            <c:if test="${stockTake.status == 'completed'}">
                <div class="row">
                    <div class="col-md-12">
                        <div class="card border-success">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0"><i class="bi bi-arrow-repeat"></i> Điều chỉnh tồn kho</h5>
                            </div>
                            <div class="card-body">
                                <form id="reconcileForm" method="POST" action="${pageContext.request.contextPath}/stock-take">
                                    <input type="hidden" name="action" value="reconcile">
                                    <input type="hidden" name="stockTakeId" value="${stockTake.stockTakeId}">
                                    
                                    <div class="mb-3">
                                        <div class="alert alert-info">
                                            <i class="bi bi-info-circle"></i>
                                            <strong>Lưu ý:</strong> Việc điều chỉnh tồn kho sẽ cập nhật số lượng trong inventory theo số lượng kiểm đếm thực tế.
                                            <c:if test="${not empty discrepancies}">
                                                <br><strong>Sẽ điều chỉnh ${discrepancies.size()} sản phẩm có chênh lệch.</strong>
                                            </c:if>
                                        </div>
                                    </div>
                                    
                                    <div class="d-grid">
                                        <button type="button" class="btn btn-success btn-lg" onclick="confirmReconcile()">
                                            <i class="bi bi-arrow-repeat"></i> Điều chỉnh tồn kho theo kết quả kiểm kê
                                        </button>
                                    </div>
                                </form>
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
                            <h4 class="mt-2">Đã điều chỉnh tồn kho</h4>
                            <p class="mb-0">Tồn kho đã được cập nhật theo kết quả kiểm kê.</p>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty discrepancies && stockTake.status == 'completed'}">
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="alert alert-success text-center" role="alert">
                            <i class="bi bi-check-circle-fill fs-1"></i>
                            <h4 class="mt-2">Kiểm kê chính xác 100%</h4>
                            <p class="mb-0">Tất cả sản phẩm đều khớp với số lượng hệ thống. Không cần điều chỉnh tồn kho!</p>
                        </div>
                    </div>
                </div>
            </c:if>
        </main>
    </div>
</div>

<script>
function confirmReconcile() {
    if (confirm('Bạn có chắc chắn muốn điều chỉnh tồn kho theo kết quả kiểm kê?\n\nSau khi điều chỉnh, số lượng tồn kho sẽ được cập nhật theo số lượng kiểm đếm thực tế.')) {
        document.getElementById('reconcileForm').submit();
    }
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
</body>
</html> 