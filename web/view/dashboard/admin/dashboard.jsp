<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Dashboard - Quản Lý Kho Hàng</title>
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
            .sidebar-heading {
                color: rgba(255,255,255,0.5);
                font-size: 0.65rem;
                font-weight: 600;
                letter-spacing: 1px;
                margin: 1rem 1rem 0.5rem 1rem;
                padding-bottom: 0.5rem;
                text-transform: uppercase;
                display: none;
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
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-primary">
                                <div class="card-body">
                                    <h5 class="card-title">Tổng Sản Phẩm</h5>
                                    <p class="card-text fs-4">${totalProducts}</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-success">
                                <div class="card-body">
                                    <h5 class="card-title">Đã Nhập Hôm Nay</h5>
                                    <p class="card-text fs-4">${totalReceivedToday}</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-warning">
                                <div class="card-body">
                                    <h5 class="card-title">Sắp Hết Hàng</h5>
                                    <p class="card-text fs-4">
                                        0
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-danger">
                                <div class="card-body">
                                    <h5 class="card-title">Hết Hàng</h5>
                                    <p class="card-text fs-4">
                                        <c:choose>
                                            <c:when test="${not empty totalOutOfStock}">
                                                ${totalOutOfStock}
                                            </c:when>
                                            <c:otherwise>0</c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row mt-3">
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-info">
                                <div class="card-body">
                                    <h5 class="card-title">Tổng User</h5>
                                    <p class="card-text fs-4">${totalUsers}</p>
                                </div>
                            </div>
                        </div>
                    </div>


                    <div class="card mt-4">
                        <div class="card-header bg-light">
                            <h5>📋 Danh sách sản phẩm gần đây</h5>
                        </div>
                        <div class="card-body">
                            <c:if test="${empty recentProducts}">
                                <div class="alert alert-info">Không có sản phẩm nào gần đây.</div>
                            </c:if>

                            <c:if test="${not empty recentProducts}">
                                <table class="table table-hover table-bordered">
                                    <thead class="table-light">
                                        <tr>
                                            <th>#</th>
                                            <th>Mã SP</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Danh mục</th>
                                            <th>Nhà cung cấp</th>
                                            <th>Giá bán</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="entry" items="${recentProducts}" varStatus="status">
                                            <c:set var="product" value="${entry.product}"/>
                                            <c:set var="category" value="${entry.category}"/>
                                            <c:set var="supplier" value="${entry.supplier}"/>
                                            <tr>
                                                <td>${status.index + 1}</td>
                                                <td>${product.productCode}</td>
                                                <td>${product.productName}</td>
                                                <td>${category.categoryName}</td>
                                                <td>${supplier.supplierName}</td>
                                                <td><fmt:formatNumber value="${product.salePrice}" type="currency" currencySymbol="đ"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${product.lowStockThreshold == 0}">
                                                            <span class="badge bg-danger">Hết hàng</span>
                                                        </c:when>
                                                        <c:when test="${product.lowStockThreshold <= 10}">
                                                            <span class="badge bg-warning">Sắp hết</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-success">Còn hàng</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                                <div class="text-center mt-3">
                                    <a href="${pageContext.request.contextPath}/product" class="btn btn-primary">
                                        📦 Xem tất cả sản phẩm
                                    </a>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </main>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
           
        </script>
    </body>
</html>
