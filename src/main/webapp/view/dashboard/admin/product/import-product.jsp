<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Nhập Sản Phẩm Từ Excel - Quản Lý Kho Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

        <!-- Main Content -->
        <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
            <h3>Nhập Sản Phẩm Từ File Excel</h3>

            <div class="alert alert-info" role="alert">
                Vui lòng tải lên tệp Excel (.xlsx) với định dạng cột lần lượt: <strong>Mã SP, Tên SP, Mô tả, Đơn vị, Giá mua, Giá bán, Ngưỡng tồn kho, Trạng thái ("Hoạt động" hoặc "Không hoạt động"), Nhà cung cấp (ID hoặc Tên)</strong>.
            </div>

            <div class="mb-3">
                <a href="${pageContext.request.contextPath}/admin/manage-product?action=download-template" class="btn btn-outline-success">📥 Tải file mẫu</a>
            </div>

            <form action="${pageContext.request.contextPath}/admin/manage-product" method="POST" enctype="multipart/form-data" class="mb-4">
                <input type="hidden" name="action" value="import"/>

                <div class="mb-3">
                    <label for="excelFile" class="form-label">Chọn file Excel (.xlsx) <span class="text-danger">*</span></label>
                    <input class="form-control" type="file" id="excelFile" name="excelFile" accept=".xlsx" required/>
                </div>

                <button type="submit" class="btn btn-primary">Nhập Dữ Liệu</button>
                <a href="${pageContext.request.contextPath}/admin/manage-product?action=list" class="btn btn-secondary">Quay Lại</a>
            </form>

            <!-- Danh sách nhà cung cấp để tham khảo -->
            <div class="mt-4">
                <h5>Danh sách Nhà Cung Cấp hiện có</h5>
                <table class="table table-bordered table-sm">
                    <thead class="table-light">
                    <tr>
                        <th scope="col">ID</th>
                        <th scope="col">Tên Nhà Cung Cấp</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="sup" items="${suppliers}">
                        <tr>
                            <td>${sup.supplierId}</td>
                            <td>${sup.supplierName}</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 