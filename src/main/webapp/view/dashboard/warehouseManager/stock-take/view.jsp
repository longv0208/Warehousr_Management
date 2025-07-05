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
    <title>Warehouse Manager - Xem Kiểm Kê</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="../../../common/sidebar.jsp" />

<div class="container-fluid">
    <div class="row">
        <div class="col-md-2"></div> <!-- Space for sidebar -->
        <main class="col-md-10 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3><i class="bi bi-clipboard-data"></i> Chi Tiết Kiểm Kê - Warehouse Manager</h3>
                    <p class="text-muted mb-0">Phiếu: ${stockTake.stockTakeCode} - Ngày: <fmt:formatDate value="${stockTake.stockTakeDate}" pattern="dd/MM/yyyy HH:mm" /></p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/warehouse-manager/stock-take" class="btn btn-secondary">Quay lại</a>
                </div>
            </div>

            <!-- Thông tin phiếu kiểm kê -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0"><i class="bi bi-info-circle"></i> Thông tin phiếu kiểm kê</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-3">
                                    <strong>Mã phiếu:</strong><br>
                                    ${stockTake.stockTakeCode}
                                </div>
                                <div class="col-md-3">
                                    <strong>Người kiểm kê:</strong><br>
                                    ${stockTake.userFullName}
                                </div>
                                <div class="col-md-3">
                                    <strong>Kho hàng:</strong><br>
                                    <span class="badge bg-info">${stockTake.warehouseName != null ? stockTake.warehouseName : 'N/A'}</span>
                                </div>
                                <div class="col-md-3">
                                    <strong>Trạng thái:</strong><br>
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
                                </div>
                            </div>
                            <div class="row mt-3">
                                <div class="col-12">
                                    <strong>Ghi chú:</strong><br>
                                    ${stockTake.notes != null ? stockTake.notes : 'Không có ghi chú'}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Chi tiết sản phẩm -->
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header bg-secondary text-white">
                            <h5 class="mb-0"><i class="bi bi-list-check"></i> Chi tiết sản phẩm kiểm kê</h5>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-bordered table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th width="10%">Mã SP</th>
                                            <th width="35%">Tên sản phẩm</th>
                                            <th width="10%">Đơn vị</th>
                                            <th width="15%">SL Hệ thống</th>
                                            <th width="15%">SL Kiểm đếm</th>
                                            <th width="15%">Chênh lệch</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="detail" items="${stockTakeDetails}">
                                            <tr>
                                                <td><strong>${detail.productCode}</strong></td>
                                                <td>${detail.productName}</td>
                                                <td class="text-center">${detail.unit}</td>
                                                <td class="text-center">${detail.systemQuantity}</td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${detail.countedQuantity != null}">
                                                            <strong>${detail.countedQuantity}</strong>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">Chưa kiểm</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <c:if test="${detail.countedQuantity != null}">
                                                        <c:set var="diff" value="${detail.countedQuantity - detail.systemQuantity}" />
                                                        <c:choose>
                                                            <c:when test="${diff > 0}">
                                                                <span class="badge bg-success">+${diff}</span>
                                                            </c:when>
                                                            <c:when test="${diff < 0}">
                                                                <span class="badge bg-danger">${diff}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">0</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                                
                                <c:if test="${empty stockTakeDetails}">
                                    <div class="text-center py-4">
                                        <p class="text-muted">Không có chi tiết sản phẩm nào.</p>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Actions cho completed status -->
            <c:if test="${stockTake.status == 'completed'}">
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="alert alert-warning" role="alert">
                            <h6><i class="bi bi-exclamation-triangle"></i> Phiếu kiểm kê đã hoàn thành</h6>
                            <p class="mb-2">Phiếu này đã hoàn thành việc kiểm kê và sẵn sàng để đối soát.</p>
                            <a href="${pageContext.request.contextPath}/warehouse-manager/stock-take?action=approve-view&id=${stockTake.stockTakeId}" 
                               class="btn btn-warning">
                                <i class="bi bi-arrow-repeat"></i> Đi đến đối soát
                            </a>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${stockTake.status == 'reconciled'}">
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="alert alert-success" role="alert">
                            <h6><i class="bi bi-check-circle"></i> Phiếu kiểm kê đã được đối soát</h6>
                            <p class="mb-2">Tồn kho đã được điều chỉnh theo kết quả kiểm kê.</p>
                            <a href="${pageContext.request.contextPath}/warehouse-manager/stock-take?action=approve-view&id=${stockTake.stockTakeId}" 
                               class="btn btn-success">
                                <i class="bi bi-eye"></i> Xem kết quả đối soát
                            </a>
                        </div>
                    </div>
                </div>
            </c:if>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 