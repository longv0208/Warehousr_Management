<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Nhập Dữ Liệu Sản Phẩm - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Nhập Dữ Liệu Sản Phẩm từ CSV</h3>
        <a href="${pageContext.request.contextPath}/admin/manage-product?action=list" class="btn btn-secondary">⬅ Quay lại</a>
      </div>

      <!-- Instructions Card -->
      <div class="card mb-4">
        <div class="card-header bg-info text-white">
          <h5 class="mb-0">📋 Hướng dẫn định dạng file CSV</h5>
        </div>
        <div class="card-body">
          <p class="mb-3">File CSV cần có cấu trúc như sau (dòng đầu tiên là tiêu đề):</p>
          <div class="table-responsive">
            <table class="table table-bordered table-sm">
              <thead class="table-light">
                <tr>
                  <th>Cột A</th>
                  <th>Cột B</th>
                  <th>Cột C</th>
                  <th>Cột D</th>
                  <th>Cột E</th>
                  <th>Cột F</th>
                  <th>Cột G</th>
                  <th>Cột H</th>
                  <th>Cột I</th>
                  <th>Cột J</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Mã SP</td>
                  <td>Tên SP</td>
                  <td>Mô tả</td>
                  <td>Đơn vị</td>
                  <td>Số lượng</td>
                  <td>Giá mua</td>
                  <td>Giá bán</td>
                  <td>Ngưỡng tồn kho</td>
                  <td>Trạng thái</td>
                  <td>Nhà cung cấp</td>
                </tr>
                <tr class="table-warning">
                  <td>SP001</td>
                  <td>Áo thun nam</td>
                  <td>Áo thun cotton 100%</td>
                  <td>Cái</td>
                  <td>100</td>
                  <td>50000</td>
                  <td>75000</td>
                  <td>20</td>
                  <td>Hoạt động</td>
                  <td>Nhà cung cấp ABC</td>
                </tr>
              </tbody>
            </table>
          </div>
          
          <div class="row mt-3">
            <div class="col-md-6">
              <h6 class="text-success">✅ Lưu ý quan trọng:</h6>
              <ul class="small">
                <li>File phải có định dạng .csv</li>
                <li>Dòng đầu tiên là tiêu đề (sẽ bị bỏ qua)</li>
                <li>Sử dụng dấu phẩy (,) để phân cách các cột</li>
                <li>Trạng thái: "Hoạt động" hoặc "Không hoạt động"</li>
                <li>Tên nhà cung cấp phải khớp chính xác với dữ liệu trong hệ thống</li>
                <li>Số lượng, giá mua, giá bán phải là số</li>
                <li>Ngưỡng tồn kho tối thiểu là 10</li>
              </ul>
            </div>
            <div class="col-md-6">
              <h6 class="text-primary">📋 Danh sách nhà cung cấp hiện có:</h6>
              <div class="small" style="max-height: 150px; overflow-y: auto;">
                <c:forEach var="supplier" items="${suppliers}">
                  <span class="badge bg-light text-dark me-1 mb-1">${supplier.supplierName}</span>
                </c:forEach>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Upload Form -->
      <div class="card">
        <div class="card-header">
          <h5 class="mb-0">📁 Chọn file CSV để nhập</h5>
        </div>
        <div class="card-body">
          <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" enctype="multipart/form-data" onsubmit="return validateForm()">
            <input type="hidden" name="action" value="import">
            
            <div class="mb-3">
              <label for="csvFile" class="form-label">File CSV (.csv)</label>
              <input type="file" class="form-control" id="csvFile" name="csvFile" accept=".csv" required>
              <div class="form-text">Chỉ chấp nhận file CSV (.csv)</div>
            </div>
            
            <div class="d-flex gap-2">
              <button type="submit" class="btn btn-primary" id="submitBtn">
                <span class="spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
                📤 Nhập dữ liệu
              </button>
              <a href="${pageContext.request.contextPath}/admin/manage-product?action=export" class="btn btn-outline-success">
                📊 Tải mẫu CSV
              </a>
            </div>
          </form>
        </div>
      </div>

      <!-- Recent Import History (if available) -->
<!--      <div class="card mt-4">
        <div class="card-header">
          <h6 class="mb-0">📈 Thống kê sản phẩm hiện tại</h6>
        </div>
        <div class="card-body">
          <div class="row text-center">
            <div class="col-md-3">
              <div class="border rounded p-3">
                <h5 class="text-primary">Tổng sản phẩm</h5>
                <h3 class="text-primary">-</h3>
              </div>
            </div>
            <div class="col-md-3">
              <div class="border rounded p-3">
                <h5 class="text-success">Đang hoạt động</h5>
                <h3 class="text-success">-</h3>
              </div>
            </div>
            <div class="col-md-3">
              <div class="border rounded p-3">
                <h5 class="text-warning">Tồn kho thấp</h5>
                <h3 class="text-warning">-</h3>
              </div>
            </div>
            <div class="col-md-3">
              <div class="border rounded p-3">
                <h5 class="text-info">Nhà cung cấp</h5>
                <h3 class="text-info">${suppliers.size()}</h3>
              </div>
            </div>
          </div>
        </div>
      </div>-->
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>
<script>
  function validateForm() {
    const fileInput = document.getElementById('csvFile');
    const file = fileInput.files[0];
    
    if (!file) {
      iziToast.error({
        title: 'Lỗi',
        message: 'Vui lòng chọn file CSV để nhập.',
        position: 'topRight'
      });
      return false;
    }
    
    const allowedTypes = [
      'text/csv',
      'application/csv'
    ];
    
    if (!allowedTypes.includes(file.type) && !file.name.toLowerCase().endsWith('.csv')) {
      iziToast.error({
        title: 'Lỗi',
        message: 'Chỉ chấp nhận file CSV (.csv).',
        position: 'topRight'
      });
      return false;
    }
    
    // Show loading
    const submitBtn = document.getElementById('submitBtn');
    const spinner = submitBtn.querySelector('.spinner-border');
    submitBtn.disabled = true;
    spinner.classList.remove('d-none');
    submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Đang xử lý...';
    
    return true;
  }
  
  // Toast message display
  document.addEventListener("DOMContentLoaded", function () {
    var toastMessage = "${sessionScope.toastMessage}";
    var toastType = "${sessionScope.toastType}";
    if (toastMessage) {
        iziToast.show({
            title: toastType === 'success' ? 'Thành công' : (toastType === 'warning' ? 'Cảnh báo' : 'Lỗi'),
            message: toastMessage,
            position: 'topRight',
            color: toastType === 'success' ? 'green' : (toastType === 'warning' ? 'yellow' : 'red'),
            timeout: 8000,
            onClosing: function () {
                // Remove toast attributes from the session after displaying
                fetch('<c:out value="${pageContext.request.contextPath}"/>/remove-toast', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                }).then(response => {
                    if (!response.ok) {
                        console.error('Failed to remove toast attributes');
                    }
                }).catch(error => {
                    console.error('Error:', error);
                });
            }
        });
    }
  });
</script>
</body>
</html> 