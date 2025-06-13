<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.LowStockProduct" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Quản Lý Kho Hàng - Báo Cáo Sản Phẩm Sắp Hết Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
    <style>
        .status-badge {
            font-size: 0.75rem;
            padding: 0.375rem 0.5rem;
        }
        .quantity-critical {
            color: #dc3545;
            font-weight: bold;
        }
        .quantity-warning {
            color: #fd7e14;
            font-weight: bold;
        }
        .table-hover tbody tr:hover {
            background-color: rgba(0,0,0,.075);
        }
        .stats-card {
            border-left: 4px solid #dc3545;
        }
    </style>
</head>
<body>
<jsp:include page="../common/sidebar.jsp" />

<div class="container-fluid">
    <div class="row">
        <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3>
                    <c:choose>
                        <c:when test="${reportType == 'out-of-stock'}">
                            <i class="bi bi-exclamation-triangle-fill text-danger me-2"></i>
                            Báo Cáo Sản Phẩm Hết Hàng
                        </c:when>
                        <c:otherwise>
                            <i class="bi bi-exclamation-triangle text-warning me-2"></i>
                            Báo Cáo Sản Phẩm Sắp Hết Hàng
                        </c:otherwise>
                    </c:choose>
                </h3>
                
                <div class="btn-group" role="group">
                    <a href="${pageContext.request.contextPath}/low-stock-report" 
                       class="btn ${reportType != 'out-of-stock' ? 'btn-warning' : 'btn-outline-warning'}">
                        Sắp Hết Hàng
                    </a>
                    <a href="${pageContext.request.contextPath}/low-stock-report?action=out-of-stock" 
                       class="btn ${reportType == 'out-of-stock' ? 'btn-danger' : 'btn-outline-danger'}">
                        Hết Hàng
                    </a>
                </div>
            </div>

            <!-- Thống kê tổng quan -->
            <div class="row mb-4">
                <div class="col-md-12">
                    <div class="card stats-card">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <h5 class="card-title text-danger">
                                        <i class="bi bi-graph-down-arrow me-2"></i>
                                        Tổng Quan
                                    </h5>
                                    <p class="card-text">
                                        <c:choose>
                                            <c:when test="${reportType == 'out-of-stock'}">
                                                <strong>${totalLowStockProducts}</strong> sản phẩm đã hết hàng hoàn toàn
                                            </c:when>
                                            <c:otherwise>
                                                <strong>${totalLowStockProducts}</strong> sản phẩm có số lượng tồn kho ≤ ngưỡng cảnh báo
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                                <div class="col-md-6">
                                    <div class="text-md-end">
                                        <i class="bi bi-calendar3 me-1"></i>
                                        <small class="text-muted">
                                            Cập nhật: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy HH:mm" />
                                        </small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bộ lọc và sắp xếp -->
            <c:if test="${reportType != 'out-of-stock'}">
                <div class="row mb-3">
                    <div class="col-md-4">
                        <form method="GET" action="${pageContext.request.contextPath}/low-stock-report">
                            <div class="input-group">
                                <select name="sortBy" class="form-select">
                                    <option value="quantity" ${currentSortBy == 'quantity' ? 'selected' : ''}>Số lượng tăng dần</option>
                                    <option value="product_name" ${currentSortBy == 'product_name' ? 'selected' : ''}>Tên sản phẩm A-Z</option>
                                    <option value="threshold" ${currentSortBy == 'threshold' ? 'selected' : ''}>Ngưỡng cảnh báo</option>
                                </select>
                                <button type="submit" class="btn btn-outline-secondary">
                                    <i class="bi bi-sort-alpha-down me-1"></i>Sắp xếp
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>

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

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" role="alert">
                    ${errorMessage}
                </div>
            </c:if>

            <!-- Bảng danh sách sản phẩm -->
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>Mã sản phẩm</th>
                            <th>Tên sản phẩm</th>
                            <th>Đơn vị</th>
                            <th>Số lượng hiện tại</th>
                            <th>Ngưỡng cảnh báo</th>
                            <th>Nhà cung cấp</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="product" items="${lowStockProducts}">
                            <tr>
                                <td>
                                    <code class="text-primary">${product.productCode}</code>
                                </td>
                                <td>
                                    <strong>${product.productName}</strong>
                                    <c:if test="${not empty product.description}">
                                        <br><small class="text-muted">${product.description}</small>
                                    </c:if>
                                </td>
                                <td>${product.unit}</td>
                                <td>
                                    <span class="${product.quantityOnHand == 0 ? 'quantity-critical' : 'quantity-warning'}">
                                        ${product.quantityOnHand}
                                    </span>
                                </td>
                                <td>${product.lowStockThreshold}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty product.supplierName}">
                                            ${product.supplierName}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">Chưa có nhà cung cấp</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="badge status-badge ${product.statusClass}">
                                        ${product.statusDisplay}
                                    </span>
                                </td>
                                <td>
                                    <div class="btn-group" role="group">
                                        <c:if test="${currentUser.roleId == 'admin'}">
                                            <a href="${pageContext.request.contextPath}/admin/manage-product?action=edit&id=${product.productId}" 
                                               class="btn btn-sm btn-outline-primary" title="Chỉnh sửa sản phẩm">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                        </c:if>
                                        
                                        <c:if test="${currentUser.roleId == 'admin' || currentUser.roleId == 'purchasing_staff'}">
                                            <a href="${pageContext.request.contextPath}/purchase-request?action=create&productId=${product.productId}" 
                                               class="btn btn-sm btn-success" title="Tạo yêu cầu mua hàng">
                                                <i class="bi bi-cart-plus"></i>
                                            </a>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                
                <c:if test="${empty lowStockProducts}">
                    <div class="text-center py-5">
                        <i class="bi bi-check-circle text-success" style="font-size: 3rem;"></i>
                        <h5 class="mt-3 text-success">Tuyệt vời!</h5>
                        <p class="text-muted">
                            <c:choose>
                                <c:when test="${reportType == 'out-of-stock'}">
                                    Hiện tại không có sản phẩm nào hết hàng.
                                </c:when>
                                <c:otherwise>
                                    Hiện tại không có sản phẩm nào sắp hết hàng.
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </c:if>
            </div>

            <!-- Ghi chú -->
            <div class="mt-4">
                <div class="card">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-info-circle me-2"></i>Ghi chú</h6>
                    </div>
                    <div class="card-body">
                        <ul class="mb-0">
                            <li><span class="badge bg-danger">Hết hàng</span> - Sản phẩm có số lượng = 0</li>
                            <li><span class="badge bg-warning">Sắp hết hàng</span> - Sản phẩm có số lượng ≤ ngưỡng cảnh báo</li>
                            <li>Báo cáo được cập nhật theo thời gian thực từ hệ thống quản lý kho</li>
                            <li>Khuyến nghị: Tạo yêu cầu mua hàng cho các sản phẩm sắp hết hàng để tránh gián đoạn kinh doanh</li>
                        </ul>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 