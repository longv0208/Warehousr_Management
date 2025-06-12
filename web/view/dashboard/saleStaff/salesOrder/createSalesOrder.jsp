<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
      <%
        Integer debugCount = (Integer) request.getAttribute("debugProductCount");
        if (debugCount != null && debugCount > 0) {
      %>
        <div class="alert alert-info alert-dismissible fade show" role="alert">
          <strong>Debug:</strong> Tìm thấy <%= debugCount %> sản phẩm active.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      <%
        }
      %>
      
      <%
        java.util.List<?> productList2 = (java.util.List<?>) request.getAttribute("products");
        if (productList2 == null || productList2.isEmpty()) {
      %>
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
          <strong>Cảnh báo:</strong> Không có sản phẩm nào có sẵn để tạo đơn hàng. Vui lòng thêm sản phẩm trước khi tạo đơn hàng.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      <%
        }
      %>

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

<!-- Hidden data for JavaScript -->
<div id="productData" style="display: none;">
<%
  java.util.List<model.Product> productList = (java.util.List<model.Product>) request.getAttribute("products");
  System.out.println("DEBUG JSP: Product list is null? " + (productList == null));
  System.out.println("DEBUG JSP: Product list size: " + (productList != null ? productList.size() : "N/A"));
  
  if (productList != null && !productList.isEmpty()) {
    System.out.println("DEBUG JSP: Processing " + productList.size() + " products");
    for (int i = 0; i < productList.size(); i++) {
      model.Product product = productList.get(i);
      if (product != null && product.getProductId() != null) {
        System.out.println("DEBUG JSP: Product " + (i+1) + " - ID: " + product.getProductId() + ", Name: " + product.getProductName());
%>
        <div class="product-item" 
             data-id="<%= product.getProductId() %>"
             data-name="<%= product.getProductName() != null ? product.getProductName().replace("\"", "&quot;").replace("'", "&#39;") : "" %>"
             data-code="<%= product.getProductCode() != null ? product.getProductCode().replace("\"", "&quot;").replace("'", "&#39;") : "" %>"
             data-price="<%= product.getSalePrice() != null ? product.getSalePrice() : 0 %>"
             data-quantity="<%= product.getQuantity() != null ? product.getQuantity() : 0 %>"
             data-unit="<%= product.getUnit() != null ? product.getUnit().replace("\"", "&quot;").replace("'", "&#39;") : "" %>"
             data-description="<%= product.getDescription() != null ? product.getDescription().replace("\"", "&quot;").replace("'", "&#39;") : "" %>">
        </div>
<%
      } else {
        System.out.println("DEBUG JSP: Skipping invalid product at index " + i);
      }
    }
  } else {
    System.out.println("DEBUG JSP: No products available, adding no-products marker");
%>
    <div class="no-products" data-message="Không có sản phẩm nào"></div>
<%
  }
%>
</div>

