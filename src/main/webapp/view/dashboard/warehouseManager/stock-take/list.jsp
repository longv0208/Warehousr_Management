<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.StockTake" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Warehouse Manager - Kiểm Kê Kho</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="../../../common/sidebar.jsp" />

<div class="container-fluid">
    <div class="row">
        <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3>Danh sách Kiểm Kê - Đối Soát</h3>
                <span class="badge bg-primary fs-6">Warehouse Manager</span>
            </div>

            <!-- Bộ lọc trạng thái -->
            <div class="row mb-3">
                <div class="col-md-4">
                    <form method="GET" action="${pageContext.request.contextPath}/warehouse-manager/stock-take">
                        <div class="input-group">
                            <select name="status" class="form-select">
                                <option value="">-- Tất cả trạng thái --</option>
                                <option value="pending" ${param.status == 'pending' ? 'selected' : ''}>Chờ xử lý</option>
                                <option value="in_progress" ${param.status == 'in_progress' ? 'selected' : ''}>Đang kiểm kê</option>
                                <option value="completed" ${param.status == 'completed' ? 'selected' : ''}>Hoàn thành</option>
                                <option value="reconciled" ${param.status == 'reconciled' ? 'selected' : ''}>Đã đối soát</option>
                            </select>
                            <button type="submit" class="btn btn-outline-secondary">Lọc</button>
                        </div>
                    </form>
                </div>
                <div class="col-md-4">
                    <form method="GET" action="${pageContext.request.contextPath}/warehouse-manager/stock-take">
                        <div class="input-group">
                            <select name="warehouseId" class="form-select">
                                <option value="">-- Tất cả kho hàng --</option>
                                <c:forEach var="warehouse" items="${warehouses}">
                                    <option value="${warehouse.warehouseId}" 
                                            ${selectedWarehouseId == warehouse.warehouseId.toString() ? 'selected' : ''}>
                                        ${warehouse.warehouseName}
                                    </option>
                                </c:forEach>
                            </select>
                            <button type="submit" class="btn btn-outline-primary">Lọc theo kho</button>
                        </div>
                    </form>
                </div>
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

            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>Mã phiếu</th>
                            <th>Ngày kiểm kê</th>
                            <th>Người tạo</th>
                            <th>Kho hàng</th>
                            <th>Trạng thái</th>
                            <th>Tổng sản phẩm</th>
                            <th>Đã kiểm</th>
                            <th>Tiến độ</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="stockTake" items="${stockTakes}">
                            <tr>
                                <td>${stockTake.stockTakeCode}</td>
                                <td><fmt:formatDate value="${stockTake.stockTakeDate}" pattern="dd/MM/yyyy" /></td>
                                <td>${stockTake.userFullName}</td>
                                <td>
                                    <span class="badge bg-primary">${stockTake.warehouseName != null ? stockTake.warehouseName : 'N/A'}</span>
                                </td>
                                <td>
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
                                            <span class="badge bg-dark">Đã đối soát</span>
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>${stockTake.totalProducts != null ? stockTake.totalProducts : 0}</td>
                                <td>${stockTake.completedProducts != null ? stockTake.completedProducts : 0}</td>
                                <td>
                                    <c:if test="${stockTake.totalProducts != null && stockTake.totalProducts > 0}">
                                        <c:set var="progress" value="${(stockTake.completedProducts * 100) / stockTake.totalProducts}" />
                                        <div class="progress" style="height: 20px;">
                                            <div class="progress-bar" role="progressbar" style="width: ${progress}%" aria-valuenow="${progress}" aria-valuemin="0" aria-valuemax="100">
                                                <fmt:formatNumber value="${progress}" maxFractionDigits="1" />%
                                            </div>
                                        </div>
                                    </c:if>
                                </td>
                                <td>
                                    <div class="btn-group" role="group">
                                        <a href="${pageContext.request.contextPath}/warehouse-manager/stock-take?action=view&id=${stockTake.stockTakeId}" 
                                           class="btn btn-sm btn-outline-info">Xem</a>
                                        
                                        <!-- Warehouse Manager có thể đối soát các phiếu đã hoàn thành -->
                                        <c:if test="${stockTake.status == 'completed' || stockTake.status == 'reconciled'}">
                                            <a href="${pageContext.request.contextPath}/warehouse-manager/stock-take?action=approve-view&id=${stockTake.stockTakeId}" 
                                               class="btn btn-sm btn-warning">
                                                <c:choose>
                                                    <c:when test="${stockTake.status == 'completed'}">Đối soát</c:when>
                                                    <c:otherwise>Xem đối soát</c:otherwise>
                                                </c:choose>
                                            </a>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                
                <c:if test="${empty stockTakes}">
                    <div class="text-center py-4">
                        <p class="text-muted">Không có phiếu kiểm kê nào.</p>
                    </div>
                </c:if>
            </div>

            <!-- Thông tin hướng dẫn -->
            <div class="alert alert-info mt-4" role="alert">
                <h6><i class="bi bi-info-circle"></i> Hướng dẫn sử dụng</h6>
                <ul class="mb-0">
                    <li><strong>Xem:</strong> Xem thông tin chi tiết phiếu kiểm kê</li>
                    <li><strong>Đối soát:</strong> Điều chỉnh tồn kho theo kết quả kiểm kê (chỉ áp dụng với phiếu đã hoàn thành)</li>
                    <li><strong>Xem đối soát:</strong> Xem kết quả đối soát đã thực hiện</li>
                </ul>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 