<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Quản Lý Cài Đặt</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">

      <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Danh sách Cài Đặt Hệ Thống</h3>
        <a href="${pageContext.request.contextPath}/admin/manage-setting?action=add" class="btn btn-primary">
          <i class="fas fa-plus"></i> Thêm Cài Đặt Mới
        </a>
      </div>

      <div class="table-responsive">
        <table class="table table-bordered table-hover">
          <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Khóa</th>
            <th>Giá trị</th>
            <th>Hành động</th>
          </tr>
          </thead>
          <tbody>
          <c:choose>
            <c:when test="${not empty settings}">
              <c:forEach var="setting" items="${settings}" varStatus="loop">
                <tr>
                  <td>${loop.count}</td>
                  <td><code><c:out value="${setting.key}"/></code></td>
                  <td><c:out value="${setting.value}"/></td>
                  <td>
                    <a href="${pageContext.request.contextPath}/admin/manage-setting?action=edit&id=${setting.id}" class="btn btn-sm btn-info">Sửa</a>
                  </td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr>
                <td colspan="4" class="text-center">Không tìm thấy cài đặt nào.</td>
              </tr>
            </c:otherwise>
          </c:choose>
          </tbody>
        </table>
      </div>

    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>
<script>
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