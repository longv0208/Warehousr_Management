<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Inventory List</title>
        <!-- Include Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Include Bootstrap Icons -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <!-- Include DataTables CSS -->
        <link href="https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    </head>
    <body>
        <jsp:include page="../../common/sidebar.jsp" />
        
        <div class="container-fluid" style="margin-left: 250px; padding: 20px;">
            <h2 class="mb-4">Inventory List</h2>
            
            <div class="card">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped" id="inventoryTable">
                            <thead>
                                <tr>
                                    <th>Product Code</th>
                                    <th>Product Name</th>
                                    <th>Warehouse</th>
                                    <th>Quantity on Hand</th>
                                    <th>Unit</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${products}" var="product">
                                    <c:forEach items="${warehouses}" var="warehouse">
                                        <tr>
                                            <td>${product.productCode}</td>
                                            <td>${product.productName}</td>
                                            <td>${warehouse.warehouseName}</td>
                                            <td>
                                                <!-- You'll need to implement this in your DAO -->
                                                <c:set var="quantity" value="${inventoryDAO.getQuantityOnHand(product.productId, warehouse.warehouseId)}" />
                                                ${quantity}
                                            </td>
                                            <td>${product.unit}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${quantity <= product.minStockLevel}">
                                                        <span class="badge bg-danger">Low Stock</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-success">In Stock</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Include jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
        <!-- Include Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <!-- Include DataTables JS -->
        <script src="https://cdn.datatables.net/1.13.5/js/jquery.dataTables.min.js"></script>
        <script src="https://cdn.datatables.net/1.13.5/js/dataTables.bootstrap5.min.js"></script>
        
        <script>
            $(document).ready(function() {
                $('#inventoryTable').DataTable({
                    "pageLength": 25,
                    "order": [[0, "asc"]]
                });
            });
        </script>
    </body>
</html> 