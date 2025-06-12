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
    <title>Quản Lý Kho Hàng - Báo Cáo Kiểm Kê</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="../common/sidebar.jsp" />

<div class="container-fluid">
    <div class="row">
        <main class="col-md-12 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3>Báo Cáo Kiểm Kê</h3>
                    <p class="text-muted mb-0">Phiếu: ${stockTake.stockTakeCode} - Ngày: <fmt:formatDate value="${stockTake.stockTakeDate}" pattern="dd/MM/yyyy" /></p>
                </div>
                <div>
                    <button onclick="window.print()" class="btn btn-info me-2">In báo cáo</button>
                    <a href="${pageContext.request.contextPath}/stock-take" class="btn btn-secondary">Quay lại</a>
                </div>
            </div>

            <!-- Thống kê tổng quan -->
            <c:if test="${not empty statistics}">
                <c:forEach var="stat" items="${statistics}">
                    <div class="row mb-4">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header bg-primary text-white">
                                    <h5 class="mb-0">Thống kê tổng quan</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row text-center">
                                        <div class="col-md-2">
                                            <h4 class="text-primary">${stat[0]}</h4>
                                            <p>Tổng sản phẩm</p>
                                        </div>
                                        <div class="col-md-2">
                                            <h4 class="text-success">${stat[1]}</h4>
                                            <p>Đã kiểm đếm</p>
                                        </div>
                                        <div class="col-md-2">
                                            <h4 class="text-warning">${stat[0] - stat[1]}</h4>
                                            <p>Chưa kiểm</p>
                                        </div>
                                        <div class="col-md-2">
                                            <h4 class="text-success">${stat[2]}</h4>
                                            <p>Thừa</p>
                                        </div>
                                        <div class="col-md-2">
                                            <h4 class="text-danger">${stat[3]}</h4>
                                            <p>Thiếu</p>
                                        </div>
                                        <div class="col-md-2">
                                            <h4 class="text-secondary">${stat[4]}</h4>
                                            <p>Khớp</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:if>

            <!-- Danh sách chênh lệch -->
            <c:if test="${not empty discrepancies}">
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header bg-warning text-dark">
                                <h5 class="mb-0">Sản phẩm có chênh lệch</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-bordered table-hover">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Mã SP</th>
                                                <th>Tên sản phẩm</th>
                                                <th>Đơn vị</th>
                                                <th>SL Hệ thống</th>
                                                <th>SL Kiểm đếm</th>
                                                <th>Chênh lệch</th>
                                                <th>Tỷ lệ</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="detail" items="${discrepancies}">
                                                <tr>
                                                    <td>${detail.productCode}</td>
                                                    <td>${detail.productName}</td>
                                                    <td>${detail.unit}</td>
                                                    <td class="text-center">${detail.systemQuantity}</td>
                                                    <td class="text-center">${detail.countedQuantity}</td>
                                                    <td class="text-center">
                                                        <c:set var="diff" value="${detail.countedQuantity - detail.systemQuantity}" />
                                                        <span class="badge ${diff > 0 ? 'bg-success' : 'bg-danger'}">
                                                            ${diff > 0 ? '+' : ''}${diff}
                                                        </span>
                                                    </td>
                                                    <td class="text-center">
                                                        <c:if test="${detail.systemQuantity > 0}">
                                                            <c:set var="percentage" value="${(detail.countedQuantity - detail.systemQuantity) * 100 / detail.systemQuantity}" />
                                                            <fmt:formatNumber value="${percentage}" maxFractionDigits="1" />%
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

            <!-- Danh sách chi tiết đầy đủ -->
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header bg-info text-white">
                            <h5 class="mb-0">Chi tiết kiểm kê đầy đủ</h5>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-bordered table-hover" id="fullReportTable">
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
                                            <tr>
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
                                                <td class="text-center">
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
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Thông tin phiếu kiểm kê -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
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
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 