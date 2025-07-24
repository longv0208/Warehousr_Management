<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Giá - ${rfq.rfqCode}</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
        }
        
        .quote-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            margin: 30px auto;
            max-width: 1200px;
            overflow: hidden;
        }
        
        .quote-header {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .quote-header h1 {
            margin: 0;
            font-size: 2.5rem;
            font-weight: bold;
        }
        
        .quote-info {
            background: #f8f9fa;
            padding: 20px;
            border-bottom: 1px solid #dee2e6;
        }
        
        .info-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 4px solid #28a745;
        }
        
        .products-table {
            margin: 0;
        }
        
        .products-table th {
            background: #28a745;
            color: white;
            border: none;
            padding: 15px;
            font-weight: bold;
        }
        
        .products-table td {
            padding: 15px;
            vertical-align: middle;
            border-bottom: 1px solid #dee2e6;
        }
        
        .price-input {
            border: 2px solid #28a745;
            border-radius: 8px;
            padding: 10px;
            font-size: 16px;
            font-weight: bold;
            text-align: right;
            width: 100%;
        }
        
        .price-input:focus {
            outline: none;
            border-color: #20c997;
            box-shadow: 0 0 0 3px rgba(40,167,69,0.1);
        }
        
        .submit-section {
            padding: 30px;
            text-align: center;
            background: #f8f9fa;
        }
        
        .submit-btn {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            border: none;
            color: white;
            padding: 15px 40px;
            font-size: 18px;
            font-weight: bold;
            border-radius: 25px;
            transition: all 0.3s ease;
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(40,167,69,0.3);
        }
        
        .alert {
            border-radius: 10px;
            margin: 20px;
        }
        
        .company-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .company-info div {
            flex: 1;
            min-width: 200px;
        }
        
        .label {
            font-weight: bold;
            color: #495057;
            display: inline-block;
            min-width: 120px;
        }
        
        .value {
            color: #212529;
        }
        
        .total-display {
            background: #e8f5e8;
            padding: 10px;
            border-radius: 5px;
            font-weight: bold;
            color: #28a745;
            text-align: right;
        }
        
        @media (max-width: 768px) {
            .quote-container {
                margin: 15px;
            }
            
            .company-info {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .products-table {
                font-size: 14px;
            }
            
            .quote-header h1 {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <div class="quote-container">
        <!-- Header -->
        <div class="quote-header">
            <h1><i class="fas fa-file-invoice-dollar"></i> BÁO GIÁ</h1>
            <h2>${rfq.rfqCode}</h2>
            <p class="mb-0">Hệ Thống Quản Lý Kho Hàng</p>
        </div>
        
        <!-- Alerts -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i> ${successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle"></i> ${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <!-- RFQ Information -->
        <div class="quote-info">
            <div class="info-card">
                <h4><i class="fas fa-info-circle text-primary"></i> Thông Tin Yêu Cầu Báo Giá</h4>
                <div class="company-info">
                    <div>
                        <span class="label">Mã YCB:</span>
                        <span class="value text-primary fw-bold">${rfq.rfqCode}</span>
                    </div>
                    <div>
                        <span class="label">Ngày tạo:</span>
                        <span class="value"><fmt:formatDate value="${rfq.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                    </div>
                    <div>
                        <span class="label">Ngày giao hàng:</span>
                        <span class="value text-danger fw-bold"><fmt:formatDate value="${rfq.expectedDeliveryDate}" pattern="dd/MM/yyyy"/></span>
                    </div>
                </div>
            </div>
            
            <div class="info-card">
                <h4><i class="fas fa-building text-success"></i> Thông Tin Nhà Cung Cấp</h4>
                <div class="company-info">
                    <div>
                        <span class="label">Tên công ty:</span>
                        <span class="value fw-bold">${supplier.supplierName}</span>
                    </div>
                    <div>
                        <span class="label">Người liên hệ:</span>
                        <span class="value">${supplier.contactPerson}</span>
                    </div>
                    <div>
                        <span class="label">Email:</span>
                        <span class="value">${supplier.email}</span>
                    </div>
                    <div>
                        <span class="label">Điện thoại:</span>
                        <span class="value">${supplier.phoneNumber}</span>
                    </div>
                </div>
            </div>
            
            <c:if test="${not empty rfq.note}">
                <div class="info-card">
                    <h4><i class="fas fa-sticky-note text-warning"></i> Ghi Chú</h4>
                    <p class="mb-0">${rfq.note}</p>
                </div>
            </c:if>
        </div>
        
        <!-- Products Form -->
        <form method="post" action="supplier-quote" id="quoteForm">
            <input type="hidden" name="rfqId" value="${rfq.rfqId}">
            <input type="hidden" name="supplierId" value="${supplier.supplierId}">
            
            <div class="table-responsive">
                <table class="table products-table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">STT</th>
                            <th>Mã Sản Phẩm</th>
                            <th>Tên Sản Phẩm</th>
                            <th>Đơn Vị</th>
                            <th style="width: 100px;">Số Lượng</th>
                            <th style="width: 200px;">Đơn Giá (VND)</th>
                            <th style="width: 200px;">Thành Tiền (VND)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="detail" items="${rfqDetails}" varStatus="status">
                            <c:set var="product" value="${products[status.index]}" />
                            <tr>
                                <td class="text-center fw-bold">${status.index + 1}</td>
                                <td class="fw-bold">${product.productCode}</td>
                                <td>${product.productName}</td>
                                <td>${product.unit}</td>
                                <td class="text-center fw-bold">${detail.quantity}</td>
                                <td>
                                    <input type="number" 
                                           name="price_${detail.rfqDetailId}" 
                                           class="price-input" 
                                           placeholder="Nhập đơn giá..."
                                           value="${detail.price != null ? detail.price : ''}"
                                           step="0.01" 
                                           min="0"
                                           onchange="calculateTotal(${status.index}, '${detail.quantity}')"
                                           required>
                                </td>
                                <td>
                                    <div class="total-display" id="total_${status.index}">
                                        <c:choose>
                                            <c:when test="${detail.price != null}">
                                                <fmt:formatNumber value="${detail.price * detail.quantity}" type="number" maxFractionDigits="0"/>
                                            </c:when>
                                            <c:otherwise>
                                                0
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            
            <!-- Submit Section -->
            <div class="submit-section">
                <div class="row justify-content-center">
                    <div class="col-md-8">
                        <h4 class="mb-3"><i class="fas fa-handshake text-success"></i> Xác Nhận Báo Giá</h4>
                        <p class="text-muted mb-4">
                            Vui lòng kiểm tra kỹ thông tin trước khi gửi báo giá. 
                            Báo giá của bạn sẽ được gửi đến hệ thống quản lý kho hàng.
                        </p>
                        
                        <div class="d-grid gap-2 d-md-flex justify-content-md-center">
                            <button type="submit" class="btn submit-btn me-md-2">
                                <i class="fas fa-paper-plane"></i> GỬI BÁO GIÁ
                            </button>
                            <button type="reset" class="btn btn-outline-secondary" onclick="resetForm()">
                                <i class="fas fa-undo"></i> Làm Lại
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Calculate total for each row
        function calculateTotal(rowIndex, quantity) {
            const priceInputs = document.querySelectorAll('.price-input');
            const priceInput = priceInputs[rowIndex];
            const totalDiv = document.getElementById(`total_${rowIndex}`);
            
            if (priceInput && totalDiv) {
                const price = parseFloat(priceInput.value) || 0;
                const total = price * parseInt(quantity);
                totalDiv.textContent = total.toLocaleString('vi-VN');
            }
        }
        
        // Reset form
        function resetForm() {
            if (confirm('Bạn có chắc chắn muốn làm lại? Tất cả dữ liệu đã nhập sẽ bị xóa.')) {
                document.getElementById('quoteForm').reset();
                // Reset all total displays
                const totalDivs = document.querySelectorAll('[id^="total_"]');
                totalDivs.forEach(div => div.textContent = '0');
            }
        }
        
        // Form validation
        document.getElementById('quoteForm').addEventListener('submit', function(e) {
            const priceInputs = document.querySelectorAll('.price-input');
            let hasPrice = false;
            
            priceInputs.forEach(input => {
                if (input.value && parseFloat(input.value) > 0) {
                    hasPrice = true;
                }
            });
            
            if (!hasPrice) {
                e.preventDefault();
                alert('Vui lòng nhập ít nhất một đơn giá cho sản phẩm!');
                return false;
            }
            
            return confirm('Bạn có chắc chắn muốn gửi báo giá này không?');
        });
        
        // Auto-save functionality (optional)
        let autoSaveTimer;
        document.querySelectorAll('.price-input').forEach(input => {
            input.addEventListener('input', function() {
                clearTimeout(autoSaveTimer);
                autoSaveTimer = setTimeout(() => {
                    // You can implement auto-save to localStorage here
                    console.log('Auto-saving...');
                }, 2000);
            });
        });
        
        // Initialize totals on page load
        document.addEventListener('DOMContentLoaded', function() {
            <c:forEach var="detail" items="${rfqDetails}" varStatus="status">
                <c:if test="${detail.price != null}">
                    calculateTotal(${status.index}, ${detail.quantity});
                </c:if>
            </c:forEach>
        });
    </script>
</body>
</html>
