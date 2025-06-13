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
    <title>Quản Lý Kho Hàng - Thực Hiện Kiểm Kê</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="${pageContext.request.contextPath}/styles/index.css" rel="stylesheet"/>
    <style>
        /* Sidebar layout fix */
        .main-content {
            margin-left: 250px !important;
            width: calc(100% - 250px) !important;
            min-height: 100vh;
        }
        
        @media (max-width: 767.98px) {
            .main-content {
                margin-left: 0 !important;
                width: 100% !important;
            }
        }

        /* Badge-like styles cho chênh lệch */
        .difference-positive {
            background-color: #198754; /* bootstrap success */
            color: #fff;
            padding: 0.35em 0.65em;
            border-radius: 0.25rem;
            font-size: 0.875em;
        }
        .difference-negative {
            background-color: #dc3545; /* bootstrap danger */
            color: #fff;
            padding: 0.35em 0.65em;
            border-radius: 0.25rem;
            font-size: 0.875em;
        }
        .difference-zero {
            background-color: #6c757d; /* bootstrap secondary */
            color: #fff;
            padding: 0.35em 0.65em;
            border-radius: 0.25rem;
            font-size: 0.875em;
        }
    </style>
</head>
<body>
<jsp:include page="../common/sidebar.jsp" />

<div class="container-fluid main-content">
    <div class="row">
        <main class="col-md-12 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3>Thực Hiện Kiểm Kê</h3>
                    <p class="text-muted mb-0">Phiếu: ${stockTake.stockTakeCode} - Ngày: <fmt:formatDate value="${stockTake.stockTakeDate}" pattern="dd/MM/yyyy" /></p>
                </div>
                <a href="${pageContext.request.contextPath}/stock-take" class="btn btn-secondary">Quay lại</a>
            </div>

            <!-- Hiển thị thông báo -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <!-- Bộ lọc và tìm kiếm -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <input type="text" id="searchProduct" class="form-control" placeholder="Tìm kiếm sản phẩm...">
                </div>
                <div class="col-md-3">
                    <select id="filterStatus" class="form-select">
                        <option value="">Tất cả</option>
                        <option value="counted">Đã kiểm</option>
                        <option value="not-counted">Chưa kiểm</option>
                        <option value="discrepancy">Có chênh lệch</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <button type="button" class="btn btn-success" onclick="saveAllChanges()">Lưu tất cả thay đổi</button>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-bordered table-hover" id="stockTakeTable">
                    <thead class="table-light">
                        <tr>
                            <th>Mã SP</th>
                            <th>Tên sản phẩm</th>
                            <th>Đơn vị</th>
                            <th>SL Hệ thống</th>
                            <th>SL Kiểm đếm</th>
                            <th>Chênh lệch</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="detail" items="${stockTakeDetails}">
                            <tr data-product-code="${detail.productCode}" data-product-name="${detail.productName}">
                                <td>${detail.productCode}</td>
                                <td>${detail.productName}</td>
                                <td>${detail.unit}</td>
                                <td class="text-center">${detail.systemQuantity}</td>
                                <td class="text-center">
                                    <input type="number" 
                                           class="form-control text-center counted-input" 
                                           value="${detail.countedQuantity != null ? detail.countedQuantity : ''}"
                                           data-detail-id="${detail.stockTakeDetailId}"
                                           data-system-qty="${detail.systemQuantity}"
                                           min="0"
                                           style="width: 100px; margin: 0 auto;">
                                </td>
                                <td class="text-center discrepancy-cell">
                                    <!-- Chênh lệch sẽ được tính bằng JavaScript từ input -->
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- Thống kê -->
            <div class="row mt-4">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <h6>Thống kê tiến độ</h6>
                        </div>
                        <div class="card-body">
                            <div class="row text-center">
                                <div class="col-md-3">
                                    <h4 id="totalItems" class="text-primary">${stockTakeDetails.size()}</h4>
                                    <p>Tổng sản phẩm</p>
                                </div>
                                <div class="col-md-3">
                                    <h4 id="countedItems" class="text-success">0</h4>
                                    <p>Đã kiểm</p>
                                </div>
                                <div class="col-md-3">
                                    <h4 id="remainingItems" class="text-warning">${stockTakeDetails.size()}</h4>
                                    <p>Còn lại</p>
                                </div>
                                <div class="col-md-3">
                                    <h4 id="progressPercentage" class="text-info">0%</h4>
                                    <p>Tiến độ</p>
                                </div>
                            </div>
                            <div class="progress mt-3">
                                <div id="progressBar" class="progress-bar" role="progressbar" style="width: 0%"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/stock-take-perform.js"></script>
<script>
// Initialize the stock take functionality when page loads
document.addEventListener('DOMContentLoaded', function() {
    initializeStockTake('${stockTake.stockTakeId}', '${pageContext.request.contextPath}');
});
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 