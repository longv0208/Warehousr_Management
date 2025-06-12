<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Chỉnh Sửa Cài Đặt - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet" />
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
      <h3>Chỉnh Sửa Cài Đặt</h3>
      <form action="${pageContext.request.contextPath}/admin/manage-setting" method="POST">
        <input type="hidden" name="action" value="edit">
        <input type="hidden" name="settingId" value="${setting.id}">

        <div class="row mb-3">
          <div class="col-md-6">
            <label for="key" class="form-label">Khóa</label>
            <input type="text" class="form-control" id="key" name="key" value="${setting.key}" readonly style="background-color: #f8f9fa;">
            <small class="form-text text-muted">Khóa không thể thay đổi.</small>
          </div>
          <div class="col-md-6">
            <label for="value" class="form-label">Giá Trị</label>
            <input type="text" class="form-control" id="value" name="value" value="${setting.value}" required>
          </div>
        </div>

        <button type="submit" class="btn btn-success">Cập Nhật Cài Đặt</button>
        <a href="${pageContext.request.contextPath}/admin/manage-setting?action=list" class="btn btn-secondary">Hủy</a>
      </form>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 