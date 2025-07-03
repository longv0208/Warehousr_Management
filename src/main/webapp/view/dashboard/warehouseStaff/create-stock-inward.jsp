<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Phiếu Nhập Kho từ Đơn Mua Hàng</title>
    <jsp:include page="/view/common/head.jsp"/>
    <style>
        .main-content {
            margin-left: 250px; /* Same as sidebar width */
            padding: 20px;
        }
        .info-card .row { margin-bottom: 0.5rem; }
        .info-card-title { font-weight: bold; color: #555; }
        .product-table th { text-align: center; }
        .product-table td { vertical-align: middle; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/sidebar.jsp"/>
    <div class="main-content">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h4 class="mb-0">Tạo Phiếu Nhập Kho từ Đơn Mua Hàng - ${po.poCode}</h4>
                <a href="${pageContext.request.contextPath}/warehouse?action=list-po-for-inward" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Quay lại Danh sách Đơn Hàng
                </a>
            </div>
            <div class="card-body">
                <!-- Purchase Order Information -->
                <div class="card mb-4 info-card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-file-invoice"></i> Thông tin Đơn Mua Hàng</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Mã ĐM:</div>
                                    <div class="col-sm-8">${po.poCode}</div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Ngày đặt:</div>
                                    <div class="col-sm-8">${po.formattedOrderDate}</div>
                                </div>
                                 <div class="row">
                                    <div class="col-sm-4 info-card-title">Kho:</div>
                                    <div class="col-sm-8">${warehouse.warehouseName}</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Nhà cung cấp:</div>
                                    <div class="col-sm-8">${supplier.supplierName}</div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Giao hàng dự kiến:</div>
                                    <div class="col-sm-8"><fmt:formatDate value="${po.expectedDeliveryDate}" pattern="dd/MM/yyyy"/></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Create Import Receipt Form -->
                <form action="${pageContext.request.contextPath}/warehouse" method="POST" id="createInwardForm">
                    <input type="hidden" name="action" value="create-stock-inward">
                    <input type="hidden" name="poId" value="${po.poId}">

                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-receipt"></i> Tạo Phiếu Nhập Kho</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="supplierName" class="form-label">Tên Nhà Cung Cấp</label>
                                    <input type="text" id="supplierName" class="form-control" value="${supplier.supplierName}" readonly>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="status" class="form-label">Trạng thái</label>
                                    <input type="text" id="status" class="form-control" value="Hoàn thành" readonly>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="receiptDate" class="form-label">Ngày nhận</label>
                                    <input type="text" id="receiptDate" class="form-control" value="<fmt:formatDate pattern = "dd/MM/yyyy" value="<%= new java.util.Date() %>" />" readonly>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="description" class="form-label">Mô tả</label>
                                    <textarea id="description" name="description" class="form-control" rows="1"></textarea>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Products -->
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-box-open"></i> Sản phẩm - Nhập số lượng thực nhận</h5>
                        </div>
                        <div class="card-body">
                            <table class="table table-bordered product-table">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th>SL Đặt</th>
                                        <th>Đơn giá</th>
                                        <th>SL thực nhận <span class="text-danger">*</span></th>
                                        <th>Ghi chú</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="detailView" items="${poDetails}">
                                        <tr>
                                            <td>
                                                ${detailView.product.productName} (${detailView.product.productCode})
                                                <input type="hidden" name="productId" value="${detailView.detail.productId}">
                                                <input type="hidden" name="unitPrice" value="${detailView.detail.unitPrice}">
                                            </td>
                                            <td class="text-center">${detailView.detail.quantity}</td>
                                            <td class="text-end">
                                                <fmt:formatNumber value="${detailView.detail.unitPrice}" type="currency" currencyCode="VND" pattern="#,##0 ¤"/>
                                            </td>
                                            <td>
                                                <input type="number" name="actualReceivedQty" class="form-control" value="${detailView.detail.quantity}" min="0" required>
                                            </td>
                                            <td>
                                                <input type="text" name="notes" class="form-control">
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <a href="${pageContext.request.contextPath}/warehouse?action=list-po-for-inward" class="btn btn-secondary">Hủy</a>
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-check-circle"></i> Tạo & Hoàn thành
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/view/common/foot.jsp"/>
<script>
    document.getElementById('createInwardForm').addEventListener('submit', function(e) {
        let valid = true;
        const receivedQtys = document.querySelectorAll('input[name="actualReceivedQty"]');
        receivedQtys.forEach(input => {
            if (input.value.trim() === '' || parseInt(input.value) < 0) {
                valid = false;
                input.classList.add('is-invalid');
            } else {
                input.classList.remove('is-invalid');
            }
        });

        if (!valid) {
            e.preventDefault();
            alert('Vui lòng nhập số lượng hợp lệ (không âm) cho tất cả sản phẩm.');
        }
    });
</script>
</body>
</html> 