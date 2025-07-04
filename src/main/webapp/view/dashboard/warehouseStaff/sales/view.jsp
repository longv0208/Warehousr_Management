<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <jsp:include page="../../../common/head.jsp">
        <jsp:param name="title" value="View Sales Order"/>
    </jsp:include>
    <body>
        <div class="wrapper">
            <jsp:include page="../../../common/sidebar.jsp"/>
            <div class="main">
                <main class="content">
                    <div class="container-fluid p-0">
                        <h1 class="h3 mb-3">Sales Order Details</h1>
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="card-title">Order Code: ${order.orderCode}</h5>
                                    </div>
                                    <div class="card-body">
                                        <p><strong>Customer:</strong> ${order.customerName}</p>
                                        <p><strong>Order Date:</strong> <fmt:formatDate value="${order.orderDate}" pattern="dd-MM-yyyy HH:mm"/></p>
                                        <p><strong>Created By:</strong> ${creator.fullName}</p>
                                        <p><strong>Warehouse:</strong> ${warehouse.warehouseName}</p>
                                        <p><strong>Notes:</strong> ${order.notes}</p>
                                        <p><strong>Status:</strong> 
                                            <span class="badge 
                                                <c:choose>
                                                    <c:when test="${order.status == 'pending_stock_check'}">bg-warning</c:when>
                                                    <c:when test="${order.status == 'awaiting_shipment'}">bg-info</c:when>
                                                    <c:when test="${order.status == 'shipped'}">bg-primary</c:when>
                                                    <c:when test="${order.status == 'completed'}">bg-success</c:when>
                                                    <c:when test="${order.status == 'cancelled'}">bg-danger</c:when>
                                                </c:choose>
                                            ">
                                                <c:out value="${order.status.replace('_', ' ')}" />
                                            </span>
                                        </p>

                                        <h5 class="mt-4">Order Items</h5>
                                        <table class="table">
                                            <thead>
                                                <tr>
                                                    <th>Product</th>
                                                    <th>Unit Price</th>
                                                    <th>Ordered</th>
                                                    <th>In Stock</th>
                                                    <th>Status</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:set var="allInStock" value="${true}" />
                                                <c:forEach var="detail" items="${details}">
                                                     <c:if test="${detail.quantityOrdered > inventoryInfo[detail.productId]}">
                                                        <c:set var="allInStock" value="${false}" />
                                                    </c:if>
                                                    <tr>
                                                        <td>${detail.productName}</td>
                                                        <td><fmt:formatNumber value="${detail.unitSalePrice}" type="currency" currencySymbol="₫"/></td>
                                                        <td>${detail.quantityOrdered}</td>
                                                        <td>${inventoryInfo[detail.productId]}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${detail.quantityOrdered <= inventoryInfo[detail.productId]}">
                                                                    <span class="badge bg-success">In Stock</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-danger">Out of Stock</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>

                                        <div class="mt-4">
                                            <c:if test="${order.status == 'pending_stock_check' && allInStock}">
                                                <form action="${pageContext.request.contextPath}/warehouse" method="GET" style="display: inline;">
                                                    <input type="hidden" name="action" value="confirm-stock">
                                                    <input type="hidden" name="id" value="${order.salesOrderId}">
                                                    <button type="submit" class="btn btn-success">Confirm Stock Availability</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${order.status == 'awaiting_shipment'}">
                                                 <a href="${pageContext.request.contextPath}/warehouse?action=create-outward-form&id=${order.salesOrderId}" class="btn btn-primary">Create Stock Outward</a>
                                            </c:if>
                                            <c:if test="${order.status == 'shipped'}">
                                                <form action="${pageContext.request.contextPath}/warehouse" method="POST" style="display: inline;">
                                                    <input type="hidden" name="action" value="complete-order">
                                                    <input type="hidden" name="id" value="${order.salesOrderId}">
                                                    <button type="submit" class="btn btn-success">Mark as Completed</button>
                                                </form>
                                            </c:if>
                                            <a href="${pageContext.request.contextPath}/warehouse?action=list-sales-orders" class="btn btn-secondary">Back to List</a>
                                        </div>
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