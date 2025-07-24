<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Trạng Thái Sản Phẩm Trong Kho</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
                <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
                <!-- DataTables CSS & JS -->
                <link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css"/>
                <script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                    rel="stylesheet" />
                <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet" />
                <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet" />
                
                <%@include file="../../../common/head.jsp" %>
                    <style>
                        .search-section {
                            background-color: #f8f9fa;
                            padding: 20px;
                            border-radius: 10px;
                            margin-bottom: 20px;
                        }

                        .filter-row {
                            display: flex;
                            gap: 15px;
                            align-items: end;
                            flex-wrap: wrap;
                        }

                        .filter-group {
                            display: flex;
                            flex-direction: column;
                            min-width: 120px;
                        }

                        .filter-group label {
                            font-weight: 500;
                            margin-bottom: 5px;
                            color: #333;
                        }

                        .btn-export {
                            background-color: #28a745;
                            border-color: #28a745;
                            color: white;
                        }

                        .btn-export:hover {
                            background-color: #218838;
                            border-color: #1e7e34;
                        }

                        .table-container {
                            background: white;
                            border-radius: 10px;
                            overflow: hidden;
                            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                        }

                        .table th {
                            background-color: #f8f9fa;
                            font-weight: 600;
                            border-bottom: 2px solid #dee2e6;
                            text-align: center;
                            vertical-align: middle;
                        }

                        .table td {
                            text-align: center;
                            vertical-align: middle;
                        }

                        .status-available {
                            color: #28a745;
                            font-weight: bold;
                        }

                        .status-low {
                            color: #fd7e14;
                            font-weight: bold;
                        }

                        .status-out {
                            color: #dc3545;
                            font-weight: bold;
                        }

                        .quantity-on-hand {
                            font-size: 1.1em;
                            font-weight: bold;
                        }

                        .quantity-outgoing {
                            color: #dc3545;
                            font-style: italic;
                        }

                        .quantity-incoming {
                            color: #28a745;
                            font-style: italic;
                        }

                        .quantity-detail {
                            font-size: 0.9em;
                            margin-top: 2px;
                        }

                        .stats-card {
                            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                            color: white;
                            border-radius: 10px;
                            padding: 20px;
                            margin-bottom: 20px;
                        }

                        .stats-item {
                            text-align: center;
                        }

                        .stats-number {
                            font-size: 2rem;
                            font-weight: bold;
                            display: block;
                        }

                        .stats-label {
                            font-size: 0.9rem;
                            opacity: 0.9;
                        }
                    </style>
            </head>

            <body>
                <div class="container-fluid">
                    <div class="row">
                        <!-- Sidebar -->
                        <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

                        <!-- Main Content -->
                        <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h3><i class="fas fa-warehouse me-2"></i>Trạng Thái Sản Phẩm Trong Kho:
                                    ${warehouse.warehouseName}</h3>
                                <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=view&id=${warehouse.warehouseId}"
                                    class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Quay Lại Chi Tiết Kho
                                </a>
                            </div>

                            <!-- Statistics Section -->
                            <div class="stats-card">
                                <div class="row">
                                    <div class="col-md-3">
                                        <div class="stats-item">
                                            <span class="stats-number">
                                                <c:set var="totalProducts" value="0" />
                                                <c:forEach var="product" items="${productStatusList}">
                                                    <c:set var="totalProducts" value="${totalProducts + 1}" />
                                                </c:forEach>
                                                ${totalProducts}
                                            </span>
                                            <span class="stats-label">Tổng Sản Phẩm</span>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="stats-item">
                                            <span class="stats-number">
                                                <c:set var="availableProducts" value="0" />
                                                <c:forEach var="product" items="${productStatusList}">
                                                    <c:if test="${product.onHand > 10}">
                                                        <c:set var="availableProducts" value="${availableProducts + 1}" />
                                                    </c:if>
                                                </c:forEach>
                                                ${availableProducts}
                                            </span>
                                            <span class="stats-label">Có Sẵn</span>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="stats-item">
                                            <span class="stats-number">
                                                <c:set var="lowStockProducts" value="0" />
                                                <c:forEach var="product" items="${productStatusList}">
                                                    <c:if test="${product.onHand > 0 && product.onHand <= 10}">
                                                        <c:set var="lowStockProducts" value="${lowStockProducts + 1}" />
                                                    </c:if>
                                                </c:forEach>
                                                ${lowStockProducts}
                                            </span>
                                            <span class="stats-label">Sắp Hết</span>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="stats-item">
                                            <span class="stats-number">
                                                <c:set var="outOfStockProducts" value="0" />
                                                <c:forEach var="product" items="${productStatusList}">
                                                    <c:if test="${product.onHand <= 0}">
                                                        <c:set var="outOfStockProducts" value="${outOfStockProducts + 1}" />
                                                    </c:if>
                                                </c:forEach>
                                                ${outOfStockProducts}
                                            </span>
                                            <span class="stats-label">Hết Hàng</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Search and Filter Section -->
                            <div class="search-section">
                                <form method="GET" action="${pageContext.request.contextPath}/admin/manage-warehouse">
                                    <input type="hidden" name="action" value="history">
                                    <input type="hidden" name="id" value="${warehouse.warehouseId}">

                                    <div class="filter-row">
                                        <div class="filter-group">
                                            <label for="productCode">Mã/Tên Sản Phẩm</label>
                                            <input type="text" class="form-control" id="productCode" name="productCode"
                                                placeholder="Nhập mã hoặc tên SP" value="${filterProductCode}">
                                        </div>

                                        <div class="filter-group">
                                            <label for="statusFilter">Trạng Thái</label>
                                            <select class="form-select" id="statusFilter" name="statusFilter">
                                                <option value="">Tất cả</option>
                                                <option value="available" ${filterStatusFilter=='available' ? 'selected' : '' }>Có Sẵn</option>
                                                <option value="low_stock" ${filterStatusFilter=='low_stock' ? 'selected' : '' }>Sắp Hết</option>
                                                <option value="out_of_stock" ${filterStatusFilter=='out_of_stock' ? 'selected' : '' }>Hết Hàng</option>
                                            </select>
                                        </div>

                                        <div class="filter-group">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-search"></i> Lọc
                                            </button>
                                        </div>

                                        <div class="filter-group">
                                            <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=history&id=${warehouse.warehouseId}"
                                                class="btn btn-secondary">
                                                <i class="fas fa-undo"></i> Đặt Lại
                                            </a>
                                        </div>

                                        <div class="filter-group">
                                            <form method="get" action="${pageContext.request.contextPath}/admin/manage-warehouse">
                                                <input type="hidden" name="action" value="export_history"/>
                                                <input type="hidden" name="id" value="${warehouse.warehouseId}"/>
                                                <input type="hidden" name="productCode" value="${filterProductCode}"/>
                                                <input type="hidden" name="statusFilter" value="${filterStatusFilter}"/>
                                                <button type="submit" class="btn btn-export">
                                                    <i class="fas fa-file-excel"></i> Xuất Excel
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </form>
                            </div>

                            <!-- Product Status Table -->
                            <div class="table-container">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0" id="productStatusTable">
                                        <thead>
                                            <tr>
                                                <th>Mã Sản Phẩm</th>
                                                <th>Tên Sản Phẩm</th>
                                                <th>Đơn Vị</th>
                                                <th>On Hand<br><small>(Có thể bán)</small></th>
                                                <th>Outgoing<br><small>(Đã đặt)</small></th>
                                                <th>Incoming<br><small>(Sắp nhập)</small></th>
                                                <th>Tổng Tồn Kho</th>
                                                <th>Đơn Giá</th>
                                                <th>Trạng Thái</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <!-- Product Status Records -->
                                            <c:forEach var="product" items="${productStatusList}">
                                                <tr>
                                                    <td><strong>${product.productCode}</strong></td>
                                                    <td class="text-start">${product.productName}</td>
                                                    <td>${product.unit}</td>
                                                    <td>
                                                        <span class="quantity-on-hand 
                                                            <c:choose>
                                                                <c:when test="${product.onHand <= 0}">status-out</c:when>
                                                                <c:when test="${product.onHand <= 10}">status-low</c:when>
                                                                <c:otherwise>status-available</c:otherwise>
                                                            </c:choose>
                                                        ">
                                                            ${product.onHand}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <span class="quantity-outgoing">
                                                            ${product.outgoing}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <span class="quantity-incoming">
                                                            ${product.incoming}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <strong>${product.totalInventory}</strong>
                                                    </td>
                                                    <td>
                                                        <c:if test="${product.unitPrice != null && product.unitPrice > 0}">
                                                            <fmt:formatNumber value="${product.unitPrice}" type="currency" currencySymbol="₫" />
                                                        </c:if>
                                                        <c:if test="${product.unitPrice == null || product.unitPrice <= 0}">
                                                            -
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${product.onHand <= 0}">
                                                                <span class="badge bg-danger">Hết Hàng</span>
                                                            </c:when>
                                                            <c:when test="${product.onHand <= 10}">
                                                                <span class="badge bg-warning text-dark">Sắp Hết</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-success">Có Sẵn</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>

                                            <c:if test="${empty productStatusList}">
                                                <tr>
                                                    <td colspan="9" class="text-center text-muted py-4">
                                                        <i class="fas fa-box-open fa-3x mb-3"></i><br>
                                                        Không có sản phẩm nào trong kho này
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Legend -->
                            <div class="row mt-4">
                                <div class="col-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0">Giải thích các trạng thái</h5>
                                        </div>
                                        <div class="card-body">
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <strong class="status-available">On Hand:</strong> Số lượng có thể bán ngay (Tổng tồn kho - Outgoing)
                                                </div>
                                                <div class="col-md-4">
                                                    <strong class="status-out">Outgoing:</strong> Số lượng đã được đặt hàng và chờ xuất kho
                                                </div>
                                                <div class="col-md-4">
                                                    <strong class="status-low">Incoming:</strong> Số lượng sắp được nhập từ đơn mua hàng đã duyệt
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </main>
                    </div>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                <%@include file="../../../common/foot.jsp" %>
                <script>
                    $(document).ready(function() {
                        $('#productStatusTable').DataTable({
                            "pageLength": 25,
                            "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "Tất cả"]],
                            "language": {
                                "url": "//cdn.datatables.net/plug-ins/1.13.7/i18n/vi.json"
                            },
                            "order": [[ 0, "asc" ]], // Sort by product code
                            "columnDefs": [
                                { "orderable": false, "targets": [8] } // Disable ordering on status column
                            ]
                        });
                    });
                </script>
            </body>

            </html>
