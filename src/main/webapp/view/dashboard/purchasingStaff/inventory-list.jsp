<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xem Tồn Kho</title>
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
                    <h1 class="h2"><i class="fas fa-boxes me-2"></i>Xem Tồn Kho</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/purchase-staff/inventory?action=export" 
                           class="btn btn-success">
                            <i class="fas fa-file-excel me-1"></i>Xuất Excel
                        </a>
                    </div>
                </div>

                <!-- Filter Form -->
                <div class="card mb-4">
                    <div class="card-body">
                        <form method="GET" action="${pageContext.request.contextPath}/purchase-staff/inventory">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label for="warehouseId" class="form-label">Chọn Kho</label>
                                    <select class="form-select" id="warehouseId" name="warehouseId">
                                        <option value="">Tất cả kho</option>
                                        <c:forEach var="warehouse" items="${warehouses}">
                                            <option value="${warehouse.warehouseId}" 
                                                    ${warehouseId == warehouse.warehouseId ? 'selected' : ''}>
                                                ${warehouse.warehouseName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label for="searchTerm" class="form-label">Tìm kiếm</label>
                                    <input type="text" class="form-control" id="searchTerm" name="searchTerm" 
                                           value="${searchTerm}" placeholder="Nhập tên hoặc mã sản phẩm...">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">&nbsp;</label>
                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-search me-1"></i>Tìm kiếm
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Inventory Table -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Danh sách tồn kho</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead class="table-dark">
                                    <tr>
                                        <th>STT</th>
                                        <th>Kho</th>
                                        <th>Mã sản phẩm</th>
                                        <th>Tên sản phẩm</th>
                                        <th>Đơn vị</th>
                                        <th>Số lượng tồn</th>
                                        <th>Cập nhật</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty inventoryList}">
                                            <c:forEach var="inventory" items="${inventoryList}" varStatus="status">
                                                <tr>
                                                    <td>${status.index + 1}</td>
                                                    <td>${inventory.warehouseName}</td>
                                                    <td><code>${inventory.productCode}</code></td>
                                                    <td>${inventory.productName}</td>
                                                    <td>${inventory.unit}</td>
                                                    <td>
                                                        <span class="badge bg-info fs-6">${inventory.quantityOnHand}</span>
                                                    </td>
                                                    <td>
                                                        <c:if test="${not empty inventory.lastUpdated}">
                                                            <fmt:formatDate value="${inventory.lastUpdated}" pattern="dd/MM/yyyy"/>
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${inventory.quantityOnHand <= 0}">
                                                                <span class="badge bg-danger">Hết hàng</span>
                                                            </c:when>
                                                            <c:when test="${inventory.quantityOnHand <= 10}">
                                                                <span class="badge bg-warning">Sắp hết</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-success">Đủ hàng</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="8" class="text-center py-4">
                                                    <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                                    <p class="text-muted">Không có dữ liệu tồn kho</p>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 