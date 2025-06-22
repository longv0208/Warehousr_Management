<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Yêu Cầu Nhập Hàng</title>
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
                    <h1 class="h2"><i class="fas fa-clipboard-check me-2"></i>Quản Lý Yêu Cầu Nhập Hàng</h1>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        ${sessionScope.successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>

                <c:if test="${not empty sessionScope.warningMessage}">
                    <div class="alert alert-warning alert-dismissible fade show" role="alert">
                        ${sessionScope.warningMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="warningMessage" scope="session"/>
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
                        <form method="GET" action="${pageContext.request.contextPath}/admin/purchase-management/requests">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label for="status" class="form-label">Trạng thái</label>
                                    <select class="form-select" id="status" name="status">
                                        <option value="">Tất cả trạng thái</option>
                                        <option value="pending_approval" ${status == 'pending_approval' ? 'selected' : ''}>Chờ duyệt</option>
                                        <option value="approved" ${status == 'approved' ? 'selected' : ''}>Đã duyệt</option>
                                        <option value="rejected" ${status == 'rejected' ? 'selected' : ''}>Đã từ chối</option>
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
                                        <a href="${pageContext.request.contextPath}/admin/purchase-management/requests" 
                                           class="btn btn-outline-secondary">
                                            <i class="fas fa-refresh me-1"></i>Làm mới
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card border-warning">
                            <div class="card-body text-center">
                                <h5 class="card-title text-warning">Chờ duyệt</h5>
                                <h2 class="text-warning">
                                    <c:set var="pendingCount" value="0"/>
                                    <c:forEach var="request" items="${purchaseRequests}">
                                        <c:if test="${request.status == 'pending_approval'}">
                                            <c:set var="pendingCount" value="${pendingCount + 1}"/>
                                        </c:if>
                                    </c:forEach>
                                    ${pendingCount}
                                </h2>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card border-success">
                            <div class="card-body text-center">
                                <h5 class="card-title text-success">Đã duyệt</h5>
                                <h2 class="text-success">
                                    <c:set var="approvedCount" value="0"/>
                                    <c:forEach var="request" items="${purchaseRequests}">
                                        <c:if test="${request.status == 'approved'}">
                                            <c:set var="approvedCount" value="${approvedCount + 1}"/>
                                        </c:if>
                                    </c:forEach>
                                    ${approvedCount}
                                </h2>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card border-danger">
                            <div class="card-body text-center">
                                <h5 class="card-title text-danger">Đã từ chối</h5>
                                <h2 class="text-danger">
                                    <c:set var="rejectedCount" value="0"/>
                                    <c:forEach var="request" items="${purchaseRequests}">
                                        <c:if test="${request.status == 'rejected'}">
                                            <c:set var="rejectedCount" value="${rejectedCount + 1}"/>
                                        </c:if>
                                    </c:forEach>
                                    ${rejectedCount}
                                </h2>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card border-info">
                            <div class="card-body text-center">
                                <h5 class="card-title text-info">Tổng cộng</h5>
                                <h2 class="text-info">${not empty purchaseRequests ? purchaseRequests.size() : 0}</h2>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Requests Table -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Danh sách yêu cầu nhập hàng</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>STT</th>
                                        <th>Mã yêu cầu</th>
                                        <th>Người yêu cầu</th>
                                        <th>Kho</th>
                                        <th>Ngày tạo</th>
                                        <th>Trạng thái</th>
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
                                                            <c:when test="${not empty request.requestedByName}">
                                                                ${request.requestedByName}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">N/A</span>
                                                            </c:otherwise>
                                                        </c:choose>
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
                                                            <c:when test="${request.status == 'pending_approval'}">
                                                                <span class="badge bg-warning">Chờ duyệt</span>
                                                            </c:when>
                                                                                                                    <c:when test="${request.status == 'approved'}">
                                                            <span class="badge bg-success">Đã duyệt (chờ nhập hàng)</span>
                                                        </c:when>
                                                            <c:when test="${request.status == 'rejected'}">
                                                                <span class="badge bg-danger">Đã từ chối</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">${request.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>

                                                    <td>
                                                        <div class="btn-group-vertical btn-group-sm" role="group">
                                                            <a href="${pageContext.request.contextPath}/admin/purchase-management/requests?action=view&id=${request.requestId}" 
                                                               class="btn btn-outline-info btn-sm">
                                                                <i class="fas fa-eye"></i> Xem
                                                            </a>
                                                            <c:if test="${request.status == 'pending_approval'}">
                                                                <a href="${pageContext.request.contextPath}/admin/purchase-management/requests?action=approve-form&id=${request.requestId}" 
                                                                   class="btn btn-outline-success btn-sm">
                                                                    <i class="fas fa-check"></i> Duyệt
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
                                                    <p class="text-muted">Không có yêu cầu nhập hàng nào</p>
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