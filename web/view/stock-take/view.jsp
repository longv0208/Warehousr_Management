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
    <title>Quản Lý Kho Hàng - Chi Tiết Kiểm Kê</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="../common/sidebar.jsp" />

<div class="container-fluid">
    <div class="row">
        <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3>Chi Tiết Phiếu Kiểm Kê</h3>
                    <p class="text-muted mb-0">Mã phiếu: ${stockTake.stockTakeCode}</p>
                </div>
                <a href="${pageContext.request.contextPath}/stock-take" class="btn btn-secondary">Quay lại</a>
            </div>

            <!-- Thông tin phiếu kiểm kê -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">Thông tin phiếu kiểm kê</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <p><strong>Mã phiếu:</strong> ${stockTake.stockTakeCode}</p>
                                    <p><strong>Ngày tạo:</strong> <fmt:formatDate value="${stockTake.stockTakeDate}" pattern="dd/MM/yyyy HH:mm:ss" /></p>
                                    <p><strong>Người tạo:</strong> ${stockTake.userFullName}</p>
                                </div>
                                <div class="col-md-6">
                                    <p><strong>Trạng thái:</strong> 
                                        <c:choose>
                                            <c:when test="${stockTake.status == 'pending'}">
                                                <span class="badge bg-warning">Chờ xử lý</span>
                                            </c:when>
                                            <c:when test="${stockTake.status == 'in_progress'}">
                                                <span class="badge bg-info">Đang kiểm kê</span>
                                            </c:when>
                                            <c:when test="${stockTake.status == 'completed'}">
                                                <span class="badge bg-success">Hoàn thành</span>
                                            </c:when>
                                            <c:when test="${stockTake.status == 'reconciled'}">
                                                <span class="badge bg-primary">Đã đối soát</span>
                                            </c:when>
                                        </c:choose>
                                    </p>
                                    <p><strong>Ghi chú:</strong> ${stockTake.notes != null ? stockTake.notes : 'Không có'}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bộ lọc -->
            <div class="row mb-3">
                <div class="col-md-4">
                    <input type="text" id="searchProduct" class="form-control" placeholder="Tìm kiếm sản phẩm...">
                </div>
                <div class="col-md-3">
                    <select id="filterStatus" class="form-select">
                        <option value="">Tất cả trạng thái</option>
                        <option value="counted">Đã kiểm</option>
                        <option value="not-counted">Chưa kiểm</option>
                        <option value="match">Khớp</option>
                        <option value="discrepancy">Có chênh lệch</option>
                    </select>
                </div>
            </div>

            <!-- Chi tiết kiểm kê -->
            <div class="table-responsive">
                <table class="table table-bordered table-hover" id="stockTakeTable">
                    <thead class="table-light">
                        <tr>
                            <th>STT</th>
                            <th>Mã SP</th>
                            <th>Tên sản phẩm</th>
                            <th>Đơn vị</th>
                            <th>SL Hệ thống</th>
                            <th>SL Kiểm đếm</th>
                            <th>Chênh lệch</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="detail" items="${stockTakeDetails}" varStatus="status">
                            <tr data-product-code="${detail.productCode}" data-product-name="${detail.productName}">
                                <td>${status.index + 1}</td>
                                <td>${detail.productCode}</td>
                                <td>${detail.productName}</td>
                                <td>${detail.unit}</td>
                                <td class="text-center">${detail.systemQuantity}</td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${detail.countedQuantity != null}">
                                            ${detail.countedQuantity}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">Chưa kiểm</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:if test="${detail.countedQuantity != null}">
                                        <c:set var="diff" value="${detail.countedQuantity - detail.systemQuantity}" />
                                        <span class="badge ${diff > 0 ? 'bg-success' : diff < 0 ? 'bg-danger' : 'bg-secondary'}">
                                            ${diff > 0 ? '+' : ''}${diff}
                                        </span>
                                    </c:if>
                                </td>
                                <td class="text-center status-cell">
                                    <c:choose>
                                        <c:when test="${detail.countedQuantity == null}">
                                            <span class="badge bg-warning">Chưa kiểm</span>
                                        </c:when>
                                        <c:when test="${detail.countedQuantity == detail.systemQuantity}">
                                            <span class="badge bg-success">Khớp</span>
                                        </c:when>
                                        <c:when test="${detail.countedQuantity > detail.systemQuantity}">
                                            <span class="badge bg-info">Thừa</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger">Thiếu</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                
                <c:if test="${empty stockTakeDetails}">
                    <div class="text-center py-4">
                        <p class="text-muted">Không có chi tiết kiểm kê nào.</p>
                    </div>
                </c:if>
            </div>

            <!-- Thống kê -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h6>Thống kê tổng quan</h6>
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
                                    <h4 id="matchedItems" class="text-info">0</h4>
                                    <p>Khớp</p>
                                </div>
                                <div class="col-md-3">
                                    <h4 id="discrepancyItems" class="text-warning">0</h4>
                                    <p>Chênh lệch</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script>
// Tính toán thống kê
function calculateStatistics() {
    const rows = document.querySelectorAll('#stockTakeTable tbody tr');
    let counted = 0, matched = 0, discrepancy = 0;
    
    rows.forEach(row => {
        const statusCell = row.querySelector('.status-cell .badge');
        if (statusCell) {
            const statusText = statusCell.textContent;
            if (statusText !== 'Chưa kiểm') {
                counted++;
                if (statusText === 'Khớp') {
                    matched++;
                } else {
                    discrepancy++;
                }
            }
        }
    });
    
    document.getElementById('countedItems').textContent = counted;
    document.getElementById('matchedItems').textContent = matched;
    document.getElementById('discrepancyItems').textContent = discrepancy;
}

// Tìm kiếm sản phẩm
document.getElementById('searchProduct').addEventListener('input', function() {
    const searchTerm = this.value.toLowerCase();
    const rows = document.querySelectorAll('#stockTakeTable tbody tr');
    
    rows.forEach(row => {
        const productCode = row.dataset.productCode.toLowerCase();
        const productName = row.dataset.productName.toLowerCase();
        
        if (productCode.includes(searchTerm) || productName.includes(searchTerm)) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
});

// Lọc theo trạng thái
document.getElementById('filterStatus').addEventListener('change', function() {
    const filterValue = this.value;
    const rows = document.querySelectorAll('#stockTakeTable tbody tr');
    
    rows.forEach(row => {
        const statusCell = row.querySelector('.status-cell .badge');
        let show = true;
        
        if (filterValue && statusCell) {
            const statusText = statusCell.textContent;
            
            switch(filterValue) {
                case 'counted':
                    show = statusText !== 'Chưa kiểm';
                    break;
                case 'not-counted':
                    show = statusText === 'Chưa kiểm';
                    break;
                case 'match':
                    show = statusText === 'Khớp';
                    break;
                case 'discrepancy':
                    show = statusText === 'Thừa' || statusText === 'Thiếu';
                    break;
            }
        }
        
        row.style.display = show ? '' : 'none';
    });
});

// Tính toán thống kê khi trang load
document.addEventListener('DOMContentLoaded', function() {
    calculateStatistics();
});
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 