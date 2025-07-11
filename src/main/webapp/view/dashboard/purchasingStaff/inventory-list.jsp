<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Inventory List</title>
        <!-- Include Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Include Bootstrap Icons -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <!-- Include DataTables CSS -->
        <link href="https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css" rel="stylesheet">
        <link href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.bootstrap5.min.css" rel="stylesheet">
        
        <style>
            .main-content {
                margin-left: 250px;
                padding: 20px;
            }
            
            @media (max-width: 768px) {
                .main-content {
                    margin-left: 0;
                    padding: 10px;
                }
            }
            
            .table th, .table td {
                white-space: nowrap;
                font-size: 0.875rem;
            }
            
            .filter-section {
                background-color: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 20px;
            }
            
            .status-badge {
                font-size: 0.75rem;
            }
            
            .filter-alert {
                border: none;
                border-radius: 8px;
                font-size: 0.875rem;
            }
            
            .btn-group .btn {
                border-radius: 0;
            }
            
            .btn-group .btn:first-child {
                border-top-left-radius: 0.375rem;
                border-bottom-left-radius: 0.375rem;
            }
            
            .btn-group .btn:last-child {
                border-top-right-radius: 0.375rem;
                border-bottom-right-radius: 0.375rem;
            }
        </style>
    </head>
    <body>
        <jsp:include page="../../common/sidebar.jsp" />
        
        <div class="main-content">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="mb-0">
                    <i class="bi bi-boxes"></i> Quản lý tồn kho
                </h2>
            </div>
            
            <!-- Filter Section -->
            <div class="filter-section">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="mb-0">
                        <i class="bi bi-funnel"></i> Bộ lọc và tìm kiếm
                    </h5>
                    <div class="btn-group">
                        <button type="button" class="btn btn-primary btn-sm" id="applyFilters" 
                                title="Nhấn để áp dụng các bộ lọc đã chọn"
                                data-bs-toggle="tooltip" data-bs-placement="bottom">
                            <i class="bi bi-funnel-fill"></i> Áp dụng bộ lọc
                        </button>
                        <button type="button" class="btn btn-outline-secondary btn-sm" id="clearFilters"
                                title="Xóa tất cả bộ lọc và tìm kiếm"
                                data-bs-toggle="tooltip" data-bs-placement="bottom">
                            <i class="bi bi-x-circle"></i> Xóa bộ lọc
                        </button>
                    </div>
                </div>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label for="warehouseFilter" class="form-label">
                            <i class="bi bi-building"></i> Lọc theo kho
                        </label>
                        <select class="form-select" id="warehouseFilter">
                            <option value="">Tất cả kho</option>
                            <c:forEach items="${warehouses}" var="warehouse">
                                <option value="${warehouse.warehouseName}">${warehouse.warehouseName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label for="statusFilter" class="form-label">
                            <i class="bi bi-tag"></i> Lọc theo trạng thái
                        </label>
                        <select class="form-select" id="statusFilter">
                            <option value="">Tất cả trạng thái</option>
                            <option value="In Stock">Còn hàng</option>
                            <option value="Low Stock">Sắp hết hàng</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label for="quickSearch" class="form-label">
                            <i class="bi bi-search"></i> Tìm kiếm nhanh
                        </label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="quickSearch" placeholder="Tìm theo mã hoặc tên sản phẩm...">
                            <button class="btn btn-primary" type="button" id="searchBtn">
                                <i class="bi bi-search"></i> Tìm
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Active Filters Display -->
                <div class="mt-3" id="activeFiltersContainer" style="display: none;">
                    <small class="text-muted">Bộ lọc đang áp dụng:</small>
                    <div id="activeFilters" class="d-flex flex-wrap gap-2 mt-1"></div>
                </div>
            </div>
            
            <div class="card">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover" id="inventoryTable">
                            <thead class="table-dark">
                                <tr>
                                    <th>Mã SP</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Kho</th>
                                    <th>SL tồn</th>
                                    <th>ĐVT</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${inventoryData}" var="item">
                                        <tr>
                                        <td><code>${item.productCode}</code></td>
                                        <td class="fw-medium">${item.productName}</td>
                                            <td>
                                            <span class="badge bg-info text-dark">${item.warehouseName}</span>
                                            </td>
                                        <td class="text-end fw-bold">
                                                <c:choose>
                                                <c:when test="${item.quantity <= item.lowStockThreshold}">
                                                    <span class="text-danger">${item.quantity}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                    <span class="text-success">${item.quantity}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        <td><small class="text-muted">${item.unit}</small></td>
                                        <td>
                                            <span class="badge ${item.statusClass} status-badge">${item.status}</span>
                                        </td>
                                        </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Summary Section -->
                    <div class="row mt-3">
                        <div class="col-md-6">
                            <div class="d-flex align-items-center">
                                <i class="bi bi-info-circle text-primary me-2"></i>
                                <small class="text-muted">
                                    Tổng: <span id="totalRows">${inventoryData.size()}</span> bản ghi
                                </small>
                            </div>
                        </div>
                        <div class="col-md-6 text-end">
                            <div class="d-flex justify-content-end gap-3">
                                <div>
                                    <span class="badge bg-success">Còn hàng:</span>
                                    <span id="inStockCount">0</span>
                                </div>
                                <div>
                                    <span class="badge bg-danger">Sắp hết:</span>
                                    <span id="lowStockCount">0</span>
                                </div>
                            </div>
                        </div>
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
        <script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
        <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.bootstrap5.min.js"></script>
        
        <script>
            $(document).ready(function() {
                // Initialize DataTable
                var table = $('#inventoryTable').DataTable({
                    "pageLength": 25,
                    "order": [[0, "asc"]],
                    "language": {
                        "search": "Tìm kiếm:",
                        "lengthMenu": "Hiển thị _MENU_ bản ghi",
                        "info": "Hiển thị _START_ đến _END_ của _TOTAL_ bản ghi",
                        "infoEmpty": "Hiển thị 0 đến 0 của 0 bản ghi",
                        "infoFiltered": "(được lọc từ _MAX_ tổng số bản ghi)",
                        "paginate": {
                            "first": "Đầu",
                            "last": "Cuối",
                            "next": "Tiếp",
                            "previous": "Trước"
                        },
                        "emptyTable": "Không có dữ liệu trong bảng",
                        "zeroRecords": "Không tìm thấy bản ghi nào phù hợp"
                    },
                    "responsive": true,
                    /* Remove built-in DataTables search box (we provide our own quick search) */
                    "dom": '<"row"<"col-sm-12 col-md-6"l>>rtip',
                    "drawCallback": function() {
                        // Pass current DataTable API instance to avoid undefined 'table' during initial draw
                        updateSummary(this.api());
                    }
                });

                // Custom filter function using jQuery.fn.dataTable.ext.search
                $.fn.dataTable.ext.search.push(function(settings, data, dataIndex) {
                    var warehouseFilter = $('#warehouseFilter').val();
                    var statusFilter = $('#statusFilter').val();
                    
                    // Get text content from cells (strip HTML)
                    var warehouseText = $('<div>').html(data[2]).text().trim();
                    var statusText = $('<div>').html(data[5]).text().trim();
                    
                    // Check warehouse filter
                    if (warehouseFilter && !warehouseText.toLowerCase().includes(warehouseFilter.toLowerCase())) {
                        return false;
                    }
                    
                    // Check status filter
                    if (statusFilter && !statusText.toLowerCase().includes(statusFilter.toLowerCase())) {
                        return false;
                    }
                    
                    return true;
                });
                
                // Filter function
                function applyFilters() {
                    table.draw();
                    // Refresh active filters display after draw
                    updateActiveFilters();
                }
                
                // Quick search function
                function quickSearch() {
                    var searchValue = $('#quickSearch').val();
                    
                    if (searchValue) {
                        // Clear column-specific searches first
                        table.columns().search('');
                        // Apply global search
                        table.search(searchValue).draw();
                    } else {
                        // Clear search
                        table.search('').draw();
                    }
                    // Update active filters badge after search
                    updateActiveFilters();
                }
                
                // Update summary counts
                function updateSummary(dtApi) {
                    // Use provided API instance if available, otherwise fallback to global 'table'
                    var dt = dtApi || table;
                    var visibleRows = dt.rows({ filter: 'applied' });
                    var inStockCount = 0;
                    var lowStockCount = 0;
                    
                    visibleRows.every(function() {
                        var statusCell = $(this.node()).find('td:eq(5)');
                        var statusText = statusCell.text().trim();
                        
                        if (statusText === 'In Stock') {
                            inStockCount++;
                        } else if (statusText === 'Low Stock') {
                            lowStockCount++;
                        }
                    });
                    
                    $('#inStockCount').text(inStockCount);
                    $('#lowStockCount').text(lowStockCount);
                    $('#totalRows').text(visibleRows.count());
                }

                // Clear filters function
                function clearFilters() {
                    $('#warehouseFilter').val('');
                    $('#statusFilter').val('');
                    $('#quickSearch').val('');
                    table.search('').columns().search('').draw();
                    updateActiveFilters();
                    
                    // Show success message
                    showFilterMessage('Đã xóa tất cả bộ lọc!', 'success');
                    
                    // Clear any search timeouts
                    if (window.searchTimeout) {
                        clearTimeout(window.searchTimeout);
                    }
                }
                
                // Update active filters display
                function updateActiveFilters() {
                    var activeFilters = [];
                    var container = $('#activeFiltersContainer');
                    var filtersDiv = $('#activeFilters');
                    
                    // Check warehouse filter
                    var warehouseVal = $('#warehouseFilter').val();
                    if (warehouseVal) {
                        activeFilters.push('<span class="badge bg-primary"><i class="bi bi-building"></i> Kho: ' + warehouseVal + '</span>');
                    }
                    
                    // Check status filter
                    var statusVal = $('#statusFilter').val();
                    if (statusVal) {
                        var statusText = statusVal === 'In Stock' ? 'Còn hàng' : 'Sắp hết hàng';
                        activeFilters.push('<span class="badge bg-info"><i class="bi bi-tag"></i> Trạng thái: ' + statusText + '</span>');
                    }
                    
                    // Check search
                    var searchVal = $('#quickSearch').val();
                    if (searchVal) {
                        activeFilters.push('<span class="badge bg-success"><i class="bi bi-search"></i> Tìm kiếm: "' + searchVal + '"</span>');
                    }
                    
                    if (activeFilters.length > 0) {
                        filtersDiv.html(activeFilters.join(' '));
                        container.show();
                    } else {
                        container.hide();
                    }
                }

                // Show filter message
                function showFilterMessage(message, type = 'info') {
                    // Remove existing alerts
                    $('.filter-alert').remove();
                    
                    var alertClass = type === 'success' ? 'alert-success' : 'alert-info';
                    var alertHtml = '<div class="alert ' + alertClass + ' alert-dismissible fade show filter-alert mt-2" role="alert">' +
                                    '<i class="bi bi-info-circle"></i> ' + message +
                                    '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                                    '</div>';
                    
                    $('.filter-section').append(alertHtml);
                    
                    // Auto hide after 3 seconds
                    setTimeout(function() {
                        $('.filter-alert').fadeOut();
                    }, 3000);
                }
                
                // Check if filters need to be applied (show indicator)
                function checkFilterChanges() {
                    var hasChanges = $('#warehouseFilter').val() || $('#statusFilter').val();
                    var applyBtn = $('#applyFilters');
                    
                    if (hasChanges) {
                        applyBtn.removeClass('btn-primary').addClass('btn-warning');
                        applyBtn.html('<i class="bi bi-exclamation-triangle"></i> Áp dụng bộ lọc');
                    } else {
                        applyBtn.removeClass('btn-warning').addClass('btn-primary');
                        applyBtn.html('<i class="bi bi-funnel-fill"></i> Áp dụng bộ lọc');
                    }
                }

                // Event listeners
                $('#warehouseFilter, #statusFilter').on('change', function() {
                    checkFilterChanges();
                    // Don't auto-apply, wait for button click
                });
                
                $('#quickSearch').on('keyup input', function() {
                    // Search is still real-time for better UX
                    clearTimeout(window.searchTimeout);
                    window.searchTimeout = setTimeout(quickSearch, 300); // Debounce 300ms
                });
                
                $('#searchBtn').on('click', quickSearch);
                $('#applyFilters').on('click', function() {
                    applyFilters();
                    // Reset button state
                    $(this).removeClass('btn-warning').addClass('btn-primary');
                    $(this).html('<i class="bi bi-funnel-fill"></i> Áp dụng bộ lọc');
                });
                $('#clearFilters').on('click', function() {
                    clearFilters();
                    checkFilterChanges();
                });
                
                // Enter key support for search
                $('#quickSearch').on('keypress', function(e) {
                    if (e.which === 13) { // Enter key
                        quickSearch();
                    }
                });
                
                // Initialize tooltips
                var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
                var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                    return new bootstrap.Tooltip(tooltipTriggerEl);
                });
                
                // Initialize summary and active filters
                updateSummary();
                updateActiveFilters();
                checkFilterChanges();
                
                console.log('DataTable initialized with manual filters and search');
            });
        </script>
    </body>
</html> 