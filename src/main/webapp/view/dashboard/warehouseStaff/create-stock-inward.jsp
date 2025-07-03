<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Import Receipt from Purchase Order</title>
    <jsp:include page="/view/common/head.jsp"/>
    <style>
        .main-content {
            margin-left: 250px; /* Same as sidebar width */
            padding: 20px;
        }
        .info-card .row { margin-bottom: 0.5rem; }
        .info-card-title { font-weight: bold; color: #555; }
        .product-table th { text-align: center; }
        .product-table td { vertical-align: middle; }
    </style>
</head>
<body>
    <jsp:include page="/view/common/sidebar.jsp"/>
    <div class="main-content">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h4 class="mb-0">Create Import Receipt from Purchase Order - ${po.poCode}</h4>
                <a href="${pageContext.request.contextPath}/warehouse?action=list-po-for-inward" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to PO List
                </a>
            </div>
            <div class="card-body">
                <!-- Purchase Order Information -->
                <div class="card mb-4 info-card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-file-invoice"></i> Purchase Order Information</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">PO ID:</div>
                                    <div class="col-sm-8">${po.poCode}</div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Order Date:</div>
                                    <div class="col-sm-8">${po.formattedOrderDate}</div>
                                </div>
                                 <div class="row">
                                    <div class="col-sm-4 info-card-title">Warehouse:</div>
                                    <div class="col-sm-8">${warehouse.warehouseName}</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Provider:</div>
                                    <div class="col-sm-8">${supplier.supplierName}</div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-4 info-card-title">Expected Delivery:</div>
                                    <div class="col-sm-8"><fmt:formatDate value="${po.expectedDeliveryDate}" pattern="dd/MM/yyyy"/></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Create Import Receipt Form -->
                <form action="${pageContext.request.contextPath}/warehouse" method="POST" id="createInwardForm">
                    <input type="hidden" name="action" value="create-stock-inward">
                    <input type="hidden" name="poId" value="${po.poId}">

                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-receipt"></i> Create Import Receipt</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="supplierName" class="form-label">Supplier Name</label>
                                    <input type="text" id="supplierName" class="form-control" value="${supplier.supplierName}" readonly>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="status" class="form-label">Status</label>
                                    <input type="text" id="status" class="form-control" value="Completed" readonly>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="receiptDate" class="form-label">Receipt Date</label>
                                    <input type="text" id="receiptDate" class="form-control" value="<fmt:formatDate pattern = "dd/MM/yyyy" value="<%= new java.util.Date() %>" />" readonly>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="description" class="form-label">Description</label>
                                    <textarea id="description" name="description" class="form-control" rows="1"></textarea>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Products -->
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-box-open"></i> Products - Enter Actual Received Quantities</h5>
                        </div>
                        <div class="card-body">
                            <table class="table table-bordered product-table">
                                <thead>
                                    <tr>
                                        <th>Product</th>
                                        <th>Ordered Qty</th>
                                        <th>Unit Price</th>
                                        <th>Actual Received Qty <span class="text-danger">*</span></th>
                                        <th>Notes</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="detailView" items="${poDetails}">
                                        <tr>
                                            <td>
                                                ${detailView.product.productName} (${detailView.product.productCode})
                                                <input type="hidden" name="productId" value="${detailView.detail.productId}">
                                                <input type="hidden" name="unitPrice" value="${detailView.detail.unitPrice}">
                                            </td>
                                            <td class="text-center">${detailView.detail.quantity}</td>
                                            <td class="text-end">
                                                <fmt:formatNumber value="${detailView.detail.unitPrice}" type="currency" currencySymbol="$"/>
                                            </td>
                                            <td>
                                                <input type="number" name="actualReceivedQty" class="form-control" value="${detailView.detail.quantity}" min="0" required>
                                            </td>
                                            <td>
                                                <input type="text" name="notes" class="form-control">
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <a href="${pageContext.request.contextPath}/warehouse?action=list-po-for-inward" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-check-circle"></i> Create & Complete
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/view/common/foot.jsp"/>
<script>
    document.getElementById('createInwardForm').addEventListener('submit', function(e) {
        let valid = true;
        const receivedQtys = document.querySelectorAll('input[name="actualReceivedQty"]');
        receivedQtys.forEach(input => {
            if (input.value.trim() === '' || parseInt(input.value) < 0) {
                valid = false;
                input.classList.add('is-invalid');
            } else {
                input.classList.remove('is-invalid');
            }
        });

        if (!valid) {
            e.preventDefault();
            alert('Please enter a valid, non-negative quantity for all products.');
        }
    });
</script>
</body>
</html> 