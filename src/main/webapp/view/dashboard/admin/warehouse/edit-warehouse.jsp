<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa Kho hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
        }
        
        .btn-primary:hover {
            background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
        }
        
        .info-box {
            background-color: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body class="bg-light">
    <div class="container-fluid">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2><i class="fas fa-edit text-primary"></i> Chỉnh sửa Kho hàng</h2>
                <p class="text-muted mb-0">Cập nhật thông tin kho hàng</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=list" 
               class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
        </div>

        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="card shadow">
                    <div class="card-header text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-warehouse"></i> Thông tin Kho hàng
                        </h5>
                    </div>
                    <div class="card-body">
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

                        <form method="POST" action="${pageContext.request.contextPath}/admin/manage-warehouse" novalidate>
                            <input type="hidden" name="action" value="edit">
                            <input type="hidden" name="warehouseId" value="${warehouse.warehouseId}">
                            
                            <div class="mb-3">
                                <label for="warehouseName" class="form-label">
                                    <i class="fas fa-warehouse text-primary"></i> Tên Kho hàng <span class="text-danger">*</span>
                                </label>
                                <input type="text" class="form-control" id="warehouseName" name="warehouseName" 
                                       value="${warehouse.warehouseName}" placeholder="Nhập tên kho hàng..." required>
                                <div class="invalid-feedback">
                                    Vui lòng nhập tên kho hàng.
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="address" class="form-label">
                                    <i class="fas fa-map-marker-alt text-primary"></i> Địa chỉ <span class="text-danger">*</span>
                                </label>
                                <textarea class="form-control" id="address" name="address" rows="3" 
                                          placeholder="Nhập địa chỉ đầy đủ của kho hàng..." required>${warehouse.address}</textarea>
                                <div class="invalid-feedback">
                                    Vui lòng nhập địa chỉ kho hàng.
                                </div>
                            </div>

                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="fas fa-save"></i> Cập nhật Kho hàng
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=list" 
                                   class="btn btn-outline-secondary">
                                    <i class="fas fa-times"></i> Hủy
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation
        (function() {
            'use strict';
            window.addEventListener('load', function() {
                var forms = document.getElementsByClassName('needs-validation');
                var validation = Array.prototype.filter.call(forms, function(form) {
                    form.addEventListener('submit', function(event) {
                        if (form.checkValidity() === false) {
                            event.preventDefault();
                            event.stopPropagation();
                        }
                        form.classList.add('was-validated');
                    }, false);
                });
            }, false);
        })();

        // Auto-hide alerts
        setTimeout(function() {
            var alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                var bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            });
        }, 5000);
    </script>
</body>
</html> 