<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.StockTake" %>
<%@ page import="model.StockTakeDetail" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Quản Lý Kho Hàng - Thực Hiện Kiểm Kê</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
    <style>
        /* Sidebar layout fix */
        .main-content {
            margin-left: 250px !important;
            width: calc(100% - 250px) !important;
            min-height: 100vh;
        }
        
        @media (max-width: 767.98px) {
            .main-content {
                margin-left: 0 !important;
                width: 100% !important;
            }
        }
    </style>
</head>
<body>
<jsp:include page="../common/sidebar.jsp" />

<div class="container-fluid main-content">
    <div class="row">
        <main class="col-md-12 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3>Thực Hiện Kiểm Kê</h3>
                    <p class="text-muted mb-0">Phiếu: ${stockTake.stockTakeCode} - Ngày: <fmt:formatDate value="${stockTake.stockTakeDate}" pattern="dd/MM/yyyy" /></p>
                </div>
                <a href="${pageContext.request.contextPath}/stock-take" class="btn btn-secondary">Quay lại</a>
            </div>

            <!-- Hiển thị thông báo -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <!-- Bộ lọc và tìm kiếm -->
            <div class="row mb-3">
                <div class="col-md-6">
                    <input type="text" id="searchProduct" class="form-control" placeholder="Tìm kiếm sản phẩm...">
                </div>
                <div class="col-md-3">
                    <select id="filterStatus" class="form-select">
                        <option value="">Tất cả</option>
                        <option value="counted">Đã kiểm</option>
                        <option value="not-counted">Chưa kiểm</option>
                        <option value="discrepancy">Có chênh lệch</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <button type="button" class="btn btn-success" onclick="saveAllChanges()">Lưu tất cả thay đổi</button>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-bordered table-hover" id="stockTakeTable">
                    <thead class="table-light">
                        <tr>
                            <th>Mã SP</th>
                            <th>Tên sản phẩm</th>
                            <th>Đơn vị</th>
                            <th>SL Hệ thống</th>
                            <th>SL Kiểm đếm</th>
                            <th>Chênh lệch</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="detail" items="${stockTakeDetails}">
                            <tr data-product-code="${detail.productCode}" data-product-name="${detail.productName}">
                                <td>${detail.productCode}</td>
                                <td>${detail.productName}</td>
                                <td>${detail.unit}</td>
                                <td class="text-center">${detail.systemQuantity}</td>
                                <td class="text-center">
                                    <input type="number" 
                                           class="form-control text-center counted-input" 
                                           value="${detail.countedQuantity != null ? detail.countedQuantity : ''}"
                                           data-detail-id="${detail.stockTakeDetailId}"
                                           data-system-qty="${detail.systemQuantity}"
                                           min="0"
                                           style="width: 100px; margin: 0 auto;">
                                </td>
                                <td class="text-center discrepancy-cell">
                                    <c:if test="${detail.countedQuantity != null}">
                                        <c:set var="diff" value="${detail.countedQuantity - detail.systemQuantity}" />
                                        <span class="badge ${diff > 0 ? 'bg-success' : diff < 0 ? 'bg-danger' : 'bg-secondary'}">
                                            ${diff > 0 ? '+' : ''}${diff}
                                        </span>
                                    </c:if>
                                </td>
                                <td class="text-center">
                                    <button type="button" 
                                            class="btn btn-sm btn-primary save-btn"
                                            onclick="saveCount('${detail.stockTakeDetailId}', '${stockTake.stockTakeId}')"
                                            data-detail-id="${detail.stockTakeDetailId}">
                                        Lưu
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- Thống kê -->
            <div class="row mt-4">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <h6>Thống kê tiến độ</h6>
                        </div>
                        <div class="card-body">
                            <div class="row text-center">
                                <div class="col-md-3">
                                    <h4 id="totalItems" class="text-primary">${stockTakeDetails.size()}</h4>
                                    <p>Tổng sản phẩm</p>
                                </div>
                                <div class="col-md-3">
                                    <h4 id="countedItems" class="text-success">0</h4>
                                    <p>Đã kiểm</p>
                                </div>
                                <div class="col-md-3">
                                    <h4 id="remainingItems" class="text-warning">${stockTakeDetails.size()}</h4>
                                    <p>Còn lại</p>
                                </div>
                                <div class="col-md-3">
                                    <h4 id="progressPercentage" class="text-info">0%</h4>
                                    <p>Tiến độ</p>
                                </div>
                            </div>
                            <div class="progress mt-3">
                                <div id="progressBar" class="progress-bar" role="progressbar" style="width: 0%"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script>
