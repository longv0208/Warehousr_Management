<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Giá Thành Công</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .success-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            padding: 50px;
            text-align: center;
            max-width: 600px;
            width: 90%;
        }
        
        .success-icon {
            color: #28a745;
            font-size: 5rem;
            margin-bottom: 30px;
            animation: bounce 2s infinite;
        }
        
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% {
                transform: translateY(0);
            }
            40% {
                transform: translateY(-10px);
            }
            60% {
                transform: translateY(-5px);
            }
        }
        
        .success-title {
            color: #28a745;
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 20px;
        }
        
        .success-message {
            color: #6c757d;
            font-size: 1.2rem;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        
        .info-box {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            border-left: 4px solid #28a745;
            text-align: left;
        }
        
        .info-box h5 {
            color: #28a745;
            margin-bottom: 15px;
        }
        
        .info-box p {
            margin-bottom: 5px;
            color: #495057;
        }
        
        .close-button {
            background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
            border: none;
            color: white;
            padding: 12px 30px;
            font-size: 16px;
            font-weight: bold;
            border-radius: 25px;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .close-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(108,117,125,0.3);
        }
        
        .countdown {
            color: #dc3545;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="success-container">
        <div class="success-icon">
            <i class="fas fa-check-circle"></i>
        </div>
        
        <h1 class="success-title">BÁO GIÁ THÀNH CÔNG!</h1>
        
        <p class="success-message">
            Cảm ơn bạn đã gửi báo giá. Thông tin báo giá của bạn đã được ghi nhận thành công vào hệ thống.
        </p>
        
        <div class="info-box">
            <h5><i class="fas fa-info-circle"></i> Thông Tin Tiếp Theo</h5>
            <p><strong><i class="fas fa-envelope"></i> Thông báo:</strong> Chúng tôi sẽ liên hệ với bạn trong thời gian sớm nhất để xác nhận đơn hàng.</p>
            <p><strong><i class="fas fa-clock"></i> Thời gian xử lý:</strong> Trong vòng 1-2 ngày làm việc.</p>
            <p><strong><i class="fas fa-phone"></i> Hỗ trợ:</strong> Nếu có thắc mắc, vui lòng liên hệ hotline: 1900-xxxx</p>
        </div>
        
        <p class="text-muted mb-4">
            <small>Trang này sẽ tự động đóng sau <span class="countdown" id="countdown">10</span> giây.</small>
        </p>
        
        <button type="button" class="close-button" onclick="window.close()">
            <i class="fas fa-times"></i> Đóng Trang
        </button>
    </div>
    
    <script>
        // Countdown timer
        let countdown = 10;
        const countdownElement = document.getElementById('countdown');
        
        const timer = setInterval(() => {
            countdown--;
            countdownElement.textContent = countdown;
            
            if (countdown <= 0) {
                clearInterval(timer);
                window.close();
            }
        }, 1000);
        
        // Allow user to stop countdown by clicking anywhere
        document.addEventListener('click', () => {
            clearInterval(timer);
            countdownElement.textContent = '∞';
            document.querySelector('.text-muted').innerHTML = '<small>Countdown đã dừng. Bạn có thể đóng trang bất cứ lúc nào.</small>';
        });
    </script>
</body>
</html>
