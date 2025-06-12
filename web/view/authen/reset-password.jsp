<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đặt Lại Mật Khẩu - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet">
  <style>
    body {
      font-family: 'JetBrains Mono', monospace;
      background-color: #f1f3f5;
    }
    .reset-password-box {
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
    .step.completed {
      background-color: #198754;
    }
    .step-line {
      width: 50px;
      height: 2px;
      background-color: #198754;
      margin-top: 19px;
    }
    .icon-large {
      font-size: 3rem;
      color: #198754;
      margin-bottom: 20px;
    }
    .password-strength {
      height: 5px;
      border-radius: 3px;
      margin-top: 5px;
      transition: all 0.3s ease;
    }
    .strength-weak { background-color: #dc3545; }
    .strength-medium { background-color: #ffc107; }
    .strength-strong { background-color: #198754; }
  </style>
</head>
<body>

<div class="reset-password-box">
  <!-- Step Indicator -->
  <div class="step-indicator">
    <div class="step completed">✓</div>
    <div class="step-line"></div>
    <div class="step completed">✓</div>
    <div class="step-line"></div>
    <div class="step active">3</div>
  </div>

  <div class="text-center">
    <div class="icon-large">🔐</div>
    <h3 class="mb-3">Đặt Lại Mật Khẩu</h3>
    <p class="text-muted mb-4">Tạo mật khẩu mới cho tài khoản của bạn</p>
  </div>
  
  <c:if test="${not empty sessionScope.errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
      ${sessionScope.errorMessage}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <c:remove var="errorMessage" scope="session"/>
  </c:if>
  
  <form action="${pageContext.request.contextPath}/reset-password" method="post" id="resetForm">
    <div class="mb-3">
      <label class="form-label">Mật khẩu mới</label>
      <input type="password" name="newPassword" id="newPassword" class="form-control form-control-lg" 
             placeholder="Nhập mật khẩu mới" required minlength="6">
      <div class="password-strength" id="strengthBar"></div>
      <div class="form-text" id="strengthText">Mật khẩu phải có ít nhất 6 ký tự</div>
    </div>
    
    <div class="mb-4">
      <label class="form-label">Xác nhận mật khẩu</label>
      <input type="password" name="confirmPassword" id="confirmPassword" class="form-control form-control-lg" 
             placeholder="Nhập lại mật khẩu mới" required>
      <div class="form-text" id="matchText"></div>
    </div>
    
    <button type="submit" class="btn btn-success btn-lg w-100 mb-3" id="submitBtn" disabled>
      🔐 Đặt Lại Mật Khẩu
    </button>
    
    <div class="text-center">
      <a href="${pageContext.request.contextPath}/login" class="text-decoration-none">
        ← Quay lại đăng nhập
      </a>
    </div>
  </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const newPasswordInput = document.getElementById('newPassword');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const strengthBar = document.getElementById('strengthBar');
    const strengthText = document.getElementById('strengthText');
    const matchText = document.getElementById('matchText');
    const submitBtn = document.getElementById('submitBtn');
    
    function checkPasswordStrength(password) {
        let strength = 0;
        let text = '';
        
        if (password.length >= 6) strength++;
        if (password.match(/[a-z]/)) strength++;
        if (password.match(/[A-Z]/)) strength++;
        if (password.match(/[0-9]/)) strength++;
        if (password.match(/[^a-zA-Z0-9]/)) strength++;
        
        strengthBar.style.width = (strength * 20) + '%';
        
        if (strength < 2) {
            strengthBar.className = 'password-strength strength-weak';
            text = 'Mật khẩu yếu';
        } else if (strength < 4) {
            strengthBar.className = 'password-strength strength-medium';
            text = 'Mật khẩu trung bình';
        } else {
            strengthBar.className = 'password-strength strength-strong';
            text = 'Mật khẩu mạnh';
        }
        
        strengthText.textContent = text;
        return strength >= 2;
    }
    
    function checkPasswordMatch() {
        const password = newPasswordInput.value;
        const confirmPassword = confirmPasswordInput.value;
        
        if (confirmPassword === '') {
            matchText.textContent = '';
            return false;
        }
        
        if (password === confirmPassword) {
            matchText.textContent = '✅ Mật khẩu khớp';
            matchText.style.color = '#198754';
            return true;
        } else {
            matchText.textContent = '❌ Mật khẩu không khớp';
            matchText.style.color = '#dc3545';
            return false;
        }
    }
    
    function updateSubmitButton() {
        const isStrong = checkPasswordStrength(newPasswordInput.value);
        const isMatch = checkPasswordMatch();
        
        if (isStrong && isMatch && newPasswordInput.value.length >= 6) {
            submitBtn.disabled = false;
            submitBtn.classList.remove('btn-secondary');
            submitBtn.classList.add('btn-success');
        } else {
            submitBtn.disabled = true;
            submitBtn.classList.remove('btn-success');
            submitBtn.classList.add('btn-secondary');
        }
    }
    
    newPasswordInput.addEventListener('input', updateSubmitButton);
    confirmPasswordInput.addEventListener('input', updateSubmitButton);
});
</script>
</body>
</html>
