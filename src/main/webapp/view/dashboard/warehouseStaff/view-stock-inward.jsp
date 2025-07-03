<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết phiếu nhập kho - ${stockInward.inwardCode}</title>
    <jsp:include page="/view/common/head.jsp"/>
    <style>
        .main-content {
            margin-left: 250px;
            padding: 20px;
        }
        .info-card .row {
            margin-bottom: 0.5rem;
        }
        .info-card-title {
            font-weight: bold;
            color: #555;
        }
    </style>
</head>
<body>
    <jsp:include page="/view/common/sidebar.jsp"/>
    <div class="main-content">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h4 class="mb-0">Chi tiết phiếu nhập kho: ${stockInward.inwardCode}</h4>
                <a href="${pageContext.request.contextPath}/warehouse?action=list-stock-inward" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                </a>
            </div>
            <div class="card-body">
                <!-- Inward Information -->
                <div class="card mb-4 info-card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-info-circle"></i> Thông tin chung</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Mã phiếu:</div>
                                    <div class="col-sm-8">${stockInward.inwardCode}</div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Nhà cung cấp:</div>
                                    <div class="col-sm-8">${stockInward.supplierName}</div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Ghi chú:</div>
                                    <div class="col-sm-8">${stockInward.notes}</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Kho nhập:</div>
                                    <div class="col-sm-8">${stockInward.warehouseName}</div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Người tạo:</div>
                                    <div class="col-sm-8">${stockInward.userFullName}</div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Ngày tạo:</div>
                                    <div class="col-sm-8">
                                        ${stockInward.formattedInwardDate}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Products -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-boxes"></i> Sản phẩm đã nhập</h5>
                    </div>
                    <div class="card-body">
                        <table class="table table-bordered">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã sản phẩm</th>
                                    <th>Tên sản phẩm</th>
                                    <th class="text-end">Giá nhập/đơn vị</th>
                                    <th class="text-center">Số lượng đã nhận</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="detail" items="${details}">
                                    <c:set var="product" value="${products.stream().filter(p -> p.productId == detail.productId).findFirst().orElse(null)}"/>
                                    <tr>
                                        <td>${product.productCode}</td>
                                        <td>${product.productName}</td>
                                        <td class="text-end">
                                            <fmt:formatNumber value="${detail.unitPurchasePrice}" type="currency" currencySymbol="đ"/>
                                        </td>
                                        <td class="text-center">${detail.quantityReceived}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="/view/common/foot.jsp"/>
</body>
</html> 