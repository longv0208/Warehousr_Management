<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
        <%@page contentType="text/html" pageEncoding="UTF-8" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Tạo Đơn Mua Hàng</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
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
                                        <h4 class="mb-0">Tạo Đơn Mua Hàng từ YCB: ${rfq.rfqCode}</h4>
                                        <a href="purchasing?action=view-rfq&id=${rfq.rfqId}" class="btn btn-secondary">
                                            <i class="fas fa-arrow-left"></i> Quay lại YCB
                                        </a>
                                    </div>
                                    <div class="card-body">
                                        <!-- RFQ Information -->
                                        <div class="card mb-4">
                                            <div class="card-header">
                                                <h6 class="mb-0">Thông tin YCB</h6>
                                            </div>
                                            <div class="card-body">
                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <table class="table table-borderless table-sm">
                                                            <tr>
                                                                <th width="120">Mã YCB:</th>
                                                                <td>${rfq.rfqCode}</td>
                                                            </tr>
                                                            <tr>
                                                                <th>Nhà cung cấp:</th>
                                                                <td>${supplier.supplierName}</td>
                                                            </tr>
                                                            <tr>
                                                                <th>Kho:</th>
                                                                <td>${warehouse.warehouseName}</td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <table class="table table-borderless table-sm">
                                                            <tr>
                                                                <th width="140">Ngày giao dự kiến:</th>
                                                                <td>
                                                                    <fmt:formatDate value="${rfq.expectedDeliveryDate}"
                                                                        pattern="dd/MM/yyyy" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <th>Ghi chú:</th>
                                                                <td>${rfq.note}</td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Purchase Order Form -->
                                        <form action="purchasing" method="post" id="poForm">
                                            <input type="hidden" name="action" value="create-po">
                                            <input type="hidden" name="rfqId" value="${rfq.rfqId}">

                                            <h5>Sản phẩm & Giá cả</h5>
                                            <div class="table-responsive">
                                                <table class="table table-bordered">
                                                    <thead class="table-light">
                                                        <tr>
                                                            <th>Mã sản phẩm</th>
                                                            <th>Tên sản phẩm</th>
                                                            <th>Đơn vị</th>
                                                            <th>Số lượng</th>
                                                            <th>Đơn giá <span class="text-danger">*</span></th>
                                                            <th>Tổng tiền</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:set var="grandTotal" value="0" />
                                                        <c:forEach var="detail" items="${rfqDetails}">
                                                            <c:forEach var="product" items="${products}">
                                                                <c:if test="${product.productId == detail.productId}">
                                                                    <tr>
                                                                        <input type="hidden" name="productId"
                                                                            value="${product.productId}">
                                                                        <input type="hidden" name="quantity"
                                                                            value="${detail.quantity}">

                                                                        <td>${product.productCode}</td>
                                                                        <td>${product.productName}</td>
                                                                        <td>${product.unit}</td>
                                                                        <td>${detail.quantity}</td>
                                                                        <td>
                                                                            <input type="number"
                                                                                class="form-control unit-price"
                                                                                name="unitPrice" min="0" step="0.01"
                                                                                value="${product.purchasePrice}"
                                                                                data-quantity="${detail.quantity}"
                                                                                onchange="calculateRowTotal(this)"
                                                                                required>
                                                                        </td>
                                                                        <td>
                                                                            <span class="row-total fw-bold">
                                                                                <c:set var="unitPrice"
                                                                                    value="${product.purchasePrice}" />
                                                                                <fmt:formatNumber
                                                                                    value="${unitPrice * detail.quantity}"
                                                                                    type="currency"
                                                                                    currencySymbol="₫" />
                                                                            </span>
                                                                        </td>
                                                                    </tr>
                                                                    <c:set var="grandTotal"
                                                                        value="${grandTotal + (unitPrice * detail.quantity)}" />
                                                                </c:if>
                                                            </c:forEach>
                                                        </c:forEach>
                                                    </tbody>
                                                    <tfoot class="table-light">
                                                        <tr>
                                                            <td colspan="6" class="text-end fw-bold">Tổng cộng:</td>
                                                            <td class="fw-bold">
                                                                <span id="grandTotal">
                                                                    <fmt:formatNumber value="${grandTotal}"
                                                                        type="currency" currencySymbol="₫" />
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </tfoot>
                                                </table>
                                            </div>

                                            <div class="d-flex justify-content-end gap-2 mt-4">
                                                <a href="purchasing?action=view-rfq&id=${rfq.rfqId}"
                                                    class="btn btn-secondary">Hủy</a>
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="fas fa-save"></i> Tạo Đơn Mua Hàng
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

                <script>
                    function calculateRowTotal(input) {
                        const row = input.closest('tr');
                        const quantity = parseInt(input.dataset.quantity);
                        const unitPrice = parseFloat(input.value) || 0;
                        const total = quantity * unitPrice;

                        // Update row total
                        const rowTotalSpan = row.querySelector('.row-total');
                        rowTotalSpan.textContent = formatCurrency(total);

                        // Update grand total
                        updateGrandTotal();
                    }

                    function updateGrandTotal() {
                        let grandTotal = 0;
                        document.querySelectorAll('.unit-price').forEach(input => {
                            const quantity = parseInt(input.dataset.quantity);
                            const unitPrice = parseFloat(input.value) || 0;
                            grandTotal += quantity * unitPrice;
                        });

                        document.getElementById('grandTotal').textContent = formatCurrency(grandTotal);
                    }

                    function formatCurrency(amount) {
                        return new Intl.NumberFormat('vi-VN', {
                            style: 'currency',
                            currency: 'VND'
                        }).format(amount);
                    }

                    // Form validation
                    document.getElementById('poForm').addEventListener('submit', function (e) {
                        const unitPrices = document.querySelectorAll('input[name="unitPrice"]');
                        let hasError = false;

                        unitPrices.forEach(input => {
                            if (!input.value || parseFloat(input.value) <= 0) {
                                hasError = true;
                                input.classList.add('is-invalid');
                            } else {
                                input.classList.remove('is-invalid');
                            }
                        });

                        if (hasError) {
                            e.preventDefault();
                            alert('Vui lòng nhập đơn giá hợp lệ cho tất cả sản phẩm');
                        }
                    });

                    // Initialize calculations
                    document.addEventListener('DOMContentLoaded', function () {
                        updateGrandTotal();
                    });
                </script>
            </body>

            </html>
