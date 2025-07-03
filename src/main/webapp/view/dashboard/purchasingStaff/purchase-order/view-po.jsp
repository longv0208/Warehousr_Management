<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Purchase Order</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css" rel="stylesheet">
    <style>
        /* Add margin to account for sidebar */
        .main-content {
            margin-left: 250px;
            padding: 20px;
        }
    </style>
</head>
<body>
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>
    
    <div class="main-content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h4 class="mb-0">Purchase Order Details - ${po.poCode}</h4>
                            <div class="d-flex gap-2">
                                <c:if test="${po.status == 'pending' && existingStockInward == null}">
                                    <a href="purchasing?action=create-stock-inward&poId=${po.poId}" class="btn btn-success">
                                        <i class="fas fa-truck"></i> Create Stock Inward
                                    </a>
                                </c:if>
                                
                                <c:if test="${existingStockInward != null}">
                                    <a href="purchasing?action=view-stock-inward&id=${existingStockInward.stockInwardId}" class="btn btn-info">
                                        <i class="fas fa-eye"></i> View Stock Inward
                                    </a>
                                </c:if>
                                
                                <a href="purchasing?action=list-po" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Back to List
                                </a>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <table class="table table-borderless">
                                        <tr>
                                            <th width="150">PO Code:</th>
                                            <td>${po.poCode}</td>
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
                                            <th>Order Date:</th>
                                            <td>
                                                ${po.formattedOrderDate}
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Expected Delivery:</th>
                                            <td>
                                                <fmt:formatDate value="${po.expectedDeliveryDate}" pattern="dd/MM/yyyy"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Status:</th>
                                            <td>
                                                <span class="badge 
                                                    ${po.status == 'pending' ? 'bg-warning' : 
                                                      po.status == 'approved' ? 'bg-success' : 
                                                      po.status == 'completed' ? 'bg-primary' : 'bg-danger'}">
                                                    ${po.status.toUpperCase()}
                                                </span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Created Date:</th>
                                            <td>
                                                <fmt:formatDate value="${po.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            
                            <hr>
                            
                            <h5>Order Details</h5>
                            <div class="table-responsive">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>Product Code</th>
                                            <th>Product Name</th>
                                            <th>Unit</th>
                                            <th>Quantity</th>
                                            <th>Unit Price</th>
                                            <th>Total Amount</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:set var="grandTotal" value="0" />
                                        <c:forEach var="detail" items="${poDetails}">
                                            <c:forEach var="product" items="${products}">
                                                <c:if test="${product.productId == detail.productId}">
                                                    <tr>
                                                        <td>${product.productCode}</td>
                                                        <td>${product.productName}</td>
                                                        <td>${product.unit}</td>
                                                        <td>${detail.quantity}</td>
                                                        <td>
                                                            <fmt:formatNumber value="${detail.unitPrice}" type="currency" currencySymbol="₫"/>
                                                        </td>
                                                        <td>
                                                            <c:set var="lineTotal" value="${detail.quantity * detail.unitPrice}" />
                                                            <fmt:formatNumber value="${lineTotal}" type="currency" currencySymbol="₫"/>
                                                            <c:set var="grandTotal" value="${grandTotal + lineTotal}" />
                                                        </td>
                                                    </tr>
                                                </c:if>
                                            </c:forEach>
                                        </c:forEach>
                                    </tbody>
                                    <tfoot class="table-light">
                                        <tr>
                                            <td colspan="5" class="text-end fw-bold">Grand Total:</td>
                                            <td class="fw-bold">
                                                <fmt:formatNumber value="${grandTotal}" type="currency" currencySymbol="₫"/>
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                            
                            <c:if test="${existingStockInward != null}">
                                <hr>
                                <div class="alert alert-success">
                                    <strong>Stock Inward Created:</strong> 
                                    A stock inward (${existingStockInward.inwardCode}) has been created from this Purchase Order.
                                    <a href="purchasing?action=view-stock-inward&id=${existingStockInward.stockInwardId}" class="alert-link">View Stock Inward</a>
                                </div>
                            </c:if>
                            
                            <c:if test="${po.status == 'pending' && existingStockInward == null}">
                                <hr>
                                <div class="alert alert-info">
                                    <strong>Next Step:</strong> 
                                    Create a Stock Inward to receive the goods and update inventory.
                                    <a href="purchasing?action=create-stock-inward&poId=${po.poId}" class="alert-link">Create Stock Inward</a>
                                </div>
                            </c:if>
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