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
        <div class="row mb-2">
          <div class="col-md-6">
            <label class="form-label">Mã đơn hàng</label>
            <input type="text" class="form-control" value="${order.orderCode}" readonly>
          </div>
          <div class="col-md-6">
            <label class="form-label">Khách hàng</label>
            <input type="text" class="form-control" name="customerName" value="${order.customerName}" required>
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-md-6">
            <label class="form-label">Ngày đặt</label>
            <input type="date" class="form-control" name="orderDate" value="<fmt:formatDate value='${order.orderDate}' pattern='yyyy-MM-dd'/>" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Ghi chú</label>
            <input type="text" class="form-control" name="notes" value="${order.notes}">
          </div>
        </div>
      </div>
    </div>
    <h5>Danh sách sản phẩm</h5>
    <div id="productContainer">
      <c:forEach var="detail" items="${orderDetailsWithProduct}" varStatus="status">
        <div class="row mb-2 product-row">
          <div class="col-md-4">
            <select class="form-select" name="productId" required>
              <c:forEach var="p" items="${products}">
                <option value="${p['productId']}" data-price="${p['salePrice']}" data-quantity="${p['quantity']}" data-unit="${p['unit']}"
                  <c:if test="${p['productId'] == detail.productId}">selected</c:if>>
                  ${p['productCode']} - ${p['productName']} (${p['unit']})
                </option>
              </c:forEach>
            </select>
          </div>
          <div class="col-md-2">
            <input type="number" class="form-control" name="quantity" min="1" value="${detail.quantityOrdered}" required>
          </div>
          <div class="col-md-2">
            <input type="number" class="form-control" name="unitPrice" step="0.01" min="0" value="${detail.unitSalePrice}" required>
          </div>
          <div class="col-md-2">
            <span class="form-control-plaintext">${detail.unit}</span>
          </div>
          <div class="col-md-2">
            <button type="button" class="btn btn-danger btn-sm" onclick="this.closest('.product-row').remove()">Xóa</button>
          </div>
        </div>
      </c:forEach>
    </div>
    <button type="button" class="btn btn-success mb-3" onclick="addProductRowEdit()">+ Thêm sản phẩm</button>
    <div class="d-flex justify-content-end">
      <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
    </div>
  </form>
</div>
<script>
function addProductRowEdit() {
  var container = document.getElementById('productContainer');
  var row = document.createElement('div');
  row.className = 'row mb-2 product-row';
  row.innerHTML = `
    <div class="col-md-4">
      <select class="form-select" name="productId" required>
        ${document.querySelector('#productContainer select').innerHTML}
      </select>
    </div>
    <div class="col-md-2">
      <input type="number" class="form-control" name="quantity" min="1" value="1" required>
    </div>
    <div class="col-md-2">
      <input type="number" class="form-control" name="unitPrice" step="0.01" min="0" value="0" required>
    </div>
    <div class="col-md-2">
      <span class="form-control-plaintext"></span>
    </div>
    <div class="col-md-2">
      <button type="button" class="btn btn-danger btn-sm" onclick="this.closest('.product-row').remove()">Xóa</button>
    </div>
  `;
  container.appendChild(row);
}
</script>
</body>
</html> 