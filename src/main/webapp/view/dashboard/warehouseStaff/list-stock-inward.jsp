<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách phiếu nhập kho</title>
    <jsp:include page="/view/common/head.jsp"/>
    <style>
        .main-content {
            margin-left: 250px; /* Same as sidebar width */
            padding: 20px;
        }
    </style>
</head>
<body>
    <jsp:include page="/view/common/sidebar.jsp"/>
    <div class="main-content">
        <div class="card">
            <div class="card-header">
                <h4><i class="fas fa-list-alt"></i> Danh sách phiếu nhập kho</h4>
            </div>
            <div class="card-body">
                <c:if test="${not empty stockInwards}">
                    <table class="table table-hover table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>Mã phiếu nhập</th>
                                <th>Nhà cung cấp</th>
                                <th>Kho</th>
                                <th>Người tạo</th>
                                <th>Ngày nhập</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="inward" items="${stockInwards}">
                                <tr>
                                    <td><strong>${inward.inwardCode}</strong></td>
                                    <td>${inward.supplierName}</td>
                                    <td>${inward.warehouseName}</td>
                                    <td>${inward.userFullName}</td>
                                    <td>
                                        <fmt:formatDate value="${inward.inwardDate}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/warehouse?action=view-stock-inward&id=${inward.stockInwardId}" class="btn btn-sm btn-info">
                                            <i class="fas fa-eye"></i> Xem
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:if>
                <c:if test="${empty stockInwards}">
                    <div class="alert alert-info text-center">
                        Chưa có phiếu nhập kho nào được tạo.
                    </div>
                </c:if>
            </div>
        </div>
    </div>
    <jsp:include page="/view/common/foot.jsp"/>
</body>
</html> 