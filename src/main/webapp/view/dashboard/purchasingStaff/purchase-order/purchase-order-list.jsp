<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phiếu Nhập Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp"/>
            
            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2"><i class="fas fa-cart-plus me-2"></i>Phiếu Nhập Hàng</h1>
                </div>

                <!-- Coming Soon Card -->
                <div class="card">
                    <div class="card-body text-center py-5">
                        <i class="fas fa-cogs fa-5x text-muted mb-4"></i>
                        <h3 class="card-title">Chức năng đang phát triển</h3>
                        <p class="card-text text-muted">
                            Chức năng quản lý phiếu nhập hàng đang được phát triển và sẽ có sẵn trong phiên bản tiếp theo.
                        </p>
                        <div class="mt-4">
                            <a href="${pageContext.request.contextPath}/purchase-staff/inventory" class="btn btn-primary me-2">
                                <i class="fas fa-boxes me-1"></i>Xem Tồn Kho
                            </a>
                            <a href="${pageContext.request.contextPath}/purchase-staff/purchase-request" class="btn btn-outline-primary">
                                <i class="fas fa-file-alt me-1"></i>Yêu Cầu Nhập Hàng
                            </a>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 