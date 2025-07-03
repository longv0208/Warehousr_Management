<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Stock Inward</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>
    
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Create Stock Inward from PO: ${po.poCode}</h4>
                        <a href="purchasing?action=view-po&id=${po.poId}" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to Purchase Order
                        </a>
                    </div>
                    <div class="card-body">
                        <!-- Purchase Order Information -->
                        <div class="card mb-4">
                            <div class="card-header">
                                <h6 class="mb-0">Purchase Order Information</h6>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <table class="table table-borderless table-sm">
                                            <tr>
                                                <th width="120">PO Code:</th>
                                                <td>${po.poCode}</td>
                                            </tr>
                                            <tr>
                                                <th>Supplier:</th>
                                                <td>${supplier.supplierName}</td>
                                            </tr>
                                            <tr>
                                                <th>Warehouse:</th>
                                                <td>${warehouse.warehouseName}</td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div class="col-md-6">
                                        <table class="table table-borderless table-sm">
                                            <tr>
                                                <th width="140">Order Date:</th>
                                                <td>
                                                    <fmt:formatDate value="${po.orderDate}" pattern="dd/MM/yyyy"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Expected Delivery:</th>
                                                <td>
                                                    <fmt:formatDate value="${po.expectedDeliveryDate}" pattern="dd/MM/yyyy"/>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Stock Inward Form -->
                        <div class="mb-3">
                            <label for="notes" class="form-label">Notes</label>
                            <textarea class="form-control" id="notes" name="notes" rows="3" placeholder="Enter any notes about the delivery..."></textarea>
                        </div>
                        
                        <h5>Products Received</h5>
                        <div class="table-responsive">
                            <table class="table table-bordered">
                                <thead class="table-light">
                                    <tr>
                                        <th>Product Code</th>
                                        <th>Product Name</th>
                                        <th>Unit</th>
                                        <th>Ordered Quantity</th>
                                        <th>Unit Price</th>
                                        <th>Received Quantity <span class="text-danger">*</span></th>
                                        <th>Total Value</th>
                                    </tr>
                                </thead>
                                <tbody id="productsTableBody">
                                    <c:set var="totalValue" value="0" />
                                    <c:forEach var="detail" items="${poDetails}">
                                        <c:forEach var="product" items="${products}">
                                            <c:if test="${product.productId == detail.productId}">
                                                <tr>
                                                    <input type="hidden" name="productId" value="${product.productId}">
                                                    <input type="hidden" name="unitPrice" value="${detail.unitPrice}">
                                                    
                                                    <td>${product.productCode}</td>
                                                    <td>${product.productName}</td>
                                                    <td>${product.unit}</td>
                                                    <td>${detail.quantity}</td>
                                                    <td>
                                                        <fmt:formatNumber value="${detail.unitPrice}" type="currency" currencySymbol="₫"/>
                                                    </td>
                                                    <td>
                                                        <input type="number" 
                                                               class="form-control quantity-received" 
                                                               name="quantityReceived" 
                                                               min="0" 
                                                               max="${detail.quantity}"
                                                               value="${detail.quantity}"
                                                               data-unit-price="${detail.unitPrice}"
                                                               onchange="calculateRowValue(this)"
                                                               required>
                                                    </td>
                                                    <td>
                                                        <span class="row-value fw-bold">
                                                            <c:set var="lineValue" value="${detail.quantity * detail.unitPrice}" />
                                                            <fmt:formatNumber value="${lineValue}" type="currency" currencySymbol="₫"/>
                                                            <c:set var="totalValue" value="${totalValue + lineValue}" />
                                                        </span>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </c:forEach>
                                    </c:forEach>
                                </tbody>
                                <tfoot class="table-light">
                                    <tr>
                                        <td colspan="6" class="text-end fw-bold">Total Value:</td>
                                        <td class="fw-bold">
                                            <span id="totalValue">
                                                <fmt:formatNumber value="${totalValue}" type="currency" currencySymbol="₫"/>
                                            </span>
                                        </td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                        
                        <div class="alert alert-warning">
                            <strong>Important:</strong>
                            <ul class="mb-0">
                                <li><strong>Save:</strong> Creates the stock inward record but does not update inventory</li>
                                <li><strong>Create & Complete:</strong> Creates the record, updates inventory, and marks all related documents as completed</li>
                            </ul>
                        </div>
                        
                        <div class="d-flex justify-content-end gap-2 mt-4">
                            <a href="purchasing?action=view-po&id=${po.poId}" class="btn btn-secondary">Cancel</a>
                            <button type="button" class="btn btn-primary" onclick="submitForm('create-stock-inward')">
                                <i class="fas fa-save"></i> Save
                            </button>
                            <button type="button" class="btn btn-success" onclick="submitForm('create-and-complete-stock-inward')">
                                <i class="fas fa-check-circle"></i> Create & Complete
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden form for submission -->
    <form id="stockInwardForm" action="purchasing" method="post" style="display: none;">
        <input type="hidden" name="action" id="formAction">
        <input type="hidden" name="poId" value="${po.poId}">
        <textarea name="notes" id="hiddenNotes"></textarea>
        <div id="hiddenInputs"></div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function calculateRowValue(input) {
            const row = input.closest('tr');
            const unitPrice = parseFloat(input.dataset.unitPrice);
            const quantity = parseInt(input.value) || 0;
            const value = quantity * unitPrice;
            
            // Update row value
            const rowValueSpan = row.querySelector('.row-value');
            rowValueSpan.textContent = formatCurrency(value);
            
            // Update total value
            updateTotalValue();
        }
        
        function updateTotalValue() {
            let totalValue = 0;
            document.querySelectorAll('.quantity-received').forEach(input => {
                const unitPrice = parseFloat(input.dataset.unitPrice);
                const quantity = parseInt(input.value) || 0;
                totalValue += quantity * unitPrice;
            });
            
            document.getElementById('totalValue').textContent = formatCurrency(totalValue);
        }
        
        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            }).format(amount);
        }
        
        function submitForm(action) {
            // Validate form
            const quantityInputs = document.querySelectorAll('input[name="quantityReceived"]');
            let hasError = false;
            
            quantityInputs.forEach(input => {
                const value = parseInt(input.value);
                const max = parseInt(input.getAttribute('max'));
                
                if (isNaN(value) || value < 0 || value > max) {
                    hasError = true;
                    input.classList.add('is-invalid');
                } else {
                    input.classList.remove('is-invalid');
                }
            });
            
            if (hasError) {
                alert('Please enter valid received quantities (0 to ordered quantity)');
                return;
            }
            
            // Confirm action
            const message = action === 'create-and-complete-stock-inward' 
                ? 'This will create the stock inward, update inventory, and mark all related documents as completed. Continue?'
                : 'Create stock inward record?';
                
            if (!confirm(message)) {
                return;
            }
            
            // Set form action
            document.getElementById('formAction').value = action;
            
            // Copy notes
            document.getElementById('hiddenNotes').value = document.getElementById('notes').value;
            
            // Copy product data
            const hiddenInputs = document.getElementById('hiddenInputs');
            hiddenInputs.innerHTML = '';
            
            document.querySelectorAll('input[name="productId"]').forEach(input => {
                hiddenInputs.appendChild(input.cloneNode(true));
            });
            
            document.querySelectorAll('input[name="unitPrice"]').forEach(input => {
                hiddenInputs.appendChild(input.cloneNode(true));
            });
            
            document.querySelectorAll('input[name="quantityReceived"]').forEach(input => {
                hiddenInputs.appendChild(input.cloneNode(true));
            });
            
            // Submit form
            document.getElementById('stockInwardForm').submit();
        }
        
        // Initialize calculations
        document.addEventListener('DOMContentLoaded', function() {
            updateTotalValue();
        });
    </script>
</body>
</html> 