<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Kho hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .table th {
            background-color: #f8f9fa;
            border-top: none;
        }
        
        .btn-group .btn {
            margin-right: 5px;
        }
        
        .search-box {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .warehouse-count {
            color: #6c757d;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2><i class="fas fa-warehouse text-primary"></i> Quản lý Kho hàng</h2>
                <p class="text-muted mb-0">Quản lý thông tin các kho hàng trong hệ thống</p>
            </div>
            <c:if test="${userRole == 'admin'}">
                <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=create" 
                   class="btn btn-primary">
                    <i class="fas fa-plus"></i> Thêm Kho hàng
                </a>
            </c:if>
        </div>

        <!-- Alert Messages -->
        <c:if test="${not empty sessionScope.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i> ${sessionScope.success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="success" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <!-- Information for non-admin users -->
        <c:if test="${userRole != 'admin'}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <i class="fas fa-info-circle"></i> 
                Bạn chỉ có quyền xem danh sách kho hàng. Để thêm, sửa hoặc xóa kho hàng, vui lòng liên hệ quản trị viên.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Search Section -->
        <div class="search-box">
            <form method="GET" action="${pageContext.request.contextPath}/admin/manage-warehouse">
                <input type="hidden" name="action" value="list">
                <div class="row align-items-end">
                    <div class="col-md-10">
                        <label for="search" class="form-label">
                            <i class="fas fa-search"></i> Tìm kiếm kho hàng
                        </label>
                        <input type="text" class="form-control" id="search" name="search" 
                               value="${searchTerm}" placeholder="Nhập tên kho hoặc địa chỉ...">
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-outline-primary w-100">
                            <i class="fas fa-search"></i> Tìm kiếm
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Warehouses Table -->
        <div class="card shadow">
            <div class="card-header text-white">
                <h5 class="mb-0">
                    <i class="fas fa-list"></i> Danh sách Kho hàng
                    <span class="warehouse-count float-end">
                        (${warehouses.size()} kho hàng)
                    </span>
                </h5>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty warehouses}">
                        <div class="text-center py-5">
                            <i class="fas fa-warehouse fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">Không có kho hàng nào</h5>
                            <p class="text-muted">
                                <c:choose>
                                    <c:when test="${not empty searchTerm}">
                                        Không tìm thấy kho hàng nào phù hợp với từ khóa "<strong>${searchTerm}</strong>"
                                        <br>
                                        <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=list" 
                                           class="btn btn-link">Xem tất cả kho hàng</a>
                                    </c:when>
                                    <c:otherwise>
                                        Hãy thêm kho hàng đầu tiên để bắt đầu quản lý
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th width="8%">ID</th>
                                        <th width="25%">Tên Kho hàng</th>
                                        <th width="40%">Địa chỉ</th>
                                        <th width="15%">Ngày tạo</th>
                                        <c:if test="${userRole == 'admin'}">
                                            <th width="12%" class="text-center">Thao tác</th>
                                        </c:if>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="warehouse" items="${warehouses}">
                                        <tr>
                                            <td>
                                                <span class="badge bg-secondary">#${warehouse.warehouseId}</span>
                                            </td>
                                            <td>
                                                <strong>${warehouse.warehouseName}</strong>
                                            </td>
                                            <td>
                                                <i class="fas fa-map-marker-alt text-muted"></i>
                                                ${warehouse.address}
                                            </td>
                                            <td>
                                                <c:if test="${not empty warehouse.createdAt}">
                                                    <fmt:formatDate value="${warehouse.createdAt}" 
                                                                    pattern="dd/MM/yyyy HH:mm"/>
                                                </c:if>
                                            </td>
                                            <c:if test="${userRole == 'admin'}">
                                                <td class="text-center">
                                                    <div class="btn-group btn-group-sm" role="group">
                                                        <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=edit&id=${warehouse.warehouseId}" 
                                                           class="btn btn-outline-primary" title="Chỉnh sửa">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <button type="button" class="btn btn-outline-danger" 
                                                                data-warehouse-id="${warehouse.warehouseId}" 
                                                                data-warehouse-name="${warehouse.warehouseName}"
                                                                onclick="confirmDelete(this)" 
                                                                title="Xóa">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </c:if>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal - Only for Admin -->
    <c:if test="${userRole == 'admin'}">
        <div class="modal fade" id="deleteModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title">
                            <i class="fas fa-exclamation-triangle"></i> Xác nhận xóa
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p>Bạn có chắc chắn muốn xóa kho hàng <strong id="warehouseName"></strong>?</p>
                        <div class="alert alert-warning">
                            <i class="fas fa-info-circle"></i>
                            Hành động này không thể hoàn tác. Kho hàng sẽ bị xóa vĩnh viễn khỏi hệ thống.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <a href="#" id="deleteLink" class="btn btn-danger">
                            <i class="fas fa-trash"></i> Xóa
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmDelete(button) {
            var warehouseId = button.getAttribute('data-warehouse-id');
            var warehouseName = button.getAttribute('data-warehouse-name');
            
            document.getElementById('warehouseName').textContent = warehouseName;
            document.getElementById('deleteLink').href = 
                '${pageContext.request.contextPath}/admin/manage-warehouse?action=delete&id=' + warehouseId;
            new bootstrap.Modal(document.getElementById('deleteModal')).show();
        }

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