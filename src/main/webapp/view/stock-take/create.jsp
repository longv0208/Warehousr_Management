<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Warehouse" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Quản Lý Kho Hàng - Tạo Phiếu Kiểm Kê</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="../common/sidebar.jsp" />

<div class="container-fluid">
    <div class="row">
        <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3>Tạo Phiếu Kiểm Kê Mới</h3>
                <a href="${pageContext.request.contextPath}/stock-take" class="btn btn-secondary">Quay lại</a>
            </div>

            <!-- Hiển thị thông báo lỗi -->
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">Thông tin phiếu kiểm kê</h5>
                        </div>
                        <div class="card-body">
                            <form method="POST" action="${pageContext.request.contextPath}/stock-take">
                                <input type="hidden" name="action" value="create">
                                
                                <div class="mb-3">
                                    <label for="warehouseId" class="form-label">Chọn Kho Hàng <span class="text-danger">*</span></label>
                                    <select name="warehouseId" id="warehouseId" class="form-select" required>
                                        <option value="">-- Chọn kho hàng để kiểm kê --</option>
                                        <c:forEach var="warehouse" items="${warehouses}">
                                            <option value="${warehouse.warehouseId}">${warehouse.warehouseName}</option>
                                        </c:forEach>
                                    </select>
                                    <div class="form-text">Chọn kho hàng mà bạn muốn thực hiện kiểm kê</div>
                                    <div id="warehouseInfo" class="mt-2" style="display: none;">
                                        <div id="warehouseStatus" class="alert" role="alert"></div>
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="notes" class="form-label">Ghi chú kiểm kê</label>
                                    <textarea name="notes" id="notes" class="form-control" rows="4" 
                                              placeholder="Nhập ghi chú về lý do kiểm kê, phạm vi kiểm kê..."></textarea>
                                </div>

                                <div class="alert alert-info">
                                    <h6>Lưu ý:</h6>
                                    <ul class="mb-0">
                                        <li>Hệ thống sẽ tự động tạo mã phiếu kiểm kê</li>
                                        <li>Chỉ các sản phẩm có tồn kho trong kho hàng được chọn sẽ được thêm vào phiếu</li>
                                        <li>Sau khi tạo, bạn có thể tiến hành kiểm kê từng sản phẩm</li>
                                        <li>Số lượng hệ thống sẽ được lấy từ dữ liệu tồn kho của kho hàng được chọn</li>
                                    </ul>
                                </div>

                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <a href="${pageContext.request.contextPath}/stock-take" class="btn btn-secondary me-md-2">Hủy</a>
                                    <button type="submit" id="submitBtn" class="btn btn-primary" disabled>Tạo Phiếu Kiểm Kê</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const warehouseSelect = document.getElementById('warehouseId');
    const warehouseInfo = document.getElementById('warehouseInfo');
    const warehouseStatus = document.getElementById('warehouseStatus');
    const submitBtn = document.getElementById('submitBtn');
    
    warehouseSelect.addEventListener('change', function() {
        const warehouseId = this.value;
        
        if (!warehouseId) {
            warehouseInfo.style.display = 'none';
            submitBtn.disabled = true;
            return;
        }
        
        // Show loading
        warehouseInfo.style.display = 'block';
        warehouseStatus.className = 'alert alert-info';
        warehouseStatus.innerHTML = '<i class="spinner-border spinner-border-sm me-2"></i>Đang kiểm tra kho hàng...';
        submitBtn.disabled = true;
        
        // Make AJAX request to check warehouse
        fetch('${pageContext.request.contextPath}/stock-take?action=check-warehouse&warehouseId=' + warehouseId)
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    if (data.hasProducts) {
                        warehouseStatus.className = 'alert alert-success';
                        warehouseStatus.innerHTML = '<i class="bi bi-check-circle-fill me-2"></i>' + data.message;
                        submitBtn.disabled = false;
                    } else {
                        warehouseStatus.className = 'alert alert-warning';
                        warehouseStatus.innerHTML = '<i class="bi bi-exclamation-triangle-fill me-2"></i>' + data.message + 
                                                  '<br><small>Vui lòng chọn kho khác hoặc nhập hàng vào kho này trước.</small>';
                        submitBtn.disabled = true;
                    }
                } else {
                    warehouseStatus.className = 'alert alert-danger';
                    warehouseStatus.innerHTML = '<i class="bi bi-x-circle-fill me-2"></i>' + data.message;
                    submitBtn.disabled = true;
                }
            })
            .catch(error => {
                warehouseStatus.className = 'alert alert-danger';
                warehouseStatus.innerHTML = '<i class="bi bi-x-circle-fill me-2"></i>Có lỗi xảy ra khi kiểm tra kho hàng';
                submitBtn.disabled = true;
            });
    });
});
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 