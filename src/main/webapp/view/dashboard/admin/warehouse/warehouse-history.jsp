<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Xem Nhật Ký Hàng Tồn Kho</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
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

                        .badge-inward {
                            background-color: #28a745;
                        }

                        .badge-outward {
                            background-color: #dc3545;
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
                                <h3><i class="fas fa-warehouse me-2"></i>Xem Nhật Ký Hàng Tồn Kho:
                                    ${warehouse.warehouseName}</h3>
                                <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=view&id=${warehouse.warehouseId}"
                                    class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Quay Lại Chi Tiết Kho
                                </a>
                            </div>

                            <!-- Search and Filter Section -->
                            <div class="search-section">
                                <form method="GET" action="${pageContext.request.contextPath}/admin/manage-warehouse">
                                    <input type="hidden" name="action" value="history">
                                    <input type="hidden" name="id" value="${warehouse.warehouseId}">

                                    <div class="filter-row">
                                        <div class="filter-group">
                                            <label for="productCode">Mã Sản Phẩm</label>
                                            <input type="text" class="form-control" id="productCode" name="productCode"
                                                placeholder="Nhập mã SP" value="${filterProductCode}">
                                        </div>

                                        <div class="filter-group">
                                            <label for="transactionType">Loại Giao Dịch</label>
                                            <select class="form-select" id="transactionType" name="transactionType">
                                                <option value="">Tất cả</option>
                                                <option value="inward" ${filterTransactionType=='inward' ? 'selected'
                                                    : '' }>Nhập Kho</option>
                                                <option value="outward" ${filterTransactionType=='outward' ? 'selected'
                                                    : '' }>Xuất Kho</option>
                                            </select>
                                        </div>

                                        <div class="filter-group">
                                            <label for="fromDate">Từ Ngày</label>
                                            <input type="date" class="form-control" id="fromDate" name="fromDate"
                                                value="${filterFromDate}">
                                        </div>

                                        <div class="filter-group">
                                            <label for="toDate">Đến Ngày</label>
                                            <input type="date" class="form-control" id="toDate" name="toDate"
                                                value="${filterToDate}">
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
                                            <button type="button" class="btn btn-export">
                                                <i class="fas fa-file-excel"></i> Xuất Excel
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>

                            <!-- Transaction History Table -->
                            <div class="table-container">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0" id="historyTable">
                                        <thead>
                                            <tr>
                                                <th>Mã Sản Phẩm</th>
                                                <th>Tên Sản Phẩm</th>
                                                <th>Loại Giao Dịch</th>
                                                <th>Số Lượng</th>
                                                <th>Số Lượng Tồn</th>
                                                <th>Đơn Vị</th>
                                                <th>Ngày Giao Dịch</th>
                                                <th>Mã Phiếu</th>
                                                <th>Ghi Chú</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <!-- Transaction Records -->
                                            <c:forEach var="transaction" items="${transactions}">
                                                <tr>
                                                    <td>${transaction.productCode}</td>
                                                    <td>${transaction.productName}</td>
                                                    <td>
                                                        <span
                                                            class="badge ${transaction.transactionType == 'inward' ? 'badge-inward' : 'badge-outward'}">
                                                            ${transaction.transactionType == 'inward' ? 'Nhập Kho' :
                                                            'Xuất Kho'}
                                                        </span>
                                                    </td>
                                                    <td>${transaction.quantity > 0 ? transaction.quantity : '-'}</td>
                                                    <td>${transaction.remainingQuantity > 0 ?
                                                        transaction.remainingQuantity : '-'}</td>
                                                    <td>${transaction.unit}</td>
                                                    <td>
                                                        <c:set var="day"
                                                            value="${transaction.transactionDate.dayOfMonth < 10 ? '0' : ''}${transaction.transactionDate.dayOfMonth}" />
                                                        <c:set var="month"
                                                            value="${transaction.transactionDate.monthValue < 10 ? '0' : ''}${transaction.transactionDate.monthValue}" />
                                                        ${day}/${month}/${transaction.transactionDate.year}
                                                    </td>
                                                    <td>${transaction.transactionCode}</td>
                                                    <td>${transaction.notes}</td>
                                                </tr>
                                            </c:forEach>

                                            <c:if test="${empty transactions}">
                                                <tr>
                                                    <td colspan="9" class="text-center py-4">
                                                        <i class="fas fa-inbox fa-2x text-muted mb-2"></i>
                                                        <br>
                                                        <span class="text-muted">Không có giao dịch nào được tìm
                                                            thấy</span>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Summary Statistics -->
                            <div class="row mt-4">
                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-body text-center">
                                            <h5 class="card-title text-success">
                                                <i class="fas fa-arrow-down"></i> Tổng Phiếu Nhập
                                            </h5>
                                            <h3 class="text-success">
                                                <c:set var="inwardCount" value="0" />
                                                <c:forEach var="transaction" items="${transactions}">
                                                    <c:if test="${transaction.transactionType == 'inward'}">
                                                        <c:set var="inwardCount" value="${inwardCount + 1}" />
                                                    </c:if>
                                                </c:forEach>
                                                ${inwardCount}
                                            </h3>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-body text-center">
                                            <h5 class="card-title text-danger">
                                                <i class="fas fa-arrow-up"></i> Tổng Phiếu Xuất
                                            </h5>
                                            <h3 class="text-danger">
                                                <c:set var="outwardCount" value="0" />
                                                <c:forEach var="transaction" items="${transactions}">
                                                    <c:if test="${transaction.transactionType == 'outward'}">
                                                        <c:set var="outwardCount" value="${outwardCount + 1}" />
                                                    </c:if>
                                                </c:forEach>
                                                ${outwardCount}
                                            </h3>
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
                        $(document).ready(function () {
                            // Initialize DataTable with Vietnamese language
                            $('#historyTable').DataTable({
                                "language": {
                                    "url": "//cdn.datatables.net/plug-ins/1.10.21/i18n/Vietnamese.json"
                                },
                                "order": [[6, "desc"]], // Sort by date descending
                                "pageLength": 25,
                                "responsive": true
                            });

                            // Export to Excel functionality
                            $('.btn-export').click(function () {
                                // Implementation for Excel export
                                alert('Chức năng xuất Excel sẽ được phát triển sau');
                            });
                        });
                    </script>
            </body>

            </html>