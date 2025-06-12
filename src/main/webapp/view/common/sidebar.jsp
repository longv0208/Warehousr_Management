<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="model.User" %>
<%@ page import="utils.SessionUtil" %>
<%
    User currentUser = SessionUtil.getUserFromSession(request);
    String userRole = (currentUser != null) ? currentUser.getRoleId() : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sidebar Fixed Icons</title>

    <!-- Bootstrap & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
    <link href="./styles/sidebar.css" rel="stylesheet" />
    <style>
        body {
    margin: 0;
    background-color: #f8f9fa;
    font-family: 'Segoe UI', sans-serif;
}

.sidebar {
    position: fixed;
    top: 0;
    left: 0;
    height: 100vh;
    background-color: #343a40;
    overflow-x: hidden;
    padding-top: 20px;
    z-index: 1000;
    width: 250px;
}


.user-section {
    text-align: center;
    margin-bottom: 30px;
    position: relative;
}

.user-avatar-icon {
    font-size: 50px;
    color: #0d6efd;
    cursor: pointer;
    transition: color 0.3s ease;
}

.user-avatar-icon:hover {
    color: #0a58ca;
}

.user-name {
    color: white;
    font-size: 14px;
    margin-top: 8px;

}


.dropdown-menu-user {
    position: absolute;
    top: 60px;
    left: 50%;
    transform: translateX(-50%);
    background-color: #343a40;
    border: 1px solid #0d6efd;
    border-radius: 6px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.3);
    width: 180px;
    display: none;
    flex-direction: column;
    z-index: 1100;
}

.dropdown-menu-user .dropdown-item {
    color: #ced4da;
    padding: 10px 15px;
    text-decoration: none;
    transition: background-color 0.2s ease;
}

.dropdown-menu-user .dropdown-item:hover {
    background-color: #0d6efd;
    color: white;
}

.dropdown-divider {
    border-top: 1px solid #495057;
    margin: 5px 0;
}

ul#sidebarnav {
    padding-left: 0;
    margin: 0;
    list-style: none;
}

ul#sidebarnav li a.nav-link {
    position: relative;
    display: block;
    color: white;
    padding: 12px 20px 12px 24px;
    text-decoration: none;
    height: 48px;
}

ul#sidebarnav li a.nav-link i {
    position: absolute;
    top: 50%;
    left: 24px;
    transform: translateY(-50%);
    font-size: 1.3rem;
}

ul#sidebarnav li a .link-text {
    margin-left: 60px;

    white-space: nowrap;
}

