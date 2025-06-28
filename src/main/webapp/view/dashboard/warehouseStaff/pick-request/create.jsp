<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo yêu cầu lấy hàng - Internal Transfer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .form-section {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .section-title {
            font-size: 16px;
            font-weight: 600;
            color: #495057;
            margin-bottom: 15px;
            border-bottom: 2px solid #dee2e6;
            padding-bottom: 8px;
        }
        .btn-action {
            min-width: 120px;
        }
        .product-row {
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Include sidebar -->
            <jsp:include page="../../../common/sidebar.jsp"/>
            
            <div class="col-md-10 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">
                        <i class="fas fa-exchange-alt text-primary me-2"></i>
                        Tạo yêu cầu lấy hàng - Internal Transfer
                    </h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <div class="btn-group me-2">
                            <button type="button" class="btn btn-outline-secondary" onclick="window.history.back();">
                                <i class="fas fa-arrow-left"></i> Quay lại
                            </button>
                        </div>
                    </div>
                </div>

                <form method="post" action="warehouse-staff" id="pickRequestForm">
                    <input type="hidden" name="action" value="create-pick-request">
                    <c:if test="${not empty salesOrder}">
                        <input type="hidden" name="salesOrderId" value="${salesOrder.salesOrderId}">
                    </c:if>

                    <div class="row">
                        <!-- Left Column - Main Information -->
                        <div class="col-lg-8">
                            <!-- General Information -->
                            <div class="form-section">
                                <div class="section-title">Thông tin chung</div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <label for="contact" class="form-label">Người yêu cầu</label>
                                        <input type="text" class="form-control" id="contact" 
                                               value="${sessionScope.user.fullName}" readonly>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="scheduledDate" class="form-label">Ngày thực hiện</label>
                                        <input type="datetime-local" class="form-control" id="scheduledDate" 
                                               value="<fmt:formatDate value='<%=new java.util.Date()%>' pattern='yyyy-MM-dd'/>T<fmt:formatDate value='<%=new java.util.Date()%>' pattern='HH:mm'/>" readonly>
                                    </div>
                                </div>
                                <div class="row mt-3">
                                    <div class="col-md-6">
                                        <label for="operationType" class="form-label">Loại thao tác</label>
                                        <select class="form-select" id="operationType" disabled>
                                            <option selected>Lấy hàng ra khỏi kho</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="sourceDocument" class="form-label">Chứng từ nguồn</label>
                                        <input type="text" class="form-control" id="sourceDocument" 
                                               value="${not empty salesOrder ? salesOrder.orderCode : ''}" readonly>
                                    </div>
                                </div>
                                <div class="row mt-3">
                                    <div class="col-md-6">
                                        <label for="sourceLocation" class="form-label">Vị trí nguồn</label>
                                        <select class="form-select" name="warehouseId" required>
                                            <option value="">Chọn kho</option>
                                            <c:forEach var="warehouse" items="${warehouses}">
                                                <option value="${warehouse.warehouseId}">${warehouse.warehouseName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="destinationLocation" class="form-label">Vị trí đích</label>
                                        <input type="text" class="form-control" id="destinationLocation" 
                                               value="Khu vực đóng gói" readonly>
                                    </div>
                                </div>
                                <div class="row mt-3">
                                    <div class="col-12">
                                        <label for="notes" class="form-label">Ghi chú</label>
                                        <textarea class="form-control" name="notes" id="notes" rows="2" 
                                                  placeholder="Nhập ghi chú cho yêu cầu lấy hàng..."></textarea>
                                    </div>
                                </div>
                            </div>

                            <!-- Products Section -->
                            <div class="form-section">
                                <div class="section-title">
                                    Danh sách sản phẩm cần lấy
                                    <small class="text-muted">(từ đơn hàng: ${salesOrder.orderCode})</small>
                                </div>
                                
                                <div id="productsContainer">
                                    <c:forEach var="detail" items="${salesOrderDetails}" varStatus="status">
                                        <div class="product-row">
                                            <input type="hidden" name="productId" value="${detail.productId}">
                                            <div class="row align-items-center">
                                                <div class="col-md-3">
                                                    <label class="form-label">Sản phẩm</label>
                                                    <div class="fw-bold">${detail.productCode}</div>
                                                    <small class="text-muted">${detail.productName}</small>
                                                </div>
                                                <div class="col-md-2">
                                                    <label class="form-label">Đơn vị</label>
                                                    <div>${detail.unit}</div>
                                                </div>
                                                <div class="col-md-2">
                                                    <label class="form-label">SL yêu cầu</label>
                                                    <input type="number" class="form-control" 
                                                           name="quantityRequested" 
                                                           value="${detail.quantityOrdered}" 
                                                           min="1" required>
                                                </div>
                                                <div class="col-md-2">
                                                    <label class="form-label">SL tồn kho</label>
                                                    <div class="text-info fw-bold">${detail.availableQuantity}</div>
                                                </div>
                                                <div class="col-md-2">
                                                    <label class="form-label">Vị trí</label>
                                                    <input type="text" class="form-control" 
                                                           value="A1-01-01" placeholder="Vị trí kệ">
                                                </div>
                                                <div class="col-md-1">
                                                    <label class="form-label text-white">.</label>
                                                    <div>
                                                        <span class="badge bg-primary">
                                                            <i class="fas fa-check"></i>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>

                        <!-- Right Column - Summary & Actions -->
                        <div class="col-lg-4">
                            <div class="form-section">
                                <div class="section-title">Thông tin đơn hàng</div>
                                <c:if test="${not empty salesOrder}">
                                    <table class="table table-sm">
                                        <tr>
                                            <td><strong>Mã đơn hàng:</strong></td>
                                            <td>${salesOrder.orderCode}</td>
                                        </tr>
                                        <tr>
                                            <td><strong>Khách hàng:</strong></td>
                                            <td>${salesOrder.customerName}</td>
                                        </tr>
                                        <tr>
                                            <td><strong>Ngày đặt:</strong></td>
                                            <td>
                                                <fmt:formatDate value="${salesOrder.orderDate}" pattern="dd/MM/yyyy"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><strong>Trạng thái:</strong></td>
                                            <td>
                                                <span class="badge bg-warning">
                                                    <c:choose>
                                                        <c:when test="${salesOrder.status == 'pending_stock_check'}">Chờ kiểm tra kho</c:when>
                                                        <c:when test="${salesOrder.status == 'awaiting_shipment'}">Chờ xuất hàng</c:when>
                                                        <c:when test="${salesOrder.status == 'shipped'}">Đã xuất hàng</c:when>
                                                        <c:when test="${salesOrder.status == 'completed'}">Hoàn thành</c:when>
                                                        <c:otherwise>Đã hủy</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                        </tr>
                                    </table>
                                </c:if>
                            </div>

                            <div class="form-section">
                                <div class="section-title">Thống kê</div>
                                <div class="row text-center">
                                    <div class="col-6">
                                        <div class="border rounded p-2">
                                            <div class="h4 text-primary mb-0" id="totalProducts">${salesOrderDetails.size()}</div>
                                            <small class="text-muted">Sản phẩm</small>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="border rounded p-2">
                                            <div class="h4 text-success mb-0" id="totalQuantity">
                                                <c:set var="totalQty" value="0"/>
                                                <c:forEach var="detail" items="${salesOrderDetails}">
                                                    <c:set var="totalQty" value="${totalQty + detail.quantityOrdered}"/>
                                                </c:forEach>
                                                ${totalQty}
                                            </div>
                                            <small class="text-muted">Tổng SL</small>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="form-section">
                                <div class="d-grid gap-2">
                                    <button type="submit" class="btn btn-primary btn-action">
                                        <i class="fas fa-save me-2"></i>Tạo yêu cầu lấy hàng
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary btn-action" onclick="window.history.back();">
                                        <i class="fas fa-times me-2"></i>Hủy bỏ
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Validation
        document.getElementById('pickRequestForm').addEventListener('submit', function(e) {
            const warehouseSelect = document.querySelector('select[name="warehouseId"]');
            if (!warehouseSelect.value) {
                e.preventDefault();
                alert('Vui lòng chọn kho để lấy hàng');
                warehouseSelect.focus();
                return false;
            }
            
            const quantities = document.querySelectorAll('input[name="quantityRequested"]');
            let hasValidQuantity = false;
            
            quantities.forEach(function(input) {
                if (input.value && parseInt(input.value) > 0) {
                    hasValidQuantity = true;
                }
            });
            
            if (!hasValidQuantity) {
                e.preventDefault();
                alert('Vui lòng nhập số lượng cần lấy cho ít nhất một sản phẩm');
                return false;
            }
        });
        
        // Update total when quantities change
        document.querySelectorAll('input[name="quantityRequested"]').forEach(function(input) {
            input.addEventListener('input', function() {
                updateTotals();
            });
        });
        
        function updateTotals() {
            let total = 0;
            document.querySelectorAll('input[name="quantityRequested"]').forEach(function(input) {
                if (input.value) {
                    total += parseInt(input.value) || 0;
                }
            });
            document.getElementById('totalQuantity').textContent = total;
        }
    </script>
</body>
</html> 