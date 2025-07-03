<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Orders for Stock Inward</title>
    <jsp:include page="/view/common/head.jsp"/>
    <style>
        .main-content {
            margin-left: 250px; /* Same as sidebar width */
            padding: 20px;
        }
    </style>
</head>
<body>
    <jsp:include page="/view/common/sidebar.jsp"/>
    <div class="main-content">
        <div class="card">
            <div class="card-header">
                <h4>Purchase Orders Ready for Import</h4>
            </div>
            <div class="card-body">
                <c:if test="${not empty pos}">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>PO Code</th>
                                <th>Order Date</th>
                                <th>Expected Delivery</th>
                                <th>Supplier</th>
                                <th>Destination Warehouse</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="po" items="${pos}">
                                <tr>
                                    <td>${po.poCode}</td>
                                    <td>${po.formattedOrderDate}</td>
                                    <td><fmt:formatDate value="${po.expectedDeliveryDate}" pattern="dd/MM/yyyy"/></td>
                                    <td>
                                        <c:forEach var="supplier" items="${suppliers}">
                                            <c:if test="${supplier.supplierId == po.providerId}">
                                                ${supplier.supplierName}
                                            </c:if>
                                        </c:forEach>
                                    </td>
                                    <td>
                                        <c:forEach var="warehouse" items="${warehouses}">
                                            <c:if test="${warehouse.warehouseId == po.warehouseId}">
                                                ${warehouse.warehouseName}
                                            </c:if>
                                        </c:forEach>
                                    </td>
                                    <td>
                                        <span class="badge 
                                            <c:choose>
                                                <c:when test="${po.status == 'pending'}">bg-warning</c:when>
                                                <c:when test="${po.status == 'completed'}">bg-success</c:when>
                                                <c:when test="${po.status == 'cancelled'}">bg-danger</c:when>
                                                <c:otherwise>bg-secondary</c:otherwise>
                                            </c:choose>
                                        ">${po.status}</span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/warehouse?action=create-stock-inward&poId=${po.poId}" class="btn btn-primary btn-sm">
                                            <i class="fas fa-plus-circle"></i> Create Import Receipt
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:if>
                <c:if test="${empty pos}">
                    <div class="alert alert-info" role="alert">
                        There are no pending purchase orders waiting for import.
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/view/common/foot.jsp"/>
</body>
</html> 