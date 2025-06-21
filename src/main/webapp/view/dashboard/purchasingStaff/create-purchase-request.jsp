<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Yêu Cầu Nhập Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp"/>
            
            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2"><i class="fas fa-plus-circle me-2"></i>Tạo Yêu Cầu Nhập Hàng</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/purchase-staff/purchase-request" 
                           class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-1"></i>Quay lại
                        </a>
                    </div>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        ${sessionScope.successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>

                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        ${sessionScope.errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <!-- Purchase Request Form -->
                <form method="POST" action="${pageContext.request.contextPath}/purchase-staff/purchase-request?action=create">
                    <div class="row">
                        <!-- Request Information -->
                        <div class="col-md-6">
                            <div class="card mb-4">
                                <div class="card-header">
                                    <h5 class="card-title mb-0">Thông tin yêu cầu</h5>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label for="warehouseId" class="form-label">Kho nhập hàng <span class="text-danger">*</span></label>
                                        <select class="form-select" id="warehouseId" name="warehouseId" required>
                                            <option value="">Chọn kho...</option>
                                            <c:forEach var="warehouse" items="${warehouses}">
                                                <option value="${warehouse.warehouseId}">
                                                    ${warehouse.warehouseName} - ${warehouse.address}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label for="notes" class="form-label">Ghi chú lý do</label>
                                        <textarea class="form-control" id="notes" name="notes" rows="4" 
                                                  placeholder="Nhập lý do yêu cầu nhập hàng..."></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Add Product -->
                        <div class="col-md-6">
                            <div class="card mb-4">
                                <div class="card-header">
                                    <h5 class="card-title mb-0">Thêm sản phẩm nhanh</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row g-2">
                                        <div class="col-6">
                                            <select class="form-select" id="quickProductSelect">
                                                <option value="">Chọn sản phẩm...</option>
                                                <c:forEach var="product" items="${products}">
                                                    <option value="${product.productId}" 
                                                            data-name="${product.productName}"
                                                            data-code="${product.productCode}"
                                                            data-unit="${product.unit}">
                                                        ${product.productCode} - ${product.productName}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-3">
                                            <input type="number" class="form-control" id="quickQuantity" 
                                                   placeholder="Số lượng" min="1">
                                        </div>
                                        <div class="col-3">
                                            <button type="button" class="btn btn-primary w-100" onclick="addProduct()">
                                                <i class="fas fa-plus"></i> Thêm
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Product List -->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="card-title mb-0">Danh sách sản phẩm yêu cầu</h5>
                            <small class="text-muted">Tối thiểu 1 sản phẩm</small>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-borderless" id="productTable">
                                    <thead>
                                        <tr>
                                            <th width="30%">Sản phẩm <span class="text-danger">*</span></th>
                                            <th width="15%">Số lượng <span class="text-danger">*</span></th>
                                            <th width="25%">Nhà cung cấp đề xuất</th>
                                            <th width="25%">Ghi chú</th>
                                            <th width="5%">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody id="productTableBody">
                                        <!-- Default row -->
                                        <tr>
                                            <td>
                                                <select class="form-select" name="productId" required>
                                                    <option value="">Chọn sản phẩm...</option>
                                                    <c:forEach var="product" items="${products}">
                                                        <option value="${product.productId}">
                                                            ${product.productCode} - ${product.productName}
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </td>
                                            <td>
                                                <input type="number" class="form-control" name="quantity" 
                                                       min="1" required placeholder="0">
                                            </td>
                                            <td>
                                                <select class="form-select" name="supplierId">
                                                    <option value="">Chọn nhà cung cấp...</option>
                                                    <c:forEach var="supplier" items="${suppliers}">
                                                        <option value="${supplier.supplierId}">
                                                            ${supplier.supplierName}
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </td>
                                            <td>
                                                <input type="text" class="form-control" name="productNotes" 
                                                       placeholder="Ghi chú cho sản phẩm">
                                            </td>
                                            <td>
                                                <button type="button" class="btn btn-sm btn-outline-danger" 
                                                        onclick="removeProduct(this)" title="Xóa sản phẩm">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            <div class="text-center mt-3">
                                <button type="button" class="btn btn-outline-primary" onclick="addEmptyProduct()">
                                    <i class="fas fa-plus me-1"></i>Thêm sản phẩm
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Submit Buttons -->
                    <div class="card">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-12 text-end">
                                    <a href="${pageContext.request.contextPath}/purchase-staff/purchase-request" 
                                       class="btn btn-secondary me-2">
                                        <i class="fas fa-times me-1"></i>Hủy
                                    </a>
                                    <button type="submit" class="btn btn-success">
                                        <i class="fas fa-save me-1"></i>Tạo yêu cầu
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    let productRowIndex = 1;

    function addProduct() {
        const productSelect = document.getElementById('quickProductSelect');
        const quantityInput = document.getElementById('quickQuantity');
        
        if (productSelect.value && quantityInput.value) {
            const selectedOption = productSelect.options[productSelect.selectedIndex];
            const productId = selectedOption.value;
            const productName = selectedOption.dataset.name;
            const productCode = selectedOption.dataset.code;
            
            // Check if product already exists
            const existingSelects = document.querySelectorAll('select[name="productId"]');
            let productExists = false;
            for (let select of existingSelects) {
                if (select.value === productId) {
                    alert('Sản phẩm này đã được thêm vào danh sách!');
                    productExists = true;
                    break;
                }
            }
            
            if (!productExists) {
                addProductRow(productId, productName + ' (' + productCode + ')', quantityInput.value);
                productSelect.value = '';
                quantityInput.value = '';
            }
        } else {
            alert('Vui lòng chọn sản phẩm và nhập số lượng!');
        }
    }

    function addProductRow(productId = '', productDisplay = '', quantity = '') {
        const tbody = document.getElementById('productTableBody');
        const newRow = document.createElement('tr');
        
        newRow.innerHTML = `
            <td>
                <select class="form-select" name="productId" required>
                    <option value="">Chọn sản phẩm...</option>
                    <c:forEach var="product" items="${products}">
                        <option value="${product.productId}" ${productId == '${product.productId}' ? 'selected' : ''}>
                            ${product.productCode} - ${product.productName}
                        </option>
                    </c:forEach>
                </select>
            </td>
            <td>
                <input type="number" class="form-control" name="quantity" 
                       min="1" required placeholder="0" value="${quantity}">
            </td>
            <td>
                <select class="form-select" name="supplierId">
                    <option value="">Chọn nhà cung cấp...</option>
                    <c:forEach var="supplier" items="${suppliers}">
                        <option value="${supplier.supplierId}">
                            ${supplier.supplierName}
                        </option>
                    </c:forEach>
                </select>
            </td>
            <td>
                <input type="text" class="form-control" name="productNotes" 
                       placeholder="Ghi chú cho sản phẩm">
            </td>
            <td>
                <button type="button" class="btn btn-sm btn-outline-danger" 
                        onclick="removeProduct(this)" title="Xóa sản phẩm">
                    <i class="fas fa-trash"></i>
                </button>
            </td>
        `;
        
        tbody.appendChild(newRow);
        productRowIndex++;
    }

    function addEmptyProduct() {
        addProductRow();
    }

    function removeProduct(button) {
        const tbody = document.getElementById('productTableBody');
        if (tbody.children.length > 1) {
            button.closest('tr').remove();
        } else {
            alert('Phải có ít nhất 1 sản phẩm trong yêu cầu!');
        }
    }

    // Form validation
    document.querySelector('form').addEventListener('submit', function(e) {
        const productSelects = document.querySelectorAll('select[name="productId"]');
        let hasValidProduct = false;
        
        for (let select of productSelects) {
            if (select.value) {
                hasValidProduct = true;
                break;
            }
        }
        
        if (!hasValidProduct) {
            e.preventDefault();
            alert('Vui lòng chọn ít nhất 1 sản phẩm!');
        }
    });
    </script>
</body>
</html> 