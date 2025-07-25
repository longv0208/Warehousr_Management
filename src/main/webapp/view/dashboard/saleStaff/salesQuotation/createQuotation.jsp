<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:choose><c:when test="${quotation != null}">Chỉnh sửa báo giá</c:when><c:otherwise>Tạo báo giá mới</c:otherwise></c:choose></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    
    <style>
        .product-row {
            border: 1px solid #ddd;
            border-radius: 5px;
            margin-bottom: 10px;
            padding: 15px;
            background-color: #f9f9f9;
        }
        .remove-product {
            color: #dc3545;
            cursor: pointer;
        }
        .product-total {
            font-weight: bold;
            color: #007bff;
        }
    </style>
</head>
<body>
    <!-- Hidden data containers for JavaScript -->
    <div id="products-data" style="display: none;">
        <c:forEach var="product" items="${products}">
        <div class="product-item" 
             data-id="${product.productId}"
             data-name="${product.productName}"
             data-price="${product.salePrice}"
             data-unit="${product.unit}"></div>
        </c:forEach>
    </div>
    
    <div id="quotation-details-data" style="display: none;">
        <c:if test="${quotationDetails != null}">
        <c:forEach var="detail" items="${quotationDetails}">
        <div class="detail-item"
             data-product-id="${detail.productId}"
             data-quantity="${detail.quantity}"
             data-unit-price="${detail.unitPrice}"></div>
        </c:forEach>
        </c:if>
    </div>

    <!-- Include Header -->
    <jsp:include page="/view/common/head.jsp" />

    <div class="container-fluid main">
        <div class="row">
            <!-- Include Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp" />

            <!-- Main Content -->
            <main role="main" class="col-md-9 ml-sm-auto col-lg-10 px-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">${quotation != null ? 'Chỉnh sửa báo giá' : 'Tạo báo giá mới'}</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/sale-staff/sales-quotation?action=list" 
                           class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <form id="quotationForm" method="POST" action="${pageContext.request.contextPath}/sale-staff/sales-quotation">
                    <input type="hidden" name="action" value="${quotation != null ? 'update' : 'create'}">
                    <c:if test="${quotation != null}">
                        <input type="hidden" name="quotationId" value="${quotation.quotationId}">
                    </c:if>

                    <!-- Customer Information -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5><i class="fas fa-user"></i> Thông tin khách hàng</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="customerName" class="form-label">Tên khách hàng <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="customerName" name="customerName" 
                                               value="<c:out value='${quotation.customerName}'/>" required>
                                    </div>
                                    <div class="mb-3">
                                        <label for="customerEmail" class="form-label">Email <span class="text-danger">*</span></label>
                                        <input type="email" class="form-control" id="customerEmail" name="customerEmail" 
                                               value="<c:out value='${quotation.customerEmail}'/>" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="customerPhone" class="form-label">Số điện thoại</label>
                                        <input type="tel" class="form-control" id="customerPhone" name="customerPhone"
                                               value="<c:out value='${quotation.customerPhone}'/>">
                                    </div>
                                    <div class="mb-3">
                                        <label for="customerAddress" class="form-label">Địa chỉ</label>
                                        <textarea class="form-control" id="customerAddress" name="customerAddress" rows="2"><c:out value='${quotation.customerAddress}'/></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quotation Information -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5><i class="fas fa-file-alt"></i> Thông tin báo giá</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="quotationDate" class="form-label">Ngày báo giá <span class="text-danger">*</span></label>
                                        <input type="date" class="form-control" id="quotationDate" name="quotationDate" 
                                               value="<fmt:formatDate value='${quotation.quotationDate}' pattern='yyyy-MM-dd'/>" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="validUntil" class="form-label">Hiệu lực đến <span class="text-danger">*</span></label>
                                        <input type="date" class="form-control" id="validUntil" name="validUntil" 
                                               value="<fmt:formatDate value='${quotation.validUntil}' pattern='yyyy-MM-dd'/>" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="warehouseId" class="form-label">Kho hàng <span class="text-danger">*</span></label>
                                        <select class="form-control" id="warehouseId" name="warehouseId" required>
                                            <option value="">-- Chọn kho hàng --</option>
                                            <c:forEach var="warehouse" items="${warehouses}">
                                                <option value="${warehouse.warehouseId}" 
                                                        <c:if test="${quotation.warehouseId == warehouse.warehouseId}">selected</c:if>>
                                                    ${warehouse.warehouseName}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="mb-3">
                                        <label for="notes" class="form-label">Ghi chú</label>
                                        <textarea class="form-control" id="notes" name="notes" rows="3"><c:out value='${quotation.notes}'/></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Products Section -->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5><i class="fas fa-box"></i> Sản phẩm</h5>
                            <button type="button" class="btn btn-sm btn-primary" onclick="addProduct()">
                                <i class="fas fa-plus"></i> Thêm sản phẩm
                            </button>
                        </div>
                        <div class="card-body">
                            <div id="productsContainer">
                                <!-- Product rows will be added dynamically -->
                            </div>
                            <div class="row mt-3">
                                <div class="col-md-12 text-end">
                                    <h5>Tổng cộng: <span id="grandTotal" class="text-primary">0 VNĐ</span></h5>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="row mb-4">
                        <div class="col-md-12 text-end">
                            <button type="button" class="btn btn-secondary" onclick="history.back()">Hủy</button>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> Lưu báo giá
                            </button>
                        </div>
                    </div>
                </form>
            </main>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="/view/common/foot.jsp" />

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        // Load data from HTML data attributes
        function loadProductsData() {
            const products = [];
            document.querySelectorAll('#products-data .product-item').forEach(item => {
                products.push({
                    id: parseInt(item.dataset.id),
                    name: item.dataset.name,
                    price: parseFloat(item.dataset.price),
                    unit: item.dataset.unit
                });
            });
            return products;
        }
        
        function loadExistingDetailsData() {
            const details = [];
            document.querySelectorAll('#quotation-details-data .detail-item').forEach(item => {
                details.push({
                    productId: parseInt(item.dataset.productId),
                    quantity: parseFloat(item.dataset.quantity),
                    unitPrice: parseFloat(item.dataset.unitPrice)
                });
            });
            return details;
        }
        
        // Get data 
        const products = loadProductsData();
        const existingDetails = loadExistingDetailsData();
        
        let productCounter = 0;

        // Set default valid until date (30 days from today)
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date();
            const quotationDate = document.getElementById('quotationDate');
            const validUntil = document.getElementById('validUntil');
            
            if (!quotationDate.value) {
                quotationDate.value = today.toISOString().split('T')[0];
            }
            
            const validDate = new Date(today);
            validDate.setDate(validDate.getDate() + 30);
            validUntil.value = validDate.toISOString().split('T')[0];
        });

        function addProduct() {
            productCounter++;
            const container = document.getElementById('productsContainer');
            
            const productRow = document.createElement('div');
            productRow.className = 'product-row';
            productRow.id = 'product-' + productCounter;
            
            var html = ''
                + '<div class="row align-items-end">'
                + '<div class="col-md-4">'
                + '<label class="form-label">Sản phẩm</label>'
                + '<select class="form-control product-select" name="productId[]" onchange="updateProductInfo(this, ' + productCounter + ')" required>'
                + '<option value="">-- Chọn sản phẩm --</option>'
                + products.map(function(p) {
                    return '<option value="' + p.id + '" data-price="' + p.price + '" data-unit="' + p.unit + '">' + p.name + '</option>';
                  }).join('')
                + '</select>'
                + '</div>'
                + '<div class="col-md-2">'
                + '<label class="form-label">Đơn vị</label>'
                + '<input type="text" class="form-control unit-display" readonly>'
                + '</div>'
                + '<div class="col-md-2">'
                + '<label class="form-label">Số lượng</label>'
                + '<input type="number" class="form-control quantity-input" name="quantity[]" min="1" value="1" onchange="calculateRowTotal(' + productCounter + ')" required>'
                + '</div>'
                + '<div class="col-md-2">'
                + '<label class="form-label">Đơn giá</label>'
                + '<input type="number" class="form-control price-input" name="unitPrice[]" step="0.01" onchange="calculateRowTotal(' + productCounter + ')" required>'
                + '</div>'
                + '<div class="col-md-1">'
                + '<label class="form-label">Thành tiền</label>'
                + '<input type="text" class="form-control row-total" readonly>'
                + '</div>'
                + '<div class="col-md-1">'
                + '<button type="button" class="btn btn-sm btn-danger remove-product" onclick="removeProduct(' + productCounter + ')">'
                + '<i class="fas fa-trash"></i>'
                + '</button>'
                + '</div>'
                + '</div>';
            productRow.innerHTML = html;
            
            container.appendChild(productRow);
        }

        function updateProductInfo(selectElement, rowId) {
            const selectedOption = selectElement.selectedOptions[0];
            const row = document.getElementById('product-' + rowId);
            
            if (selectedOption.value) {
                const unitDisplay = row.querySelector('.unit-display');
                const priceInput = row.querySelector('.price-input');
                
                unitDisplay.value = selectedOption.dataset.unit;
                priceInput.value = selectedOption.dataset.price;
                
                calculateRowTotal(rowId);
            }
        }

        function calculateRowTotal(rowId) {
            const row = document.getElementById('product-' + rowId);
            const quantity = parseFloat(row.querySelector('.quantity-input').value) || 0;
            const price = parseFloat(row.querySelector('.price-input').value) || 0;
            const total = quantity * price;
            
            row.querySelector('.row-total').value = formatCurrency(total);
            calculateGrandTotal();
        }

        function calculateGrandTotal() {
            let grandTotal = 0;
            document.querySelectorAll('.quantity-input').forEach((input, index) => {
                const quantity = parseFloat(input.value) || 0;
                const price = parseFloat(document.querySelectorAll('.price-input')[index].value) || 0;
                grandTotal += quantity * price;
            });
            
            document.getElementById('grandTotal').textContent = formatCurrency(grandTotal);
        }

        function removeProduct(rowId) {
            const row = document.getElementById('product-' + rowId);
            row.remove();
            calculateGrandTotal();
        }

        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            }).format(amount);
        }

        // Form validation
        document.getElementById('quotationForm').addEventListener('submit', function(e) {
            const productRows = document.querySelectorAll('.product-row');
            if (productRows.length === 0) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Thông báo',
                    text: 'Vui lòng thêm ít nhất một sản phẩm vào báo giá.'
                });
                return;
            }
        });

        // Load existing quotation details if in edit mode
        function loadExistingQuotationDetails() {
            if (existingDetails.length > 0) {
                // Clear the container first
                document.getElementById('productsContainer').innerHTML = '';
                
                // Load each existing detail
                existingDetails.forEach(function(detail) {
                    addProduct();
                    const lastRow = document.querySelector('#productsContainer .product-row:last-child');
                    if (lastRow) {
                        const productSelect = lastRow.querySelector('select[name="productId[]"]');
                        const quantityInput = lastRow.querySelector('input[name="quantity[]"]');
                        const priceInput = lastRow.querySelector('input[name="unitPrice[]"]');
                        
                        if (productSelect) productSelect.value = detail.productId;
                        if (quantityInput) quantityInput.value = detail.quantity;
                        if (priceInput) priceInput.value = detail.unitPrice;
                        
                        // Update product info based on selection
                        updateProductInfo(productSelect, productCounter);
                        
                        // Override price if different from default
                        if (priceInput) priceInput.value = detail.unitPrice;
                        calculateRowTotal(productCounter);
                    }
                });
            } else {
                // Add first product row by default if no existing details
                addProduct();
            }
        }

        // Call the function after DOM is loaded
        document.addEventListener('DOMContentLoaded', loadExistingQuotationDetails);
    </script>
</body>
</html>
