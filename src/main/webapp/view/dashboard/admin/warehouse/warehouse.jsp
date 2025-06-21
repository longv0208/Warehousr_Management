<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quản Lý Kho Hàng</title>
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
                <h3>Danh sách Kho hàng</h3>
                <c:if test="${userRole == 'admin'}">
                    <div>
                        <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=create" class="btn btn-success">+ Thêm Kho hàng</a>
                    </div>
                </c:if>
            </div>

            <!-- Information for non-admin users -->
            <c:if test="${userRole != 'admin'}">
                <div class="alert alert-info alert-dismissible fade show" role="alert">
                    <i class="fas fa-info-circle"></i> 
                    Bạn chỉ có quyền xem danh sách kho hàng. Để thêm, sửa hoặc xóa kho hàng, vui lòng liên hệ quản trị viên.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Filter Form -->
            <form action="${pageContext.request.contextPath}/admin/manage-warehouse" method="GET" class="row g-3 mb-4">
                <input type="hidden" name="action" value="list">
                <div class="col-md-4">
                    <input type="text" id="searchInput" name="search" class="form-control" placeholder="Tìm theo tên kho hoặc địa chỉ..." value="${searchTerm}"/>
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
                            <th>Tên Kho hàng</th>
                            <th>Địa chỉ</th>
                            <th>Ngày tạo</th>
                            <c:if test="${userRole == 'admin'}">
                                <th>Hành động</th>
                            </c:if>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty warehouses}">
                                <c:forEach var="warehouse" items="${warehouses}" varStatus="loop">
                                    <tr>
                                        <td>${loop.count}</td>
                                        <td><c:out value="${warehouse.warehouseId}"/></td>
                                        <td><c:out value="${warehouse.warehouseName}"/></td>
                                        <td><c:out value="${warehouse.address}"/></td>
                                        <td>
                                            <c:if test="${not empty warehouse.createdAt}">
                                                <fmt:formatDate value="${warehouse.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </c:if>
                                        </td>
                                        <c:if test="${userRole == 'admin'}">
                                            <td>
                                                <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=edit&id=${warehouse.warehouseId}" class="btn btn-sm btn-info">Sửa</a>
                                                <button class="btn btn-sm btn-danger" onclick="confirmDelete('${warehouse.warehouseId}', '${warehouse.warehouseName}')">Xóa</button>
                                            </td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="${userRole == 'admin' ? '6' : '5'}" class="text-center">
                                        <c:choose>
                                            <c:when test="${not empty searchTerm}">
                                                Không tìm thấy kho hàng nào phù hợp với từ khóa "<c:out value="${searchTerm}"/>".
                                            </c:when>
                                            <c:otherwise>
                                                Không tìm thấy kho hàng nào.
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Total Count -->
            <div class="mt-3">
                <small class="text-muted">Tổng cộng: ${warehouses.size()} kho hàng</small>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

<script>
    function confirmDelete(warehouseId, warehouseName) {
        if (confirm('Bạn có chắc chắn muốn xóa kho hàng "' + warehouseName + '"? Hành động này không thể hoàn tác.')) {
            window.location.href = '${pageContext.request.contextPath}/admin/manage-warehouse?action=delete&id=' + warehouseId;
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