ul#sidebarnav li a.nav-link:hover,
ul#sidebarnav li a.nav-link.active {
    background-color: #0d6efd;
    color: white !important;
    
    .inactive {
    color: gray;
    background-color: #f0f0f0;
}
}</style>
</head>
<body>
    
    <nav class="sidebar" id="sidebar">
        <div class="user-section" id="userSection">
            <div class="user-avatar-wrapper" style="position: relative; display: inline-block;">
                <i class="bi bi-person-circle user-avatar-icon" 
                   id="userAvatar"></i>
                <div class="user-name">
                    <%= currentUser != null ? currentUser.getFullName() : "Khách" %>
                </div>
                <div class="dropdown-menu-user" id="dropdownUserMenu">
                    <a href="${pageContext.request.contextPath}/profile" class="dropdown-item">
                        <i class="bi bi-person-circle me-2"></i>Thông tin cá nhân
                    </a>
                    <hr class="dropdown-divider" />
                    <a href="${pageContext.request.contextPath}/logout" class="dropdown-item">
                        <i class="bi bi-box-arrow-right me-2"></i>Đăng xuất
                    </a>
                </div>
            </div>
        </div>

        <ul class="nav flex-column" id="sidebarnav">
            <!-- Dashboard - Admin only -->
            <% if ("admin".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="bi bi-speedometer2"></i><span class="link-text">Dashboard</span></a>
            </li>
            <% } %>
            
            <!-- Quản lý danh mục - Admin only -->
            <% if ("admin".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-category" class="nav-link"><i class="bi bi-tags"></i><span class="link-text">Danh mục</span></a>
            </li>
            <% } %>
            
            <!-- Quản lý sản phẩm - Admin only -->
            <% if ("admin".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-product" class="nav-link"><i class="bi bi-box-seam"></i><span class="link-text">Sản phẩm</span></a>
            </li>
            <% } %>
            
            <!-- Quản lý nhà cung cấp - Admin only -->
            <% if ("admin".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-supplier" class="nav-link"><i class="bi bi-truck"></i><span class="link-text">Nhà cung cấp</span></a>
            </li>
            <% } %>
            
            <!-- Quản lý đơn bán hàng - Admin only -->
            <% if ("admin".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-sales-order" class="nav-link"><i class="bi bi-receipt"></i><span class="link-text">Đơn bán hàng</span></a>
            </li>
            <% } %>
            
            <!-- Quản lý đơn mua hàng - Admin only -->
            <% if ("admin".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-purchase-order" class="nav-link"><i class="bi bi-cart-plus"></i><span class="link-text">Đơn mua hàng</span></a>
            </li>
            <% } %>
            
            <!-- Đơn bán hàng - sales_staff only -->
            <% if ("sales_staff".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/sale-staff/sales-order" class="nav-link"><i class="bi bi-receipt"></i><span class="link-text">Đơn bán hàng</span></a>
            </li>
            <% } %>
            
            <!-- Nhập kho - purchasing_staff only -->
            <% if ("purchasing_staff".equals(userRole)) { %>
            <li class="nav-item">
                <a href="stockin.jsp" class="nav-link"><i class="bi bi-arrow-down-circle"></i><span class="link-text">Nhập kho</span></a>
            </li>
            <% } %>
            
            <!-- Xuất kho - sales_staff only -->
            <% if ("sales_staff".equals(userRole)) { %>
            <li class="nav-item">
                <a href="stockout.jsp" class="nav-link"><i class="bi bi-arrow-up-circle"></i><span class="link-text">Xuất kho</span></a>
            </li>
            <% } %>
            
            <!-- Kiểm kê - admin and warehouse_staff -->
            <% if ("admin".equals(userRole) || "warehouse_staff".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/stock-take" class="nav-link"><i class="bi bi-journal-check"></i><span class="link-text">Kiểm kê</span></a>
            </li>
            <% } %>
            
            <!-- Đơn mua hàng - purchasing_staff only -->
            <% if ("purchasing_staff".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/purchasing-staff/purchase-order" class="nav-link"><i class="bi bi-cart-plus"></i><span class="link-text">Đơn mua hàng</span></a>
            </li>
            <% } %>
            
            <!-- Yêu cầu mua - purchasing_staff only -->
            <% if ("purchasing_staff".equals(userRole)) { %>
            <li class="nav-item">
                <a href="purchaserequest.jsp" class="nav-link"><i class="bi bi-bag-plus"></i><span class="link-text">Yêu cầu mua</span></a>
            </li>
            <% } %>
            
            <!-- Quản lý người dùng - Admin only -->
            <% if ("admin".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/UserServlet" class="nav-link"><i class="bi bi-people"></i><span class="link-text">Quản lý người dùng</span></a>
            </li>
            <% } %>
            
            <!-- Cài đặt - Admin only -->
            <% if ("admin".equals(userRole)) { %>
            <li class="nav-item">
                <a href="${pageContext.request.contextPath}/admin/manage-setting" class="nav-link"><i class="bi bi-box-seam"></i><span class="link-text">Cài đặt</span></a>
            </li>
            <% } %>
        </ul>
    </nav>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(function () {
            // Gán active cho link đang mở
            var url = window.location.href;
            $('#sidebarnav a').each(function () {
                if (this.href === url) {
                    $(this).addClass('active');
                }
            });

            // Toggle dropdown khi click vào avatar
            $('#userAvatar').click(function (e) {
                e.preventDefault();
                e.stopPropagation();
                $('#dropdownUserMenu').toggle();
            });

            // Đóng dropdown khi click ra ngoài
            $(document).click(function (e) {
                if (!$(e.target).closest('.user-avatar-wrapper').length) {
                    $('#dropdownUserMenu').hide();
                }
            });

            // Ngăn dropdown đóng khi click vào chính nó
            $('#dropdownUserMenu').click(function (e) {
                e.stopPropagation();
            });
        });
    </script>
</body>
</html>
