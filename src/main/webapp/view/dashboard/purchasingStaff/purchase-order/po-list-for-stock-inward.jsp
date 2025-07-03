<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Orders - Ready for Stock Inward</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
    <style>
        body {
            background-color: #f8f9fa;
            margin-left: 250px;
        }
        
        .main-content {
            padding: 20px;
            min-height: 100vh;
        }
        
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border: none;
            transition: transform 0.2s;
        }
        
        .stat-card:hover {
            transform: translateY(-2px);
        }
        
        .status-badge {
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
        }
        
        .status-completed {
            background-color: #d4edda;
            color: #155724;
        }
        
        .btn-action {
            margin-right: 0.5rem;
            margin-bottom: 0.5rem;
        }
        
        .table-hover tbody tr:hover {
            background-color: #f8f9fa;
        }
    </style>
</head>
<body>
    <!-- Include Sidebar -->
    <jsp:include page="/view/common/sidebar.jsp" />

    <div class="main-content">
        <!-- Page Header -->
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col">
                    <h2 class="mb-2">
                        <i class="bi bi-truck"></i>
                        Purchase Orders - Ready for Stock Inward
                    </h2>
                    <p class="mb-0">Manage completed purchase orders ready for stock inward creation</p>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="text-muted mb-1">Completed POs</h5>
                            <h3 class="mb-0 text-success">${purchaseOrders.size()}</h3>
                        </div>
                        <i class="bi bi-check-circle-fill text-success fs-1"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Purchase Orders Table -->
        <div class="card">
            <div class="card-header bg-white py-3">
                <div class="row align-items-center">
                    <div class="col">
                        <h5 class="mb-0">
                            <i class="bi bi-list-ul"></i>
                            Completed Purchase Orders
                        </h5>
                    </div>
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>PO Code</th>
                                <th>Supplier</th>
                                <th>Warehouse</th>
                                <th>Order Date</th>
                                <th>Expected Delivery</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="po" items="${purchaseOrders}">
                                <tr>
                                    <td>
                                        <strong>${po.poCode}</strong>
                                    </td>
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
                                        <fmt:formatDate value="${po.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${po.expectedDeliveryDate}" pattern="dd/MM/yyyy"/>
                                    </td>
                                    <td>
                                        <span class="status-badge status-completed">
                                            <i class="bi bi-check-circle"></i>
                                            Completed
                                        </span>
                                    </td>
                                    <td>
                                        <a href="purchasing?action=view-po&id=${po.poId}" 
                                           class="btn btn-outline-primary btn-sm btn-action">
                                            <i class="bi bi-eye"></i>
                                            View
                                        </a>
                                        <a href="purchasing?action=create-stock-inward&poId=${po.poId}" 
                                           class="btn btn-success btn-sm btn-action">
                                            <i class="bi bi-plus-square"></i>
                                            Create Stock Inward
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty purchaseOrders}">
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">
                                        <i class="bi bi-inbox"></i>
                                        <div class="mt-2">No completed purchase orders available for stock inward creation</div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>
    
    <!-- Toast Messages -->
    <c:if test="${not empty sessionScope.toastMessage}">
        <script>
            iziToast.${sessionScope.toastType}({
                title: '${sessionScope.toastType == "success" ? "Success" : "Error"}',
                message: '${sessionScope.toastMessage}',
                position: 'topRight',
                timeout: 3000
            });
        </script>
        <c:remove var="toastMessage" scope="session"/>
        <c:remove var="toastType" scope="session"/>
    </c:if>
</body>
</html>