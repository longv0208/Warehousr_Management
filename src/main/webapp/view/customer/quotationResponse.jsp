<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phản hồi báo giá</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .response-container {
            max-width: 800px;
            margin: 50px auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .content-section {
            padding: 30px;
        }
        .quotation-info {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 25px;
        }
        .action-buttons {
            text-align: center;
            margin-top: 30px;
        }
        .btn-confirm {
            background: #28a745;
            border: none;
            padding: 12px 30px;
            margin: 0 10px;
            border-radius: 25px;
            font-weight: 600;
            color: white;
            min-width: 120px;
        }
        .btn-reject {
            background: #dc3545;
            border: none;
            padding: 12px 30px;
            margin: 0 10px;
            border-radius: 25px;
            font-weight: 600;
            color: white;
            min-width: 120px;
        }
        .btn-confirm:hover {
            background: #218838;
            color: white;
        }
        .btn-reject:hover {
            background: #c82333;
            color: white;
        }
        .product-table {
            margin-top: 20px;
        }
        .total-row {
            background: #e3f2fd;
            font-weight: bold;
        }
        .alert-success {
            border-left: 4px solid #28a745;
        }
        .alert-danger {
            border-left: 4px solid #dc3545;
        }
    </style>
</head>
<body>
    <div class="response-container">
        <!-- Header Section -->
        <div class="header-section">
            <h2><i class="fas fa-file-invoice-dollar"></i> Báo giá từ ClothesWareHouse</h2>
            <p class="mb-0">Vui lòng xem xét và phản hồi báo giá dưới đây</p>
        </div>

        <!-- Content Section -->
        <div class="content-section">
            <c:choose>
                <c:when test="${not empty quotation}">
                    <!-- Quotation Information -->
                    <div class="quotation-info">
                        <div class="row">
                            <div class="col-md-6">
                                <h5><i class="fas fa-info-circle text-primary"></i> Thông tin báo giá</h5>
                                <p><strong>Mã báo giá:</strong> ${quotation.quotationCode}</p>
                                <p><strong>Ngày báo giá:</strong> <fmt:formatDate value="${quotation.quotationDate}" pattern="dd/MM/yyyy"/></p>
                                <p><strong>Hiệu lực đến:</strong> <fmt:formatDate value="${quotation.validUntil}" pattern="dd/MM/yyyy"/></p>
                            </div>
                            <div class="col-md-6">
                                <h5><i class="fas fa-user text-primary"></i> Thông tin khách hàng</h5>
                                <p><strong>Tên:</strong> ${quotation.customerName}</p>
                                <p><strong>Email:</strong> ${quotation.customerEmail}</p>
                                <c:if test="${not empty quotation.customerPhone}">
                                    <p><strong>Điện thoại:</strong> ${quotation.customerPhone}</p>
                                </c:if>
                            </div>
                        </div>
                        <c:if test="${not empty quotation.notes}">
                            <div class="mt-3">
                                <h6><i class="fas fa-sticky-note text-primary"></i> Ghi chú:</h6>
                                <p class="text-muted">${quotation.notes}</p>
                            </div>
                        </c:if>
                    </div>

                    <!-- Products Details -->
                    <h5><i class="fas fa-box text-primary"></i> Chi tiết sản phẩm</h5>
                    <div class="table-responsive product-table">
                        <table class="table table-striped">
                            <thead class="table-light">
                                <tr>
                                    <th>STT</th>
                                    <th>Sản phẩm</th>
                                    <th>Đơn vị</th>
                                    <th class="text-end">Số lượng</th>
                                    <th class="text-end">Đơn giá</th>
                                    <th class="text-end">Thành tiền</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:set var="totalAmount" value="0"/>
                                <c:forEach var="detail" items="${quotationDetails}" varStatus="status">
                                    <c:set var="lineTotal" value="${detail.quantity * detail.unitPrice}"/>
                                    <c:set var="totalAmount" value="${totalAmount + lineTotal}"/>
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <td>
                                            <strong>${detail.product.productName}</strong><br>
                                            <small class="text-muted">${detail.product.productCode}</small>
                                        </td>
                                        <td>${detail.product.unit}</td>
                                        <td class="text-end">${detail.quantity}</td>
                                        <td class="text-end">
                                            <fmt:formatNumber value="${detail.unitPrice}" type="currency" currencySymbol="VNĐ"/>
                                        </td>
                                        <td class="text-end">
                                            <fmt:formatNumber value="${lineTotal}" type="currency" currencySymbol="VNĐ"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                            <tfoot>
                                <tr class="total-row">
                                    <td colspan="5" class="text-end"><strong>Tổng cộng:</strong></td>
                                    <td class="text-end">
                                        <strong><fmt:formatNumber value="${totalAmount}" type="currency" currencySymbol="VNĐ"/></strong>
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>

                    <!-- Response Status -->
                    <c:choose>
                        <c:when test="${quotation.status eq 'approved'}">
                            <div class="alert alert-success text-center">
                                <i class="fas fa-check-circle fa-2x mb-2"></i>
                                <h5>Báo giá đã được chấp nhận</h5>
                                <p>Cảm ơn bạn đã chấp nhận báo giá của chúng tôi. Chúng tôi sẽ liên hệ với bạn để xử lý đơn hàng.</p>
                            </div>
                        </c:when>
                        <c:when test="${quotation.status eq 'rejected'}">
                            <div class="alert alert-danger text-center">
                                <i class="fas fa-times-circle fa-2x mb-2"></i>
                                <h5>Báo giá đã bị từ chối</h5>
                                <p>Cảm ơn bạn đã xem xét báo giá. Nếu có thắc mắc, vui lòng liên hệ với chúng tôi.</p>
                            </div>
                        </c:when>
                        <c:when test="${quotation.status eq 'sent'}">
                            <!-- Action Buttons for Response -->
                            <div class="action-buttons">
                                <h5 class="mb-3">Bạn có chấp nhận báo giá này không?</h5>
                                <form method="POST" style="display: inline;">
                                    <input type="hidden" name="action" value="confirm">
                                    <button type="submit" class="btn btn-confirm">
                                        <i class="fas fa-check"></i> Chấp nhận
                                    </button>
                                </form>
                                <form method="POST" style="display: inline;">
                                    <input type="hidden" name="action" value="reject">
                                    <button type="submit" class="btn btn-reject">
                                        <i class="fas fa-times"></i> Từ chối
                                    </button>
                                </form>
                            </div>
                        </c:when>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-danger text-center">
                        <i class="fas fa-exclamation-triangle fa-2x mb-2"></i>
                        <h5>Báo giá không tồn tại hoặc đã hết hạn</h5>
                        <p>Liên kết này không hợp lệ hoặc báo giá đã hết hạn. Vui lòng liên hệ với chúng tôi để được hỗ trợ.</p>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Contact Information -->
            <div class="text-center mt-4 pt-4 border-top">
                <h6>Liên hệ hỗ trợ</h6>
                <p class="text-muted">
                    Email: support@clotheswarehouse.com | 
                    Điện thoại: (84) 123-456-789
                </p>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        // Show toast message if exists
        <c:if test="${not empty sessionScope.toastMessage}">
            Swal.fire({
                icon: '${sessionScope.toastType}',
                title: '${sessionScope.toastMessage}',
                showConfirmButton: false,
                timer: 3000
            });
            <%-- Remove attributes after showing --%>
            <c:remove var="toastMessage" scope="session"/>
            <c:remove var="toastType" scope="session"/>
        </c:if>

        // Confirm before submitting response
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                const action = this.querySelector('input[name="action"]').value;
                const message = action === 'confirm' ? 
                    'Bạn có chắc chắn muốn chấp nhận báo giá này?' : 
                    'Bạn có chắc chắn muốn từ chối báo giá này?';
                
                e.preventDefault();
                Swal.fire({
                    title: 'Xác nhận',
                    text: message,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: action === 'confirm' ? '#28a745' : '#dc3545',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: action === 'confirm' ? 'Chấp nhận' : 'Từ chối',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        this.submit();
                    }
                });
            });
        });
    </script>
</body>
</html>
