<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Cáo Tồn Kho</title>
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
                    <h1 class="h2"><i class="fas fa-chart-bar me-2"></i>Báo Cáo Tồn Kho</h1>
                </div>

                <!-- Export Options -->
                <div class="row mb-4">
                    <div class="col-md-4">
                        <div class="card border-success">
                            <div class="card-body text-center">
                                <i class="fas fa-file-excel fa-3x text-success mb-3"></i>
                                <h5 class="card-title">Báo cáo tổng hợp</h5>
                                <p class="card-text">Xuất báo cáo tồn kho theo kho và sản phẩm</p>
                                <a href="${pageContext.request.contextPath}/admin/purchase-management/reports?action=export-excel&warehouseId=${warehouseId}&productId=${productId}" 
                                   class="btn btn-success">
                                    <i class="fas fa-download me-1"></i>Tải Excel
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card border-info">
                            <div class="card-body text-center">
                                <i class="fas fa-cube fa-3x text-info mb-3"></i>
                                <h5 class="card-title">Báo cáo theo sản phẩm</h5>
                                <p class="card-text">Báo cáo tổng hợp theo từng sản phẩm</p>
                                <a href="${pageContext.request.contextPath}/admin/purchase-management/reports?action=export-product-excel" 
                                   class="btn btn-info">
                                    <i class="fas fa-download me-1"></i>Tải Excel
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card border-warning">
                            <div class="card-body text-center">
                                <i class="fas fa-warehouse fa-3x text-warning mb-3"></i>
                                <h5 class="card-title">Báo cáo theo kho</h5>
                                <p class="card-text">Báo cáo tổng hợp theo từng kho</p>
                                <a href="${pageContext.request.contextPath}/admin/purchase-management/reports?action=export-warehouse-excel" 
                                   class="btn btn-warning">
                                    <i class="fas fa-download me-1"></i>Tải Excel
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filter Form -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Bộ lọc báo cáo</h5>
                    </div>
                    <div class="card-body">
                        <form method="GET" action="${pageContext.request.contextPath}/admin/purchase-management/reports">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label for="warehouseId" class="form-label">Kho</label>
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
                                <div class="col-md-3">
                                    <label for="productId" class="form-label">Sản phẩm</label>
                                    <select class="form-select" id="productId" name="productId">
                                        <option value="">Tất cả sản phẩm</option>
                                        <c:forEach var="product" items="${products}">
                                            <option value="${product.productId}" 
                                                    ${productId == product.productId ? 'selected' : ''}>
                                                ${product.productCode} - ${product.productName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="fromDate" class="form-label">Từ ngày</label>
                                    <input type="date" class="form-control" id="fromDate" name="fromDate" value="${fromDate}">
                                </div>
                                <div class="col-md-2">
                                    <label for="toDate" class="form-label">Đến ngày</label>
                                    <input type="date" class="form-control" id="toDate" name="toDate" value="${toDate}">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">&nbsp;</label>
                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-search me-1"></i>Lọc
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Summary Statistics -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card bg-primary text-white">
                            <div class="card-body">
                                <h5 class="card-title">Tổng sản phẩm</h5>
                                <h2>${not empty inventoryList ? inventoryList.size() : 0}</h2>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-success text-white">
                            <div class="card-body">
                                <h5 class="card-title">Tổng số lượng</h5>
                                <h2>
                                    <c:set var="totalQuantity" value="0"/>
                                    <c:forEach var="inventory" items="${inventoryList}">
                                        <c:set var="totalQuantity" value="${totalQuantity + inventory.quantityOnHand}"/>
                                    </c:forEach>
                                    ${totalQuantity}
                                </h2>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-warning text-white">
                            <div class="card-body">
                                <h5 class="card-title">Sắp hết hàng</h5>
                                <h2>
                                    <c:set var="lowStockCount" value="0"/>
                                    <c:forEach var="inventory" items="${inventoryList}">
                                        <c:if test="${inventory.quantityOnHand <= 10 && inventory.quantityOnHand > 0}">
                                            <c:set var="lowStockCount" value="${lowStockCount + 1}"/>
                                        </c:if>
                                    </c:forEach>
                                    ${lowStockCount}
                                </h2>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-danger text-white">
                            <div class="card-body">
                                <h5 class="card-title">Hết hàng</h5>
                                <h2>
                                    <c:set var="outOfStockCount" value="0"/>
                                    <c:forEach var="inventory" items="${inventoryList}">
                                        <c:if test="${inventory.quantityOnHand <= 0}">
                                            <c:set var="outOfStockCount" value="${outOfStockCount + 1}"/>
                                        </c:if>
                                    </c:forEach>
                                    ${outOfStockCount}
                                </h2>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Inventory Details Table -->
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-title mb-0">Chi tiết tồn kho</h5>
                        <div class="btn-group">
                            <a href="${pageContext.request.contextPath}/admin/purchase-management/reports?action=export-excel&warehouseId=${warehouseId}&productId=${productId}" 
                               class="btn btn-success btn-sm">
                                <i class="fas fa-file-excel me-1"></i>Xuất Excel
                            </a>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>STT</th>
                                        <th>Kho</th>
                                        <th>Mã SP</th>
                                        <th>Tên sản phẩm</th>
                                        <th>Đơn vị</th>
                                        <th>Số lượng tồn</th>
                                        <th>Giá mua</th>
                                        <th>Giá bán</th>
                                        <th>Giá trị tồn</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty inventoryList}">
                                            <c:forEach var="inventory" items="${inventoryList}" varStatus="status">
                                                <c:set var="warehouse" value="${null}"/>
                                                <c:set var="product" value="${null}"/>
                                                
                                                <!-- Find corresponding product and warehouse -->
                                                <c:forEach var="w" items="${warehouses}">
                                                    <c:if test="${w.warehouseId == inventory.warehouseId}">
                                                        <c:set var="warehouse" value="${w}"/>
                                                    </c:if>
                                                </c:forEach>
                                                
                                                <c:forEach var="p" items="${products}">
                                                    <c:if test="${p.productId == inventory.productId}">
                                                        <c:set var="product" value="${p}"/>
                                                    </c:if>
                                                </c:forEach>
                                                
                                                <tr>
                                                    <td>${status.index + 1}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty warehouse}">
                                                                <strong>${warehouse.warehouseName}</strong>
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty product}">
                                                                <code>${product.productCode}</code>
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty product}">
                                                                ${product.productName}
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty product}">
                                                                ${product.unit}
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-info fs-6">${inventory.quantityOnHand}</span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty product}">
                                                                <fmt:formatNumber value="${product.purchasePrice}" type="currency" currencySymbol="₫"/>
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty product}">
                                                                <fmt:formatNumber value="${product.salePrice}" type="currency" currencySymbol="₫"/>
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty product}">
                                                                <c:set var="totalValue" value="${inventory.quantityOnHand * product.purchasePrice}"/>
                                                                <strong><fmt:formatNumber value="${totalValue}" type="currency" currencySymbol="₫"/></strong>
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
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
                                                <td colspan="10" class="text-center py-4">
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