// Cập nhật thống kê
function updateStatistics() {
    const inputs = document.querySelectorAll('.counted-input');
    const total = inputs.length;
    let counted = 0;
    
    inputs.forEach(input => {
        if (input.value !== null && input.value !== '') {
            counted++;
        }
    });
    
    const remaining = total - counted;
    const percentage = total > 0 ? Math.round((counted / total) * 100) : 0;
    
    document.getElementById('countedItems').textContent = counted;
    document.getElementById('remainingItems').textContent = remaining;
    document.getElementById('progressPercentage').textContent = percentage + '%';
    document.getElementById('progressBar').style.width = percentage + '%';
    
    // Update progress bar color based on percentage
    const progressBar = document.getElementById('progressBar');
    if (percentage === 100) {
        progressBar.className = 'progress-bar bg-success';
    } else if (percentage >= 50) {
        progressBar.className = 'progress-bar bg-warning';
    } else {
        progressBar.className = 'progress-bar bg-danger';
    }
}

// Cập nhật chênh lệch
function updateDiscrepancy(input) {
    try {
        const systemQty = parseInt(input.dataset.systemQty);
        const countedQty = input.value ? parseInt(input.value) : null;
        const discrepancyCell = input.closest('tr').querySelector('.discrepancy-cell');
        
        if (countedQty !== null && !isNaN(countedQty) && !isNaN(systemQty)) {
            const diff = countedQty - systemQty;
            const badgeClass = diff > 0 ? 'bg-success' : diff < 0 ? 'bg-danger' : 'bg-secondary';
            const sign = diff > 0 ? '+' : '';
            discrepancyCell.innerHTML = `<span class="badge ${badgeClass}">${sign}${diff}</span>`;
        } else {
            discrepancyCell.innerHTML = '';
        }
    } catch (error) {
        console.error('Error updating discrepancy:', error);
    }
}

// Lưu số lượng kiểm đếm
function saveCount(detailId, stockTakeId) {
    const input = document.querySelector(`input[data-detail-id="${detailId}"]`);
    const countedQuantity = input.value;
    
    // Validate input
    if (countedQuantity === '' || countedQuantity < 0) {
        alert('Vui lòng nhập số lượng hợp lệ!');
        return;
    }
    
    const formData = new FormData();
    formData.append('action', 'update-count');
    formData.append('detailId', detailId);
    formData.append('stockTakeId', stockTakeId);
    formData.append('countedQuantity', countedQuantity);
    
    // Disable button during request
    const button = document.querySelector(`button[data-detail-id="${detailId}"]`);
    button.disabled = true;
    button.textContent = 'Đang lưu...';
    
    fetch('${pageContext.request.contextPath}/stock-take', {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json(); // Changed from text() to json()
    })
    .then(result => {
        if (result.success) {
            // Update discrepancy immediately
            updateDiscrepancy(input);
            updateStatistics();
            
            // Update input's default value to mark as saved
            input.defaultValue = input.value;
            
            // Show success message
            showAlert(result.message, 'success');
            
            // If all completed, show additional info
            if (result.allCompleted) {
                showAlert('Kiểm kê đã hoàn thành! Vui lòng chờ admin duyệt.', 'info');
            }
        } else {
            showAlert(result.message || 'Có lỗi xảy ra khi lưu dữ liệu!', 'danger');
        }
        
        // Re-enable button
        button.disabled = false;
        button.textContent = 'Lưu';
    })
    .catch(error => {
        console.error('Error:', error);
        showAlert('Có lỗi xảy ra khi lưu dữ liệu!', 'danger');
        
        // Re-enable button
        button.disabled = false;
        button.textContent = 'Lưu';
    });
}

