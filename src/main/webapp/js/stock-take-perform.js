// Stock Take Perform JavaScript Functions

// Global variables
let stockTakeId = '';
let contextPath = '';

// Initialize the page
function initializeStockTake(stockTakeIdParam, contextPathParam) {
    console.log('Initializing stock take with:', {
        stockTakeId: stockTakeIdParam,
        contextPath: contextPathParam
    });
    
    stockTakeId = stockTakeIdParam;
    contextPath = contextPathParam;
    
    // Initialize event listeners
    initializeEventListeners();
    
    // Calculate initial discrepancies
    calculateAllDiscrepancies();
    
    // Update initial statistics
    updateStatistics();
    
    console.log('Stock take initialization completed');
}

// Initialize all event listeners
function initializeEventListeners() {
    console.log('Initializing event listeners...');
    
    // Search functionality
    const searchInput = document.getElementById('searchProduct');
    if (searchInput) {
        searchInput.addEventListener('input', handleSearch);
        console.log('Search input listener added');
    }
    
    // Filter functionality
    const filterSelect = document.getElementById('filterStatus');
    if (filterSelect) {
        filterSelect.addEventListener('change', handleFilter);
        console.log('Filter select listener added');
    }
    
    // Input change listeners for all counted inputs
    const countedInputs = document.querySelectorAll('.counted-input');
    console.log('Found', countedInputs.length, 'counted inputs');
    
    countedInputs.forEach((input, index) => {
        // Store initial value
        input.setAttribute('data-initial-value', input.value || '');
        
        // Add event listeners
        input.addEventListener('input', handleInputChange);
        input.addEventListener('blur', handleInputBlur);
        
        console.log('Input', index + 1, '- systemQty:', input.getAttribute('data-system-qty'), 'value:', input.value);
    });
}

// Handle input changes
function handleInputChange(event) {
    const input = event.target;
    updateDiscrepancy(input);
    updateStatistics();
}

// Handle input blur (when user leaves the field)
function handleInputBlur(event) {
    const input = event.target;
    // Ensure the value is valid
    if (input.value !== '' && (isNaN(input.value) || parseFloat(input.value) < 0)) {
        input.value = '';
        updateDiscrepancy(input);
        updateStatistics();
    }
}

// Calculate discrepancy for a single input
function updateDiscrepancy(input) {
    try {
        const systemQtyAttr = input.getAttribute('data-system-qty');
        const systemQty = parseInt(systemQtyAttr);
        const countedValue = input.value.trim();
        const discrepancyCell = input.closest('tr').querySelector('.discrepancy-cell');
        
        console.log('Debug discrepancy calculation:', {
            systemQtyAttr: systemQtyAttr,
            systemQty: systemQty,
            countedValue: countedValue,
            isNaNSystemQty: isNaN(systemQty),
            isNaNCountedValue: isNaN(countedValue)
        });
        
        if (countedValue !== '' && !isNaN(countedValue)) {
            const countedQty = parseInt(countedValue);
            if (!isNaN(systemQty) && !isNaN(countedQty)) {
                const diff = countedQty - systemQty;
                let diffClass = '';
                let sign = '';
                
                if (diff > 0) {
                    diffClass = 'difference-positive';
                    sign = '+';
                } else if (diff < 0) {
                    diffClass = 'difference-negative';
                    sign = '';
                } else {
                    diffClass = 'difference-zero';
                    sign = '';
                }
                
                const spanHTML = '<span class="' + diffClass + '">' + sign + diff + '</span>';
                console.log('Setting discrepancy HTML:', spanHTML);
                discrepancyCell.innerHTML = spanHTML;
            } else {
                console.log('Clearing discrepancy - invalid numbers');
                discrepancyCell.innerHTML = '';
            }
        } else {
            console.log('Clearing discrepancy - empty or invalid input');
            discrepancyCell.innerHTML = '';
        }
    } catch (error) {
        console.error('Error updating discrepancy:', error);
        // Clear the discrepancy cell on error
        const discrepancyCell = input.closest('tr').querySelector('.discrepancy-cell');
        if (discrepancyCell) {
            discrepancyCell.innerHTML = '';
        }
    }
}

// Calculate discrepancies for all inputs
function calculateAllDiscrepancies() {
    const inputs = document.querySelectorAll('.counted-input');
    inputs.forEach(input => {
        if (input.value && input.value.trim() !== '') {
            updateDiscrepancy(input);
        }
    });
}

// Update statistics
function updateStatistics() {
    const inputs = document.querySelectorAll('.counted-input');
    const total = inputs.length;
    let counted = 0;
    
    inputs.forEach(input => {
        if (input.value && input.value.trim() !== '') {
            counted++;
        }
    });
    
    const remaining = total - counted;
    const percentage = total > 0 ? Math.round((counted / total) * 100) : 0;
    
    // Update DOM elements
    const countedElement = document.getElementById('countedItems');
    const remainingElement = document.getElementById('remainingItems');
    const percentageElement = document.getElementById('progressPercentage');
    const progressBar = document.getElementById('progressBar');
    
    if (countedElement) countedElement.textContent = counted;
    if (remainingElement) remainingElement.textContent = remaining;
    if (percentageElement) percentageElement.textContent = percentage + '%';
    
    if (progressBar) {
        progressBar.style.width = percentage + '%';
        
        // Update progress bar color
        if (percentage === 100) {
            progressBar.className = 'progress-bar bg-success';
        } else if (percentage >= 50) {
            progressBar.className = 'progress-bar bg-warning';
        } else {
            progressBar.className = 'progress-bar bg-danger';
        }
    }
}

