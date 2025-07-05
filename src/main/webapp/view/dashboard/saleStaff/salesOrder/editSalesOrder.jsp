<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <title>Chỉnh sửa đơn bán hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
</head>
<body>
<div class="container mt-4">
  <h3>Chỉnh sửa đơn bán hàng</h3>
  <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=list" class="btn btn-secondary mb-3">← Quay lại</a>
  <form action="${pageContext.request.contextPath}/sale-staff/sales-order" method="POST">
    <input type="hidden" name="action" value="edit">
    <input type="hidden" name="id" value="${order.salesOrderId}">
    <div class="card mb-4">
      <div class="card-body">
        <div class="row mb-3">
          <div class="col-md-6">
            <label for="customerName" class="form-label">Tên khách hàng</label>
            <input type="text" class="form-control" id="customerName" name="customerName" value="${order.customerName}" required>
          </div>
          <div class="col-md-6">
            <label for="orderDate" class="form-label">Ngày đặt</label>
            <input type="date" class="form-control" id="orderDate" name="orderDate" value="<fmt:formatDate value='${order.orderDate}' pattern='yyyy-MM-dd'/>" required>
          </div>
        </div>
        <div class="row mb-3">
          <div class="col-md-6">
            <label for="warehouseId" class="form-label">Kho xuất hàng</label>
            <select class="form-select" id="warehouseId" name="warehouseId" required>
              <option value="" disabled>-- Chọn kho --</option>
              <c:forEach var="warehouse" items="${warehouses}">
                <option value="${warehouse.warehouseId}" ${warehouse.warehouseId == order.warehouseId ? 'selected' : ''}>
                  ${warehouse.warehouseName}
                </option>
              </c:forEach>
            </select>
          </div>
          <div class="col-md-6">
            <label for="notes" class="form-label">Ghi chú</label>
            <textarea class="form-control" id="notes" name="notes" rows="1">${order.notes}</textarea>
          </div>
        </div>
      </div>
    </div>
    <h5>Danh sách sản phẩm</h5>
    
    <!-- Product Table Header -->
    <div class="row fw-bold border-bottom mb-2 pb-2">
      <div class="col-md-3">Sản phẩm</div>
      <div class="col-md-2">Số lượng</div>
      <div class="col-md-2">Đơn giá</div>
      <div class="col-md-2">Thành tiền</div>
      <div class="col-md-2">Đơn vị</div>
      <div class="col-md-1">Thao tác</div>
    </div>
    
    <div id="productContainer">
      <c:forEach var="detail" items="${orderDetailsWithProduct}" varStatus="status">
        <div class="row mb-2 product-row">
          <div class="col-md-3">
            <select class="form-select" name="productId" onchange="updateProductInfoEdit(this)" required>
              <c:forEach var="p" items="${products}">
                <option value="${p['productId']}" data-price="${p['salePrice']}" data-quantity="${p['quantity']}" data-unit="${p['unit']}"
                  <c:if test="${p['productId'] == detail.productId}">selected</c:if>>
                  ${p['productCode']} - ${p['productName']}
                </option>
              </c:forEach>
            </select>
          </div>
          <div class="col-md-2">
            <input type="number" class="form-control" name="quantity" min="1" value="${detail.quantityOrdered}" 
                   oninput="calculateRowTotalEdit(this)" onchange="calculateRowTotalEdit(this)" required>
          </div>
          <div class="col-md-2">
            <input type="number" class="form-control" name="unitPrice" step="0.01" min="0" value="${detail.unitSalePrice}" 
                   oninput="calculateRowTotalEdit(this)" onchange="calculateRowTotalEdit(this)" required>
          </div>
          <div class="col-md-2">
            <div class="form-control-plaintext fw-bold text-success row-total">
              <fmt:formatNumber value="${detail.quantityOrdered * detail.unitSalePrice}" type="number" pattern="#,##0" /> đ
            </div>
          </div>
          <div class="col-md-2">
            <span class="form-control-plaintext unit-display">${detail.unit}</span>
          </div>
          <div class="col-md-1">
            <button type="button" class="btn btn-danger btn-sm" onclick="removeProductRowEdit(this)">Xóa</button>
          </div>
        </div>
      </c:forEach>
    </div>
    
    <button type="button" class="btn btn-success mb-3" onclick="addProductRowEdit()">+ Thêm sản phẩm</button>
    
    <!-- Total Amount -->
    <div class="row mt-3">
      <div class="col-md-6 offset-md-6">
        <div class="d-flex justify-content-between align-items-center border-top pt-3">
          <h5 class="mb-0 text-primary">Tổng tiền:</h5>
          <h5 class="mb-0 text-success fw-bold" id="totalAmount">0 đ</h5>
        </div>
      </div>
    </div>
    
    <div class="d-flex justify-content-end mt-3">
      <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
    </div>
  </form>
</div>
<!-- Include external JavaScript -->
<script src="${pageContext.request.contextPath}/js/sales-order-edit.js"></script>
</body>
</html> 