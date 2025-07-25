<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cảm ơn phản hồi - Hệ thống quản lý kho hàng</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .success-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .success-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
            max-width: 600px;
            width: 100%;
        }
        .success-header {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .success-header.rejected {
            background: linear-gradient(135deg, #dc3545, #fd7e14);
        }
        .success-icon {
            font-size: 4rem;
            margin-bottom: 20px;
            animation: bounceIn 1s;
        }
        .success-title {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .success-subtitle {
            font-size: 1.1rem;
            opacity: 0.9;
        }
        .success-body {
            padding: 40px 30px;
        }
        .quotation-info {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            padding: 5px 0;
            border-bottom: 1px dotted #dee2e6;
        }
        .info-row:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }
        .info-label {
            font-weight: 600;
            color: #495057;
        }
        .info-value {
            color: #28a745;
            font-weight: 500;
        }
        .next-steps {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 20px;
            margin: 20px 0;
            border-radius: 0 5px 5px 0;
        }
        .next-steps.rejected {
            background: #ffebee;
            border-left-color: #f44336;
        }
        .contact-info {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-top: 30px;
            text-align: center;
        }
        @keyframes bounceIn {
            0% { transform: scale(0.3); opacity: 0; }
            50% { transform: scale(1.05); }
            70% { transform: scale(0.9); }
            100% { transform: scale(1); opacity: 1; }
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
    <div class="success-container">
        <div class="success-card fade-in">
            <div class="success-header ${action == 'reject' ? 'rejected' : ''}">
                <div class="success-icon">
                    <c:choose>
                        <c:when test="${action == 'confirm'}">
                            <i class="fas fa-check-circle"></i>
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-info-circle"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="success-title">
                    <c:choose>
                        <c:when test="${action == 'confirm'}">
                            Cảm ơn Quý khách!
                        </c:when>
                        <c:otherwise>
                            Đã ghi nhận phản hồi
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="success-subtitle">
                    <c:choose>
                        <c:when test="${action == 'confirm'}">
                            Báo giá đã được xác nhận thành công
                        </c:when>
                        <c:otherwise>
                            Chúng tôi đã nhận được phản hồi của Quý khách
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="success-body">
                <div class="quotation-info">
                    <h5><i class="fas fa-file-alt text-primary"></i> Thông tin báo giá</h5>
                    <div class="info-row">
                        <span class="info-label">Mã báo giá:</span>
                        <span class="info-value">${quotation.quotationCode}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Khách hàng:</span>
                        <span class="info-value">${quotation.customerName}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Ngày báo giá:</span>
                        <span class="info-value">
                            <fmt:formatDate value="${quotation.quotationDate}" pattern="dd/MM/yyyy"/>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Trạng thái:</span>
                        <span class="info-value">
                            <c:choose>
                                <c:when test="${quotation.status == 'approved'}">
                                    <span class="badge bg-success">Đã chấp nhận</span>
                                </c:when>
                                <c:when test="${quotation.status == 'rejected'}">
                                    <span class="badge bg-danger">Đã từ chối</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">${quotation.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <c:choose>
                    <c:when test="${action == 'confirm'}">
                        <div class="next-steps">
                            <h6><i class="fas fa-list-check text-primary"></i> Các bước tiếp theo:</h6>
                            <ul class="mb-0">
                                <li>Nhân viên kinh doanh sẽ liên hệ với Quý khách trong vòng 24h</li>
                                <li>Xác nhận chi tiết đơn hàng và thời gian giao hàng</li>
                                <li>Thỏa thuận về phương thức thanh toán</li>
                                <li>Tiến hành xử lý và giao hàng</li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="next-steps rejected">
                            <h6><i class="fas fa-heart text-danger"></i> Ghi nhận của chúng tôi:</h6>
                            <p class="mb-0">
                                Chúng tôi rất tiếc vì chưa đáp ứng được kỳ vọng của Quý khách. 
                                Phản hồi của Quý khách là động lực để chúng tôi cải thiện sản phẩm 
                                và dịch vụ tốt hơn. Chúng tôi hy vọng có cơ hội phục vụ Quý khách 
                                trong tương lai.
                            </p>
                        </div>
                    </c:otherwise>
                </c:choose>

                <div class="contact-info">
                    <h6><i class="fas fa-phone-alt text-success"></i> Thông tin liên hệ</h6>
                    <p class="mb-2">
                        <strong>Hệ Thống Quản Lý Kho Hàng</strong>
                    </p>
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
                        <i class="fas fa-globe"></i> 
                        <a href="http://www.company.com" class="text-decoration-none" target="_blank">
                            www.company.com
                        </a>
                    </p>
                </div>

                <div class="text-center mt-4">
                    <p class="text-muted">
                        <i class="fas fa-clock"></i> 
                        Phản hồi được ghi nhận lúc: 
                        <strong><fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy HH:mm"/></strong>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto close after 30 seconds (optional)
        setTimeout(function() {
            if (confirm('Cửa sổ này sẽ tự động đóng. Bạn có muốn giữ lại không?')) {
                // User wants to keep the window open
                return;
            } else {
                window.close();
            }
        }, 30000);
    </script>
</body>
</html>
