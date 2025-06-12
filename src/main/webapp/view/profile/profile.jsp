<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Profile - Quản Lý Kho Hàng</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/styles/index.css" rel="stylesheet"/>

  <style>
    .sidebar {
      height: 100vh;
      background-color: #343a40 !important;
      background: #343a40 !important;
      box-shadow: 2px 0 5px rgba(0,0,0,0.1);
      position: fixed;
      top: 0;
      left: 0;
      z-index: 1000;
      overflow-y: auto;
      width: 250px;
    }

    .sidebar-sticky {
      position: sticky;
      top: 0;
      height: 100vh;
      padding: 0;
    }

    .sidebar-brand {
      background: rgba(0,0,0,0.2);
      border-bottom: 1px solid rgba(255,255,255,0.1);
      padding: 1.5rem 1rem;
    }

    .sidebar-brand h4 {
      color: #ffffff !important;
      margin-bottom: 0;
      font-size: 1.1rem;
      font-weight: 500;
    }
    .sidebar-nav {
      padding: 0.5rem 0;
    }

    .sidebar-nav .nav-item {
      margin-bottom: 0;
    }
    .sidebar .nav-link {
      color: rgba(255,255,255,0.9) !important;
      text-decoration: none;
      padding: 0.875rem 1.5rem;
      margin: 0;
      border-radius: 0;
      transition: all 0.2s ease;
      display: block;
      font-size: 0.9rem;
      font-weight: 400;
      border-left: 3px solid transparent;
      border-bottom: 1px solid rgba(255,255,255,0.05);
    }

    .sidebar .nav-link:hover {
      background-color: rgba(255,255,255,0.08) !important;
      color: #ffffff !important;
      border-left: 3px solid #28a745;
    }

    .sidebar .nav-link.active {
      background-color: #28a745 !important;
      color: #ffffff !important;
      border-left: 3px solid #28a745;
      font-weight: 500;
    }
    .main-content {
      margin-left: 250px !important;
      width: calc(100% - 250px) !important;
      min-height: 100vh;
    }
    @media (max-width: 767.98px) {
      .sidebar {
        position: fixed;
        top: 0;
        left: -250px;
        width: 250px;
        height: 100vh;
        z-index: 1050;
        transition: left 0.3s ease;
      }

      .sidebar.show {
        left: 0;
      }

      .main-content {
        margin-left: 0 !important;
        width: 100% !important;
      }
    }
    .sidebar::-webkit-scrollbar {
      width: 6px;
    }

    .sidebar::-webkit-scrollbar-track {
      background: rgba(255,255,255,0.1);
    }

    .sidebar::-webkit-scrollbar-thumb {
      background: rgba(255,255,255,0.3);
      border-radius: 3px;
    }

    .sidebar::-webkit-scrollbar-thumb:hover {
      background: rgba(255,255,255,0.5);
    }
  </style>
</head>
<body>
    
    <jsp:include page="/view/common/sidebar.jsp" />
    
