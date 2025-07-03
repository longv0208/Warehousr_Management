<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <jsp:include page="../../../common/head.jsp">
        <jsp:param name="title" value="Delivery Tracking"/>
    </jsp:include>
    <body>
        <div class="wrapper">
            <jsp:include page="../../../common/sidebar.jsp"/>
            <div class="main">
                <main class="content">
                    <div class="container-fluid p-0">
                        <h1 class="h3 mb-3">Delivery Tracking</h1>
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="card-title">Orders in Transit</h5>
                                    </div>
                                    <div class="card-body">
                                        <table class="table table-striped">
                                            <thead>
                                                <tr>
                                                    <th>Order Code</th>
                                                    <th>Customer</th>
                                                    <th>Last Status</th>
                                                    <th>Last Updated</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="delivery" items="${deliveries}">
                                                    <tr>
                                                        <td>${delivery.salesOrder.orderCode}</td>
                                                        <td>${delivery.salesOrder.customerName}</td>
                                                        <td>
                                                            <span class="badge ${delivery.status == 'shipped' ? 'bg-primary' : (delivery.status == 'delivered' ? 'bg-success' : 'bg-danger')}">
                                                                ${delivery.status}
                                                            </span>
                                                        </td>
                                                        <td><fmt:formatDate value="${delivery.updatedAt}" pattern="dd-MM-yyyy HH:mm:ss"/></td>
                                                        <td>
                                                            <a href="${pageContext.request.contextPath}/warehouse-manager/delivery?action=view&id=${delivery.salesOrderId}" class="btn btn-sm btn-info">View Details</a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                                <c:if test="${empty deliveries}">
                                                    <tr>
                                                        <td colspan="5" class="text-center">No deliveries in transit.</td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
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