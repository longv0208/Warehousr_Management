<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Tạo Đơn Bán Hàng - Sale Staff</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
      
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Tạo Đơn Bán Hàng</h3>
        <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=list" class="btn btn-secondary">← Quay lại</a>
      </div>
      
      <!-- Debug information -->
      <c:if test="${debugProductCount != null && debugProductCount > 0}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
          <strong>Debug:</strong> Tìm thấy ${debugProductCount} sản phẩm active.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </c:if>
      
      <c:if test="${empty products}">
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
          <strong>Cảnh báo:</strong> Không có sản phẩm nào có sẵn để tạo đơn hàng. Vui lòng thêm sản phẩm trước khi tạo đơn hàng.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/sale-staff/sales-order" method="POST" class="needs-validation" novalidate>
        <input type="hidden" name="action" value="create">
        
        <div class="row">
          <div class="col-md-6">
            <div class="card mb-4">
              <div class="card-header">
                <h5 class="card-title mb-0">Thông tin đơn hàng</h5>
              </div>
              <div class="card-body">
                <div class="mb-3">
                  <label for="orderCode" class="form-label">Mã đơn hàng</label>
                  <input type="text" class="form-control" id="orderCode" name="orderCode" value="${orderCode}" readonly>
                </div>
                
                <div class="mb-3">
                  <label for="customerName" class="form-label">Tên khách hàng <span class="text-danger">*</span></label>
                  <input type="text" class="form-control" id="customerName" name="customerName" required>
                  <div class="invalid-feedback">
                    Vui lòng nhập tên khách hàng.
                  </div>
                </div>
                
                <div class="mb-3">
                  <label for="orderDate" class="form-label">Ngày đặt hàng <span class="text-danger">*</span></label>
                  <input type="date" class="form-control" id="orderDate" name="orderDate" value="<fmt:formatDate value='<%=new java.util.Date()%>' pattern='yyyy-MM-dd'/>" required>
                  <div class="invalid-feedback">
                    Vui lòng chọn ngày đặt hàng.
                  </div>
                </div>
                
                <div class="mb-3">
                  <label for="notes" class="form-label">Ghi chú</label>
                  <textarea class="form-control" id="notes" name="notes" rows="3" placeholder="Ghi chú về đơn hàng..."></textarea>
                </div>
              </div>
            </div>
          </div>
          
          <div class="col-md-6">
            <div class="card mb-4">
              <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0">Chi tiết sản phẩm</h5>
                <button type="button" class="btn btn-sm btn-success" onclick="addProductRow()">+ Thêm sản phẩm</button>
              </div>
              <div class="card-body">
                <div id="productContainer">
                  <!-- Product rows will be added here -->
                </div>
                <div class="row mt-3">
                  <div class="col-md-6 offset-md-6">
                    <div class="d-flex justify-content-between">
                      <strong>Tổng tiền:</strong>
                      <strong id="totalAmount">0 đ</strong>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="row">
          <div class="col-12">
            <div class="d-flex justify-content-end">
              <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=list" class="btn btn-secondary me-2">Hủy</a>
              <button type="submit" class="btn btn-primary">Tạo đơn hàng</button>
            </div>
          </div>
        </div>
      </form>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

<!-- Hidden template for product options -->
<template id="productOptionsTemplate">
    <option value="">-- Chọn sản phẩm --</option>
    <c:forEach var="p" items="${products}">
        <option value="${p['productId']}"
                data-price="${p['salePrice']}"
                data-quantity="${p['quantity']}"
                data-unit="${p['unit']}">
            ${p['productCode']} - ${p['productName']} (${p['unit']})
        </option>
    </c:forEach>
</template>

