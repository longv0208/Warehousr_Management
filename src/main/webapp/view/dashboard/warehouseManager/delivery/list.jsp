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
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title">All Shipments</h5>
                            </div>
                            <div class="card-body">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>Order Code</th>
                                            <th>Customer</th>
                                            <th>Last Status</th>
                                            <th>Last Location</th>
                                            <th>Last Updated</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="tracking" items="${trackingList}">
                                            <tr>
                                                <td>${tracking.orderCode}</td>
                                                <td>${tracking.customerName}</td>
                                                <td><span class="badge bg-info">${tracking.lastStatus}</span></td>
                                                <td>${tracking.lastLocation}</td>
                                                <td><fmt:formatDate value="${tracking.lastUpdateTime}" pattern="dd-MM-yyyy HH:mm"/></td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/delivery-tracking?action=view&soId=${tracking.salesOrderId}" class="btn btn-primary btn-sm">View Details</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty trackingList}">
                                            <tr>
                                                <td colspan="6" class="text-center">No shipments to track.</td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </main>
                <jsp:include page="../../../common/foot.jsp"/>
            </div>
        </div>
    </body>
</html> 