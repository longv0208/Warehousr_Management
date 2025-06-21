<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Chỉnh Sửa Kho Hàng - Quản Lý Kho Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet" />
    <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
    <style>
        .invalid-feedback {
            display: block;
        }
        .info-box {
            background-color: #f8f9fa;
            border-left: 4px solid #0d6efd;
            padding: 15px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

        <!-- Main Content -->
        <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
            <h3>Chỉnh sửa Kho hàng</h3>
            
            <!-- Warehouse Info -->
            <div class="info-box">
                <h6><i class="fas fa-info-circle text-primary"></i> Thông tin hiện tại</h6>
                <p class="mb-1"><strong>ID:</strong> #${warehouse.warehouseId}</p>
                <c:if test="${not empty warehouse.createdAt}">
                    <p class="mb-0"><strong>Ngày tạo:</strong> 
                        <fmt:formatDate value="${warehouse.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </p>
                </c:if>
            </div>
            
            <!-- Alert Messages -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle"></i> ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            
            <form action="${pageContext.request.contextPath}/admin/manage-warehouse" method="POST" id="warehouseForm" novalidate>
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="warehouseId" value="${warehouse.warehouseId}">

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label for="warehouseName" class="form-label">Tên Kho hàng <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="warehouseName" name="warehouseName" 
                               value="${warehouse.warehouseName}" maxlength="255" required>
                        <div class="invalid-feedback"></div>
                        <div class="form-text">Tối đa 255 ký tự</div>
                    </div>
                    <div class="col-md-6">
                        <!-- Empty column for better layout -->
                    </div>
                </div>

                <div class="mb-3">
                    <label for="address" class="form-label">Địa chỉ <span class="text-danger">*</span></label>
                    <textarea class="form-control" id="address" name="address" rows="3" 
                              maxlength="500" required>${warehouse.address}</textarea>
                    <div class="invalid-feedback"></div>
                    <div class="form-text">Tối đa 500 ký tự</div>
                </div>

                <button type="submit" class="btn btn-success">Cập nhật Kho hàng</button>
                <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=list" class="btn btn-secondary">Hủy</a>
            </form>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const form = document.getElementById('warehouseForm');
        const warehouseNameInput = document.getElementById('warehouseName');
        const addressInput = document.getElementById('address');
        
        // Real-time validation functions
        function validateWarehouseName() {
            const value = warehouseNameInput.value.trim();
            const feedback = warehouseNameInput.nextElementSibling;
            
            if (value === '') {
                warehouseNameInput.classList.add('is-invalid');
                feedback.textContent = 'Tên kho hàng không được để trống';
                return false;
            } else if (value.length > 255) {
                warehouseNameInput.classList.add('is-invalid');
                feedback.textContent = 'Tên kho hàng không được quá 255 ký tự';
                return false;
            } else {
                warehouseNameInput.classList.remove('is-invalid');
                warehouseNameInput.classList.add('is-valid');
                return true;
            }
        }
        
        function validateAddress() {
            const value = addressInput.value.trim();
            const feedback = addressInput.nextElementSibling;
            
            if (value === '') {
                addressInput.classList.add('is-invalid');
                feedback.textContent = 'Địa chỉ không được để trống';
                return false;
            } else if (value.length > 500) {
                addressInput.classList.add('is-invalid');
                feedback.textContent = 'Địa chỉ không được quá 500 ký tự';
                return false;
            } else {
                addressInput.classList.remove('is-invalid');
                addressInput.classList.add('is-valid');
                return true;
            }
        }
        
        // Real-time validation
        warehouseNameInput.addEventListener('input', validateWarehouseName);
        addressInput.addEventListener('input', validateAddress);
        
        // Form submission validation
        form.addEventListener('submit', function(event) {
            const isValid = validateWarehouseName() && validateAddress();
            
            if (!isValid) {
                event.preventDefault();
                event.stopPropagation();
            }
        });
    });
</script>
</body>
</html> 