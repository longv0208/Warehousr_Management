<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Yêu Cầu Nhập Hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp" />
            
            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Chi Tiết Yêu Cầu Nhập Hàng</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/purchase-staff/purchase-request" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <!-- Purchase Request Info -->
                <div class="row">
                    <div class="col-md-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Thông Tin Yêu Cầu</h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><strong>Mã yêu cầu:</strong> ${purchaseRequest.requestCode}</p>
                                        <p><strong>Người yêu cầu:</strong> ${purchaseRequest.requestedByName}</p>
                                        <p><strong>Ngày tạo:</strong> 
                                            <fmt:formatDate value="${purchaseRequest.requestDate}" pattern="dd/MM/yyyy HH:mm"/>
                                        </p>
                                    </div>
                                    <div class="col-md-6">
                                        <p><strong>Trạng thái:</strong> 
                                            <c:choose>
                                                <c:when test="${purchaseRequest.status == 'pending_approval'}">
                                                    <span class="badge bg-warning">Chờ duyệt</span>
                                                </c:when>
                                                <c:when test="${purchaseRequest.status == 'approved'}">
                                                    <span class="badge bg-success">Đã duyệt</span>
                                                </c:when>
                                                <c:when test="${purchaseRequest.status == 'rejected'}">
                                                    <span class="badge bg-danger">Từ chối</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">${purchaseRequest.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </p>
                                        <p><strong>Ghi chú:</strong> ${purchaseRequest.notes}</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Request Details -->
                <div class="row mt-4">
                    <div class="col-md-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Chi Tiết Sản Phẩm</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>STT</th>
                                                <th>Mã sản phẩm</th>
                                                <th>Tên sản phẩm</th>
                                                <th>Số lượng yêu cầu</th>
                                                <th>Nhà cung cấp đề xuất</th>
                                                <th>Ghi chú</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="detail" items="${requestDetails}" varStatus="status">
                                                <tr>
                                                    <td>${status.index + 1}</td>
                                                    <td>${detail.productCode}</td>
                                                    <td>${detail.productName}</td>
                                                    <td>${detail.requestedQuantity}</td>
                                                    <td>${detail.supplierName != null ? detail.supplierName : 'Chưa chọn'}</td>
                                                    <td>${detail.notes}</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 