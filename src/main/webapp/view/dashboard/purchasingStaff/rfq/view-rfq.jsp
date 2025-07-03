<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Request for Quotation</title>
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
                        <h4 class="mb-0">RFQ Details - ${rfq.rfqCode}</h4>
                        <div class="d-flex gap-2">
                            <c:if test="${rfq.status == 'pending'}">
                                <form action="purchasing" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="send-rfq">
                                    <input type="hidden" name="id" value="${rfq.rfqId}">
                                    <button type="submit" class="btn btn-success" onclick="return confirm('Are you sure you want to send this RFQ?')">
                                        <i class="fas fa-paper-plane"></i> Send RFQ
                                    </button>
                                </form>
                            </c:if>
                            
                            <c:if test="${rfq.status == 'sent' && existingPO == null}">
                                <a href="purchasing?action=create-po-from-rfq&rfqId=${rfq.rfqId}" class="btn btn-primary">
                                    <i class="fas fa-file-invoice"></i> Create Purchase Order
                                </a>
                            </c:if>
                            
                            <c:if test="${existingPO != null}">
                                <a href="purchasing?action=view-po&id=${existingPO.poId}" class="btn btn-info">
                                    <i class="fas fa-eye"></i> View Purchase Order
                                </a>
                            </c:if>
                            
                            <a href="purchasing?action=list-rfq" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Back to List
                            </a>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <table class="table table-borderless">
                                    <tr>
                                        <th width="150">RFQ Code:</th>
                                        <td>${rfq.rfqCode}</td>
                                    </tr>
                                    <tr>
                                        <th>Supplier:</th>
                                        <td>${supplier.supplierName}</td>
                                    </tr>
                                    <tr>
                                        <th>Contact Person:</th>
                                        <td>${supplier.contactPerson}</td>
                                    </tr>
                                    <tr>
                                        <th>Email:</th>
                                        <td>${supplier.email}</td>
                                    </tr>
                                    <tr>
                                        <th>Phone:</th>
                                        <td>${supplier.phoneNumber}</td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <table class="table table-borderless">
                                    <tr>
                                        <th width="180">Warehouse:</th>
                                        <td>${warehouse.warehouseName}</td>
                                    </tr>
                                    <tr>
                                        <th>Expected Delivery:</th>
                                        <td>
                                            <fmt:formatDate value="${rfq.expectedDeliveryDate}" pattern="dd/MM/yyyy"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Status:</th>
                                        <td>
                                            <span class="badge 
                                                ${rfq.status == 'pending' ? 'bg-warning' : 
                                                  rfq.status == 'sent' ? 'bg-info' : 
                                                  rfq.status == 'approved' ? 'bg-success' : 
                                                  rfq.status == 'completed' ? 'bg-primary' : 'bg-danger'}">
                                                ${rfq.status.toUpperCase()}
                                            </span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Created Date:</th>
                                        <td>
                                            <fmt:formatDate value="${rfq.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Note:</th>
                                        <td>${rfq.note}</td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        
                        <hr>
                        
                        <h5>Products Requested</h5>
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Product Code</th>
                                        <th>Product Name</th>
                                        <th>Unit</th>
                                        <th>Quantity Requested</th>
                                        <th>Purchase Price</th>
                                        <th>Sale Price</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="detail" items="${rfqDetails}">
                                        <c:forEach var="product" items="${products}">
                                            <c:if test="${product.productId == detail.productId}">
                                                <tr>
                                                    <td>${product.productCode}</td>
                                                    <td>${product.productName}</td>
                                                    <td>${product.unit}</td>
                                                    <td>${detail.quantity}</td>
                                                    <td>
                                                        <fmt:formatNumber value="${product.purchasePrice}" type="currency" currencySymbol="₫"/>
                                                    </td>
                                                    <td>
                                                        <fmt:formatNumber value="${product.salePrice}" type="currency" currencySymbol="₫"/>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </c:forEach>
                                    </c:forEach>
                                    <c:if test="${empty rfqDetails}">
                                        <tr>
                                            <td colspan="6" class="text-center">No products found</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        
                        <c:if test="${existingPO != null}">
                            <hr>
                            <div class="alert alert-info">
                                <strong>Purchase Order Created:</strong> 
                                A purchase order (${existingPO.poCode}) has been created from this RFQ.
                                <a href="purchasing?action=view-po&id=${existingPO.poId}" class="alert-link">View Purchase Order</a>
                            </div>
                        </c:if>
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