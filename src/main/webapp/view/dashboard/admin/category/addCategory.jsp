<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Thêm Danh Mục Mới</title>
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
        <h3>Thêm Danh Mục Mới</h3>
        <div>
          <a href="${pageContext.request.contextPath}/admin/manage-category?action=list" class="btn btn-secondary">← Quay lại</a>
        </div>
      </div>

      <div class="row justify-content-center">
        <div class="col-md-8">
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Thông tin danh mục</h5>
            </div>
            <div class="card-body">
              <form action="${pageContext.request.contextPath}/admin/manage-category" method="POST" id="categoryForm">
                <input type="hidden" name="action" value="create">
                
                <div class="mb-3">
                  <label for="categoryName" class="form-label">Tên danh mục <span class="text-danger">*</span></label>
                  <input type="text" class="form-control" id="categoryName" name="categoryName" 
                         placeholder="Nhập tên danh mục..." maxlength="45" required>
                  <div class="form-text">Tối đa 45 ký tự.</div>
                </div>

                <div class="d-flex justify-content-end gap-2">
                  <a href="${pageContext.request.contextPath}/admin/manage-category?action=list" class="btn btn-secondary">Hủy</a>
                  <button type="submit" class="btn btn-success">Thêm danh mục</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

<script>
  // Form validation
  document.getElementById('categoryForm').addEventListener('submit', function(e) {
    const categoryName = document.getElementById('categoryName').value.trim();
    
    if (!categoryName) {
      e.preventDefault();
      iziToast.error({
        title: 'Lỗi',
        message: 'Tên danh mục không được để trống',
        position: 'topRight'
      });
      return false;
    }
    
    if (categoryName.length > 45) {
      e.preventDefault();
      iziToast.error({
        title: 'Lỗi',
        message: 'Tên danh mục không được quá 45 ký tự',
        position: 'topRight'
      });
      return false;
    }
  });

  // Character count
  document.getElementById('categoryName').addEventListener('input', function() {
    const maxLength = 45;
    const currentLength = this.value.length;
    const formText = this.nextElementSibling;
    formText.textContent = `${currentLength}/${maxLength} ký tự.`;
    
    if (currentLength > maxLength) {
      formText.className = 'form-text text-danger';
    } else {
      formText.className = 'form-text';
    }
  });

  // Toast message display
  var toastMessage = "${sessionScope.toastMessage}";
  var toastType = "${sessionScope.toastType}";
  if (toastMessage) {
    iziToast.show({
      title: toastType === 'success' ? 'Thành công' : 'Lỗi',
      message: toastMessage,
      position: 'topRight',
      color: toastType === 'success' ? 'green' : 'red',
      timeout: 5000,
      onClosing: function () {
        fetch('${pageContext.request.contextPath}/remove-toast', {
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
</script>
</body>
</html> 