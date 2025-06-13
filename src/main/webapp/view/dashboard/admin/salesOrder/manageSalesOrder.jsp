<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Quản Lý Đơn Bán Hàng - Admin</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
  <style>
    .status-transition-info {
      font-size: 0.8em;
      color: #6c757d;
      margin-top: 5px;
    }
    .dropdown-item:hover {
      background-color: #f8f9fa;
    }
    .dropdown-item-text {
      font-style: italic;
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
        <h3>Quản Lý Đơn Bán Hàng</h3>
<!--        <div>
          <a href="${pageContext.request.contextPath}/admin/manage-sales-order?action=create" class="btn btn-success">+ Tạo Đơn Hàng</a>
        </div>-->
      </div>
      
      <!-- Status Workflow Info -->
      <div class="alert alert-info mb-4">
        <h6><i class="fas fa-info-circle"></i> Quy trình chuyển trạng thái đơn hàng:</h6>
        <small>
          <strong>Chờ kiểm tra kho</strong> → Chờ giao hàng, Đã hủy<br/>
          <strong>Chờ giao hàng</strong> → Đã giao, Chờ kiểm tra kho (nếu cần kiểm tra lại), Đã hủy<br/>
          <strong>Đã giao</strong> → Hoàn thành, Chờ giao hàng (nếu cần giao lại), Đã hủy<br/>
          <strong>Hoàn thành</strong> → Đã giao (nếu cần xử lý vấn đề)<br/>
          <strong>Đã hủy</strong> → Chờ kiểm tra kho (khôi phục đơn hàng)
        </small>
      </div>

      <!-- Filter Form -->
      <form action="${pageContext.request.contextPath}/admin/manage-sales-order" method="GET" class="row g-3 mb-4">
        <input type="hidden" name="action" value="list">
        <div class="col-md-2">
          <input type="text" name="customer" class="form-control" placeholder="Tên khách hàng..." value="${customerFilter}"/>
        </div>
        <div class="col-md-2">
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
          <select name="userId" class="form-select">
            <option value="">-- Tất cả nhân viên --</option>
            <c:forEach var="staff" items="${salesStaff}">
              <option value="${staff.userId}" ${userIdFilter eq staff.userId.toString() ? 'selected' : ''}>${staff.fullName}</option>
            </c:forEach>
          </select>
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-primary w-100">Lọc</button>
        </div>
      </form>

      <div class="table-responsive-lg">
        <table class="table table-bordered table-hover">
          <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Mã đơn hàng</th>
            <th>Tên khách hàng</th>
            <th>Nhân viên tạo</th>
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
                  <td>
                    <c:set var="creator" value="${userDAO.findById(order.userId)}" />
                    <c:choose>
                      <c:when test="${creator != null}">
                        ${creator.fullName}
                      </c:when>
                      <c:otherwise>
                        <span class="text-muted">N/A</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
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
                    <div class="btn-group-vertical btn-group-sm" role="group">
                      <a href="${pageContext.request.contextPath}/admin/manage-sales-order?action=view&id=${order.salesOrderId}" class="btn btn-outline-primary btn-sm">Xem</a>
                      <a href="${pageContext.request.contextPath}/admin/manage-sales-order?action=edit&id=${order.salesOrderId}" class="btn btn-info btn-sm">Sửa</a>
                      
                      <!-- Status update dropdown -->
                      <div class="dropdown">
                        <button class="btn btn-outline-secondary btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
                          Trạng thái
                        </button>
                        <ul class="dropdown-menu">
                          <c:set var="validStatuses" value="${orderValidStatuses[order.salesOrderId]}" />
                          <c:choose>
                            <c:when test="${not empty validStatuses}">
                              <c:forEach var="validStatus" items="${validStatuses}">
                                <li>
                                  <a class="dropdown-item" 
                                     href="${pageContext.request.contextPath}/admin/manage-sales-order?action=update-status&id=${order.salesOrderId}&status=${validStatus}"
                                     onclick="return confirm('Bạn có chắc chắn muốn chuyển trạng thái đơn hàng từ &quot;${statusDisplayNames[order.status]}&quot; thành &quot;${statusDisplayNames[validStatus]}&quot;?')">
                                    ${statusDisplayNames[validStatus]}
                                  </a>
                                </li>
                              </c:forEach>
                            </c:when>
                            <c:otherwise>
                              <li><span class="dropdown-item-text text-muted">Không thể thay đổi trạng thái</span></li>
                            </c:otherwise>
                          </c:choose>
                        </ul>
                      </div>
                      
                      <button class="btn btn-danger btn-sm" onclick="confirmDelete('${order.salesOrderId}', '${order.orderCode}')">Xóa</button>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr>
                <td colspan="9" class="text-center">Không tìm thấy đơn hàng nào.</td>
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
              <c:url var="prevPageUrl" value="/admin/manage-sales-order">
                <c:param name="action" value="list"/>
                <c:param name="page" value="${currentPage - 1}"/>
                <c:if test="${not empty statusFilter}"><c:param name="status" value="${statusFilter}"/></c:if>
                <c:if test="${not empty customerFilter}"><c:param name="customer" value="${customerFilter}"/></c:if>
                <c:if test="${not empty userIdFilter}"><c:param name="userId" value="${userIdFilter}"/></c:if>
              </c:url>
              <a class="page-link" href="${prevPageUrl}">Trước</a>
            </li>
            <c:forEach begin="1" end="${totalPages}" var="i">
              <c:url var="pageUrl" value="/admin/manage-sales-order">
                <c:param name="action" value="list"/>
                <c:param name="page" value="${i}"/>
                <c:if test="${not empty statusFilter}"><c:param name="status" value="${statusFilter}"/></c:if>
                <c:if test="${not empty customerFilter}"><c:param name="customer" value="${customerFilter}"/></c:if>
                <c:if test="${not empty userIdFilter}"><c:param name="userId" value="${userIdFilter}"/></c:if>
              </c:url>
              <li class="page-item ${currentPage == i ? 'active' : ''}">
                <a class="page-link" href="${pageUrl}">${i}</a>
              </li>
            </c:forEach>
            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
              <c:url var="nextPageUrl" value="/admin/manage-sales-order">
                <c:param name="action" value="list"/>
                <c:param name="page" value="${currentPage + 1}"/>
                <c:if test="${not empty statusFilter}"><c:param name="status" value="${statusFilter}"/></c:if>
                <c:if test="${not empty customerFilter}"><c:param name="customer" value="${customerFilter}"/></c:if>
                <c:if test="${not empty userIdFilter}"><c:param name="userId" value="${userIdFilter}"/></c:if>
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
  function confirmDelete(orderId, orderCode) {
    if (confirm('Bạn có chắc chắn muốn xóa đơn hàng "' + orderCode + '"? Hành động này không thể hoàn tác.')) {
      window.location.href = '${pageContext.request.contextPath}/admin/manage-sales-order?action=delete&id=' + orderId;
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