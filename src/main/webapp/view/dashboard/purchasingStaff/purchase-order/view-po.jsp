<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
        <%@page contentType="text/html" pageEncoding="UTF-8" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Xem Đơn Mua Hàng</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
                <script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>
                <link href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css" rel="stylesheet">
                <style>
                    /* Add margin to account for sidebar */
                    .main-content {
                        margin-left: 250px;
                        padding: 20px;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

                <div class="main-content">
                    <div class="container-fluid">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <h4 class="mb-0">Chi Tiết Đơn Mua Hàng - ${po.poCode}</h4>
                                        <div class="d-flex gap-2">
                                            <c:if test="${po.status == 'pending' && existingStockInward == null}">
                                                <!--                                    <a href="purchasing?action=create-stock-inward&poId=${po.poId}" class="btn btn-success">
                                        <i class="fas fa-truck"></i> Tạo Phiếu Nhập Kho
                                    </a>-->
                                            </c:if>

                                            <c:if test="${existingStockInward != null}">
                                                <a href="purchasing?action=view-stock-inward&id=${existingStockInward.stockInwardId}"
                                                    class="btn btn-info">
                                                    <i class="fas fa-eye"></i> Xem Phiếu Nhập Kho
                                                </a>
                                            </c:if>

                                            <a href="${pageContext.request.contextPath}/purchasing?action=list-rfq"
                                                class="btn btn-secondary">
                                                <i class="fas fa-arrow-left"></i> Quay Lại Danh Sách
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <table class="table table-borderless">
                                                    <tr>
                                                        <th width="150">Mã Đơn Hàng:</th>
                                                        <td>${po.poCode}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Nhà Cung Cấp:</th>
                                                        <td>${supplier.supplierName}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Người Liên Hệ:</th>
                                                        <td>${supplier.contactPerson}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Email:</th>
                                                        <td>${supplier.email}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Số Điện Thoại:</th>
                                                        <td>${supplier.phoneNumber}</td>
                                                    </tr>
                                                </table>
                                            </div>
                                            <div class="col-md-6">
                                                <table class="table table-borderless">
                                                    <tr>
                                                        <th width="180">Kho Hàng:</th>
                                                        <td>${warehouse.warehouseName}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Ngày Đặt Hàng:</th>
                                                        <td>
                                                            ${po.formattedOrderDate}
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th>Ngày Giao Dự Kiến:</th>
                                                        <td>
                                                            <fmt:formatDate value="${po.expectedDeliveryDate}"
                                                                pattern="dd/MM/yyyy" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th>Trạng Thái:</th>
                                                        <td>
                                                            <span class="badge 
                                                    ${po.status == 'pending' ? 'bg-warning' : 
                                                      po.status == 'approved' ? 'bg-success' : 
                                                      po.status == 'completed' ? 'bg-primary' : 'bg-danger'}">
                                                                ${po.status.toUpperCase()}
                                                            </span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th>Ngày Tạo:</th>
                                                        <td>
                                                            <fmt:formatDate value="${po.createdAt}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>

                                        <hr>

                                        <h5>Chi Tiết Đơn Hàng</h5>
                                        <div class="table-responsive">
                                            <table class="table table-striped">
                                                <thead>
                                                    <tr>
                                                        <th>Mã Sản Phẩm</th>
                                                        <th>Tên Sản Phẩm</th>
                                                        <th>Đơn Vị</th>
                                                        <th>Số Lượng</th>
                                                        <th>Đơn Giá</th>
                                                        <th>Thành Tiền</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:set var="grandTotal" value="0" />
                                                    <c:forEach var="detail" items="${poDetails}">
                                                        <c:forEach var="product" items="${products}">
                                                            <c:if test="${product.productId == detail.productId}">
                                                                <tr>
                                                                    <td>${product.productCode}</td>
                                                                    <td>${product.productName}</td>
                                                                    <td>${product.unit}</td>
                                                                    <td>${detail.quantity}</td>
                                                                    <td>
                                                                        <fmt:formatNumber value="${detail.unitPrice}"
                                                                            type="currency" currencySymbol="₫" />
                                                                    </td>
                                                                    <td>
                                                                        <c:set var="lineTotal"
                                                                            value="${detail.quantity * detail.unitPrice}" />
                                                                        <fmt:formatNumber value="${lineTotal}"
                                                                            type="currency" currencySymbol="₫" />
                                                                        <c:set var="grandTotal"
                                                                            value="${grandTotal + lineTotal}" />
                                                                    </td>
                                                                </tr>
                                                            </c:if>
                                                        </c:forEach>
                                                    </c:forEach>
                                                </tbody>
                                                <tfoot class="table-light">
                                                    <tr>
                                                        <td colspan="5" class="text-end fw-bold">Tổng Cộng:</td>
                                                        <td class="fw-bold">
                                                            <fmt:formatNumber value="${grandTotal}" type="currency"
                                                                currencySymbol="₫" />
                                                        </td>
                                                    </tr>
                                                </tfoot>
                                            </table>
                                        </div>

                                        <c:if test="${existingStockInward != null}">
                                            <hr>
                                            <div class="alert alert-success">
                                                <strong>Đã Tạo Phiếu Nhập Kho:</strong>
                                                Một phiếu nhập kho (${existingStockInward.inwardCode}) đã được tạo từ
                                                Đơn Mua Hàng này.
                                                <a href="purchasing?action=view-stock-inward&id=${existingStockInward.stockInwardId}"
                                                    class="alert-link">Xem Phiếu Nhập Kho</a>
                                            </div>
                                        </c:if>

                                        <c:if test="${po.status == 'pending' && existingStockInward == null}">
                                            <hr>
                                            <!--                                <div class="alert alert-info">
                                    <strong>Bước Tiếp Theo:</strong> 
                                    Tạo một Phiếu Nhập Kho để nhận hàng hóa và cập nhật kho.
                                    <a href="purchasing?action=create-stock-inward&poId=${po.poId}" class="alert-link">Tạo Phiếu Nhập Kho</a>
                                </div>-->
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

                <script>
                    // Toast message display
                    var toastMessage = "${sessionScope.toastMessage}";
                    var toastType = "${sessionScope.toastType}";
                    if (toastMessage) {
                        iziToast.show({
                            title: toastType === 'success' ? 'Thành Công' : 'Lỗi',
                            message: toastMessage,
                            position: 'topRight',
                            color: toastType === 'success' ? 'green' : 'red',
                            timeout: 5000,
                            onClosing: function () {
                                fetch('${pageContext.request.contextPath}/remove-toast', {
                                    method: 'POST',
                                    headers: {
                                        'Content-Type': 'application/x-www-form-urlencoded',
                                    },
                                }).then(response => {
                                    if (!response.ok) {
                                        console.error('Không thể xóa thuộc tính toast');
                                    }
                                }).catch(error => {
                                    console.error('Lỗi:', error);
                                });
                            }
                        });
                    }
                </script>
            </body>

            </html>