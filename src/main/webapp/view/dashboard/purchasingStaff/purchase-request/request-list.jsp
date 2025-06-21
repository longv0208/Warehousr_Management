<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Yêu Cầu Nhập Hàng</title>
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
                    <h1 class="h2"><i class="fas fa-list me-2"></i>Yêu Cầu Nhập Hàng</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/purchase-staff/purchase-request?action=create" 
                           class="btn btn-success">
                            <i class="fas fa-plus me-1"></i>Tạo yêu cầu mới
                        </a>
                    </div>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        ${sessionScope.successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>

                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        ${sessionScope.errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <!-- Filter Card -->
                <div class="card mb-4">
                    <div class="card-body">
                        <form method="GET" action="${pageContext.request.contextPath}/purchase-staff/purchase-request">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label for="status" class="form-label">Trạng thái</label>
                                    <select class="form-select" id="status" name="status">
                                        <option value="">Tất cả trạng thái</option>
                                        <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>Chờ duyệt</option>
                                        <option value="APPROVED" ${status == 'APPROVED' ? 'selected' : ''}>Đã duyệt</option>
                                        <option value="REJECTED" ${status == 'REJECTED' ? 'selected' : ''}>Đã từ chối</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label for="warehouseId" class="form-label">Kho</label>
                                    <select class="form-select" id="warehouseId" name="warehouseId">
                                        <option value="">Tất cả kho</option>
                                        <c:forEach var="warehouse" items="${warehouses}">
                                            <option value="${warehouse.warehouseId}" 
                                                    ${warehouseId == warehouse.warehouseId ? 'selected' : ''}>
                                                ${warehouse.warehouseName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">&nbsp;</label>
                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-search me-1"></i>Lọc
                                        </button>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">&nbsp;</label>
                                    <div class="d-grid">
                                        <a href="${pageContext.request.contextPath}/purchase-staff/purchase-request" 
                                           class="btn btn-outline-secondary">
                                            <i class="fas fa-refresh me-1"></i>Làm mới
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Requests Table -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Danh sách yêu cầu của tôi</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>STT</th>
                                        <th>Mã yêu cầu</th>
                                        <th>Kho</th>
                                        <th>Ngày tạo</th>
                                        <th>Trạng thái</th>
                                        <th>Người duyệt</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty purchaseRequests}">
                                            <c:forEach var="request" items="${purchaseRequests}" varStatus="status">
                                                <tr>
                                                    <td>${status.index + 1}</td>
                                                    <td>
                                                        <strong>${request.requestCode}</strong>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty request.warehouseName}">
                                                                ${request.warehouseName}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">N/A</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:if test="${not empty request.requestDate}">
                                                            <fmt:formatDate value="${request.requestDate}" pattern="dd/MM/yyyy HH:mm"/>
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${request.status == 'PENDING'}">
                                                                <span class="badge bg-warning">Chờ duyệt</span>
                                                            </c:when>
                                                            <c:when test="${request.status == 'APPROVED'}">
                                                                <span class="badge bg-success">Đã duyệt</span>
                                                            </c:when>
                                                            <c:when test="${request.status == 'REJECTED'}">
                                                                <span class="badge bg-danger">Đã từ chối</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">${request.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty request.approvedByName}">
                                                                ${request.approvedByName}
                                                                <c:if test="${not empty request.approvedDate}">
                                                                    <br><small class="text-muted">
                                                                        <fmt:formatDate value="${request.approvedDate}" pattern="dd/MM/yyyy"/>
                                                                    </small>
                                                                </c:if>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">Chưa duyệt</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div class="btn-group-vertical btn-group-sm" role="group">
                                                            <a href="${pageContext.request.contextPath}/purchase-staff/purchase-request?action=view&id=${request.requestId}" 
                                                               class="btn btn-outline-info btn-sm">
                                                                <i class="fas fa-eye"></i> Xem
                                                            </a>
                                                            <c:if test="${request.status == 'PENDING'}">
                                                                <a href="${pageContext.request.contextPath}/purchase-staff/purchase-request?action=edit&id=${request.requestId}" 
                                                                   class="btn btn-outline-warning btn-sm">
                                                                    <i class="fas fa-edit"></i> Sửa
                                                                </a>
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="7" class="text-center py-4">
                                                    <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                                    <p class="text-muted">Bạn chưa có yêu cầu nhập hàng nào</p>
                                                    <a href="${pageContext.request.contextPath}/purchase-staff/purchase-request?action=create" 
                                                       class="btn btn-success">
                                                        <i class="fas fa-plus me-1"></i>Tạo yêu cầu đầu tiên
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>