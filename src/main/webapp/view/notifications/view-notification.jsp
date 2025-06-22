<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết thông báo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .main-content {
            margin-left: 250px;
            padding: 20px;
            min-height: 100vh;
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <jsp:include page="/view/common/sidebar.jsp"/>
    
    <!-- Main Content -->
    <div class="main-content">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Chi tiết thông báo</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/notifications" 
                           class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <!-- Notification Details -->
                <c:if test="${not empty notification}">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title mb-0">
                                <i class="fas fa-bell"></i> ${notification.title}
                            </h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-8">
                                    <div class="mb-4">
                                        <h6>Nội dung:</h6>
                                        <div class="p-3 bg-light rounded">
                                            <div style="white-space: pre-line;">${notification.message}</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="card bg-light">
                                        <div class="card-body">
                                            <h6>Thông tin chi tiết</h6>
                                            <p><strong>Người gửi:</strong> ${notification.senderName}</p>
                                            <p><strong>Thời gian:</strong> 
                                               <fmt:formatDate value="${notification.createdAt}" 
                                                             pattern="dd/MM/yyyy HH:mm"/>
                                            </p>
                                            <p><strong>Trạng thái:</strong>
                                               <span class="badge ${notification.read ? 'bg-success' : 'bg-warning'}">
                                                   ${notification.read ? 'Đã đọc' : 'Chưa đọc'}
                                               </span>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card-footer">
                            <a href="${pageContext.request.contextPath}/notifications" 
                               class="btn btn-primary">
                                <i class="fas fa-list"></i> Về danh sách thông báo
                            </a>
                        </div>
                                         </div>
                 </c:if>
     </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 