<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="model.User" %>
<%@ page import="utils.SessionUtil" %>
<%
    User currentUser = SessionUtil.getUserFromSession(request);
    String userRole = (currentUser != null) ? currentUser.getRoleId() : "";
%>
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

    .main {
        margin-left: 250px; /* Same as sidebar width */
        padding: 20px;
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
    }

    .inactive {
        color: gray;
        background-color: #f0f0f0;
    }

    .sidebar .nav-item .collapse .nav-link,
    .sidebar .nav-item .collapsing .nav-link {
        padding: 10px 20px 10px 70px; /* Indent sub-items */
        font-size: 0.9em;
        background-color: #2c3136;
    }

    .sidebar .nav-item .collapse .nav-link:hover,
    .sidebar .nav-item .collapsing .nav-link:hover {
        background-color: #0d6efd;
    }
</style>
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
        <!-- ============================================================== -->
        <!-- Admin-specific items -->
        <!-- ============================================================== -->
        <% if ("admin".equals(userRole)) { %>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="bi bi-people"></i><span class="link-text">Dashboard</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-user" class="nav-link"><i class="bi bi-people"></i><span class="link-text">Người dùng</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-notification" class="nav-link"><i class="bi bi-bell"></i><span class="link-text">Thông báo</span></a>
        </li>
        <li class="nav-item">
            <a class="nav-link" data-bs-toggle="collapse" href="#activityCollapse" role="button" aria-expanded="false" aria-controls="activityCollapse">
                <i class="bi bi-shield-check"></i><span class="link-text">Giám sát hoạt động</span>
            </a>
            <div class="collapse" id="activityCollapse">
                <ul class="nav flex-column ms-1">
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/admin/activity-log?action=login-history" class="nav-link">
                            <span class="link-text">Lịch sử đăng nhập</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/admin/activity-log?action=after-hours" class="nav-link">
                            <span class="link-text">Đăng nhập ngoài giờ</span>
                        </a>
                    </li>
                </ul>
            </div>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-setting" class="nav-link">
                <i class="bi bi-gear"></i><span class="link-text">Cài đặt hệ thống</span>
            </a>
        </li>
        <% } %>

        <!-- ============================================================== -->
        <!-- Warehouse Manager items -->
        <!-- ============================================================== -->
        <% if ("warehouse_manager".equals(userRole)) { %>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="bi bi-speedometer2"></i><span class="link-text">Dashboard</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-category" class="nav-link"><i class="bi bi-tags"></i><span class="link-text">Danh mục</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-product" class="nav-link"><i class="bi bi-box-seam"></i><span class="link-text">Sản phẩm</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-supplier" class="nav-link"><i class="bi bi-truck"></i><span class="link-text">Nhà cung cấp</span></a>
        </li>
        <!--        <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/manage-sales-order" class="nav-link"><i class="bi bi-receipt"></i><span class="link-text">Đơn bán hàng</span></a>
                </li>-->
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/stock-take" class="nav-link"><i class="bi bi-clipboard-check"></i><span class="link-text">Kiểm kê kho</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/low-stock-report" class="nav-link">
                <i class="bi bi-exclamation-triangle"></i><span class="link-text">Hàng sắp hết</span>
            </a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/manage-warehouse" class="nav-link"><i class="bi bi-building"></i><span class="link-text">Kho hàng</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/warehouse-manager/delivery?action=list" class="nav-link"><i class="bi bi-geo-alt"></i><span class="link-text">Theo dõi giao hàng</span></a>
        </li>
        <% } %>

        <!-- ============================================================== -->
        <!-- Chức năng chung -->
        <!-- ============================================================== -->
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/notifications" class="nav-link">
                <i class="bi bi-bell-fill"></i><span class="link-text">Thông báo của bạn</span>
            </a>
        </li>

        <!-- ============================================================== -->
        <!-- Purchasing Staff -->
        <!-- ============================================================== -->
        <% if ("purchasing_staff".equals(userRole)) { %>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/purchasing?action=inventory-list" class="nav-link"><i class="bi bi-boxes"></i><span class="link-text">Xem tồn kho</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/purchasing?action=list-rfq" class="nav-link"><i class="bi bi-file-text"></i><span class="link-text">Quản lý RFQ</span></a>
        </li>
        <% } %>

        <!-- ============================================================== -->
        <!-- Sales Staff -->
        <!-- ============================================================== -->
        <% if ("sales_staff".equals(userRole)) { %>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/sale-staff/sales-order" class="nav-link"><i class="bi bi-receipt"></i><span class="link-text">Đơn bán hàng</span></a>
        </li>
        <% } %>

        <!-- ============================================================== -->
        <!-- Warehouse Staff -->
        <!-- ============================================================== -->
        <% if ("warehouse_staff".equals(userRole)) { %>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/warehouse?action=list-po-for-inward" class="nav-link"><i class="bi bi-box-arrow-in-down"></i><span class="link-text">Nhận hàng</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/warehouse?action=list-sales-orders" class="nav-link"><i class="bi bi-box-arrow-up"></i><span class="link-text">Xuất kho bán hàng</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/stock-take" class="nav-link"><i class="bi bi-clipboard-check"></i><span class="link-text">Kiểm kê kho</span></a>
        </li>
        <% } %>

        <!-- ============================================================== -->
        <!-- Warehouse Staff & Manager -->
        <!-- ============================================================== -->
        <% if ("warehouse_staff".equals(userRole) || "warehouse_manager".equals(userRole)) { %>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/warehouse?action=list-stock-inward" class="nav-link"><i class="bi bi-card-list"></i><span class="link-text">DS Phiếu Nhập Kho</span></a>
        </li>
        <li class="nav-item">
            <a href="${pageContext.request.contextPath}/warehouse?action=list-outwards" class="nav-link"><i class="bi bi-card-list"></i><span class="link-text">DS Phiếu Xuất Kho</span></a>
        </li>
        <% } %>
    </ul>
</nav>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const userAvatar = document.getElementById("userAvatar");
        const dropdownUserMenu = document.getElementById("dropdownUserMenu");

        userAvatar.addEventListener("click", function (event) {
            event.stopPropagation();
            dropdownUserMenu.style.display = dropdownUserMenu.style.display === "flex" ? "none" : "flex";
        });

        document.addEventListener("click", function (event) {
            if (!userAvatar.contains(event.target) && !dropdownUserMenu.contains(event.target)) {
                dropdownUserMenu.style.display = "none";
            }
        });
    });
</script>