// Tìm kiếm sản phẩm
document.getElementById('searchProduct').addEventListener('input', function() {
    const searchTerm = this.value.toLowerCase();
    const rows = document.querySelectorAll('#stockTakeTable tbody tr');
    
    rows.forEach(row => {
        const productCode = row.dataset.productCode.toLowerCase();
        const productName = row.dataset.productName.toLowerCase();
        
        if (productCode.includes(searchTerm) || productName.includes(searchTerm)) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
});

// Lọc theo trạng thái
document.getElementById('filterStatus').addEventListener('change', function() {
    const filterValue = this.value;
    const rows = document.querySelectorAll('#stockTakeTable tbody tr');
    
    rows.forEach(row => {
        const input = row.querySelector('.counted-input');
        const discrepancyCell = row.querySelector('.discrepancy-cell');
        
        let show = true;
        
        if (filterValue === 'counted') {
            show = input.value !== '';
        } else if (filterValue === 'not-counted') {
            show = input.value === '';
        } else if (filterValue === 'discrepancy') {
            const badge = discrepancyCell.querySelector('.badge');
            show = badge && !badge.classList.contains('bg-secondary');
        }
        
        row.style.display = show ? '' : 'none';
    });
});

// Xử lý thay đổi input
document.querySelectorAll('.counted-input').forEach(input => {
    input.addEventListener('input', function() {
        updateDiscrepancy(this);
        updateStatistics();
    });
    
    // Cập nhật chênh lệch ban đầu cho các input đã có giá trị
    if (input.value !== '') {
        updateDiscrepancy(input);
    }
    
    // Store initial value for comparison
    input.defaultValue = input.value;
});

// Function to show alert messages
function showAlert(message, type) {
    // Remove existing alerts
    const existingAlerts = document.querySelectorAll('.alert-custom');
    existingAlerts.forEach(alert => alert.remove());
    
    // Create new alert
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show alert-custom`;
    alertDiv.role = 'alert';
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    // Insert alert at the top of the main content
    const mainContent = document.querySelector('main');
    mainContent.insertBefore(alertDiv, mainContent.firstChild);
    
    // Auto-dismiss after 3 seconds
    setTimeout(() => {
        if (alertDiv && alertDiv.parentElement) {
            alertDiv.remove();
        }
    }, 3000);
}

// Function to save all changes
function saveAllChanges() {
    const inputs = document.querySelectorAll('.counted-input');
    const changedInputs = Array.from(inputs).filter(input => 
        input.value !== '' && input.value !== input.defaultValue
    );
    
    if (changedInputs.length === 0) {
        showAlert('Không có thay đổi nào để lưu!', 'warning');
        return;
    }
    
    let savedCount = 0;
    let errorCount = 0;
    let totalItems = changedInputs.length;
    
    // Show progress
    showAlert(`Đang lưu ${totalItems} thay đổi...`, 'info');
    
    changedInputs.forEach((input, index) => {
        const detailId = input.dataset.detailId;
        const stockTakeId = '${stockTake.stockTakeId}';
        
        setTimeout(() => {
            const formData = new FormData();
            formData.append('action', 'update-count');
            formData.append('detailId', detailId);
            formData.append('stockTakeId', stockTakeId);
            formData.append('countedQuantity', input.value);
            
            fetch('${pageContext.request.contextPath}/stock-take', {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json(); // Changed from text() to json()
            })
            .then(result => {
                if (result.success) {
                    savedCount++;
                    updateDiscrepancy(input);
                    // Update input's default value to mark as saved
                    input.defaultValue = input.value;
                } else {
                    errorCount++;
                    console.error('Save failed for detail:', detailId, result.message);
                }
                
                // Check if all requests completed
                if (savedCount + errorCount === totalItems) {
                    updateStatistics();
                    if (errorCount === 0) {
                        showAlert(`Lưu thành công tất cả ${savedCount} thay đổi!`, 'success');
                    } else {
                        showAlert(`Lưu thành công ${savedCount} thay đổi, ${errorCount} lỗi!`, 'warning');
                    }
                }
            })
            .catch(error => {
                errorCount++;
                console.error('Error saving detail:', detailId, error);
                
                // Check if all requests completed
                if (savedCount + errorCount === totalItems) {
                    updateStatistics();
                    showAlert(`Lưu thành công ${savedCount} thay đổi, ${errorCount} lỗi!`, 'warning');
                }
            });
        }, index * 100); // Delay to avoid overwhelming the server
    });
}

// Cập nhật thống kê ban đầu
updateStatistics();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 