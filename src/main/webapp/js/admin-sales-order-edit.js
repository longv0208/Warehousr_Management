// Global variables
let productsData = [];

document.addEventListener('DOMContentLoaded', function() {
  console.log('Admin Sales Order Edit JS loaded');
  calculateTotalAdmin();
});

function setProductsData(data) {
  productsData = data;
}

function addProductRow() {
  const container = document.getElementById('productContainer');
  
  // Remove empty message if exists
  const emptyMessage = container.querySelector('.text-center.text-muted');
  if (emptyMessage) {
    emptyMessage.remove();
  }
  
  const row = document.createElement('div');
  row.className = 'product-row';
  
  let productOptions = '<option value="">-- Chọn sản phẩm --</option>';
  productsData.forEach(product => {
    productOptions += '<option value="' + product.id + '" data-price="' + product.price + '" data-quantity="' + product.quantity + '" data-unit="' + product.unit + '">' +
      product.code + ' - ' + product.name + '</option>';
  });
  
  row.innerHTML = 
    '<div class="row align-items-center">' +
      '<div class="col-md-3">' +
        '<select class="form-select" name="productId[]" required onchange="updateProductInfoAdmin(this)">' +
          productOptions +
        '</select>' +
      '</div>' +
      '<div class="col-md-2">' +
        '<input type="number" class="form-control" name="quantity[]" min="1" value="1" required oninput="calculateRowTotalAdmin(this)" onchange="calculateRowTotalAdmin(this)">' +
        '<small class="text-muted">Tồn: <span class="stock-info">0</span></small>' +
      '</div>' +
      '<div class="col-md-2">' +
        '<input type="number" class="form-control" name="unitPrice[]" step="0.01" min="0" value="0" required oninput="calculateRowTotalAdmin(this)" onchange="calculateRowTotalAdmin(this)">' +
      '</div>' +
      '<div class="col-md-2">' +
        '<div class="form-control-plaintext fw-bold text-success row-total">0 đ</div>' +
      '</div>' +
      '<div class="col-md-2">' +
        '<span class="form-control-plaintext unit-info"></span>' +
      '</div>' +
      '<div class="col-md-1">' +
        '<button type="button" class="btn btn-danger btn-sm" onclick="removeProductRowAdmin(this)">' +
          '<i class="fas fa-trash"></i> Xóa' +
        '</button>' +
      '</div>' +
    '</div>';
  
  container.appendChild(row);
  calculateTotalAdmin();
}

function removeProductRowAdmin(button) {
  const row = button.closest('.product-row');
  row.remove();
  
  // Show empty message if no products left
  const container = document.getElementById('productContainer');
  if (container.children.length === 0) {
    container.innerHTML = 
      '<div class="text-center text-muted py-3">' +
        '<p>Chưa có sản phẩm nào. Nhấn "Thêm sản phẩm" để bắt đầu.</p>' +
      '</div>';
  }
  calculateTotalAdmin();
}

function updateProductInfoAdmin(selectElement) {
  const selectedOption = selectElement.options[selectElement.selectedIndex];
  const row = selectElement.closest('.product-row');
  
  if (selectedOption.value) {
    const price = selectedOption.getAttribute('data-price');
    const unit = selectedOption.getAttribute('data-unit');
    const quantity = selectedOption.getAttribute('data-quantity');
    
    // Update unit price
    const priceInput = row.querySelector('input[name="unitPrice"]');
    priceInput.value = price;
    
    // Update unit display
    const unitSpan = row.querySelector('.unit-info');
    unitSpan.textContent = unit;
    
    // Update stock info
    const stockInfo = row.querySelector('.stock-info');
    if (stockInfo) {
      stockInfo.textContent = quantity;
    }
    
    // Update quantity input title
    const quantityInput = row.querySelector('input[name="quantity"]');
    quantityInput.title = 'Số lượng tồn kho: ' + quantity;
    quantityInput.max = quantity;
  } else {
    // Clear fields if no product selected
    const priceInput = row.querySelector('input[name="unitPrice"]');
    const unitSpan = row.querySelector('.unit-info');
    const stockInfo = row.querySelector('.stock-info');
    const quantityInput = row.querySelector('input[name="quantity"]');
    
    priceInput.value = '0';
    unitSpan.textContent = '';
    if (stockInfo) stockInfo.textContent = '0';
    quantityInput.removeAttribute('max');
    quantityInput.title = '';
  }
  
  calculateRowTotalAdmin(selectElement);
}

function calculateRowTotalAdmin(element) {
  const row = element.closest('.product-row');
  if (!row) return;
  
  const quantityInput = row.querySelector('input[name="quantity"]');
  const unitPriceInput = row.querySelector('input[name="unitPrice"]');
  const rowTotalEl = row.querySelector('.row-total');
  
  if (!quantityInput || !unitPriceInput || !rowTotalEl) return;
  
  const quantity = parseFloat(quantityInput.value) || 0;
  const unitPrice = parseFloat(unitPriceInput.value) || 0;
  const total = quantity * unitPrice;
  
  rowTotalEl.textContent = formatCurrencyAdmin(total);
  calculateTotalAdmin();
}

function calculateTotalAdmin() {
  let totalAmount = 0;
  const rows = document.querySelectorAll('.product-row');
  
  rows.forEach(row => {
    const quantityInput = row.querySelector('input[name="quantity"]');
    const unitPriceInput = row.querySelector('input[name="unitPrice"]');
    
    if (quantityInput && unitPriceInput) {
      const quantity = parseFloat(quantityInput.value) || 0;
      const unitPrice = parseFloat(unitPriceInput.value) || 0;
      totalAmount += quantity * unitPrice;
    }
  });
  
  const totalAmountEl = document.getElementById('totalAmountAdmin');
  if (totalAmountEl) {
    totalAmountEl.textContent = formatCurrencyAdmin(totalAmount);
  }
}

function formatCurrencyAdmin(amount) {
  return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
}

// Validate form before submit
function validateForm() {
  const productRows = document.querySelectorAll('.product-row');
  if (productRows.length === 0) {
    if (typeof iziToast !== 'undefined') {
      iziToast.error({
        title: 'Lỗi',
        message: 'Vui lòng thêm ít nhất một sản phẩm vào đơn hàng!'
      });
    } else {
      alert('Vui lòng thêm ít nhất một sản phẩm vào đơn hàng!');
    }
    return false;
  }
  
  // Check if all products are selected
  let hasEmptyProduct = false;
  productRows.forEach(row => {
    const productSelect = row.querySelector('select[name="productId"]');
    if (!productSelect.value) {
      hasEmptyProduct = true;
    }
  });
  
  if (hasEmptyProduct) {
    if (typeof iziToast !== 'undefined') {
      iziToast.error({
        title: 'Lỗi',
        message: 'Vui lòng chọn sản phẩm cho tất cả các dòng!'
      });
    } else {
      alert('Vui lòng chọn sản phẩm cho tất cả các dòng!');
    }
    return false;
  }
  
  return true;
}
