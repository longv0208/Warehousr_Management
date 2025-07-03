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
  <div class="row">
    <div class="col-md-8">
      <div class="card">
        <div class="card-header">
          <h5 class="card-title mb-0">Thông tin đơn hàng</h5>
        </div>
        <div class="card-body">
          <div class="row mb-3">
            <div class="col-md-6">
              <p><strong>Mã đơn hàng:</strong> <span class="badge bg-primary fs-6">${order.orderCode}</span></p>
              <p><strong>Tên khách hàng:</strong> ${order.customerName}</p>
            </div>
            <div class="col-md-6">
              <p><strong>Ngày đặt:</strong> <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy"/></p>
              <p><strong>Trạng thái:</strong> 
                <span class="badge 
                  <c:choose>
                    <c:when test="${order.status == 'pending_stock_check'}">bg-warning</c:when>
                    <c:when test="${order.status == 'awaiting_shipment'}">bg-info</c:when>
                    <c:when test="${order.status == 'shipped'}">bg-primary</c:when>
                    <c:when test="${order.status == 'completed'}">bg-success</c:when>
                    <c:when test="${order.status == 'cancelled'}">bg-danger</c:when>
                    <c:otherwise>bg-secondary</c:otherwise>
                  </c:choose>
                ">
                  <c:choose>
                    <c:when test="${order.status == 'pending_stock_check'}">Chờ kiểm kho</c:when>
                    <c:when test="${order.status == 'awaiting_shipment'}">Chờ giao hàng</c:when>
                    <c:when test="${order.status == 'shipped'}">Đã giao</c:when>
                    <c:when test="${order.status == 'completed'}">Hoàn thành</c:when>
                    <c:when test="${order.status == 'cancelled'}">Đã hủy</c:when>
                    <c:otherwise>${order.status}</c:otherwise>
                  </c:choose>
                </span>
              </p>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <p><strong>Nhân viên tạo:</strong> ${order.user.fullName}</p>
            </div>
            <div class="col-md-6">
              <p><strong>Kho xuất hàng:</strong> 
                <c:choose>
                  <c:when test="${not empty warehouse}">
                    ${warehouse.warehouseName}
                  </c:when>
                  <c:otherwise>
                    <span class="text-muted">Chưa chỉ định</span>
                  </c:otherwise>
                </c:choose>
              </p>
            </div>
          </div>
          <p><strong>Ghi chú:</strong> ${not empty order.notes ? order.notes : 'Không có'}</p>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card mb-4">
        <div class="card-body">
          <div class="row mb-2">
            <div class="col-md-12"><strong>Tổng cộng:</strong> <fmt:formatNumber value="${totalOrderValue}" type="currency" currencySymbol="đ"/></div>
          </div>
        </div>
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