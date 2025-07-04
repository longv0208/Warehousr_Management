<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <jsp:include page="../../../common/head.jsp">
        <jsp:param name="title" value="Quản lý đơn hàng"/>
    </jsp:include>
    <body>
        <div class="wrapper">
            <jsp:include page="../../../common/sidebar.jsp"/>
            <div class="main">
                <main class="content">
                    <div class="container-fluid p-0">
                        <h1 class="h3 mb-3">Đơn hàng cần xử lý</h1>
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="card-title">Lọc đơn hàng</h5>
                                        <form action="${pageContext.request.contextPath}/warehouse?action=list-sales-orders" method="GET" class="row row-cols-lg-auto g-3 align-items-center">
                                            <div class="col-12">
                                                <label class="visually-hidden" for="statusFilter">Trạng thái</label>
                                                <select name="status" id="statusFilter" class="form-select">
                                                    <option value="">Tất cả trạng thái</option>
                                                    <c:forEach var="status" items="${statuses}">
                                                        <option value="${status}" ${status == statusFilter ? 'selected' : ''}>
                                                            <c:choose>
                                                                <c:when test="${status == 'pending_stock_check'}">Chờ kiểm kho</c:when>
                                                                <c:when test="${status == 'awaiting_shipment'}">Chờ giao hàng</c:when>
                                                            </c:choose>
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-12">
                                                <label class="visually-hidden" for="warehouseFilter">Kho</label>
                                                <select name="warehouseId" id="warehouseFilter" class="form-select">
                                                    <option value="">Tất cả các kho</option>
                                                    <c:forEach var="warehouse" items="${warehouses}">
                                                        <option value="${warehouse.warehouseId}" ${warehouse.warehouseId == warehouseIdFilter ? 'selected' : ''}>${warehouse.warehouseName}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-12">
                                                <button type="submit" class="btn btn-primary">Lọc</button>
                                            </div>
                                        </form>
                                    </div>
                                    <div class="card-body">
                                        <table class="table table-striped">
                                            <thead>
                                                <tr>
                                                    <th>Mã đơn hàng</th>
                                                    <th>Khách hàng</th>
                                                    <th>Ngày đặt</th>
                                                    <th>Kho</th>
                                                    <th>Người tạo</th>
                                                    <th>Ghi chú</th>
                                                    <th>Trạng thái</th>
                                                    <th>Hành động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="order" items="${orders}">
                                                    <tr>
                                                        <td>${order.orderCode}</td>
                                                        <td>${order.customerName}</td>
                                                        <td><fmt:formatDate value="${order.orderDate}" pattern="dd-MM-yyyy HH:mm"/></td>
                                                        <td>
                                                            <c:forEach var="warehouse" items="${warehouses}">
                                                                <c:if test="${order.warehouseId == warehouse.warehouseId}">
                                                                    ${warehouse.warehouseName}
                                                                </c:if>
                                                            </c:forEach>
                                                        </td>
                                                        <td>
                                                            <c:forEach var="user" items="${users}">
                                                                <c:if test="${order.userId == user.userId}">
                                                                    ${user.fullName}
                                                                </c:if>
                                                            </c:forEach>
                                                        </td>
                                                        <td>${order.notes}</td>
                                                        <td>
                                                            <c:set var="statusClass">
                                                                <c:choose>
                                                                    <c:when test="${order.status == 'pending_stock_check'}">bg-warning</c:when>
                                                                    <c:when test="${order.status == 'awaiting_shipment'}">bg-info</c:when>
                                                                    <c:when test="${order.status == 'shipped'}">bg-primary</c:when>
                                                                    <c:when test="${order.status == 'completed'}">bg-success</c:when>
                                                                    <c:when test="${order.status == 'cancelled'}">bg-danger</c:when>
                                                                    <c:otherwise>bg-secondary</c:otherwise>
                                                                </c:choose>
                                                            </c:set>
                                                            <c:set var="statusText">
                                                                <c:choose>
                                                                    <c:when test="${order.status == 'pending_stock_check'}">Chờ kiểm kho</c:when>
                                                                    <c:when test="${order.status == 'awaiting_shipment'}">Chờ giao hàng</c:when>
                                                                    <c:when test="${order.status == 'shipped'}">Đã giao</c:when>
                                                                    <c:when test="${order.status == 'completed'}">Hoàn thành</c:when>
                                                                    <c:when test="${order.status == 'cancelled'}">Đã hủy</c:when>
                                                                    <c:otherwise>${order.status}</c:otherwise>
                                                                </c:choose>
                                                            </c:set>
                                                            <span class="badge ${statusClass}">${statusText}</span>
                                                        </td>
                                                        <td>
                                                            <a href="${pageContext.request.contextPath}/warehouse?action=view-sales-order&id=${order.salesOrderId}" class="btn btn-info btn-sm">Xem</a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                        <%-- Pagination --%>
                                        <nav>
                                            <ul class="pagination">
                                                <c:if test="${currentPage > 1}">
                                                    <li class="page-item"><a class="page-link" href="${pageContext.request.contextPath}/warehouse?action=list-sales-orders&page=${currentPage - 1}&status=${statusFilter}&warehouseId=${warehouseIdFilter}">Trước</a></li>
                                                </c:if>
                                                <c:forEach begin="1" end="${totalPages}" var="i">
                                                    <li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/warehouse?action=list-sales-orders&page=${i}&status=${statusFilter}&warehouseId=${warehouseIdFilter}">${i}</a></li>
                                                </c:forEach>
                                                <c:if test="${currentPage < totalPages}">
                                                    <li class="page-item"><a class="page-link" href="${pageContext.request.contextPath}/warehouse?action=list-sales-orders&page=${currentPage + 1}&status=${statusFilter}&warehouseId=${warehouseIdFilter}">Sau</a></li>
                                                </c:if>
                                            </ul>
                                        </nav>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
                <jsp:include page="../../../common/foot.jsp"/>
            </div>
        </div>
        <script src="${pageContext.request.contextPath}/js/app.js"></script>
    </body>
</html> 