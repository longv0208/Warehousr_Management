<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quên Mật Khẩu - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet">
  <style>
    body {
      font-family: 'JetBrains Mono', monospace;
      background-color: #f1f3f5;
    }
    .forgot-password-box {
      max-width: 450px;
      margin: 80px auto;
      padding: 40px;
      background: #fff;
      border-radius: 15px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.1);
    }
    .step-indicator {
      display: flex;
      justify-content: center;
      margin-bottom: 30px;
    }
    .step {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 10px;
      font-weight: bold;
      color: white;
    }
    .step.active {
      background-color: #0d6efd;
    }
    .step.inactive {
      background-color: #dee2e6;
      color: #6c757d;
    }
    .step-line {
      width: 50px;
      height: 2px;
      background-color: #dee2e6;
      margin-top: 19px;
    }
    .icon-large {
      font-size: 3rem;
      color: #0d6efd;
      margin-bottom: 20px;
    }
  </style>
</head>
<body>

<div class="forgot-password-box">
  <!-- Step Indicator -->
  <div class="step-indicator">
    <div class="step active">1</div>
    <div class="step-line"></div>
    <div class="step inactive">2</div>
    <div class="step-line"></div>
    <div class="step inactive">3</div>
  </div>

  <div class="text-center">
    <div class="icon-large">🔑</div>
    <h3 class="mb-3">Quên Mật Khẩu</h3>
    <p class="text-muted mb-4">Nhập email của bạn để nhận mã xác thực</p>
  </div>
  
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
  
  <form action="${pageContext.request.contextPath}/forgot-password" method="post">
    <div class="mb-4">
      <label class="form-label">Email</label>
      <input type="email" name="email" class="form-control form-control-lg" 
             placeholder="Nhập địa chỉ email của bạn" required>
      <div class="form-text">Chúng tôi sẽ gửi mã xác thực đến email này</div>
    </div>
    
    <button type="submit" class="btn btn-primary btn-lg w-100 mb-3">
      📧 Gửi Mã Xác Thực
    </button>
    
    <div class="text-center">
      <a href="${pageContext.request.contextPath}/login" class="text-decoration-none">
        ← Quay lại đăng nhập
      </a>
    </div>
  </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
