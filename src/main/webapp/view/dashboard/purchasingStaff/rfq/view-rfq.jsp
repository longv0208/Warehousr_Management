<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
        <%@page contentType="text/html" pageEncoding="UTF-8" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Xem Yêu Cầu Báo Giá</title>
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
                <jsp:include page="/view/common/sidebar.jsp"></jsp:include>

                <div class="main-content">
                    <div class="container-fluid">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <h4 class="mb-0">Chi tiết YCB - ${rfq.rfqCode}</h4>
                                        <div class="d-flex gap-2">
                                            <c:if test="${rfq.status == 'pending'}">
                                                <form action="purchasing" method="post" style="display: inline;">
                                                    <input type="hidden" name="action" value="send-rfq">
                                                    <input type="hidden" name="id" value="${rfq.rfqId}">
                                                    <button type="submit" class="btn btn-success"
                                                        onclick="return confirm('Bạn có chắc chắn muốn gửi yêu cầu báo giá này?\n\nEmail sẽ được gửi đến nhà cung cấp: ${supplier.supplierName}\nĐịa chỉ email: ${supplier.email}')">
                                                        <i class="fas fa-paper-plane"></i> Gửi YCB & Email
                                                    </button>
                                                </form>
                                            </c:if>

                                            <c:if test="${rfq.status == 'sent' && existingPO == null}">
                                                <a href="purchasing?action=create-po-from-rfq&rfqId=${rfq.rfqId}"
                                                    class="btn btn-primary">
                                                    <i class="fas fa-file-invoice"></i> Tạo đơn mua hàng
                                                </a>
                                            </c:if>

                                            <c:if test="${existingPO != null}">
                                                <a href="purchasing?action=view-po&id=${existingPO.poId}"
                                                    class="btn btn-info">
                                                    <i class="fas fa-eye"></i> Xem đơn mua hàng
                                                </a>
                                            </c:if>

                                            <a href="purchasing?action=list-rfq" class="btn btn-secondary">
                                                <i class="fas fa-arrow-left"></i> Quay lại danh sách
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <table class="table table-borderless">
                                                    <tr>
                                                        <th width="150">Mã YCB:</th>
                                                        <td>${rfq.rfqCode}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Nhà cung cấp:</th>
                                                        <td>${supplier.supplierName}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Người liên hệ:</th>
                                                        <td>${supplier.contactPerson}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Email:</th>
                                                        <td>${supplier.email}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Số điện thoại:</th>
                                                        <td>${supplier.phoneNumber}</td>
                                                    </tr>
                                                </table>
                                            </div>
                                            <div class="col-md-6">
                                                <table class="table table-borderless">
                                                    <tr>
                                                        <th width="180">Kho:</th>
                                                        <td>${warehouse.warehouseName}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>Ngày giao hàng dự kiến:</th>
                                                        <td>
                                                            <fmt:formatDate value="${rfq.expectedDeliveryDate}"
                                                                pattern="dd/MM/yyyy" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th>Trạng thái:</th>
                                                        <td>
                                                            <span class="badge 
                                                    ${rfq.status == 'pending' ? 'bg-warning' : 
                                                      rfq.status == 'sent' ? 'bg-info' : 
                                                      rfq.status == 'approved' ? 'bg-success' : 
                                                      rfq.status == 'completed' ? 'bg-primary' : 'bg-danger'}">
                                                                ${rfq.status == 'pending' ? 'CHỜ XỬ LÝ' :
                                                                rfq.status == 'sent' ? 'ĐÃ GỬI' :
                                                                rfq.status == 'approved' ? 'ĐÃ DUYỆT' :
                                                                rfq.status == 'completed' ? 'HOÀN THÀNH' : 'TỪ CHỐI'}
                                                            </span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th>Ngày tạo:</th>
                                                        <td>
                                                            <fmt:formatDate value="${rfq.createdAt}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th>Ghi chú:</th>
                                                        <td>${rfq.note}</td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>

                                        <hr>

                                        <h5>Sản phẩm yêu cầu</h5>
                                        <div class="table-responsive">
                                            <table class="table table-striped">
                                                <thead>
                                                    <tr>
                                                        <th>Mã sản phẩm</th>
                                                        <th>Tên sản phẩm</th>
                                                        <th>Đơn vị</th>
                                                        <th>Số lượng yêu cầu</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="detail" items="${rfqDetails}">
                                                        <c:forEach var="product" items="${products}">
                                                            <c:if test="${product.productId == detail.productId}">
                                                                <tr>
                                                                    <td>${product.productCode}</td>
                                                                    <td>${product.productName}</td>
                                                                    <td>${product.unit}</td>
                                                                    <td>${detail.quantity}</td>
                                                                </tr>
                                                            </c:if>
                                                        </c:forEach>
                                                    </c:forEach>
                                                    <c:if test="${empty rfqDetails}">
                                                        <tr>
                                                            <td colspan="6" class="text-center">Không có sản phẩm nào
                                                            </td>
                                                        </tr>
                                                    </c:if>
                                                </tbody>
                                            </table>
                                        </div>
                                        
                                        <c:if test="${rfq.status == 'sent'}">
                                            <hr>
                                            <div class="alert alert-success">
                                                <h5><i class="fas fa-check-circle"></i> <strong>Yêu cầu báo giá đã được gửi thành công!</strong></h5>
                                                <p class="mb-2">
                                                    <strong>📧 Email đã được gửi đến:</strong><br>
                                                    <i class="fas fa-building"></i> <strong>${supplier.supplierName}</strong><br>
                                                    <i class="fas fa-user"></i> Người liên hệ: ${supplier.contactPerson}<br>
                                                    <i class="fas fa-envelope"></i> Email: <code>${supplier.email}</code><br>
                                                    <i class="fas fa-phone"></i> SĐT: ${supplier.phoneNumber}
                                                </p>
                                                <div class="alert alert-info mt-3 mb-0" style="font-size: 0.9em;">
                                                    <i class="fas fa-info-circle"></i> 
                                                    <strong>Lưu ý:</strong> Nhà cung cấp sẽ nhận được email chi tiết về yêu cầu báo giá 
                                                    bao gồm danh sách sản phẩm, số lượng và thông tin liên hệ.
                                                </div>
                                            </div>
                                        </c:if>
                                        
                                        <c:if test="${existingPO != null}">
                                            <hr>
                                            <div class="alert alert-info">
                                                <strong>Đơn mua hàng đã được tạo:</strong>
                                                Đơn mua hàng (${existingPO.poCode}) đã được tạo từ yêu cầu báo giá này.
                                                <a href="purchasing?action=view-po&id=${existingPO.poId}"
                                                    class="alert-link">Xem đơn mua hàng</a>
                                            </div>
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
                            title: toastType === 'success' ? 'Thành công' : 'Lỗi',
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
                                        console.error('Failed to remove toast attributes');
                                    }
                                }).catch(error => {
                                    console.error('Error:', error);
                                });
                            }
                        });
                    }
                </script>
            </body>

            </html>