<div class="container-fluid">
  <div class="row">
 
    <main class="main-content px-4 py-4">
      <div class="d-flex justify-content-between align-items-center pb-3 mb-3 border-bottom">
        <div class="d-flex align-items-center">
          <button class="btn btn-outline-secondary d-md-none me-3" type="button" id="sidebarToggle">
            <i class="fas fa-bars"></i>
          </button>
          <h2 class="mb-0">👤 Thông Tin Cá Nhân</h2>
        </div>
        <div class="dropdown">
          <button class="btn btn-outline-primary dropdown-toggle" type="button" data-bs-toggle="dropdown">
            👤 ${user.fullName}
          </button>
          <ul class="dropdown-menu dropdown-menu-end">
            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">👤 Xem Profile</a></li>
            <li><hr class="dropdown-divider"></li>
            <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">🚪 Đăng xuất</a></li>
          </ul>
        </div>
      </div>

      <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
          ${sessionScope.errorMessage}
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
      </c:if>

      <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
          ${sessionScope.successMessage}
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
      </c:if>

      <div class="row">
        <!-- Profile Information -->
        <div class="col-md-6">
          <div class="card">
            <div class="card-header">
              <h5>Thông Tin Tài Khoản</h5>
            </div>
            <div class="card-body">
              <form action="${pageContext.request.contextPath}/profile" method="post">
                <input type="hidden" name="action" value="updateProfile">

                <div class="mb-3">
                  <label class="form-label">Tên đăng nhập</label>
                  <input type="text" class="form-control" value="${user.username}" readonly>
                </div>

                <div class="mb-3">
                  <label class="form-label">Họ và tên</label>
                  <input type="text" name="fullName" class="form-control" value="${user.fullName}" required>
                </div>
                
                <div class="mb-3">
                  <label class="form-label">Phone</label>
                  <input type="text" name="phone" class="form-control" value="${user.phone}"
                        maxlength="10" pattern="\d{10}" inputmode="numeric" required
                        oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 10);" >
                </div>
                <div class="mb-3">
                  <label class="form-label">Email</label>
                  <input type="text" class="form-control" value="${user.email}" readonly>
                </div>

                <div class="mb-3">
                  <label class="form-label">Vai trò</label>
                   <input type="text" class="form-control" value="${user.roleId}" readonly>
<!--                  <select name="role" class="form-select" required>
                    <option value="warehouse_staff" ${user.roleId == 'warehouse_staff' ? 'selected' : ''}>Nhân viên kho</option>
                    <option value="sales_staff" ${user.roleId == 'sales_staff' ? 'selected' : ''}>Nhân viên bán hàng</option>
                    <option value="purchasing_staff" ${user.roleId == 'purchasing_staff' ? 'selected' : ''}>Nhân viên mua hàng</option>
                    <option value="admin" ${user.roleId == 'admin' ? 'selected' : ''}>Quản trị viên</option>
                  </select>-->
                </div>

                <div class="mb-3">
                  <label class="form-label">Ngày tạo</label>
                  <input type="text" class="form-control" value="<fmt:formatDate value='${user.createdAt}' pattern='dd/MM/yyyy HH:mm'/>" readonly>
                </div>

                <button type="submit" class="btn btn-primary">Cập nhật thông tin</button>
              </form>
            </div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card">
            <div class="card-header">
              <h5>Đổi Mật Khẩu</h5>
            </div>
            <div class="card-body">
              <form action="${pageContext.request.contextPath}/profile" method="post">
                <input type="hidden" name="action" value="changePassword">

                <div class="mb-3">
                  <label class="form-label">Mật khẩu hiện tại</label>
                  <input type="password" name="currentPassword" class="form-control" required>
                </div>

                <div class="mb-3">
                  <label class="form-label">Mật khẩu mới</label>
                  <input type="password" name="newPassword" class="form-control" required>
                  <div class="form-text">Ít nhất 6 ký tự, bao gồm chữ và số</div>
                </div>

                <div class="mb-3">
                  <label class="form-label">Xác nhận mật khẩu mới</label>
                  <input type="password" name="confirmPassword" class="form-control" required>
                </div>

                <button type="submit" class="btn btn-warning">Đổi mật khẩu</button>
              </form>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebar = document.querySelector('.sidebar');

    if (sidebarToggle && sidebar) {
        sidebarToggle.addEventListener('click', function() {
            sidebar.classList.toggle('show');
        });
        document.addEventListener('click', function(e) {
            if (window.innerWidth < 768) {
                if (!sidebar.contains(e.target) && !sidebarToggle.contains(e.target)) {
                    sidebar.classList.remove('show');
                }
            }
        });
    }
    const sidebarLinks = document.querySelectorAll('.sidebar .nav-link');
    sidebarLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            // Add loading effect
            this.style.opacity = '0.7';
            setTimeout(() => {
                this.style.opacity = '1';
            }, 200);
        });
    });
});
</script>
</body>
</html>
