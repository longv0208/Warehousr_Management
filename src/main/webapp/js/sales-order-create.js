let productRowIndex = 0;

document.addEventListener('DOMContentLoaded', function () {
  console.log('Sales Order Create JS loaded');

  // Add first product row if products are available
  if (typeof hasProducts !== 'undefined' && hasProducts) {
    addProductRow();
  } else {
    showError('Không có sản phẩm nào có sẵn để tạo đơn hàng.');
  }

  // Add event listener for warehouse selection
  const warehouseSelect = document.getElementById('warehouseId');
  if (warehouseSelect) {
    warehouseSelect.addEventListener('change', function () {
      updateAllStockQuantities();
    });
  }
});

function addProductRow() {
  const tpl = document.getElementById('productOptionsTemplate');
  if (!tpl) {
    console.error('Product options template not found');
    return;
  }

  const container = document.getElementById('productContainer');
  const rowIndex = productRowIndex++;
  const rowWrapper = document.createElement('div');
  rowWrapper.className = 'product-row row mb-3 align-items-center';
  rowWrapper.id = 'productRow' + rowIndex;

  rowWrapper.innerHTML = `
      <div class="col-md-4">
          <label class="form-label d-md-none">Sản phẩm</label>
          <select class="form-select" name="productId[]" onchange="updateProductInfo(this, ${rowIndex})" required></select>
      </div>
      <div class="col-md-2">
          <label class="form-label d-md-none">Số lượng</label>
          <input type="number" class="form-control" name="quantity[]" min="1" value="1" oninput="calculateRowTotal(${rowIndex})" onchange="calculateRowTotal(${rowIndex})" required>
          <small class="text-muted">Tồn: <span id="stockQuantity${rowIndex}" class="text-muted">Chọn SP</span></small>
      </div>
      <div class="col-md-2">
          <label class="form-label d-md-none">Đơn giá</label>
          <input type="number" class="form-control" name="unitPrice[]" step="any" min="0" value="0" oninput="calculateRowTotal(${rowIndex})" onchange="calculateRowTotal(${rowIndex})" required>
      </div>
      <div class="col-md-2">
          <label class="form-label d-md-none">Thành tiền</label>
          <div class="form-control-plaintext fw-bold text-success" id="rowTotal${rowIndex}">0 đ</div>
      </div>
      <div class="col-md-2">
          <label class="form-label d-md-none">&nbsp;</label>
          <button type="button" class="btn btn-danger btn-sm d-block w-100" onclick="removeProductRow(${rowIndex})">Xóa</button>
      </div>
  `;

  container.appendChild(rowWrapper);

  const selectElement = rowWrapper.querySelector('select[name="productId[]"]');
  const optionsFragment = document.importNode(tpl.content, true);
  selectElement.appendChild(optionsFragment);

  // Trigger warehouse check for the new row if a warehouse is already selected
  const warehouseId = document.getElementById('warehouseId').value;
  if (warehouseId) {
    updateProductInfo(selectElement, rowIndex);
  }
}

function removeProductRow(index) {
  const row = document.getElementById('productRow' + index);
  if (row) {
    row.remove();
    calculateTotal();
  }
}

function updateAllStockQuantities() {
  const productRows = document.querySelectorAll('.product-row');
  productRows.forEach(row => {
    const select = row.querySelector('select[name^="productId"]');
    if (select && select.value) {
      const index = parseInt(row.id.replace('productRow', ''));
      // Clear current stock display first
      const stockSpan = document.getElementById('stockQuantity' + index);
      if (stockSpan) {
        stockSpan.textContent = '...';
        stockSpan.className = 'text-muted';
      }
      // Fetch new inventory data
      fetchInventory(select.value, index);
    } else {
      // If no product selected, show appropriate message
      const index = parseInt(row.id.replace('productRow', ''));
      const stockSpan = document.getElementById('stockQuantity' + index);
      if (stockSpan) {
        stockSpan.textContent = 'Chọn SP';
        stockSpan.className = 'text-muted';
      }
    }
  });
}

function updateProductInfo(selectElement, index) {
  const selectedOption = selectElement.options[selectElement.selectedIndex];
  const row = selectElement.closest('.product-row');
  const priceInput = row.querySelector('input[name^="unitPrice"]');
  const quantityInput = row.querySelector('input[name^="quantity"]');
  const rowTotalDiv = row.querySelector('#rowTotal' + index);
  const stockSpan = document.getElementById('stockQuantity' + index);

  if (!selectedOption || !selectedOption.value) {
    // Reset everything when no product is selected
    if (priceInput) priceInput.value = '';
    if (quantityInput) quantityInput.value = '1';
    if (rowTotalDiv) rowTotalDiv.textContent = '0 đ';
    if (stockSpan) {
      stockSpan.textContent = 'Chọn SP';
      stockSpan.className = 'text-muted';
    }
    // Remove quantity constraints
    if (quantityInput) quantityInput.removeAttribute('max');
    calculateTotal();
    return;
  }

  // Set price from product data
  const price = selectedOption.getAttribute('data-price');
  if (priceInput) priceInput.value = price || '0';
  if (quantityInput && !quantityInput.value) quantityInput.value = '1';

  // Fetch inventory for the selected product and warehouse
  fetchInventory(selectElement.value, index);
  calculateRowTotal(index);
}

