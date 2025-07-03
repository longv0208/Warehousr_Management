<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <jsp:include page="../../../common/head.jsp">
        <jsp:param name="title" value="Create Stock Outward"/>
    </jsp:include>
    <body>
        <div class="wrapper">
            <jsp:include page="../../../common/sidebar.jsp"/>
            <div class="main">
                <main class="content">
                    <div class="container-fluid p-0">
                        <h1 class="h3 mb-3">Create Stock Outward for Sales Order</h1>
                        <div class="row">
                            <div class="col-12">
                                <form action="${pageContext.request.contextPath}/warehouse" method="POST">
                                    <input type="hidden" name="action" value="create-stock-outward">
                                    <input type="hidden" name="orderId" value="${order.salesOrderId}">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="card-title">Order Code: ${order.orderCode}</h5>
                                        </div>
                                        <div class="card-body">
                                            <p><strong>Customer:</strong> ${order.customerName}</p>
                                            <p><strong>Warehouse:</strong> ${warehouse.warehouseName}</p>
                                            <div class="mb-3">
                                                <label for="notes" class="form-label">Notes</label>
                                                <textarea class="form-control" id="notes" name="notes" rows="3"></textarea>
                                            </div>

                                            <h5 class="mt-4">Items to Ship</h5>
                                            <table class="table">
                                                <thead>
                                                    <tr>
                                                        <th>Product</th>
                                                        <th>Quantity to Ship</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="detail" items="${details}">
                                                        <tr>
                                                            <td>${detail.productName}</td>
                                                            <td>${detail.quantityOrdered}</td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>

                                            <div class="mt-4">
                                                <button type="submit" class="btn btn-primary">Confirm and Create Outward</button>
                                                <a href="${pageContext.request.contextPath}/warehouse?action=view-sales-order&id=${order.salesOrderId}" class="btn btn-secondary">Cancel</a>
                                            </div>
                                        </div>
                                    </div>
                                </form>
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