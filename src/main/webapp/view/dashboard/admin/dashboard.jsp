<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Dashboard - Quản Lý Kho Hàng</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/styles/index.css" rel="stylesheet"/>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        
        <style>
            .sidebar {
                height: 100vh;
                background-color: #343a40 !important;
                background: #343a40 !important;
                box-shadow: 2px 0 5px rgba(0,0,0,0.1);
                position: fixed;
                top: 0;
                left: 0;
                z-index: 1000;
                overflow-y: auto;
                width: 250px;
            }

            .sidebar-sticky {
                position: sticky;
                top: 0;
                height: 100vh;
                padding: 0;
            }
            .sidebar-brand {
                background: rgba(0,0,0,0.2);
                border-bottom: 1px solid rgba(255,255,255,0.1);
                padding: 1.5rem 1rem;
            }

            .sidebar-brand h4 {
                color: #ffffff !important;
                margin-bottom: 0;
                font-size: 1.1rem;
                font-weight: 500;
            }
            .sidebar-nav {
                padding: 0.5rem 0;
            }

            .sidebar-nav .nav-item {
                margin-bottom: 0;
            }
            .sidebar-heading {
                color: rgba(255,255,255,0.5);
                font-size: 0.65rem;
                font-weight: 600;
                letter-spacing: 1px;
                margin: 1rem 1rem 0.5rem 1rem;
                padding-bottom: 0.5rem;
                text-transform: uppercase;
                display: none;
            }
            .sidebar .nav-link {
                color: rgba(255,255,255,0.9) !important;
                text-decoration: none;
                padding: 0.875rem 1.5rem;
                margin: 0;
                border-radius: 0;
                transition: all 0.2s ease;
                display: block;
                font-size: 0.9rem;
                font-weight: 400;
                border-left: 3px solid transparent;
                border-bottom: 1px solid rgba(255,255,255,0.05);
            }

            .sidebar .nav-link:hover {
                background-color: rgba(255,255,255,0.08) !important;
                color: #ffffff !important;
                border-left: 3px solid #28a745;
            }

            .sidebar .nav-link.active {
                background-color: #28a745 !important;
                color: #ffffff !important;
                border-left: 3px solid #28a745;
                font-weight: 500;
            }

            .main-content {
                margin-left: 250px !important;
                width: calc(100% - 250px) !important;
                min-height: 100vh;
            }

            @media (max-width: 767.98px) {
                .sidebar {
                    position: fixed;
                    top: 0;
                    left: -250px;
                    width: 250px;
                    height: 100vh;
                    z-index: 1050;
                    transition: left 0.3s ease;
                }

                .sidebar.show {
                    left: 0;
                }

                .main-content {
                    margin-left: 0 !important;
                    width: 100% !important;
                }
            }
            .sidebar::-webkit-scrollbar {
                width: 6px;
            }

            .sidebar::-webkit-scrollbar-track {
                background: rgba(255,255,255,0.1);
            }

            .sidebar::-webkit-scrollbar-thumb {
                background: rgba(255,255,255,0.3);
                border-radius: 3px;
            }

            .sidebar::-webkit-scrollbar-thumb:hover {
                background: rgba(255,255,255,0.5);
            }
            
            .chart-container {
                position: relative;
                height: 400px;
                margin: 20px 0;
            }
            
            .chart-card {
                height: 500px;
            }
        </style>
    </head>
    <body>
        <jsp:include page="/view/common/sidebar.jsp" />
        
            <div class="container-fluid">
            <div class="row">
                <main class="main-content px-4 py-4">
                    <c:if test="${not empty sessionScope.errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${sessionScope.errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="errorMessage" scope="session"/>
                    </c:if>

                    <c:if test="${not empty sessionScope.successMessage}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            ${sessionScope.successMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="successMessage" scope="session"/>
                    </c:if>

                    <h2 class="mb-4">📊 Dashboard - Tổng quan hệ thống</h2>

                    <!-- Statistics Cards -->
                    <div class="row">
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-primary">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h5 class="card-title">Tổng Sản Phẩm</h5>
                                            <p class="card-text fs-4">${totalProducts}</p>
                                        </div>
                                        <i class="fas fa-boxes fa-2x opacity-75"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-success">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h5 class="card-title">Đã Nhập Hôm Nay</h5>
                                            <p class="card-text fs-4">${totalReceivedToday}</p>
                                        </div>
                                        <i class="fas fa-plus-circle fa-2x opacity-75"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-warning">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h5 class="card-title">Sắp Hết Hàng</h5>
                                            <p class="card-text fs-4">${totalLowStock}</p>
                                        </div>
                                        <i class="fas fa-exclamation-triangle fa-2x opacity-75"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-danger">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h5 class="card-title">Hết Hàng</h5>
                                            <p class="card-text fs-4">${totalOutOfStock}</p>
                                        </div>
                                        <i class="fas fa-times-circle fa-2x opacity-75"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row mt-3">
                        <div class="col-md-3 mb-3">
                            <div class="card text-bg-info">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h5 class="card-title">Tổng User</h5>
                                            <p class="card-text fs-4">${totalUsers}</p>
                                        </div>
                                        <i class="fas fa-users fa-2x opacity-75"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Charts Section -->
                    <div class="row mt-4">
                        <!-- Monthly Orders Chart -->
                        <div class="col-md-6 mb-4">
                            <div class="card chart-card">
                                <div class="card-header bg-light">
                                    <h5><i class="fas fa-chart-line me-2"></i>Đơn hàng theo tháng (6 tháng gần đây)</h5>
                                </div>
                                <div class="card-body">
                                    <div class="chart-container">
                                        <canvas id="monthlyOrdersChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Category Distribution Chart -->
                        <div class="col-md-6 mb-4">
                            <div class="card chart-card">
                                <div class="card-header bg-light">
                                    <h5><i class="fas fa-chart-bar me-2"></i>Phân bổ sản phẩm theo danh mục</h5>
                                </div>
                                <div class="card-body">
                                    <div class="chart-container">
                                        <canvas id="categoryChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        </div>

        <!-- Data for Charts -->
        <div id="chartData" style="display: none;"
             data-monthly-orders='<c:out value="${monthlyOrdersJson}" escapeXml="false"/>'
             data-category-data='<c:out value="${categoryDataJson}" escapeXml="false"/>'>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Get chart data
            const chartDataElement = document.getElementById('chartData');
            
            // Monthly Orders Chart
            let monthlyOrdersData = [];
            try {
                const monthlyDataAttr = chartDataElement.getAttribute('data-monthly-orders');
                if (monthlyDataAttr && monthlyDataAttr !== 'null') {
                    monthlyOrdersData = JSON.parse(monthlyDataAttr);
                }
            } catch (e) {
                console.log('No monthly orders data available');
            }

            const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

            const monthlyLabels = monthlyOrdersData.length > 0 ? monthlyOrdersData.map(data => monthNames[data.month - 1] + ' ' + data.year) : [];
            const orderCounts = monthlyOrdersData.length > 0 ? monthlyOrdersData.map(data => data.orderCount) : [];
            const totalAmounts = monthlyOrdersData.length > 0 ? monthlyOrdersData.map(data => data.totalAmount) : [];

            const monthlyOrdersCtx = document.getElementById('monthlyOrdersChart').getContext('2d');
            new Chart(monthlyOrdersCtx, {
                type: 'line',
                data: {
                    labels: monthlyLabels,
                    datasets: [{
                        label: 'Số đơn hàng',
                        data: orderCounts,
                        borderColor: 'rgb(75, 192, 192)',
                        backgroundColor: 'rgba(75, 192, 192, 0.2)',
                        tension: 0.1,
                        yAxisID: 'y'
                    }, {
                        label: 'Doanh thu (VNĐ)',
                        data: totalAmounts,
                        borderColor: 'rgb(255, 99, 132)',
                        backgroundColor: 'rgba(255, 99, 132, 0.2)',
                        tension: 0.1,
                        yAxisID: 'y1'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false,
                    },
                    scales: {
                        x: {
                            display: true,
                            title: {
                                display: true,
                                text: 'Tháng'
                            }
                        },
                        y: {
                            type: 'linear',
                            display: true,
                            position: 'left',
                            title: {
                                display: true,
                                text: 'Số đơn hàng'
                            }
                        },
                        y1: {
                            type: 'linear',
                            display: true,
                            position: 'right',
                            title: {
                                display: true,
                                text: 'Doanh thu (VNĐ)'
                            },
                            grid: {
                                drawOnChartArea: false,
                            },
                        }
                    }
                }
            });

            // Category Distribution Chart
            let categoryData = [];
            try {
                const categoryDataAttr = chartDataElement.getAttribute('data-category-data');
                if (categoryDataAttr && categoryDataAttr !== 'null') {
                    categoryData = JSON.parse(categoryDataAttr);
                }
            } catch (e) {
                console.log('No category data available');
            }

            const categoryLabels = categoryData.map(data => data.categoryName || '');
            const productCounts = categoryData.map(data => data.productCount || 0);

            const categoryCtx = document.getElementById('categoryChart').getContext('2d');
            new Chart(categoryCtx, {
                type: 'bar',
                data: {
                    labels: categoryLabels,
                    datasets: [{
                        label: 'Số sản phẩm',
                        data: productCounts,
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.8)',
                            'rgba(54, 162, 235, 0.8)',
                            'rgba(255, 205, 86, 0.8)',
                            'rgba(75, 192, 192, 0.8)',
                            'rgba(153, 102, 255, 0.8)',
                            'rgba(255, 159, 64, 0.8)'
                        ],
                        borderColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 205, 86, 1)',
                            'rgba(75, 192, 192, 1)',
                            'rgba(153, 102, 255, 1)',
                            'rgba(255, 159, 64, 1)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Số sản phẩm'
                            }
                        },
                        x: {
                            title: {
                                display: true,
                                text: 'Danh mục'
                            }
                        }
                    }
                }
            });
        </script>
    </body>
</html>
