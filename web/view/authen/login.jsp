<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng nhập - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet">
  <style>
    body {
      font-family: 'JetBrains Mono', monospace;
      background-color: #f1f3f5;
    }
    .login-box {
      max-width: 400px;
      margin: 80px auto;
      padding: 30px;
      background: #fff;
      border-radius: 10px;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    .alert {
      margin-bottom: 20px;
    }
  </style>
</head>
<body>

<div class="login-box">
  <h3 class="text-center mb-4">📦 Đăng Nhập Hệ Thống</h3>

  <c:if test="${not empty sessionScope.errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
      ${sessionScope.errorMessage}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <c:remove var="errorMessage" scope="session"/>
  </c:if>

  <c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
      ${sessionScope.successMessage}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <c:remove var="successMessage" scope="session"/>
  </c:if>

  <form action="${pageContext.request.contextPath}/login" method="post">
    <div class="mb-3">
      <label class="form-label">Tên đăng nhập</label>
      <input type="text" name="username" class="form-control" placeholder="Nhập tên đăng nhập" required>
    </div>
    <div class="mb-3">
      <label class="form-label">Mật khẩu</label>
      <input type="password" name="password" class="form-control" placeholder="Nhập mật khẩu" required>
    </div>
    <button type="submit" class="btn btn-primary w-100">Đăng nhập</button>
    <div class="text-center mt-3">
      <a href="${pageContext.request.contextPath}/forgot-password" class="text-decoration-none">🔑 Quên mật khẩu?</a>
    </div>
<!--    <div class="text-center mt-2">
      <a href="${pageContext.request.contextPath}/register">Chưa có tài khoản? Đăng ký</a>
    </div>-->
  </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