// Handle search functionality
function handleSearch(event) {
    const searchTerm = event.target.value.toLowerCase();
    const rows = document.querySelectorAll('#stockTakeTable tbody tr');
    
    rows.forEach(row => {
        const productCode = (row.getAttribute('data-product-code') || '').toLowerCase();
        const productName = (row.getAttribute('data-product-name') || '').toLowerCase();
        
        if (productCode.includes(searchTerm) || productName.includes(searchTerm)) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

// Handle filter functionality
function handleFilter(event) {
    const filterValue = event.target.value;
    const rows = document.querySelectorAll('#stockTakeTable tbody tr');
    
    rows.forEach(row => {
        const input = row.querySelector('.counted-input');
        const discrepancyCell = row.querySelector('.discrepancy-cell');
        
        let show = true;
        
        if (filterValue === 'counted') {
            show = input.value && input.value.trim() !== '';
        } else if (filterValue === 'not-counted') {
            show = !input.value || input.value.trim() === '';
        } else if (filterValue === 'discrepancy') {
            const diffSpan = discrepancyCell.querySelector('span');
            show = diffSpan && !diffSpan.classList.contains('difference-zero');
        }
        
        row.style.display = show ? '' : 'none';
    });
}

// Show alert messages
function showAlert(message, type) {
    // Remove existing custom alerts
    const existingAlerts = document.querySelectorAll('.alert-custom');
    existingAlerts.forEach(alert => alert.remove());
    
    // Create new alert
    const alertDiv = document.createElement('div');
    alertDiv.className = 'alert alert-' + type + ' alert-dismissible fade show alert-custom';
    alertDiv.setAttribute('role', 'alert');
    alertDiv.innerHTML = message + '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';
    
    // Insert alert at the top of the main content
    const mainContent = document.querySelector('main');
    if (mainContent) {
        mainContent.insertBefore(alertDiv, mainContent.firstChild);
        
        // Auto-dismiss after 3 seconds
        setTimeout(function() {
            if (alertDiv && alertDiv.parentElement) {
                alertDiv.remove();
            }
        }, 3000);
    }
}

// Save all changes
function saveAllChanges() {
    const inputs = document.querySelectorAll('.counted-input');
    const changedInputs = [];
    
    // Find changed inputs
    inputs.forEach(input => {
        const currentValue = input.value.trim();
        const initialValue = input.getAttribute('data-initial-value') || '';
        
        if (currentValue !== '' && currentValue !== initialValue) {
            changedInputs.push(input);
        }
    });
    
    if (changedInputs.length === 0) {
        showAlert('Không có thay đổi nào để lưu!', 'warning');
        return;
    }
    
    // Validate all changed inputs
    for (let i = 0; i < changedInputs.length; i++) {
        const input = changedInputs[i];
        const value = input.value.trim();
        
        if (isNaN(value) || parseFloat(value) < 0) {
            showAlert('Vui lòng nhập số lượng hợp lệ cho tất cả sản phẩm!', 'danger');
            return;
        }
    }
    
    const totalItems = changedInputs.length;
    let savedCount = 0;
    let errorCount = 0;
    
    // Show progress
    showAlert('Đang lưu ' + totalItems + ' thay đổi...', 'info');
    
    // Disable save button
    const saveButton = document.querySelector('button[onclick="saveAllChanges()"]');
    if (saveButton) {
        saveButton.disabled = true;
        saveButton.textContent = 'Đang lưu...';
    }
    
    // Process each changed input
    changedInputs.forEach(function(input, index) {
        const detailId = input.getAttribute('data-detail-id');
        
        setTimeout(function() {
            const formData = new FormData();
            formData.append('action', 'update-count');
            formData.append('detailId', detailId);
            formData.append('stockTakeId', stockTakeId);
            formData.append('countedQuantity', input.value.trim());
            
            fetch(contextPath + '/stock-take', {
                method: 'POST',
                body: formData
            })
            .then(function(response) {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(function(result) {
                if (result.success) {
                    savedCount++;
                    // Update input's initial value to mark as saved
                    input.setAttribute('data-initial-value', input.value.trim());
                } else {
                    errorCount++;
                    console.error('Save failed for detail:', detailId, result.message);
                }
                
                // Check if all requests completed
                if (savedCount + errorCount === totalItems) {
                    handleSaveCompletion(savedCount, errorCount, totalItems, saveButton);
                }
            })
            .catch(function(error) {
                errorCount++;
                console.error('Error saving detail:', detailId, error);
                
                // Check if all requests completed
                if (savedCount + errorCount === totalItems) {
                    handleSaveCompletion(savedCount, errorCount, totalItems, saveButton);
                }
            });
        }, index * 100); // Delay to avoid overwhelming the server
    });
}

// Handle save completion
function handleSaveCompletion(savedCount, errorCount, totalItems, saveButton) {
    updateStatistics();
    
    // Re-enable save button
    if (saveButton) {
        saveButton.disabled = false;
        saveButton.textContent = 'Lưu tất cả thay đổi';
    }
    
    if (errorCount === 0) {
        showAlert('Lưu thành công tất cả ' + savedCount + ' thay đổi!', 'success');
    } else {
        showAlert('Lưu thành công ' + savedCount + '/' + totalItems + ' thay đổi. ' + errorCount + ' lỗi xảy ra!', 'warning');
    }
} 