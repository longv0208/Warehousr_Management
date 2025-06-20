<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Chỉnh Sửa Sản Phẩm - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet" />
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
  <style>
    .invalid-feedback {
      display: block;
    }
  </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
      <h3>Chỉnh Sửa Sản Phẩm</h3>
      <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" id="productEditForm" novalidate>
        <input type="hidden" name="action" value="edit">
        <input type="hidden" name="productId" value="${product.productId}">

        <div class="row mb-3">
          <div class="col-md-6">
            <label for="productCode" class="form-label">Mã Sản Phẩm <span class="text-danger">*</span></label>
            <input type="text" class="form-control" id="productCode" name="productCode" value="${product.productCode}" maxlength="10" required>
            <div class="invalid-feedback"></div>
            <div class="form-text">Tối đa 10 ký tự</div>
          </div>
          <div class="col-md-6">
            <label for="productName" class="form-label">Tên Sản Phẩm <span class="text-danger">*</span></label>
            <input type="text" class="form-control" id="productName" name="productName" value="${product.productName}" maxlength="10" required>
            <div class="invalid-feedback"></div>
            <div class="form-text">Tối đa 10 ký tự</div>
          </div>
        </div>

        <div class="mb-3">
          <label for="description" class="form-label">Mô Tả <span class="text-danger">*</span></label>
          <textarea class="form-control" id="description" name="description" rows="3" maxlength="100" required>${product.description}</textarea>
          <div class="invalid-feedback"></div>
          <div class="form-text">Tối đa 100 ký tự</div>
        </div>

        <div class="row mb-3">
          <div class="col-md-6">
            <label for="unit" class="form-label">Đơn Vị Tính <span class="text-danger">*</span></label>
            <select class="form-select" id="unit" name="unit" required>
              <option value="">-- Chọn đơn vị tính --</option>
              <option value="chiếc" ${product.unit == 'chiếc' ? 'selected' : ''}>Chiếc</option>
              <option value="thanh" ${product.unit == 'thanh' ? 'selected' : ''}>Thanh</option>
              <option value="bộ" ${product.unit == 'bộ' ? 'selected' : ''}>Bộ</option>
              <option value="sợi" ${product.unit == 'sợi' ? 'selected' : ''}>Sợi</option>
              <option value="cái" ${product.unit == 'cái' ? 'selected' : ''}>Cái</option>
              <option value="đôi" ${product.unit == 'đôi' ? 'selected' : ''}>Đôi</option>
            </select>
            <div class="invalid-feedback"></div>
          </div>
          <div class="col-md-6">
            <!-- Empty column for better layout -->
          </div>
        </div>

        <div class="row mb-3">
          <div class="col-md-6">
            <label for="supplierId" class="form-label">Nhà Cung Cấp <span class="text-danger">*</span></label>
            <select class="form-select" id="supplierId" name="supplierId" required>
              <option value="">-- Chọn nhà cung cấp --</option>
              <c:forEach var="supplier" items="${suppliers}">
                <option value="${supplier.supplierId}" ${supplier.supplierId == product.supplierId ? 'selected' : ''}>${supplier.supplierName}</option>
              </c:forEach>
            </select>
            <div class="invalid-feedback"></div>
          </div>
          <div class="col-md-6">
            <!-- Empty column for better layout --></div>
        </div>

        <div class="mb-3">
          <label for="categoryId" class="form-label">Danh Mục <span class="text-danger">*</span></label>
          <select class="form-select" id="categoryId" name="categoryId" required>
            <option value="">-- Chọn danh mục --</option>
            <c:forEach var="category" items="${categories}">
              <c:set var="isSelected" value="false" />
              <c:forEach var="productCategory" items="${productCategories}">
                <c:if test="${productCategory.categoryId == category.categoryId}">
                  <c:set var="isSelected" value="true" />
                </c:if>
              </c:forEach>
              <option value="${category.categoryId}" ${isSelected ? 'selected' : ''}>${category.categoryName}</option>
            </c:forEach>
          </select>
          <div class="invalid-feedback"></div>
        </div>

        <div class="row mb-3">
          <div class="col-md-4">
            <label for="purchasePrice" class="form-label">Giá Mua <span class="text-danger">*</span></label>
            <input type="number" class="form-control" id="purchasePrice" name="purchasePrice" step="0.01" min="0" value="${product.purchasePrice}" required>
            <div class="invalid-feedback"></div>
            <div class="form-text">Không được nhập số âm</div>
          </div>
          <div class="col-md-4">
            <label for="salePrice" class="form-label">Giá Bán <span class="text-danger">*</span></label>
            <input type="number" class="form-control" id="salePrice" name="salePrice" step="0.01" min="0" value="${product.salePrice}" required>
            <div class="invalid-feedback"></div>
            <div class="form-text">
              <span class="text-muted">Không được nhập số âm</span><br>
              <small class="text-info">💡 Gợi ý: Giá bán thường cao hơn giá mua 30%</small>
            </div>
          </div>
          <div class="col-md-4">
            <label for="lowStockThreshold" class="form-label">Ngưỡng Tồn Kho Thấp <span class="text-danger">*</span></label>
            <input type="number" class="form-control" id="lowStockThreshold" name="lowStockThreshold" min="10" value="${product.lowStockThreshold}" required>
            <div class="invalid-feedback"></div>
            <div class="form-text">Phải ít nhất là 10</div>
          </div>
        </div>
        
        <div class="mb-3 form-check">
          <input type="checkbox" class="form-check-input" id="isActive" name="isActive" value="true" ${product.isActive ? 'checked' : ''}>
          <label class="form-check-label" for="isActive">Hoạt động</label>
        </div>

        <button type="submit" class="btn btn-success">Cập Nhật Sản Phẩm</button>
        <a href="${pageContext.request.contextPath}/admin/manage-product?action=list" class="btn btn-secondary">Hủy</a>
      </form>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('productEditForm');
    const productCodeInput = document.getElementById('productCode');
    const productNameInput = document.getElementById('productName');
    const descriptionInput = document.getElementById('description');
    const purchasePriceInput = document.getElementById('purchasePrice');
    const salePriceInput = document.getElementById('salePrice');
    const lowStockThresholdInput = document.getElementById('lowStockThreshold');
    
    // Real-time validation functions
    function validateProductCode() {
      const value = productCodeInput.value.trim();
      const feedback = productCodeInput.nextElementSibling;
      
      if (value === '') {
        productCodeInput.classList.add('is-invalid');
        feedback.textContent = 'Mã sản phẩm không được để trống';
        return false;
      } else if (value.length > 10) {
        productCodeInput.classList.add('is-invalid');
        feedback.textContent = 'Mã sản phẩm không được quá 10 ký tự';
        return false;
      } else {
        productCodeInput.classList.remove('is-invalid');
        productCodeInput.classList.add('is-valid');
        return true;
      }
    }
    
    function validateProductName() {
      const value = productNameInput.value.trim();
      const feedback = productNameInput.nextElementSibling;
      
      if (value === '') {
        productNameInput.classList.add('is-invalid');
        feedback.textContent = 'Tên sản phẩm không được để trống';
        return false;
      } else if (value.length > 10) {
        productNameInput.classList.add('is-invalid');
        feedback.textContent = 'Tên sản phẩm không được quá 10 ký tự';
        return false;
      } else {
        productNameInput.classList.remove('is-invalid');
        productNameInput.classList.add('is-valid');
        return true;
      }
    }
    
    function validateDescription() {
      const value = descriptionInput.value.trim();
      const feedback = descriptionInput.nextElementSibling;
      
      if (value === '') {
        descriptionInput.classList.add('is-invalid');
        feedback.textContent = 'Mô tả không được để trống';
        return false;
      } else if (value.length > 100) {
        descriptionInput.classList.add('is-invalid');
        feedback.textContent = 'Mô tả không được quá 100 ký tự';
        return false;
      } else {
        descriptionInput.classList.remove('is-invalid');
        descriptionInput.classList.add('is-valid');
        return true;
      }
    }
    
    function validateSelect(selectInput, fieldName) {
      const feedback = selectInput.nextElementSibling;
      
      if (selectInput.value === '') {
        selectInput.classList.add('is-invalid');
        feedback.textContent = fieldName + ' không được để trống';
        return false;
      } else {
        selectInput.classList.remove('is-invalid');
        selectInput.classList.add('is-valid');
        return true;
      }
    }
    
    function validateNumberInput(input, fieldName) {
      const value = parseFloat(input.value);
      const feedback = input.nextElementSibling;
      
      if (input.value === '') {
        input.classList.add('is-invalid');
        feedback.textContent = fieldName + ' không được để trống';
        return false;
      } else if (isNaN(value) || value < 0) {
        input.classList.add('is-invalid');
        feedback.textContent = fieldName + ' không được âm';
        return false;
      } else {
        input.classList.remove('is-invalid');
        input.classList.add('is-valid');
        return true;
      }
    }
    
    function validateLowStockThreshold() {
      const value = parseInt(lowStockThresholdInput.value);
      const feedback = lowStockThresholdInput.nextElementSibling;
      
      if (lowStockThresholdInput.value === '') {
        lowStockThresholdInput.classList.add('is-invalid');
        feedback.textContent = 'Ngưỡng tồn kho thấp không được để trống';
        return false;
      } else if (isNaN(value) || value < 10) {
        lowStockThresholdInput.classList.add('is-invalid');
        feedback.textContent = 'Ngưỡng tồn kho thấp phải ít nhất là 10';
        return false;
      } else {
        lowStockThresholdInput.classList.remove('is-invalid');
        lowStockThresholdInput.classList.add('is-valid');
        return true;
      }
    }
    
    // Auto-calculate sale price with 30% markup
    function calculateSalePrice() {
      const purchasePrice = parseFloat(purchasePriceInput.value);
      if (!isNaN(purchasePrice) && purchasePrice > 0) {
        const suggestedSalePrice = (purchasePrice * 1.3).toFixed(2);
        if (confirm('Tự động tính giá bán = giá mua + 30%?\nGiá bán gợi ý: ' + suggestedSalePrice)) {
          salePriceInput.value = suggestedSalePrice;
          validateNumberInput(salePriceInput, 'Giá bán');
        }
      }
    }
    
    // Add event listeners for real-time validation
    productCodeInput.addEventListener('input', validateProductCode);
    productCodeInput.addEventListener('blur', validateProductCode);
    
    productNameInput.addEventListener('input', validateProductName);
    productNameInput.addEventListener('blur', validateProductName);
    
    descriptionInput.addEventListener('input', validateDescription);
    descriptionInput.addEventListener('blur', validateDescription);
    
    document.getElementById('unit').addEventListener('change', function() {
      validateSelect(this, 'Đơn vị tính');
    });
    
    document.getElementById('supplierId').addEventListener('change', function() {
      validateSelect(this, 'Nhà cung cấp');
    });
    
    document.getElementById('categoryId').addEventListener('change', function() {
      validateSelect(this, 'Danh mục');
    });
    
    purchasePriceInput.addEventListener('input', function() {
      validateNumberInput(this, 'Giá mua');
    });
    
    purchasePriceInput.addEventListener('blur', function() {
      if (this.value !== '' && !isNaN(parseFloat(this.value))) {
        calculateSalePrice();
      }
    });
    
    salePriceInput.addEventListener('input', function() {
      validateNumberInput(this, 'Giá bán');
    });
    
    lowStockThresholdInput.addEventListener('input', function() {
      validateLowStockThreshold();
    });
    
    // Form submission validation
    form.addEventListener('submit', function(e) {
      e.preventDefault();
      
      const isProductCodeValid = validateProductCode();
      const isProductNameValid = validateProductName();
      const isDescriptionValid = validateDescription();
      const isUnitValid = validateSelect(document.getElementById('unit'), 'Đơn vị tính');
      const isSupplierValid = validateSelect(document.getElementById('supplierId'), 'Nhà cung cấp');
      const isCategoryValid = validateSelect(document.getElementById('categoryId'), 'Danh mục');
      const isPurchasePriceValid = validateNumberInput(purchasePriceInput, 'Giá mua');
      const isSalePriceValid = validateNumberInput(salePriceInput, 'Giá bán');
      const isLowStockThresholdValid = validateLowStockThreshold();
      
      if (isProductCodeValid && isProductNameValid && isDescriptionValid && 
          isUnitValid && isSupplierValid && isCategoryValid &&
          isPurchasePriceValid && isSalePriceValid && isLowStockThresholdValid) {
        form.submit();
      } else {
        // Scroll to first invalid field
        const firstInvalid = form.querySelector('.is-invalid');
        if (firstInvalid) {
          firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
          firstInvalid.focus();
        }
      }
    });
  });
</script>
</body>
</html> 