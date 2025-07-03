<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <jsp:include page="../../../common/head.jsp">
        <jsp:param name="title" value="View Delivery Tracking"/>
    </jsp:include>
    <body>
        <div class="wrapper">
            <jsp:include page="../../../common/sidebar.jsp"/>
            <div class="main">
                <main class="content">
                    <div class="container-fluid p-0">
                        <h1 class="h3 mb-3">Tracking for Order: ${salesOrder.orderCode}</h1>

                        <!-- Update Status Form -->
                        <div class="card">
                            <div class="card-header">
                                <h5 class="card-title">Update Delivery Status</h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/delivery-tracking" method="POST">
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="salesOrderId" value="${salesOrder.salesOrderId}">
                                    <div class="row">
                                        <div class="col-md-4 mb-3">
                                            <label for="status" class="form-label">Status</label>
                                            <input type="text" class="form-control" id="status" name="status" required>
                                        </div>
                                        <div class="col-md-4 mb-3">
                                            <label for="location" class="form-label">Location</label>
                                            <input type="text" class="form-control" id="location" name="location" required>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label for="notes" class="form-label">Notes</label>
                                        <textarea class="form-control" id="notes" name="notes" rows="2"></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-primary">Add Update</button>
                                </form>
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
                                            <th>Time</th>
                                            <th>Status</th>
                                            <th>Location</th>
                                            <th>Updated By</th>
                                            <th>Notes</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="entry" items="${trackingHistory}">
                                            <tr>
                                                <td><fmt:formatDate value="${entry.updateTime}" pattern="dd-MM-yyyy HH:mm:ss"/></td>
                                                <td>${entry.status}</td>
                                                <td>${entry.location}</td>
                                                <td>${userDAO.findById(entry.updatedBy).fullName}</td>
                                                <td>${entry.notes}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                                <a href="${pageContext.request.contextPath}/delivery-tracking?action=list" class="btn btn-secondary mt-3">Back to List</a>
                            </div>
                        </div>
                    </div>
                </main>
                <jsp:include page="../../../common/foot.jsp"/>
            </div>
        </div>
    </body>
</html> 