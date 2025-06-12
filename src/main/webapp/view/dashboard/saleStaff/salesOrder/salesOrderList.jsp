<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Đơn Bán Hàng - Sale Staff</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
      
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Đơn Bán Hàng Của Tôi</h3>
        <div>
          <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=create" class="btn btn-success">+ Tạo Đơn Hàng</a>
        </div>
      </div>

      <!-- Filter Form -->
      <form action="${pageContext.request.contextPath}/sale-staff/sales-order" method="GET" class="row g-3 mb-4">
        <input type="hidden" name="action" value="list">
        <div class="col-md-3">
          <input type="text" name="customer" class="form-control" placeholder="Tìm theo tên khách hàng..." value="${customerFilter}"/>
        </div>
        <div class="col-md-3">
          <select name="status" class="form-select">
            <option value="">-- Tất cả trạng thái --</option>
            <option value="pending_stock_check" ${statusFilter == 'pending_stock_check' ? 'selected' : ''}>Chờ kiểm tra kho</option>
            <option value="awaiting_shipment" ${statusFilter == 'awaiting_shipment' ? 'selected' : ''}>Chờ giao hàng</option>
            <option value="shipped" ${statusFilter == 'shipped' ? 'selected' : ''}>Đã giao</option>
            <option value="completed" ${statusFilter == 'completed' ? 'selected' : ''}>Hoàn thành</option>
            <option value="cancelled" ${statusFilter == 'cancelled' ? 'selected' : ''}>Đã hủy</option>
          </select>
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-primary w-100">Lọc</button>
        </div>
      </form>

      <div class="table-responsive">
        <table class="table table-bordered table-hover">
          <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Mã đơn hàng</th>
            <th>Tên khách hàng</th>
            <th>Ngày đặt</th>
            <th>Trạng thái</th>
            <th>Ghi chú</th>
            <th>Ngày tạo</th>
            <th>Hành động</th>
          </tr>
          </thead>
          <tbody>
          <c:choose>
            <c:when test="${not empty orders}">
              <c:forEach var="order" items="${orders}" varStatus="loop">
                <tr>
                  <td>${(currentPage - 1) * 10 + loop.count}</td>
                  <td><c:out value="${order.orderCode}"/></td>
                  <td><c:out value="${order.customerName}"/></td>
                  <td><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy"/></td>
                  <td>
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
                        <span class="badge bg-secondary">${order.status}</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty order.notes}">
                        <c:out value="${order.notes}"/>
                      </c:when>
                      <c:otherwise>
                        <span class="text-muted">Không có ghi chú</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td><fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                  <td>
                    <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=view&id=${order.salesOrderId}" class="btn btn-sm btn-outline-primary">Xem</a>
                    <c:if test="${order.status == 'pending_stock_check'}">
                      <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=edit&id=${order.salesOrderId}" class="btn btn-sm btn-info">Sửa</a>
                    </c:if>
                    <c:if test="${order.status == 'pending_stock_check' || order.status == 'awaiting_shipment'}">
                      <button class="btn btn-sm btn-danger" onclick="confirmCancel('${order.salesOrderId}', '${order.orderCode}')">Hủy</button>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr>
                <td colspan="8" class="text-center">Không tìm thấy đơn hàng nào.</td>
              </tr>
            </c:otherwise>
          </c:choose>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <c:if test="${totalPages > 1}">
        <nav aria-label="Page navigation">
          <ul class="pagination justify-content-center">
            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
              <c:url var="prevPageUrl" value="/sale-staff/sales-order">
                <c:param name="action" value="list"/>
                <c:param name="page" value="${currentPage - 1}"/>
                <c:if test="${not empty statusFilter}"><c:param name="status" value="${statusFilter}"/></c:if>
                <c:if test="${not empty customerFilter}"><c:param name="customer" value="${customerFilter}"/></c:if>
              </c:url>
              <a class="page-link" href="${prevPageUrl}">Trước</a>
            </li>
            <c:forEach begin="1" end="${totalPages}" var="i">
              <c:url var="pageUrl" value="/sale-staff/sales-order">
                <c:param name="action" value="list"/>
                <c:param name="page" value="${i}"/>
                <c:if test="${not empty statusFilter}"><c:param name="status" value="${statusFilter}"/></c:if>
                <c:if test="${not empty customerFilter}"><c:param name="customer" value="${customerFilter}"/></c:if>
              </c:url>
              <li class="page-item ${currentPage == i ? 'active' : ''}">
                <a class="page-link" href="${pageUrl}">${i}</a>
              </li>
            </c:forEach>
            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
              <c:url var="nextPageUrl" value="/sale-staff/sales-order">
                <c:param name="action" value="list"/>
                <c:param name="page" value="${currentPage + 1}"/>
                <c:if test="${not empty statusFilter}"><c:param name="status" value="${statusFilter}"/></c:if>
                <c:if test="${not empty customerFilter}"><c:param name="customer" value="${customerFilter}"/></c:if>
              </c:url>
              <a class="page-link" href="${nextPageUrl}">Sau</a>
            </li>
          </ul>
        </nav>
      </c:if>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

<script>
  function confirmCancel(orderId, orderCode) {
    if (confirm('Bạn có chắc chắn muốn hủy đơn hàng "' + orderCode + '"?')) {
      window.location.href = '${pageContext.request.contextPath}/sale-staff/sales-order?action=cancel&id=' + orderId;
    }
  }
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