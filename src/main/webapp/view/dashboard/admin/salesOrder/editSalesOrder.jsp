<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Chỉnh sửa đơn bán hàng - Admin</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
  <style>
    .product-row {
      border: 1px solid #dee2e6;
      border-radius: 5px;
      padding: 10px;
      margin-bottom: 10px;
      background-color: #f8f9fa;
    }
    .product-header {
      background-color: #e9ecef;
      border-radius: 5px;
      padding: 8px;
      margin-bottom: 10px;
      font-weight: bold;
    }
    .alert-warning {
      border-left: 4px solid #ffc107;
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
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Chỉnh sửa đơn bán hàng</h3>
        <div>
          <a href="${pageContext.request.contextPath}/admin/manage-sales-order?action=view&id=${order.salesOrderId}" class="btn btn-info me-2">👁️ Xem chi tiết</a>
          <a href="${pageContext.request.contextPath}/admin/manage-sales-order?action=list" class="btn btn-secondary">← Quay lại danh sách</a>
        </div>
      </div>

      <!-- Warning about edit restrictions -->
      <div class="alert alert-warning mb-4">
        <h6><i class="fas fa-exclamation-triangle"></i> Lưu ý về chỉnh sửa đơn hàng:</h6>
        <small>
          Chỉ có thể chỉnh sửa đơn hàng khi trạng thái là <strong>"Chờ kiểm tra kho"</strong>. 
          Sau khi chuyển sang trạng thái khác, đơn hàng sẽ không thể chỉnh sửa được nữa.
        </small>
      </div>

      <form action="${pageContext.request.contextPath}/admin/manage-sales-order" method="POST">
        <input type="hidden" name="action" value="edit">
        <input type="hidden" name="id" value="${order.salesOrderId}">

        <!-- Order Information Card -->
        <div class="card mb-4">
          <div class="card-header">
            <h5 class="mb-0">Thông tin đơn hàng</h5>
          </div>
          <div class="card-body">
            <div class="row mb-3">
              <div class="col-md-6">
                <label class="form-label"><strong>Mã đơn hàng</strong></label>
                <input type="text" class="form-control" value="${order.orderCode}" readonly>
              </div>
              <div class="col-md-6">
                <label class="form-label"><strong>Trạng thái hiện tại</strong></label>
                <div class="form-control-plaintext">
                  <span class="badge bg-warning">Chờ kiểm tra kho</span>
                </div>
              </div>
            </div>
            <div class="row mb-3">
              <div class="col-md-6">
                <label class="form-label"><strong>Tên khách hàng</strong> <span class="text-danger">*</span></label>
                <input type="text" class="form-control" name="customerName" value="${order.customerName}" required>
              </div>
              <div class="col-md-6">
                <label class="form-label"><strong>Ngày đặt hàng</strong> <span class="text-danger">*</span></label>
                <input type="date" class="form-control" name="orderDate" value="<fmt:formatDate value='${order.orderDate}' pattern='yyyy-MM-dd'/>" required>
              </div>
            </div>
            <div class="row mb-3">
              <div class="col-md-6">
                <label class="form-label"><strong>Nhân viên phụ trách</strong> <span class="text-danger">*</span></label>
                <select class="form-select" name="userId" required>
                  <c:forEach var="staff" items="${salesStaff}">
                    <option value="${staff.userId}" ${order.userId == staff.userId ? 'selected' : ''}>${staff.fullName}</option>
                  </c:forEach>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label"><strong>Người tạo đơn</strong></label>
                <div class="form-control-plaintext">
                  <c:choose>
                    <c:when test="${creator != null}">
                      ${creator.fullName}
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted">N/A</span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
            <div class="row mb-2">
              <div class="col-md-12">
                <label class="form-label"><strong>Ghi chú</strong></label>
                <textarea class="form-control" name="notes" rows="2" placeholder="Nhập ghi chú cho đơn hàng...">${order.notes}</textarea>
              </div>
            </div>
          </div>
        </div>

        <!-- Products Section -->
        <div class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Danh sách sản phẩm</h5>
            <button type="button" class="btn btn-success btn-sm" onclick="addProductRow()">
              <i class="fas fa-plus"></i> Thêm sản phẩm
            </button>
          </div>
          <div class="card-body">
            <!-- Product Headers -->
            <div class="product-header">
              <div class="row">
                <div class="col-md-4">Sản phẩm</div>
                <div class="col-md-2">Số lượng</div>
                <div class="col-md-2">Đơn giá</div>
                <div class="col-md-2">Đơn vị</div>
                <div class="col-md-2">Hành động</div>
              </div>
            </div>
            
            <!-- Product Container -->
            <div id="productContainer">
              <c:choose>
                <c:when test="${not empty orderDetailsWithProduct}">
                  <c:forEach var="detail" items="${orderDetailsWithProduct}" varStatus="status">
                    <div class="product-row">
                      <div class="row align-items-center">
                        <div class="col-md-4">
                          <select class="form-select" name="productId" required onchange="updateProductInfo(this)">
                            <option value="">-- Chọn sản phẩm --</option>
                            <c:forEach var="p" items="${products}">
                              <option value="${p.productId}" 
                                      data-price="${p.salePrice}" 
                                      data-quantity="${p.quantity}" 
                                      data-unit="${p.unit}"
                                      ${p.productId == detail.productId ? 'selected' : ''}>
                                ${p.productCode} - ${p.productName}
                              </option>
                            </c:forEach>
                          </select>
                        </div>
                        <div class="col-md-2">
                          <input type="number" class="form-control" name="quantity" min="1" 
                                 value="${detail.quantityOrdered}" required 
                                 title="Số lượng tồn kho: ${detail.availableQuantity}">
                          <small class="text-muted">Tồn: ${detail.availableQuantity}</small>
                        </div>
                        <div class="col-md-2">
                          <input type="number" class="form-control" name="unitPrice" step="0.01" min="0" 
                                 value="${detail.unitSalePrice}" required>
                        </div>
                        <div class="col-md-2">
                          <span class="form-control-plaintext">${detail.unit}</span>
                        </div>
                        <div class="col-md-2">
                          <button type="button" class="btn btn-danger btn-sm" onclick="removeProductRow(this)">
                            <i class="fas fa-trash"></i> Xóa
                          </button>
                        </div>
                      </div>
                    </div>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <div class="text-center text-muted py-3">
                    <p>Chưa có sản phẩm nào. Nhấn "Thêm sản phẩm" để bắt đầu.</p>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-end mt-4">
          <button type="button" class="btn btn-secondary me-2" onclick="window.history.back()">Hủy</button>
          <button type="submit" class="btn btn-primary">
            <i class="fas fa-save"></i> Lưu thay đổi
          </button>
        </div>
      </form>
    </main>
  </div>
</div>

<!-- Products data for JavaScript -->
<script type="text/javascript">
  const productsData = [
    <c:forEach var="p" items="${products}" varStatus="status">
    {
      id: ${p.productId},
      code: '${p.productCode}',
      name: '${p.productName}',
      unit: '${p.unit}',
      price: ${p.salePrice},
      quantity: ${p.quantity}
    }<c:if test="${!status.last}">,</c:if>
    </c:forEach>
  ];
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

<script>
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
      '<div class="col-md-4">' +
        '<select class="form-select" name="productId" required onchange="updateProductInfo(this)">' +
          productOptions +
        '</select>' +
      '</div>' +
      '<div class="col-md-2">' +
        '<input type="number" class="form-control" name="quantity" min="1" value="1" required>' +
        '<small class="text-muted">Tồn: <span class="stock-info">0</span></small>' +
      '</div>' +
      '<div class="col-md-2">' +
        '<input type="number" class="form-control" name="unitPrice" step="0.01" min="0" value="0" required>' +
      '</div>' +
      '<div class="col-md-2">' +
        '<span class="form-control-plaintext unit-info"></span>' +
      '</div>' +
      '<div class="col-md-2">' +
        '<button type="button" class="btn btn-danger btn-sm" onclick="removeProductRow(this)">' +
          '<i class="fas fa-trash"></i> Xóa' +
        '</button>' +
      '</div>' +
    '</div>';
  
  container.appendChild(row);
}

