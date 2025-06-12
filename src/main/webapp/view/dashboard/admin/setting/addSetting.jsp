<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Thêm Cài Đặt - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet" />
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
      <h3>Thêm Cài Đặt Mới</h3>
      <form action="${pageContext.request.contextPath}/admin/manage-setting" method="POST">
        <input type="hidden" name="action" value="add">

        <div class="row mb-3">
          <div class="col-md-6">
            <label for="key" class="form-label">Khóa <span class="text-danger">*</span></label>
            <input type="text" class="form-control" id="key" name="key" placeholder="Nhập khóa cài đặt" required>
            <small class="form-text text-muted">Khóa phải là duy nhất trong hệ thống.</small>
          </div>
          <div class="col-md-6">
            <label for="value" class="form-label">Giá Trị</label>
            <input type="text" class="form-control" id="value" name="value" placeholder="Nhập giá trị cài đặt">
            <small class="form-text text-muted">Có thể để trống nếu cần.</small>
          </div>
        </div>

        <button type="submit" class="btn btn-success">Thêm Cài Đặt</button>
        <a href="${pageContext.request.contextPath}/admin/manage-setting?action=list" class="btn btn-secondary">Hủy</a>
      </form>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>
<script>
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
        // Remove toast attributes from the session after displaying
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