function fetchInventory(productId, index) {
  const warehouseId = document.getElementById('warehouseId').value;
  const stockSpan = document.getElementById('stockQuantity' + index);
  const quantityInput = document.getElementById('productRow' + index).querySelector('input[name^="quantity"]');

  if (!warehouseId) {
    stockSpan.textContent = 'Chọn kho';
    stockSpan.className = 'text-warning fw-bold';
    quantityInput.removeAttribute('max');
    return;
  }
  if (!productId) {
    stockSpan.textContent = 'Chọn SP';
    stockSpan.className = 'text-muted';
    quantityInput.removeAttribute('max');
    return;
  }

  // Show loading state
  stockSpan.textContent = '...';
  stockSpan.className = 'text-muted';

  // Build URL without template literals to avoid JSP conflicts
  const contextPath = document.querySelector('meta[name="context-path"]') ?
    document.querySelector('meta[name="context-path"]').content : '';
  const url = contextPath + '/sale-staff/sales-order?action=get-inventory&productId=' + productId + '&warehouseId=' + warehouseId;

  fetch(url)
    .then(response => {
      if (!response.ok) throw new Error('Network response was not ok');
      return response.json();
    })
    .then(data => {
      if (data.error) throw new Error(data.error);

      const stock = data.quantity || 0;
      stockSpan.textContent = stock;

      // Set visual feedback based on stock level
      if (stock <= 0) {
        stockSpan.className = 'text-danger fw-bold';
      } else if (stock <= 10) {
        stockSpan.className = 'text-warning fw-bold';
      } else {
        stockSpan.className = 'text-success';
      }

      // Set max constraint for quantity input
      quantityInput.max = stock;

      // Add real-time validation for quantity input
      quantityInput.addEventListener('input', function () {
        const currentQty = parseInt(quantityInput.value, 10) || 0;
        if (currentQty > stock) {
          stockSpan.classList.remove('text-success', 'text-warning');
          stockSpan.classList.add('text-danger', 'fw-bold');
        } else if (stock <= 0) {
          stockSpan.className = 'text-danger fw-bold';
        } else if (stock <= 10) {
          stockSpan.className = 'text-warning fw-bold';
        } else {
          stockSpan.className = 'text-success';
        }
      });
    })
    .catch(error => {
      console.error('Error fetching inventory:', error);
      stockSpan.textContent = 'Lỗi';
      stockSpan.className = 'text-danger fw-bold';
    });
}

function calculateRowTotal(index) {
  const row = document.getElementById('productRow' + index);
  if (!row) return;

  const quantityInput = row.querySelector('input[name^="quantity"]');
  const unitPriceInput = row.querySelector('input[name^="unitPrice"]');
  const rowTotalEl = document.getElementById('rowTotal' + index);

  if (!quantityInput || !unitPriceInput || !rowTotalEl) return;

  const quantity = parseFloat(quantityInput.value) || 0;
  const unitPrice = parseFloat(unitPriceInput.value) || 0;
  const total = quantity * unitPrice;

  // Format currency in Vietnamese style
  rowTotalEl.textContent = formatCurrency(total);

  calculateTotal();
}

function calculateTotal() {
  let totalAmount = 0;
  const rows = document.querySelectorAll('.product-row');

  rows.forEach(row => {
    const quantityInput = row.querySelector('input[name^="quantity"]');
    const unitPriceInput = row.querySelector('input[name^="unitPrice"]');

    if (quantityInput && unitPriceInput) {
      const quantity = parseFloat(quantityInput.value) || 0;
      const unitPrice = parseFloat(unitPriceInput.value) || 0;
      totalAmount += quantity * unitPrice;
    }
  });

  const totalAmountEl = document.getElementById('totalAmount');
  if (totalAmountEl) {
    totalAmountEl.textContent = formatCurrency(totalAmount);
  }
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
}

function showError(message) {
  if (typeof iziToast !== 'undefined') {
    iziToast.error({
      title: 'Lỗi',
      message: message
    });
  } else {
    alert('Lỗi: ' + message);
  }
}

// Bootstrap form validation
(function () {
  'use strict'
  var forms = document.querySelectorAll('.needs-validation')
  Array.prototype.slice.call(forms)
    .forEach(function (form) {
      form.addEventListener('submit', function (event) {
        if (!form.checkValidity()) {
          event.preventDefault()
          event.stopPropagation()
        }
        form.classList.add('was-validated')
      }, false)
    })
})() 