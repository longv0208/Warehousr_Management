<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Danh Sách Phiếu Xuất Kho</title>
        <jsp:include page="../../../common/head.jsp"/>
    </head>
    <body>
        <div class="wrapper">
            <jsp:include page="../../../common/sidebar.jsp"/>

            <div class="main">
                <main class="content">
                    <div class="container-fluid p-0">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h3>Danh Sách Phiếu Xuất Kho</h3>
                        </div>

                        <div class="card">
                            <div class="card-body">
                                <table class="table table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th>Mã Phiếu Xuất</th>
                                            <th>Mã Đơn Hàng</th>
                                            <th>Khách Hàng</th>
                                            <th>Kho</th>
                                            <th>Người Tạo</th>
                                            <th>Ngày Tạo</th>
                                            <th>Ghi Chú</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:if test="${empty outwards}">
                                            <tr>
                                                <td colspan="7" class="text-center">Không có phiếu xuất kho nào.</td>
                                            </tr>
                                        </c:if>
                                        <c:forEach var="outward" items="${outwards}">
                                            <tr>
                                                <td><span class="badge bg-primary">${outward.outwardCode}</span></td>
                                                <td>${outward.salesOrderCode}</td>
                                                <td>${outward.customerName}</td>
                                                <td>${outward.warehouseName}</td>
                                                <td>${outward.userFullName}</td>
                                                <td><fmt:formatDate value="${outward.outwardDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                <td>${outward.notes}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <div class="card-footer d-flex justify-content-between align-items-center">
                                <div>
                                    Hiển thị ${fn:length(outwards)} trên tổng số ${totalOutwards} kết quả
                                </div>
                                <!-- Pagination -->
                                <nav aria-label="Page navigation">
                                    <ul class="pagination mb-0">
                                        <c:if test="${currentPage > 1}">
                                            <li class="page-item">
                                                <a class="page-link" href="?action=list-outwards&page=${currentPage - 1}">Trước</a>
                                            </li>
                                        </c:if>
                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                                <a class="page-link" href="?action=list-outwards&page=${i}">${i}</a>
                                            </li>
                                        </c:forEach>
                                        <c:if test="${currentPage < totalPages}">
                                            <li class="page-item">
                                                <a class="page-link" href="?action=list-outwards&page=${currentPage + 1}">Sau</a>
                                            </li>
                                        </c:if>
                                    </ul>
                                </nav>
                            </div>
                        </div>
                    </div>
                </main>
                <jsp:include page="../../../common/foot.jsp"/>
            </div>
        </div>
    </body>
</html> 