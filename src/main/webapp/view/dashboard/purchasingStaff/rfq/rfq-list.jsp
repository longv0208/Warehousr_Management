<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Request for Quotation - List</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>
    
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Request for Quotation (RFQ)</h4>
                        <a href="purchasing?action=create-rfq" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Create New RFQ
                        </a>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>RFQ Code</th>
                                        <th>Supplier</th>
                                        <th>Warehouse</th>
                                        <th>Expected Delivery</th>
                                        <th>Status</th>
                                        <th>Created Date</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="rfq" items="${rfqs}">
                                        <tr>
                                            <td>${rfq.rfqCode}</td>
                                            <td>
                                                <c:forEach var="supplier" items="${suppliers}">
                                                    <c:if test="${supplier.supplierId == rfq.providerId}">
                                                        ${supplier.supplierName}
                                                    </c:if>
                                                </c:forEach>
                                            </td>
                                            <td>
                                                <c:forEach var="warehouse" items="${warehouses}">
                                                    <c:if test="${warehouse.warehouseId == rfq.warehouseId}">
                                                        ${warehouse.warehouseName}
                                                    </c:if>
                                                </c:forEach>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${rfq.expectedDeliveryDate}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <span class="badge 
                                                    ${rfq.status == 'pending' ? 'bg-warning' : 
                                                      rfq.status == 'sent' ? 'bg-info' : 
                                                      rfq.status == 'approved' ? 'bg-success' : 
                                                      rfq.status == 'completed' ? 'bg-primary' : 'bg-danger'}">
                                                    ${rfq.status.toUpperCase()}
                                                </span>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${rfq.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <a href="purchasing?action=view-rfq&id=${rfq.rfqId}" 
                                                       class="btn btn-sm btn-outline-primary" title="View">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <c:if test="${rfq.status == 'pending'}">
                                                        <a href="purchasing?action=edit-rfq&id=${rfq.rfqId}" 
                                                           class="btn btn-sm btn-outline-secondary" title="Edit">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty rfqs}">
                                        <tr>
                                            <td colspan="7" class="text-center">No RFQs found</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Toast message display
        var toastMessage = "${sessionScope.toastMessage}";
        var toastType = "${sessionScope.toastType}";
        if (toastMessage) {
            iziToast.show({
                title: toastType === 'success' ? 'Success' : 'Error',
                message: toastMessage,
                position: 'topRight',
                color: toastType === 'success' ? 'green' : 'red',
                timeout: 5000,
                onClosing: function () {
                    fetch('${pageContext.request.contextPath}/remove-toast', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                    }).then(response => {
                        if (!response.ok) {
                            console.error('Failed to remove toast attributes');
                        }
                    }).catch(error => {
                        console.error('Error:', error);
                    });
                }
            });
        }
    </script>
</body>
</html> 