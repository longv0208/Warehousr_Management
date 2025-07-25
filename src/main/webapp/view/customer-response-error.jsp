<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lỗi xử lý báo giá - Hệ thống quản lý kho hàng</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 50%, #fecfef 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .error-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .error-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
            max-width: 500px;
            width: 100%;
        }
        .error-header {
            background: linear-gradient(135deg, #dc3545, #c82333);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .error-icon {
            font-size: 4rem;
            margin-bottom: 20px;
            animation: shake 1s;
        }
        .error-title {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .error-subtitle {
            font-size: 1.1rem;
            opacity: 0.9;
        }
        .error-body {
            padding: 40px 30px;
            text-align: center;
        }
        .error-message {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .contact-info {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-top: 30px;
        }
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
            20%, 40%, 60%, 80% { transform: translateX(5px); }
        }
        .fade-in {
            animation: fadeIn 1s ease-in;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-card fade-in">
            <div class="error-header">
                <div class="error-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <div class="error-title">Có lỗi xảy ra</div>
                <div class="error-subtitle">Không thể xử lý yêu cầu của Quý khách</div>
            </div>

            <div class="error-body">
                <c:if test="${not empty error}">
                    <div class="error-message">
                        <i class="fas fa-info-circle"></i>
                        ${error}
                    </div>
                </c:if>

                <c:if test="${empty error}">
                    <div class="error-message">
                        <i class="fas fa-info-circle"></i>
                        Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.
                    </div>
                </c:if>

                <c:if test="${not empty quotation}">
                    <div class="alert alert-info">
                        <strong>Thông tin báo giá:</strong><br>
                        Mã: ${quotation.quotationCode}<br>
                        Khách hàng: ${quotation.customerName}
                    </div>
                </c:if>

                <div class="contact-info">
                    <h6><i class="fas fa-headset text-primary"></i> Cần hỗ trợ?</h6>
                    <p class="mb-2">Vui lòng liên hệ với chúng tôi để được hỗ trợ:</p>
                    <p class="mb-1">
                        <i class="fas fa-envelope"></i> 
                        <a href="mailto:he-thong-quan-ly-kho@company.com" class="text-decoration-none">
                            he-thong-quan-ly-kho@company.com
                        </a>
                    </p>
                    <p class="mb-1">
                        <i class="fas fa-phone"></i> 
                        <a href="tel:1900xxxx" class="text-decoration-none">1900-xxxx</a>
                    </p>
                    <p class="mb-0">
                        <i class="fas fa-clock"></i> 
                        Thời gian hỗ trợ: 8:00 - 17:00 (Thứ 2 - Thứ 6)
                    </p>
                </div>

                <div class="mt-4">
                    <button onclick="window.close()" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Đóng cửa sổ
                    </button>
                    <button onclick="window.history.back()" class="btn btn-primary">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
