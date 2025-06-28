<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xử lý lấy hàng - ${pickRequest.pickRequestCode}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .header-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .status-badge {
            font-size: 14px;
            padding: 8px 16px;
        }
        .product-card {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .product-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        .quantity-input {
            text-align: center;
            font-weight: bold;
            font-size: 18px;
        }
        .btn-scanner {
            background: #6f42c1;
            border-color: #6f42c1;
            color: white;
        }
        .btn-scanner:hover {
            background: #5a359a;
            border-color: #5a359a;
            color: white;
        }
        .location-badge {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 8px 12px;
            font-family: monospace;
            font-weight: bold;
        }
        .progress-bar-custom {
            height: 25px;
            border-radius: 12px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Include sidebar -->
            <jsp:include page="../../../common/sidebar.jsp"/>
            
            <div class="col-md-10 ms-sm-auto col-lg-10 px-md-4">
                <!-- Header -->
                <div class="header-section">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h1 class="h2 mb-2">
                                <i class="fas fa-hand-paper me-2"></i>
                                Xử lý lấy hàng
                            </h1>
                            <h4 class="mb-0">${pickRequest.pickRequestCode}</h4>
                            <p class="mb-0 opacity-75">
                                <i class="fas fa-user me-1"></i>
                                Người yêu cầu: ${pickRequest.requestedByName}
                                <span class="mx-3">|</span>
                                <i class="fas fa-warehouse me-1"></i>
                                Kho: ${pickRequest.warehouseName}
                            </p>
                        </div>
                        <div class="col-md-4 text-end">
                            <div class="mb-2">
                                <span class="status-badge badge 
                                    <c:choose>
                                        <c:when test="${pickRequest.status == 'pending'}">bg-warning</c:when>
                                        <c:when test="${pickRequest.status == 'in_progress'}">bg-info</c:when>
                                        <c:when test="${pickRequest.status == 'completed'}">bg-success</c:when>
                                        <c:otherwise>bg-secondary</c:otherwise>
                                    </c:choose>">
                                    <c:choose>
                                        <c:when test="${pickRequest.status == 'pending'}">Chờ xử lý</c:when>
                                        <c:when test="${pickRequest.status == 'in_progress'}">Đang xử lý</c:when>
                                        <c:when test="${pickRequest.status == 'completed'}">Hoàn thành</c:when>
                                        <c:otherwise>Đã hủy</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="text-sm opacity-75">
                                <fmt:formatDate value="${pickRequest.requestDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Progress Bar -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between mb-2">
                            <span class="fw-bold">Tiến độ lấy hàng</span>
                            <span id="progressText">0/0 sản phẩm</span>
                        </div>
                        <div class="progress progress-bar-custom">
                            <div class="progress-bar bg-success" role="progressbar" style="width: 0%" id="progressBar"></div>
                        </div>
                    </div>
                </div>

                <!-- Pick List Form -->
                <form method="post" action="warehouse-staff" id="pickForm">
                    <input type="hidden" name="action" value="update-pick">
                    <input type="hidden" name="pickRequestId" value="${pickRequest.pickRequestId}">

                    <div class="row">
                        <div class="col-lg-8">
                            <!-- Products to Pick -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="mb-0">
                                    <i class="fas fa-list me-2"></i>
                                    Danh sách sản phẩm cần lấy
                                </h5>
                                <button type="button" class="btn btn-scanner btn-sm">
                                    <i class="fas fa-qrcode me-1"></i>
                                    Quét mã vạch
                                </button>
                            </div>

                            <c:forEach var="detail" items="${pickRequestDetails}" varStatus="status">
                                <div class="product-card">
                                    <input type="hidden" name="detailId" value="${detail.pickDetailId}">
                                    
                                    <div class="product-header">
                                        <div class="d-flex align-items-center">
                                            <div class="me-3">
                                                <i class="fas fa-cube fa-2x text-primary"></i>
                                            </div>
                                            <div>
                                                <h6 class="mb-1 fw-bold">${detail.productCode}</h6>
                                                <p class="mb-0 text-muted">${detail.productName}</p>
                                            </div>
                                        </div>
                                        <div class="text-end">
                                            <span class="location-badge">
                                                <i class="fas fa-map-marker-alt me-1"></i>
                                                ${detail.location}
                                            </span>
                                        </div>
                                    </div>

                                    <div class="row align-items-center">
                                        <div class="col-md-3">
                                            <label class="form-label">Số lượng yêu cầu</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-light">
                                                    <i class="fas fa-list-ol"></i>
                                                </span>
                                                <input type="number" class="form-control text-center" 
                                                       value="${detail.quantityRequested}" readonly>
                                                <span class="input-group-text">${detail.unit}</span>
                                            </div>
                                        </div>
                                        
                                        <div class="col-md-3">
                                            <label class="form-label">Số lượng có sẵn</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-success text-white">
                                                    <i class="fas fa-warehouse"></i>
                                                </span>
                                                <input type="number" class="form-control text-center" 
                                                       value="${detail.availableQuantity}" readonly>
                                                <span class="input-group-text">${detail.unit}</span>
                                            </div>
                                        </div>
                                        
                                        <div class="col-md-3">
                                            <label class="form-label">Số lượng đã lấy</label>
                                            <div class="input-group">
                                                <button type="button" class="btn btn-outline-secondary" 
                                                        onclick="decreaseQuantity(this)">
                                                    <i class="fas fa-minus"></i>
                                                </button>
                                                <input type="number" class="form-control quantity-input picked-quantity" 
                                                       name="quantityPicked" 
                                                       value="${detail.quantityPicked}" 
                                                       min="0" 
                                                       max="${detail.quantityRequested}"
                                                       data-requested="${detail.quantityRequested}"
                                                       onchange="updateProgress()">
                                                <button type="button" class="btn btn-outline-secondary" 
                                                        onclick="increaseQuantity(this)">
                                                    <i class="fas fa-plus"></i>
                                                </button>
                                            </div>
                                        </div>
                                        
                                        <div class="col-md-3">
                                            <label class="form-label">Trạng thái</label>
                                            <div class="text-center">
                                                <span class="badge fs-6 status-badge-item
                                                    <c:choose>
                                                        <c:when test="${detail.quantityPicked >= detail.quantityRequested}">bg-success</c:when>
                                                        <c:when test="${detail.quantityPicked > 0}">bg-warning</c:when>
                                                        <c:otherwise>bg-secondary</c:otherwise>
                                                    </c:choose>">
                                                    <c:choose>
                                                        <c:when test="${detail.quantityPicked >= detail.quantityRequested}">
                                                            <i class="fas fa-check me-1"></i>Hoàn thành
                                                        </c:when>
                                                        <c:when test="${detail.quantityPicked > 0}">
                                                            <i class="fas fa-clock me-1"></i>Đang lấy
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="fas fa-pause me-1"></i>Chờ lấy
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    <c:if test="${not empty detail.notes}">
                                        <div class="mt-3">
                                            <div class="alert alert-info mb-0">
                                                <i class="fas fa-info-circle me-1"></i>
                                                <strong>Ghi chú:</strong> ${detail.notes}
                                            </div>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>

                        <!-- Right Sidebar - Summary & Actions -->
                        <div class="col-lg-4">
                            <!-- Quick Stats -->
                            <div class="card mb-4">
                                <div class="card-header">
                                    <h6 class="mb-0">
                                        <i class="fas fa-chart-pie me-2"></i>
                                        Thống kê
                                    </h6>
                                </div>
                                <div class="card-body">
                                    <div class="row text-center">
                                        <div class="col-6">
                                            <div class="border rounded p-3 mb-2">
                                                <div class="h4 text-primary mb-0" id="totalItems">${pickRequestDetails.size()}</div>
                                                <small class="text-muted">Sản phẩm</small>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="border rounded p-3 mb-2">
                                                <div class="h4 text-info mb-0" id="completedItems">0</div>
                                                <small class="text-muted">Hoàn thành</small>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row text-center">
                                        <div class="col-6">
                                            <div class="border rounded p-3">
                                                <div class="h4 text-success mb-0" id="totalQuantityRequested">
                                                    <c:set var="totalReq" value="0"/>
                                                    <c:forEach var="detail" items="${pickRequestDetails}">
                                                        <c:set var="totalReq" value="${totalReq + detail.quantityRequested}"/>
                                                    </c:forEach>
                                                    ${totalReq}
                                                </div>
                                                <small class="text-muted">Tổng YC</small>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="border rounded p-3">
                                                <div class="h4 text-warning mb-0" id="totalQuantityPicked">
                                                    <c:set var="totalPicked" value="0"/>
                                                    <c:forEach var="detail" items="${pickRequestDetails}">
                                                        <c:set var="totalPicked" value="${totalPicked + detail.quantityPicked}"/>
                                                    </c:forEach>
                                                    ${totalPicked}
                                                </div>
                                                <small class="text-muted">Đã lấy</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Order Information -->
                            <c:if test="${not empty pickRequest.salesOrderCode}">
                                <div class="card mb-4">
                                    <div class="card-header">
                                        <h6 class="mb-0">
                                            <i class="fas fa-shopping-cart me-2"></i>
                                            Thông tin đơn hàng
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <table class="table table-sm">
                                            <tr>
                                                <td><strong>Mã đơn:</strong></td>
                                                <td>${pickRequest.salesOrderCode}</td>
                                            </tr>
                                            <tr>
                                                <td><strong>Khách hàng:</strong></td>
                                                <td>${pickRequest.customerName}</td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </c:if>

                            <!-- Actions -->
                            <div class="card">
                                <div class="card-header">
                                    <h6 class="mb-0">
                                        <i class="fas fa-cogs me-2"></i>
                                        Thao tác
                                    </h6>
                                </div>
                                <div class="card-body">
                                    <div class="d-grid gap-2">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save me-2"></i>
                                            Cập nhật số lượng
                                        </button>
                                        
                                        <button type="button" class="btn btn-success" 
                                                onclick="completePicking()" id="completeBtn">
                                            <i class="fas fa-check-circle me-2"></i>
                                            Hoàn thành lấy hàng
                                        </button>
                                        
                                        <button type="button" class="btn btn-outline-secondary" 
                                                onclick="window.history.back();">
                                            <i class="fas fa-arrow-left me-2"></i>
                                            Quay lại
                                        </button>
                                    </div>
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
        function increaseQuantity(btn) {
            const input = btn.previousElementSibling;
            const max = parseInt(input.getAttribute('max'));
            const current = parseInt(input.value) || 0;
            if (current < max) {
                input.value = current + 1;
                updateProgress();
                updateRowStatus(input);
            }
        }
        
        function decreaseQuantity(btn) {
            const input = btn.nextElementSibling;
            const current = parseInt(input.value) || 0;
            if (current > 0) {
                input.value = current - 1;
                updateProgress();
                updateRowStatus(input);
            }
        }
        
        function updateRowStatus(input) {
            const row = input.closest('.product-card');
            const badge = row.querySelector('.status-badge-item');
            const picked = parseInt(input.value) || 0;
            const requested = parseInt(input.getAttribute('data-requested'));
            
            badge.className = 'badge fs-6 status-badge-item';
            if (picked >= requested) {
                badge.classList.add('bg-success');
                badge.innerHTML = '<i class="fas fa-check me-1"></i>Hoàn thành';
            } else if (picked > 0) {
                badge.classList.add('bg-warning');
                badge.innerHTML = '<i class="fas fa-clock me-1"></i>Đang lấy';
            } else {
                badge.classList.add('bg-secondary');
                badge.innerHTML = '<i class="fas fa-pause me-1"></i>Chờ lấy';
            }
        }
        
        function updateProgress() {
            const inputs = document.querySelectorAll('.picked-quantity');
            let totalRequested = 0;
            let totalPicked = 0;
            let completedItems = 0;
            
            inputs.forEach(input => {
                const requested = parseInt(input.getAttribute('data-requested'));
                const picked = parseInt(input.value) || 0;
                
                totalRequested += requested;
                totalPicked += picked;
                
                if (picked >= requested) {
                    completedItems++;
                }
            });
            
            const percentage = totalRequested > 0 ? (totalPicked / totalRequested) * 100 : 0;
            
            document.getElementById('progressBar').style.width = percentage + '%';
            document.getElementById('progressText').textContent = completedItems + '/' + inputs.length + ' sản phẩm';
            document.getElementById('completedItems').textContent = completedItems;
            document.getElementById('totalQuantityPicked').textContent = totalPicked;
        }
        
        function completePicking() {
            if (confirm('Bạn có chắc chắn muốn hoàn thành lấy hàng này?')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'warehouse-staff';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'complete-pick';
                form.appendChild(actionInput);
                
                const pickRequestIdInput = document.createElement('input');
                pickRequestIdInput.type = 'hidden';
                pickRequestIdInput.name = 'pickRequestId';
                pickRequestIdInput.value = '${pickRequest.pickRequestId}';
                form.appendChild(pickRequestIdInput);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        // Initialize progress on page load
        document.addEventListener('DOMContentLoaded', function() {
            updateProgress();
        });
        
        // Update status for all inputs on page load
        document.querySelectorAll('.picked-quantity').forEach(input => {
            updateRowStatus(input);
            input.addEventListener('change', function() {
                updateRowStatus(this);
                updateProgress();
            });
        });
    </script>
</body>
</html> 