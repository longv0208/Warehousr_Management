<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý báo giá bán hàng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard/sales-quotation.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <!-- Include Header -->
    <jsp:include page="/view/common/head.jsp" />

    <div class="container-fluid main">
        <div class="row">
            <!-- Include Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp" />

            <!-- Main Content -->
            <main role="main" class="col-md-9 ml-sm-auto col-lg-10 px-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Quản lý báo giá bán hàng</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/sale-staff/sales-quotation?action=create" 
                           class="btn btn-primary">
                            <i class="fas fa-plus"></i> Tạo báo giá mới
                        </a>
                    </div>
                </div>

                <!-- Status Filter -->
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-outline-secondary ${empty param.status ? 'active' : ''}" 
                                    onclick="filterByStatus('')">Tất cả</button>
                            <button type="button" class="btn btn-outline-primary ${param.status eq 'draft' ? 'active' : ''}" 
                                    onclick="filterByStatus('draft')">Nháp</button>
                            <button type="button" class="btn btn-outline-warning ${param.status eq 'sent' ? 'active' : ''}" 
                                    onclick="filterByStatus('sent')">Đã gửi</button>
                            <button type="button" class="btn btn-outline-success ${param.status eq 'approved' ? 'active' : ''}" 
                                    onclick="filterByStatus('approved')">Đã duyệt</button>
                            <button type="button" class="btn btn-outline-danger ${param.status eq 'rejected' ? 'active' : ''}" 
                                    onclick="filterByStatus('rejected')">Từ chối</button>
                        </div>
                    </div>
                </div>

                <!-- Quotations Table -->
                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>Mã báo giá</th>
                                <th>Khách hàng</th>
                                <th>Email</th>
                                <th>Ngày báo giá</th>
                                <th>Hiệu lực đến</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty quotations}">
                                    <c:forEach var="quotation" items="${quotations}">
                                        <tr>
                                            <td>${quotation.quotationCode}</td>
                                            <td>${quotation.customerName}</td>
                                            <td>${quotation.customerEmail}</td>
                                            <td>
                                                <fmt:formatDate value="${quotation.quotationDate}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${quotation.validUntil}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${quotation.status eq 'draft'}">
                                                        <span class="badge bg-secondary">Nháp</span>
                                                    </c:when>
                                                    <c:when test="${quotation.status eq 'sent'}">
                                                        <span class="badge bg-warning">Đã gửi</span>
                                                    </c:when>
                                                    <c:when test="${quotation.status eq 'approved'}">
                                                        <span class="badge bg-success">Đã duyệt</span>
                                                    </c:when>
                                                    <c:when test="${quotation.status eq 'rejected'}">
                                                        <span class="badge bg-danger">Từ chối</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${quotation.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <a href="${pageContext.request.contextPath}/sale-staff/sales-quotation?action=view&id=${quotation.quotationId}" 
                                                       class="btn btn-sm btn-outline-info" title="Xem chi tiết">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <c:if test="${quotation.status eq 'draft'}">
                                                        <a href="${pageContext.request.contextPath}/sale-staff/sales-quotation?action=edit&id=${quotation.quotationId}" 
                                                           class="btn btn-sm btn-outline-warning" title="Sửa">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <button type="button" class="btn btn-sm btn-outline-primary" 
                                                                onclick="sendQuotation(${quotation.quotationId})" title="Gửi báo giá">
                                                            <i class="fas fa-paper-plane"></i>
                                                        </button>
                                                    </c:if>
                                                    <c:if test="${quotation.status eq 'approved'}">
                                                        <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=create&quotationId=${quotation.quotationId}" 
                                                           class="btn btn-sm btn-outline-success" title="Tạo đơn hàng">
                                                            <i class="fas fa-shopping-cart"></i>
                                                        </a>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" class="text-center">Không có báo giá nào</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </main>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="/view/common/foot.jsp" />

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        function filterByStatus(status) {
            const url = new URL(window.location);
            if (status) {
                url.searchParams.set('status', status);
            } else {
                url.searchParams.delete('status');
            }
            window.location.href = url.toString();
        }

        function sendQuotation(quotationId) {
            Swal.fire({
                title: 'Xác nhận gửi báo giá',
                text: 'Bạn có chắc chắn muốn gửi báo giá này cho khách hàng?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Gửi',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Create form and submit
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '${pageContext.request.contextPath}/sale-staff/sales-quotation';

                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'send';

                    const idInput = document.createElement('input');
                    idInput.type = 'hidden';
                    idInput.name = 'id';
                    idInput.value = quotationId;

                    form.appendChild(actionInput);
                    form.appendChild(idInput);
                    document.body.appendChild(form);
                    form.submit();
                }
            });
        }

        // Show toast message if exists
        <c:if test="${not empty sessionScope.toastMessage}">
            Swal.fire({
                icon: '${sessionScope.toastType}',
                title: '${sessionScope.toastMessage}',
                showConfirmButton: false,
                timer: 3000
            });
            <c:remove var="toastMessage" scope="session"/>
            <c:remove var="toastType" scope="session"/>
        </c:if>
    </script>
</body>
</html>