function removeProductRow(button) {
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
}

function updateProductInfo(selectElement) {
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
}

// Validate form before submit
document.querySelector('form').addEventListener('submit', function(e) {
  const productRows = document.querySelectorAll('.product-row');
  if (productRows.length === 0) {
    e.preventDefault();
    iziToast.error({
      title: 'Lỗi',
      message: 'Vui lòng thêm ít nhất một sản phẩm vào đơn hàng!'
    });
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
    e.preventDefault();
    iziToast.error({
      title: 'Lỗi',
      message: 'Vui lòng chọn sản phẩm cho tất cả các dòng!'
    });
    return false;
  }
});
</script>

<!-- Toast messages -->
<c:if test="${not empty sessionScope.toastMessage}">
  <c:set var="toastMsg" value="${sessionScope.toastMessage}" />
  <c:set var="toastTyp" value="${sessionScope.toastType}" />
  <script>
    var toastMessage = '<c:out value="${toastMsg}" escapeXml="true"/>';
    var toastType = '<c:out value="${toastTyp}" escapeXml="true"/>';
    
    if (toastType === 'success') {
      iziToast.success({
        title: 'Thành công',
        message: toastMessage
      });
    } else if (toastType === 'error') {
      iziToast.error({
        title: 'Lỗi',
        message: toastMessage
      });
    } else if (toastType === 'warning') {
      iziToast.warning({
        title: 'Cảnh báo',
        message: toastMessage
      });
    }
  </script>
  <c:remove var="toastMessage" scope="session"/>
  <c:remove var="toastType" scope="session"/>
</c:if>

</body>
</html> 