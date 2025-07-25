<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết báo giá</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <style>
        .quotation-header {
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .info-card {
            border: none;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .product-table th {
            background-color: #f8f9fa;
        }
        .total-row {
            background-color: #e3f2fd;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <!-- Include Header -->
    <jsp:include page="/view/common/head.jsp" />

    <div class="container-fluid main">
        <div class="row">
            <!-- Include Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp" />

            <!-- Main Content -->
            <main role="main" class="col-md-9 ml-sm-auto col-lg-10 px-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Chi tiết báo giá</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/sale-staff/sales-quotation?action=list" 
                           class="btn btn-secondary me-2">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                        <c:if test="${quotation.status eq 'draft'}">
                            <a href="${pageContext.request.contextPath}/sale-staff/sales-quotation?action=edit&id=${quotation.quotationId}" 
                               class="btn btn-warning me-2">
                                <i class="fas fa-edit"></i> Sửa
                            </a>
                            <button type="button" class="btn btn-primary" onclick="sendQuotation()">
                                <i class="fas fa-paper-plane"></i> Gửi báo giá
                            </button>
                        </c:if>
                        <c:if test="${quotation.status eq 'approved'}">
                            <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=create&quotationId=${quotation.quotationId}" 
                               class="btn btn-success">
                                <i class="fas fa-shopping-cart"></i> Tạo đơn hàng
                            </a>
                        </c:if>
                    </div>
                </div>

                <!-- Quotation Header -->
                <div class="quotation-header">
                    <div class="row">
                        <div class="col-md-6">
                            <h3>${quotation.quotationCode}</h3>
                            <p class="mb-0">Ngày tạo: <fmt:formatDate value="${quotation.quotationDate}" pattern="dd/MM/yyyy"/></p>
                        </div>
                        <div class="col-md-6 text-end">
                            <h4>
                                <c:choose>
                                    <c:when test="${quotation.status eq 'draft'}">
                                        <span class="badge bg-secondary">Nháp</span>
                                    </c:when>
                                    <c:when test="${quotation.status eq 'sent'}">
                                        <span class="badge bg-warning">Đã gửi</span>
                                    </c:when>
                                    <c:when test="${quotation.status eq 'approved'}">
                                        <span class="badge bg-success">Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${quotation.status eq 'rejected'}">
                                        <span class="badge bg-danger">Từ chối</span>
                                    </c:when>
                                </c:choose>
                            </h4>
                            <p class="mb-0">Hiệu lực đến: <fmt:formatDate value="${quotation.validUntil}" pattern="dd/MM/yyyy"/></p>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <!-- Customer Information -->
                    <div class="col-md-6">
                        <div class="card info-card">
                            <div class="card-header">
                                <h5><i class="fas fa-user"></i> Thông tin khách hàng</h5>
                            </div>
                            <div class="card-body">
                                <table class="table table-sm">
                                    <tr>
                                        <td><strong>Tên khách hàng:</strong></td>
                                        <td>${quotation.customerName}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Email:</strong></td>
                                        <td>${quotation.customerEmail}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Số điện thoại:</strong></td>
                                        <td>${quotation.customerPhone}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Địa chỉ:</strong></td>
                                        <td>${quotation.customerAddress}</td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Quotation Information -->
                    <div class="col-md-6">
                        <div class="card info-card">
                            <div class="card-header">
                                <h5><i class="fas fa-info-circle"></i> Thông tin báo giá</h5>
                            </div>
                            <div class="card-body">
                                <table class="table table-sm">
                                    <tr>
                                        <td><strong>Người tạo:</strong></td>
                                        <td>${createdBy}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Kho hàng:</strong></td>
                                        <td>${warehouse.warehouseName}</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Ngày tạo:</strong></td>
                                        <td><fmt:formatDate value="${quotation.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    </tr>
                                    <tr>
                                        <td><strong>Ghi chú:</strong></td>
                                        <td>${quotation.notes}</td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Products -->
                <div class="card info-card">
                    <div class="card-header">
                        <h5><i class="fas fa-box"></i> Chi tiết sản phẩm</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table product-table">
                                <thead>
                                    <tr>
                                        <th>STT</th>
                                        <th>Mã sản phẩm</th>
                                        <th>Tên sản phẩm</th>
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
                                            <td>${detail.product.productCode}</td>
                                            <td>${detail.product.productName}</td>
                                            <td>${detail.product.unit}</td>
                                            <td class="text-end">${detail.quantity}</td>
                                            <td class="text-end">
                                                <fmt:formatNumber value="${detail.unitPrice}" type="currency" currencySymbol=""/>
                                            </td>
                                            <td class="text-end">
                                                <fmt:formatNumber value="${lineTotal}" type="currency" currencySymbol=""/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                                <tfoot>
                                    <tr class="total-row">
                                        <td colspan="6" class="text-end"><strong>Tổng cộng:</strong></td>
                                        <td class="text-end">
                                            <strong><fmt:formatNumber value="${totalAmount}" type="currency" currencySymbol="VNĐ"/></strong>
                                        </td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="/view/common/foot.jsp" />

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        function sendQuotation() {
            Swal.fire({
                title: 'Xác nhận gửi báo giá',
                text: 'Bạn có chắc chắn muốn gửi báo giá này cho khách hàng?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Gửi',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Create form and submit
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '${pageContext.request.contextPath}/sale-staff/sales-quotation';

                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'send';

                    const idInput = document.createElement('input');
                    idInput.type = 'hidden';
                    idInput.name = 'id';
                    idInput.value = '${quotation.quotationId}';

                    form.appendChild(actionInput);
                    form.appendChild(idInput);
                    document.body.appendChild(form);
                    form.submit();
                }
            });
        }
    </script>
</body>
</html>