<script>
  let productRowIndex = 0;
  const products = [];
  
  // Load product data from hidden divs
  document.addEventListener('DOMContentLoaded', function() {
    console.log('Loading product data...');
    
    // First, let's check what's in the productData div
    const productDataDiv = document.getElementById('productData');
    console.log('Product data div content:', productDataDiv ? productDataDiv.innerHTML : 'Not found');
    
    // Check if no products available
    const noProducts = document.querySelector('#productData .no-products');
    if (noProducts) {
      console.error('No products available - found no-products marker');
      iziToast.error({
        title: 'Lỗi', 
        message: 'Không có sản phẩm nào có sẵn để tạo đơn hàng. Vui lòng liên hệ quản trị viên.'
      });
      return;
    }
    
    const productItems = document.querySelectorAll('#productData .product-item');
    console.log('Found product items in DOM:', productItems.length);
    
    if (productItems.length === 0) {
      console.warn('No product items found in DOM');
      // Let's also check what's actually there
      console.log('ProductData children:', productDataDiv ? productDataDiv.children.length : 'ProductData div not found');
      iziToast.warning({
        title: 'Cảnh báo',
        message: 'Không tìm thấy sản phẩm nào trong danh sách.'
      });
      return;
    }
    
    productItems.forEach((item, index) => {
      try {
        const product = {
          id: item.getAttribute('data-id') || '',
          name: item.getAttribute('data-name') || '',
          code: item.getAttribute('data-code') || '',
          price: parseFloat(item.getAttribute('data-price') || '0') || 0,
          quantity: parseInt(item.getAttribute('data-quantity') || '0') || 0,
          unit: item.getAttribute('data-unit') || '',
          description: item.getAttribute('data-description') || ''
        };
        
        // Only add valid products
        if (product.id && product.name && product.code) {
          console.log(`Product ${index + 1}:`, product);
          products.push(product);
        } else {
          console.warn(`Skipping invalid product at index ${index}:`, product);
        }
      } catch (error) {
        console.error(`Error processing product at index ${index}:`, error);
      }
    });
    
    console.log('Total products loaded:', products.length);
    
    if (products.length > 0) {
      addProductRow();
      iziToast.success({
        title: 'Thành công',
        message: 'Đã tải ' + products.length + ' sản phẩm có sẵn.'
      });
    } else {
      iziToast.error({
        title: 'Lỗi',
        message: 'Không thể tải danh sách sản phẩm.'
      });
    }
  });

  function addProductRow() {
    console.log('Adding product row, total products available:', products.length);
    console.log('Products array:', products);
    
    if (products.length === 0) {
      console.error('No products available for dropdown');
      iziToast.warning({
        title: 'Cảnh báo',
        message: 'Không có sản phẩm nào để thêm vào đơn hàng.'
      });
      return;
    }
    
    const container = document.getElementById('productContainer');
    if (!container) {
      console.error('Product container not found!');
      return;
    }
    
    const rowDiv = document.createElement('div');
    rowDiv.className = 'product-row mb-3 p-3 border rounded';
    rowDiv.id = 'productRow' + productRowIndex;
    
    let optionsHtml = '<option value="">-- Chọn sản phẩm --</option>';
    if (Array.isArray(products) && products.length > 0) {
      console.log('Building options for', products.length, 'products');
      products.forEach((p, index) => {
        console.log(`Processing product ${index + 1}:`, p);
        const safeP = {
          id: p.id || '',
          price: p.price || 0,
          quantity: p.quantity || 0,
          unit: p.unit || '',
          code: p.code || '',
          name: p.name || ''
        };
        console.log(`Safe product ${index + 1}:`, safeP);
        optionsHtml += `<option value="${safeP.id}" data-price="${safeP.price}" data-quantity="${safeP.quantity}" data-unit="${safeP.unit}">${safeP.code} - ${safeP.name} (${safeP.unit})</option>`;
      });
    } else {
      console.error('Products is not an array or is empty:', products);
    }
    
    console.log('Generated options HTML:', optionsHtml);
    
    rowDiv.innerHTML = `
      <div class="row">
        <div class="col-md-4">
          <label class="form-label">Sản phẩm <span class="text-danger">*</span></label>
          <select class="form-select" name="productId" onchange="updateProductInfo(this, ${productRowIndex})" required>
            ${optionsHtml}
          </select>
        </div>
        <div class="col-md-2">
          <label class="form-label">Số lượng <span class="text-danger">*</span></label>
          <input type="number" class="form-control" name="quantity" min="1" onchange="calculateRowTotal(${productRowIndex})" required>
          <small class="text-muted">Tồn: <span id="stockQuantity${productRowIndex}">0</span> <span id="unit${productRowIndex}"></span></small>
        </div>
        <div class="col-md-2">
          <label class="form-label">Đơn giá <span class="text-danger">*</span></label>
          <input type="number" class="form-control" name="unitPrice" step="0.01" min="0" onchange="calculateRowTotal(${productRowIndex})" required>
        </div>
        <div class="col-md-2">
          <label class="form-label">Thành tiền</label>
          <div class="form-control-plaintext fw-bold" id="rowTotal${productRowIndex}">0 đ</div>
        </div>
        <div class="col-md-2">
          <label class="form-label">&nbsp;</label>
          <button type="button" class="btn btn-danger btn-sm d-block w-100" onclick="removeProductRow(${productRowIndex})">
            <i class="fas fa-trash"></i> Xóa
          </button>
        </div>
      </div>
    `;
    
    container.appendChild(rowDiv);
    productRowIndex++;
    
    console.log('Product row added successfully, index:', productRowIndex - 1);
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