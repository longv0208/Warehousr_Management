<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Chi Tiết Kho Hàng</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
        <%@include file="../../../common/head.jsp" %>
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

                <!-- Main Content -->
                <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3>Chi Tiết Kho Hàng: ${warehouse.warehouseName}</h3>
                        <a href="${pageContext.request.contextPath}/admin/manage-warehouse?action=list" class="btn btn-secondary">Quay Lại Danh Sách</a>
                    </div>

                    <div class="card">
                        <div class="card-body">
                            <p><strong>Địa chỉ:</strong> ${warehouse.address}</p>
                            <hr/>
                            <h5>Sản phẩm trong kho</h5>
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered" id="productTable">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Mã Sản Phẩm</th>
                                            <th>Tên Sản Phẩm</th>
                                            <th>Số Lượng</th>
                                            <th>Đơn Vị</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${productsInWarehouse}">
                                            <tr>
                                                <td>${item.productCode}</td>
                                                <td>${item.productName}</td>
                                                <td>${item.quantityOnHand}</td>
                                                <td>${item.unit}</td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty productsInWarehouse}">
                                            <tr>
                                                <td colspan="4" class="text-center">Không có sản phẩm nào trong kho này.</td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
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
                $('#productTable').DataTable({
                    "language": {
                        "url": "//cdn.datatables.net/plug-ins/1.10.21/i18n/Vietnamese.json"
                    }
                });
            });
        </script>
    </body>
</html> 