<script>
  let productRowIndex = 0;
  const hasProducts = <c:out value="${not empty products}" default="false"/>;
  const productCount = <c:out value="${fn:length(products)}" default="0"/>;
  
  // Check if products are available
  document.addEventListener('DOMContentLoaded', function() {
    if (hasProducts) {
      console.log('Found ' + productCount + ' products available');
      addProductRow(); // Add first product row automatically
      iziToast.success({
        title: 'Thành công',
        message: 'Đã tải ' + productCount + ' sản phẩm có sẵn.'
      });
    } else {
      console.error('No products available');
      iziToast.error({
        title: 'Lỗi',
        message: 'Không có sản phẩm nào có sẵn để tạo đơn hàng.'
      });
    }
  });

  function addProductRow() {
    const tpl = document.getElementById('productOptionsTemplate');
    if (!tpl) return;

    const container   = document.getElementById('productContainer');
    const rowIndex    = productRowIndex++;
    const rowWrapper  = document.createElement('div');
    rowWrapper.className = 'product-row mb-3 p-3 border rounded';
    rowWrapper.id       = 'productRow' + rowIndex;

    // Build basic row structure (without options yet)
    rowWrapper.innerHTML = `
        <div class="row">
          <div class="col-md-4">
            <label class="form-label">Sản phẩm <span class="text-danger">*</span></label>
            <select class="form-select"
                    name="productId"
                    onchange="updateProductInfo(this, ${rowIndex})"
                    required>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Số lượng <span class="text-danger">*</span></label>
            <input type="number" class="form-control" name="quantity" min="1" 
                   onchange="calculateRowTotal(${rowIndex})" 
                   oninput="calculateRowTotal(${rowIndex})" required>
            <small class="text-muted">Tồn: <span id="stockQuantity${rowIndex}">0</span> <span id="unit${rowIndex}"></span></small>
          </div>
          <div class="col-md-2">
            <label class="form-label">Đơn giá <span class="text-danger">*</span></label>
            <input type="number" class="form-control" name="unitPrice" step="0.01" min="0" 
                   onchange="calculateRowTotal(${rowIndex})" 
                   oninput="calculateRowTotal(${rowIndex})" required>
          </div>
          <div class="col-md-2">
            <label class="form-label">Thành tiền</label>
            <div class="form-control-plaintext fw-bold" id="rowTotal${rowIndex}">0 đ</div>
          </div>
          <div class="col-md-2">
            <label class="form-label">&nbsp;</label>
            <button type="button" class="btn btn-danger btn-sm d-block w-100" onclick="removeProductRow(${rowIndex})">
              <i class="fas fa-trash"></i> Xóa
            </button>
          </div>
        </div>
    `;

    container.appendChild(rowWrapper);

    // Append options from template AFTER row is in DOM
    const selectElement = rowWrapper.querySelector('select[name="productId"]');
    if (selectElement) {
      // Use importNode to clone <template> content properly
      const optionsFragment = document.importNode(tpl.content, true);
      selectElement.appendChild(optionsFragment);
    }
  }

  function removeProductRow(index) {
    const row = document.getElementById('productRow' + index);
    if (row) {
      row.remove();
      calculateTotal();
    }
  }

  function updateProductInfo(selectElement, index) {
    const selectedOption = selectElement.options[selectElement.selectedIndex];
    const price = selectedOption.getAttribute('data-price');
    const quantity = selectedOption.getAttribute('data-quantity');
    const unit = selectedOption.getAttribute('data-unit');
    
    const row = selectElement.closest('.product-row');
    const priceInput = row.querySelector('input[name="unitPrice"]');
    const stockSpan = row.querySelector('#stockQuantity' + index);
    const unitSpan = row.querySelector('#unit' + index);
    
    if (price && quantity) {
      priceInput.value = price;
      stockSpan.textContent = quantity;
      unitSpan.textContent = unit || '';
      calculateRowTotal(index);
      
      // Highlight low stock
      if (parseInt(quantity) < 10) {
        stockSpan.parentElement.className = 'text-warning';
      } else {
        stockSpan.parentElement.className = 'text-muted';
      }
    }
  }

  function calculateRowTotal(index) {
    const row = document.getElementById('productRow' + index);
    const quantity = parseFloat(row.querySelector('input[name="quantity"]').value) || 0;
    const unitPrice = parseFloat(row.querySelector('input[name="unitPrice"]').value) || 0;
    const total = quantity * unitPrice;
    
    document.getElementById('rowTotal' + index).textContent = formatCurrency(total);
    calculateTotal();
  }

  function calculateTotal() {
    let total = 0;
    document.querySelectorAll('.product-row').forEach(row => {
      const quantity = parseFloat(row.querySelector('input[name="quantity"]').value) || 0;
      const unitPrice = parseFloat(row.querySelector('input[name="unitPrice"]').value) || 0;
      total += quantity * unitPrice;
    });
    
    document.getElementById('totalAmount').textContent = formatCurrency(total);
  }

  function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(amount);
  }

  // Form validation
  (function() {
    'use strict';
    window.addEventListener('load', function() {
      var forms = document.getElementsByClassName('needs-validation');
      var validation = Array.prototype.filter.call(forms, function(form) {
        form.addEventListener('submit', function(event) {
          // Check if there's at least one product
          const productRows = document.querySelectorAll('.product-row');
          if (productRows.length === 0) {
            event.preventDefault();
            event.stopPropagation();
            iziToast.warning({
              title: 'Cảnh báo',
              message: 'Vui lòng thêm ít nhất một sản phẩm vào đơn hàng.'
            });
            return;
          }
          
          if (form.checkValidity() === false) {
            event.preventDefault();
            event.stopPropagation();
          }
          form.classList.add('was-validated');
        }, false);
      });
    }, false);
  })();
</script>

</body>
</html> 