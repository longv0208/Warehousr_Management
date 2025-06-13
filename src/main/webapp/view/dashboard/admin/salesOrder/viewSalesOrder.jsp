<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Chi tiết đơn bán hàng - Admin</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Chi tiết đơn bán hàng</h3>
        <a href="${pageContext.request.contextPath}/admin/manage-sales-order?action=list" class="btn btn-secondary">← Quay lại</a>
      </div>

      <div class="card mb-4">
        <div class="card-header">
          <h5 class="mb-0">Thông tin đơn hàng</h5>
        </div>
        <div class="card-body">
          <div class="row mb-3">
            <div class="col-md-6"><strong>Mã đơn hàng:</strong> <c:out value="${order.orderCode}"/></div>
            <div class="col-md-6"><strong>Khách hàng:</strong> <c:out value="${order.customerName}"/></div>
          </div>
          <div class="row mb-3">
            <div class="col-md-6"><strong>Ngày đặt:</strong> <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy"/></div>
            <div class="col-md-6">
              <strong>Trạng thái:</strong> 
              <c:choose>
                <c:when test="${order.status == 'pending_stock_check'}">
                  <span class="badge bg-warning">Chờ kiểm tra kho</span>
                </c:when>
                <c:when test="${order.status == 'awaiting_shipment'}">
                  <span class="badge bg-info">Chờ giao hàng</span>
                </c:when>
                <c:when test="${order.status == 'shipped'}">
                  <span class="badge bg-primary">Đã giao</span>
                </c:when>
                <c:when test="${order.status == 'completed'}">
                  <span class="badge bg-success">Hoàn thành</span>
                </c:when>
                <c:when test="${order.status == 'cancelled'}">
                  <span class="badge bg-danger">Đã hủy</span>
                </c:when>
                <c:otherwise>
                  <span class="badge bg-secondary"><c:out value="${order.status}"/></span>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <strong>Người tạo:</strong> 
              <c:choose>
                <c:when test="${creator != null}">
                  <c:out value="${creator.fullName}"/>
                </c:when>
                <c:otherwise>
                  <span class="text-muted">N/A</span>
                </c:otherwise>
              </c:choose>
            </div>
            <div class="col-md-6"><strong>Ngày tạo:</strong> <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
          </div>
          <div class="row mb-2">
            <div class="col-md-12">
              <strong>Ghi chú:</strong> 
              <c:choose>
                <c:when test="${not empty order.notes}">
                  <c:out value="${order.notes}"/>
                </c:when>
                <c:otherwise>
                  <span class="text-muted">Không có ghi chú</span>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <h5 class="mb-0">Danh sách sản phẩm</h5>
        </div>
        <div class="card-body">
          <div class="table-responsive">
            <table class="table table-bordered table-hover">
              <thead class="table-light">
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
                <c:choose>
                  <c:when test="${not empty orderDetailsWithProduct}">
                    <c:forEach var="detail" items="${orderDetailsWithProduct}">
                      <tr>
                        <td><c:out value="${detail.productCode}"/></td>
                        <td><c:out value="${detail.productName}"/></td>
                        <td><c:out value="${detail.unit}"/></td>
                        <td><c:out value="${detail.quantityOrdered}"/></td>
                        <td><fmt:formatNumber value="${detail.unitSalePrice}" type="currency" currencySymbol="₫"/></td>
                        <td><fmt:formatNumber value="${detail.totalPrice}" type="currency" currencySymbol="₫"/></td>
                      </tr>
                    </c:forEach>
                  </c:when>
                  <c:otherwise>
                    <tr>
                      <td colspan="6" class="text-center">Không có sản phẩm nào trong đơn hàng.</td>
                    </tr>
                  </c:otherwise>
                </c:choose>
              </tbody>
              <c:if test="${not empty orderDetailsWithProduct}">
                <tfoot class="table-light">
                  <tr>
                    <th colspan="5" class="text-end">Tổng cộng:</th>
                    <th><fmt:formatNumber value="${totalOrderValue}" type="currency" currencySymbol="₫"/></th>
                  </tr>
                </tfoot>
              </c:if>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 