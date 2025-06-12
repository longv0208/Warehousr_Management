<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Quản Lý Danh Mục</title>
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
        <h3>Danh sách Danh Mục</h3>
        <div>
          <a href="${pageContext.request.contextPath}/admin/manage-category?action=create" class="btn btn-success">+ Thêm Danh Mục</a>
        </div>
      </div>

      <!-- Filter Form -->
      <form action="${pageContext.request.contextPath}/admin/manage-category" method="GET" class="row g-3 mb-4">
        <input type="hidden" name="action" value="list">
        <div class="col-md-4">
          <input type="text" id="searchInput" name="search" class="form-control" placeholder="Tìm theo tên danh mục..." value="${searchTerm}"/>
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-primary w-100">Tìm kiếm</button>
        </div>
        <div class="col-md-6"></div>
      </form>

      <div class="table-responsive">
        <table class="table table-bordered table-hover">
          <thead class="table-light">
          <tr>
            <th>#</th>
            <th>ID</th>
            <th>Tên Danh Mục</th>
            <th>Ngày Tạo</th>
            <th>Hành động</th>
          </tr>
          </thead>
          <tbody>
          <c:choose>
            <c:when test="${not empty categories}">
              <c:forEach var="category" items="${categories}" varStatus="loop">
                <tr>
                  <td>${(currentPage - 1) * 10 + loop.count}</td>
                  <td><c:out value="${category.categoryId}"/></td>
                  <td><c:out value="${category.categoryName}"/></td>
                  <td><fmt:formatDate value="${category.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                  <td>
                    <a href="${pageContext.request.contextPath}/admin/manage-category?action=edit&id=${category.categoryId}" class="btn btn-sm btn-info">Sửa</a>
                    <button class="btn btn-sm btn-danger" onclick="confirmDelete('${category.categoryId}', '${category.categoryName}')">Xóa</button>
                  </td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr>
                <td colspan="5" class="text-center">Không tìm thấy danh mục nào.</td>
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
              <c:url var="prevPageUrl" value="/admin/manage-category">
                <c:param name="action" value="list"/>
                <c:param name="page" value="${currentPage - 1}"/>
                <c:if test="${not empty searchTerm}"><c:param name="search" value="${searchTerm}"/></c:if>
              </c:url>
              <a class="page-link" href="${prevPageUrl}">Trước</a>
            </li>
            <c:forEach begin="1" end="${totalPages}" var="i">
              <c:url var="pageUrl" value="/admin/manage-category">
                <c:param name="action" value="list"/>
                <c:param name="page" value="${i}"/>
                <c:if test="${not empty searchTerm}"><c:param name="search" value="${searchTerm}"/></c:if>
              </c:url>
              <li class="page-item ${currentPage == i ? 'active' : ''}">
                <a class="page-link" href="${pageUrl}">${i}</a>
              </li>
            </c:forEach>
            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
              <c:url var="nextPageUrl" value="/admin/manage-category">
                <c:param name="action" value="list"/>
                <c:param name="page" value="${currentPage + 1}"/>
                <c:if test="${not empty searchTerm}"><c:param name="search" value="${searchTerm}"/></c:if>
              </c:url>
              <a class="page-link" href="${nextPageUrl}">Sau</a>
            </li>
          </ul>
        </nav>
      </c:if>

      <!-- Total Count -->
      <div class="mt-3">
        <small class="text-muted">Tổng cộng: ${totalCategories} danh mục</small>
      </div>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

<script>
  function confirmDelete(categoryId, categoryName) {
    if (confirm('Bạn có chắc chắn muốn xóa danh mục "' + categoryName + '"? Hành động này không thể hoàn tác.')) {
      window.location.href = '${pageContext.request.contextPath}/admin/manage-category?action=delete&id=' + categoryId;
    }
  }

  // Toast message display
  var toastMessage = "${sessionScope.toastMessage}";
  var toastType = "${sessionScope.toastType}";
  if (toastMessage) {
    iziToast.show({
      title: toastType === 'success' ? 'Thành công' : 'Lỗi',
      message: toastMessage,
      position: 'topRight',
      color: toastType === 'success' ? 'green' : 'red',
      timeout: 5000,
      onClosing: function () {
        // Remove toast attributes from the session after displaying
        fetch('${pageContext.request.contextPath}/remove-toast', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        }).then(response => {
          if (!response.ok) {
            console.error('Failed to remove toast attributes');
          }
        }).catch(error => {
          console.error('Error:', error);
        });
      }
    });
  }
</script>
</body>
</html> 