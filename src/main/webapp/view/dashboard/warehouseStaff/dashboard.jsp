<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Warehouse Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Include sidebar -->
            <jsp:include page="../../common/sidebar.jsp"/>
            
            <div class="col-md-10 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Dashboard Kho</h1>
                </div>

                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-xl-3 col-md-6">
                        <div class="card bg-primary text-white mb-4">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <div class="text-xs font-weight-bold text-uppercase mb-1">Yêu cầu lấy hàng chờ</div>
                                        <div class="h5 mb-0 font-weight-bold">${pendingPicksCount}</div>
                                    </div>
                                    <div class="text-white-50">
                                        <i class="fas fa-clipboard-list fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="card-footer d-flex align-items-center justify-content-between">
                                <a class="small text-white stretched-link" href="warehouse-staff?action=pick-request-list">Xem chi tiết</a>
                                <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-md-6">
                        <div class="card bg-success text-white mb-4">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <div class="text-xs font-weight-bold text-uppercase mb-1">Phiếu nhập gần đây</div>
                                        <div class="h5 mb-0 font-weight-bold">${recentInwards.size()}</div>
                                    </div>
                                    <div class="text-white-50">
                                        <i class="fas fa-arrow-down fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="card-footer d-flex align-items-center justify-content-between">
                                <a class="small text-white stretched-link" href="warehouse-staff?action=stock-inward-list">Xem chi tiết</a>
                                <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-md-6">
                        <div class="card bg-warning text-white mb-4">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <div class="text-xs font-weight-bold text-uppercase mb-1">Phiếu xuất gần đây</div>
                                        <div class="h5 mb-0 font-weight-bold">${recentOutwards.size()}</div>
                                    </div>
                                    <div class="text-white-50">
                                        <i class="fas fa-arrow-up fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="card-footer d-flex align-items-center justify-content-between">
                                <a class="small text-white stretched-link" href="warehouse-staff?action=stock-outward-list">Xem chi tiết</a>
                                <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-md-6">
                        <div class="card bg-info text-white mb-4">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <div class="text-xs font-weight-bold text-uppercase mb-1">Hoạt động kho</div>
                                        <div class="h5 mb-0 font-weight-bold">Hoạt động</div>
                                    </div>
                                    <div class="text-white-50">
                                        <i class="fas fa-warehouse fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="card-footer d-flex align-items-center justify-content-between">
                                <a class="small text-white stretched-link" href="#" onclick="return false;">Thống kê</a>
                                <div class="small text-white"><i class="fas fa-angle-right"></i></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">Thao tác nhanh</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-lg-3 col-md-6 mb-3">
                                        <a href="warehouse-staff?action=approved-purchase-requests" class="btn btn-outline-primary btn-lg w-100">
                                            <i class="fas fa-plus-circle fa-2x mb-2"></i><br>
                                            Tạo phiếu nhập
                                        </a>
                                    </div>
                                    <div class="col-lg-3 col-md-6 mb-3">
                                        <a href="warehouse-staff?action=pending-sales-orders" class="btn btn-outline-success btn-lg w-100">
                                            <i class="fas fa-clipboard-list fa-2x mb-2"></i><br>
                                            Tạo yêu cầu lấy hàng
                                        </a>
                                    </div>
                                    <div class="col-lg-3 col-md-6 mb-3">
                                        <a href="warehouse-staff?action=pick-request-list" class="btn btn-outline-warning btn-lg w-100">
                                            <i class="fas fa-hand-paper fa-2x mb-2"></i><br>
                                            Xử lý lấy hàng
                                        </a>
                                    </div>
                                    <div class="col-lg-3 col-md-6 mb-3">
                                        <a href="warehouse-staff?action=stock-outward-list" class="btn btn-outline-danger btn-lg w-100">
                                            <i class="fas fa-shipping-fast fa-2x mb-2"></i><br>
                                            Xuất hàng
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Activities -->
                <div class="row">
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">Phiếu nhập gần đây</h5>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${not empty recentInwards}">
                                        <div class="table-responsive">
                                            <table class="table table-sm">
                                                <thead>
                                                    <tr>
                                                        <th>Mã phiếu</th>
                                                        <th>Nhà cung cấp</th>
                                                        <th>Ngày nhập</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="inward" items="${recentInwards}">
                                                        <tr>
                                                            <td>${inward.inwardCode}</td>
                                                            <td>${inward.supplierName}</td>
                                                            <td>
                                                                <fmt:formatDate value="${inward.inwardDate}" pattern="dd/MM/yyyy HH:mm"/>
                                                            </td>
                                                            <td>
                                                                <a href="warehouse-staff?action=view-stock-inward&id=${inward.stockInwardId}" 
                                                                   class="btn btn-sm btn-outline-primary">Xem</a>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-muted">Chưa có phiếu nhập nào.</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-lg-6">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">Phiếu xuất gần đây</h5>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${not empty recentOutwards}">
                                        <div class="table-responsive">
                                            <table class="table table-sm">
                                                <thead>
                                                    <tr>
                                                        <th>Mã phiếu</th>
                                                        <th>Lý do</th>
                                                        <th>Ngày xuất</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="outward" items="${recentOutwards}">
                                                        <tr>
                                                            <td>${outward.outwardCode}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${outward.reason == 'sale'}">Bán hàng</c:when>
                                                                    <c:when test="${outward.reason == 'internal_transfer'}">Chuyển kho</c:when>
                                                                    <c:when test="${outward.reason == 'damage'}">Hàng hỏng</c:when>
                                                                    <c:when test="${outward.reason == 'loss'}">Mất hàng</c:when>
                                                                    <c:otherwise>Khác</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <fmt:formatDate value="${outward.outwardDate}" pattern="dd/MM/yyyy HH:mm"/>
                                                            </td>
                                                            <td>
                                                                <a href="warehouse-staff?action=view-stock-outward&id=${outward.stockOutwardId}" 
                                                                   class="btn btn-sm btn-outline-primary">Xem</a>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-muted">Chưa có phiếu xuất nào.</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 