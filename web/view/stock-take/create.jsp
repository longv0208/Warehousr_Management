<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Quản Lý Kho Hàng - Tạo Phiếu Kiểm Kê</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="./styles/index.css" rel="stylesheet"/>
</head>
<body>
<jsp:include page="../common/sidebar.jsp" />

<div class="container-fluid">
    <div class="row">
        <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3>Tạo Phiếu Kiểm Kê Mới</h3>
                <a href="${pageContext.request.contextPath}/stock-take" class="btn btn-secondary">Quay lại</a>
            </div>

            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">Thông tin phiếu kiểm kê</h5>
                        </div>
                        <div class="card-body">
                            <form method="POST" action="${pageContext.request.contextPath}/stock-take">
                                <input type="hidden" name="action" value="create">
                                
                                <div class="mb-3">
                                    <label for="notes" class="form-label">Ghi chú kiểm kê</label>
                                    <textarea name="notes" id="notes" class="form-control" rows="4" 
                                              placeholder="Nhập ghi chú về lý do kiểm kê, phạm vi kiểm kê..."></textarea>
                                </div>

                                <div class="alert alert-info">
                                    <h6>Lưu ý:</h6>
                                    <ul class="mb-0">
                                        <li>Hệ thống sẽ tự động tạo mã phiếu kiểm kê</li>
                                        <li>Tất cả sản phẩm đang hoạt động sẽ được thêm vào phiếu kiểm kê</li>
                                        <li>Sau khi tạo, bạn có thể tiến hành kiểm kê từng sản phẩm</li>
                                        <li>Số lượng hệ thống sẽ được lấy từ dữ liệu tồn kho hiện tại</li>
                                    </ul>
                                </div>

                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <a href="${pageContext.request.contextPath}/stock-take" class="btn btn-secondary me-md-2">Hủy</a>
                                    <button type="submit" class="btn btn-primary">Tạo Phiếu Kiểm Kê</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 