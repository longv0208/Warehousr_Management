<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <title>Chi tiết đơn bán hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
</head>
<body>
<div class="container mt-4">
  <h3>Chi tiết đơn bán hàng</h3>
  <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=list" class="btn btn-secondary mb-3">← Quay lại</a>
  <div class="card mb-4">
    <div class="card-body">
      <div class="row mb-2">
        <div class="col-md-6"><strong>Mã đơn hàng:</strong> ${order.orderCode}</div>
        <div class="col-md-6"><strong>Khách hàng:</strong> ${order.customerName}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-6"><strong>Ngày đặt:</strong> <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy"/></div>
        <div class="col-md-6"><strong>Trạng thái:</strong> ${order.status}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-12"><strong>Ghi chú:</strong> ${order.notes}</div>
      </div>
    </div>
  </div>
  <h5>Danh sách sản phẩm</h5>
  <table class="table table-bordered">
    <thead>
      <tr>
        <th>Mã SP</th>
        <th>Tên SP</th>
        <th>Đơn vị</th>
        <th>Số lượng</th>
        <th>Đơn giá</th>
        <th>Thành tiền</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="detail" items="${orderDetailsWithProduct}">
        <tr>
          <td>${detail.productCode}</td>
          <td>${detail.productName}</td>
          <td>${detail.unit}</td>
          <td>${detail.quantityOrdered}</td>
          <td><fmt:formatNumber value="${detail.unitSalePrice}" type="currency" currencySymbol="đ"/></td>
          <td><fmt:formatNumber value="${detail.totalPrice}" type="currency" currencySymbol="đ"/></td>
        </tr>
      </c:forEach>
    </tbody>
    <tfoot>
      <tr>
        <th colspan="5" class="text-end">Tổng cộng</th>
        <th><fmt:formatNumber value="${totalOrderValue}" type="currency" currencySymbol="đ"/></th>
      </tr>
    </tfoot>
  </table>
</div>
</body>
</html> 