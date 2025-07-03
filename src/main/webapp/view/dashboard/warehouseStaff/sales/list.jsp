<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <jsp:include page="../../../common/head.jsp">
        <jsp:param name="title" value="Manage Sales Orders"/>
    </jsp:include>
    <body>
        <div class="wrapper">
            <jsp:include page="../../../common/sidebar.jsp"/>
            <div class="main">
                <main class="content">
                    <div class="container-fluid p-0">
                        <h1 class="h3 mb-3">Sales Orders for Fulfillment</h1>
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="card-title">Filter Orders</h5>
                                        <form action="${pageContext.request.contextPath}/warehouse?action=list-sales-orders" method="GET" class="row row-cols-lg-auto g-3 align-items-center">
                                            <div class="col-12">
                                                <label class="visually-hidden" for="statusFilter">Status</label>
                                                <select name="status" id="statusFilter" class="form-select">
                                                    <option value="">All Statuses</option>
                                                    <c:forEach var="status" items="${statuses}">
                                                        <option value="${status}" ${status == statusFilter ? 'selected' : ''}>
                                                            <c:choose>
                                                                <c:when test="${status == 'pending_stock_check'}">Pending Stock Check</c:when>
                                                                <c:when test="${status == 'awaiting_shipment'}">Awaiting Shipment</c:when>
                                                            </c:choose>
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-12">
                                                <label class="visually-hidden" for="warehouseFilter">Warehouse</label>
                                                <select name="warehouseId" id="warehouseFilter" class="form-select">
                                                    <option value="">All Warehouses</option>
                                                    <c:forEach var="warehouse" items="${warehouses}">
                                                        <option value="${warehouse.warehouseId}" ${warehouse.warehouseId == warehouseIdFilter ? 'selected' : ''}>${warehouse.warehouseName}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-12">
                                                <button type="submit" class="btn btn-primary">Filter</button>
                                            </div>
                                        </form>
                                    </div>
                                    <div class="card-body">
                                        <table class="table table-striped">
                                            <thead>
                                                <tr>
                                                    <th>Order Code</th>
                                                    <th>Customer</th>
                                                    <th>Order Date</th>
                                                    <th>Warehouse</th>
                                                    <th>Created By</th>
                                                    <th>Status</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="order" items="${orders}">
                                                    <tr>
                                                        <td>${order.orderCode}</td>
                                                        <td>${order.customerName}</td>
                                                        <td><fmt:formatDate value="${order.orderDate}" pattern="dd-MM-yyyy HH:mm"/></td>
                                                        <td>
                                                            <c:if test="${order.warehouseId != null}">
                                                                ${warehouseDAO.findById(order.warehouseId).warehouseName}
                                                            </c:if>
                                                            <c:if test="${order.warehouseId == null}">
                                                                N/A
                                                            </c:if>
                                                        </td>
                                                        <td>${userDAO.findById(order.userId).fullName}</td>
                                                        <td>
                                                            <span class="badge 
                                                                <c:choose>
                                                                    <c:when test="${order.status == 'pending_stock_check'}">bg-warning</c:when>
                                                                    <c:when test="${order.status == 'awaiting_shipment'}">bg-info</c:when>
                                                                </c:choose>
                                                            ">
                                                                <c:choose>
                                                                    <c:when test="${order.status == 'pending_stock_check'}">Pending Stock Check</c:when>
                                                                    <c:when test="${order.status == 'awaiting_shipment'}">Awaiting Shipment</c:when>
                                                                </c:choose>
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <a href="${pageContext.request.contextPath}/warehouse?action=view-sales-order&id=${order.salesOrderId}" class="btn btn-info btn-sm">View</a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                        <%-- Pagination --%>
                                        <nav>
                                            <ul class="pagination">
                                                <c:if test="${currentPage > 1}">
                                                    <li class="page-item"><a class="page-link" href="${pageContext.request.contextPath}/warehouse?action=list-sales-orders&page=${currentPage - 1}&status=${statusFilter}&warehouseId=${warehouseIdFilter}">Previous</a></li>
                                                </c:if>
                                                <c:forEach begin="1" end="${totalPages}" var="i">
                                                    <li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/warehouse?action=list-sales-orders&page=${i}&status=${statusFilter}&warehouseId=${warehouseIdFilter}">${i}</a></li>
                                                </c:forEach>
                                                <c:if test="${currentPage < totalPages}">
                                                    <li class="page-item"><a class="page-link" href="${pageContext.request.contextPath}/warehouse?action=list-sales-orders&page=${currentPage + 1}&status=${statusFilter}&warehouseId=${warehouseIdFilter}">Next</a></li>
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