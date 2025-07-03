<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <jsp:include page="../../../common/head.jsp">
        <jsp:param name="title" value="View Delivery Details"/>
    </jsp:include>
    <body>
        <div class="wrapper">
            <jsp:include page="../../../common/sidebar.jsp"/>
            <div class="main">
                <main class="content">
                    <div class="container-fluid p-0">
                        <h1 class="h3 mb-3">Delivery Details</h1>

                        <!-- Order Info -->
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title">Order Code: ${salesOrder.orderCode}</h5>
                            </div>
                            <div class="card-body">
                                <p><strong>Customer:</strong> ${salesOrder.customerName}</p>
                                <p><strong>Order Date:</strong> <fmt:formatDate value="${salesOrder.orderDate}" pattern="dd-MM-yyyy"/></p>
                                <p><strong>Current Status:</strong> <span class="badge bg-primary">${salesOrder.status}</span></p>
                            </div>
                        </div>

                        <!-- Tracking History -->
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title">Tracking History</h5>
                            </div>
                            <div class="card-body">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Status</th>
                                            <th>Notes</th>
                                            <th>Timestamp</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="history" items="${trackingHistory}">
                                            <tr>
                                                <td>
                                                    <span class="badge ${history.status == 'shipped' ? 'bg-primary' : (history.status == 'delivered' ? 'bg-success' : 'bg-danger')}">
                                                        ${history.status}
                                                    </span>
                                                </td>
                                                <td>${history.notes}</td>
                                                <td><fmt:formatDate value="${history.updatedAt}" pattern="dd-MM-yyyy HH:mm:ss"/></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Update Status Form -->
                        <c:if test="${salesOrder.status == 'shipped'}">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="card-title">Update Delivery Status</h5>
                                </div>
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/warehouse-manager/delivery" method="POST">
                                        <input type="hidden" name="action" value="update-status">
                                        <input type="hidden" name="salesOrderId" value="${salesOrder.salesOrderId}">
                                        
                                        <div class="mb-3">
                                            <label for="status" class="form-label">New Status</label>
                                            <select id="status" name="status" class="form-select" required>
                                                <option value="delivered">Delivered</option>
                                                <option value="failed">Failed</option>
                                            </select>
                                        </div>

                                        <div class="mb-3">
                                            <label for="notes" class="form-label">Notes</label>
                                            <textarea id="notes" name="notes" class="form-control" rows="3"></textarea>
                                        </div>

                                        <button type="submit" class="btn btn-primary">Update Status</button>
                                    </form>
                                </div>
                            </div>
                        </c:if>

                        <a href="${pageContext.request.contextPath}/warehouse-manager/delivery?action=list" class="btn btn-secondary">Back to List</a>
                    </div>
                </main>
                <jsp:include page="../../../common/foot.jsp"/>
            </div>
        </div>
        <script src="${pageContext.request.contextPath}/js/app.js"></script>
    </body>
</html> 