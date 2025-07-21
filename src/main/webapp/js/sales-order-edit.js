document.addEventListener('DOMContentLoaded', function() {
  console.log('Sales Order Edit JS loaded');
  calculateTotalEdit();
});

function addProductRowEdit() {
  var container = document.getElementById('productContainer');
  var row = document.createElement('div');
  row.className = 'row mb-2 product-row';
  row.innerHTML = `
    <div class="col-md-3">
      <select class="form-select" name="productId[]" onchange="updateProductInfoEdit(this)" required>
        ${document.querySelector('#productContainer select').innerHTML}
      </select>
    </div>
    <div class="col-md-2">
      <input type="number" class="form-control" name="quantity[]" min="1" value="1" 
             oninput="calculateRowTotalEdit(this)" onchange="calculateRowTotalEdit(this)" required>
    </div>
    <div class="col-md-2">
      <input type="number" class="form-control" name="unitPrice[]" step="0.01" min="0" value="0" 
             oninput="calculateRowTotalEdit(this)" onchange="calculateRowTotalEdit(this)" required>
    </div>
    <div class="col-md-2">
      <div class="form-control-plaintext fw-bold text-success row-total">0 đ</div>
    </div>
    <div class="col-md-2">
      <span class="form-control-plaintext unit-display"></span>
    </div>
    <div class="col-md-1">
      <button type="button" class="btn btn-danger btn-sm" onclick="removeProductRowEdit(this)">Xóa</button>
    </div>
  `;
  container.appendChild(row);
  calculateTotalEdit();
}

function removeProductRowEdit(button) {
  button.closest('.product-row').remove();
  calculateTotalEdit();
}

function updateProductInfoEdit(selectElement) {
  const selectedOption = selectElement.options[selectElement.selectedIndex];
  const row = selectElement.closest('.product-row');
  const priceInput = row.querySelector('input[name="unitPrice[]"]');
  const unitDisplay = row.querySelector('.unit-display');
  
  if (!selectedOption || !selectedOption.value) {
    if (priceInput) priceInput.value = '0';
    if (unitDisplay) unitDisplay.textContent = '';
    calculateRowTotalEdit(selectElement);
    return;
  }
  
  const price = selectedOption.getAttribute('data-price');
  const unit = selectedOption.getAttribute('data-unit');
  
  if (priceInput) priceInput.value = price || '0';
  if (unitDisplay) unitDisplay.textContent = unit || '';
  
  calculateRowTotalEdit(selectElement);
}

function calculateRowTotalEdit(element) {
  const row = element.closest('.product-row');
  if (!row) return;
  
  const quantityInput = row.querySelector('input[name="quantity[]"]');
  const unitPriceInput = row.querySelector('input[name="unitPrice[]"]');
  const rowTotalEl = row.querySelector('.row-total');
  
  if (!quantityInput || !unitPriceInput || !rowTotalEl) return;
  
  const quantity = parseFloat(quantityInput.value) || 0;
  const unitPrice = parseFloat(unitPriceInput.value) || 0;
  const total = quantity * unitPrice;
  
  rowTotalEl.textContent = formatCurrencyEdit(total);
  calculateTotalEdit();
}

function calculateTotalEdit() {
  let totalAmount = 0;
  const rows = document.querySelectorAll('.product-row');
  
  rows.forEach(row => {
    const quantityInput = row.querySelector('input[name="quantity[]"]');
    const unitPriceInput = row.querySelector('input[name="unitPrice[]"]');
    
    if (quantityInput && unitPriceInput) {
      const quantity = parseFloat(quantityInput.value) || 0;
      const unitPrice = parseFloat(unitPriceInput.value) || 0;
      totalAmount += quantity * unitPrice;
    }
  });
  
  const totalAmountEl = document.getElementById('totalAmount');
  if (totalAmountEl) {
    totalAmountEl.textContent = formatCurrencyEdit(totalAmount);
  }
}

function formatCurrencyEdit(amount) {
  return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
}
