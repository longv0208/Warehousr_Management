<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Xác Thực OTP - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet">
  <style>
    body {
      font-family: 'JetBrains Mono', monospace;
      background-color: #f1f3f5;
    }
    .verify-otp-box {
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
    .step-line.completed {
      background-color: #198754;
    }
    .icon-large {
      font-size: 3rem;
      color: #0d6efd;
      margin-bottom: 20px;
    }
    .otp-input {
      width: 60px;
      height: 60px;
      text-align: center;
      font-size: 1.5rem;
      font-weight: bold;
      margin: 0 5px;
      border: 2px solid #dee2e6;
      border-radius: 10px;
    }
    .otp-input:focus {
      border-color: #0d6efd;
      box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
    }
    .countdown {
      font-weight: bold;
      color: #dc3545;
    }
  </style>
</head>
<body>

<div class="verify-otp-box">
  <!-- Step Indicator -->
  <div class="step-indicator">
    <div class="step completed">✓</div>
    <div class="step-line completed"></div>
    <div class="step active">2</div>
    <div class="step-line"></div>
    <div class="step inactive">3</div>
  </div>

  <div class="text-center">
    <div class="icon-large">📱</div>
    <h3 class="mb-3">Xác Thực OTP</h3>
    <p class="text-muted mb-4">
      Chúng tôi đã gửi mã xác thực đến email: <br>
      <strong>${sessionScope.resetEmail}</strong>
    </p>
  </div>
  
  <c:if test="${not empty sessionScope.errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
      ${sessionScope.errorMessage}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <c:remove var="errorMessage" scope="session"/>
  </c:if>
  
  <form action="${pageContext.request.contextPath}/verify-otp" method="post">
    <div class="mb-4">
      <label class="form-label text-center d-block">Nhập mã OTP (6 chữ số)</label>
      <div class="d-flex justify-content-center mb-3">
        <input type="text" class="otp-input" maxlength="1" name="otp1" required>
        <input type="text" class="otp-input" maxlength="1" name="otp2" required>
        <input type="text" class="otp-input" maxlength="1" name="otp3" required>
        <input type="text" class="otp-input" maxlength="1" name="otp4" required>
        <input type="text" class="otp-input" maxlength="1" name="otp5" required>
        <input type="text" class="otp-input" maxlength="1" name="otp6" required>
      </div>
      <input type="hidden" name="otpCode" id="otpCode">
    </div>
    
    <button type="submit" class="btn btn-primary btn-lg w-100 mb-3">
      ✅ Xác Thực
    </button>
    
    <div class="text-center">
      <p class="mb-2">Mã sẽ hết hạn sau: <span class="countdown" id="countdown">05:00</span></p>
      <a href="${pageContext.request.contextPath}/forgot-password" class="text-decoration-none">
        ? Gửi lại mã
      </a>
      <br>
      <a href="${pageContext.request.contextPath}/login" class="text-decoration-none mt-2 d-inline-block">
        ← Quay lại đăng nhập
      </a>
    </div>
  </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const otpInputs = document.querySelectorAll('.otp-input');
    const otpCodeInput = document.getElementById('otpCode');
    
    otpInputs.forEach((input, index) => {
        input.addEventListener('input', function(e) {
            if (e.target.value.length === 1) {
                if (index < otpInputs.length - 1) {
                    otpInputs[index + 1].focus();
                }
            }
            updateOtpCode();
        });
        
        input.addEventListener('keydown', function(e) {
            if (e.key === 'Backspace' && e.target.value === '') {
                if (index > 0) {
                    otpInputs[index - 1].focus();
                }
            }
        });
    });
    
    function updateOtpCode() {
        let otp = '';
        otpInputs.forEach(input => {
            otp += input.value;
        });
        otpCodeInput.value = otp;
    }
    
    let timeLeft = 300; 
    const countdownElement = document.getElementById('countdown');
    
    const timer = setInterval(function() {
        const minutes = Math.floor(timeLeft / 60);
        const seconds = timeLeft % 60;
        countdownElement.textContent = 
            String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
        
        if (timeLeft <= 0) {
            clearInterval(timer);
            countdownElement.textContent = 'Hết hạn';
            countdownElement.style.color = '#dc3545';
        }
        timeLeft--;
    }, 1000);
});
</script>
</body>
</html>
