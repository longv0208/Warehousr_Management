<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo thông báo mới</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .user-checkbox {
            margin-bottom: 8px;
        }
        .select-all-section {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <jsp:include page="/view/common/sidebar.jsp"/>
            
            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 px-md-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Tạo thông báo mới</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <a href="${pageContext.request.contextPath}/admin/notifications" 
                           class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-triangle"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle"></i> ${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Notification Form -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Thông tin thông báo</h5>
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/admin/notifications">
                            <input type="hidden" name="action" value="send">
                            
                            <!-- Title -->
                            <div class="mb-3">
                                <label for="title" class="form-label">
                                    <i class="fas fa-heading"></i> Tiêu đề thông báo *
                                </label>
                                <input type="text" class="form-control" id="title" name="title" 
                                       placeholder="Nhập tiêu đề thông báo" required>
                            </div>

                            <!-- Message -->
                            <div class="mb-3">
                                <label for="message" class="form-label">
                                    <i class="fas fa-comment"></i> Nội dung thông báo *
                                </label>
                                <textarea class="form-control" id="message" name="message" rows="5" 
                                         placeholder="Nhập nội dung thông báo" required></textarea>
                            </div>

                            <!-- Recipients Selection -->
                            <div class="mb-3">
                                <label class="form-label">
                                    <i class="fas fa-users"></i> Chọn người nhận *
                                </label>
                                
                                <!-- Quick Actions -->
                                <div class="select-all-section">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <button type="button" class="btn btn-outline-primary btn-sm me-2" 
                                                    onclick="selectAll()">
                                                <i class="fas fa-check-square"></i> Chọn tất cả
                                            </button>
                                            <button type="button" class="btn btn-outline-secondary btn-sm" 
                                                    onclick="deselectAll()">
                                                <i class="fas fa-square"></i> Bỏ chọn tất cả
                                            </button>
                                        </div>
                                        <div class="col-md-6 text-end">
                                            <button type="button" class="btn btn-warning btn-sm" 
                                                    onclick="sendToAllUsers()">
                                                <i class="fas fa-broadcast-tower"></i> Gửi cho tất cả người dùng
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <!-- Users List -->
                                <div class="row">
                                    <c:choose>
                                        <c:when test="${empty users}">
                                            <div class="col-12">
                                                <div class="text-center py-4">
                                                    <i class="fas fa-user-slash fa-2x text-muted mb-2"></i>
                                                    <p class="text-muted">Không có người dùng nào để gửi thông báo</p>
                                                </div>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="user" items="${users}">
                                                <div class="col-md-6 col-lg-4">
                                                    <div class="user-checkbox">
                                                        <div class="form-check">
                                                            <input class="form-check-input user-checkbox-input" 
                                                                   type="checkbox" 
                                                                   value="${user.userId}" 
                                                                   name="receiverIds" 
                                                                   id="user_${user.userId}">
                                                            <label class="form-check-label" for="user_${user.userId}">
                                                                <strong>${user.fullName}</strong><br>
                                                                <small class="text-muted">
                                                                    <i class="fas fa-user"></i> ${user.username} 
                                                                    <span class="badge bg-info">${user.roleId}</span>
                                                                </small>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Submit Buttons -->
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="${pageContext.request.contextPath}/admin/notifications" 
                                   class="btn btn-secondary me-md-2">
                                    <i class="fas fa-times"></i> Hủy
                                </a>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-paper-plane"></i> Gửi thông báo
                                </button>
                            </div>
                        </form>

                        <!-- Send to All Form (Hidden) -->
                        <form id="sendToAllForm" method="post" action="${pageContext.request.contextPath}/admin/notifications" style="display: none;">
                            <input type="hidden" name="action" value="sendToAll">
                            <input type="hidden" name="title" id="allTitle">
                            <input type="hidden" name="message" id="allMessage">
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function selectAll() {
            const checkboxes = document.querySelectorAll('.user-checkbox-input');
            checkboxes.forEach(checkbox => {
                checkbox.checked = true;
            });
        }

        function deselectAll() {
            const checkboxes = document.querySelectorAll('.user-checkbox-input');
            checkboxes.forEach(checkbox => {
                checkbox.checked = false;
            });
        }

        function sendToAllUsers() {
            const title = document.getElementById('title').value;
            const message = document.getElementById('message').value;
            
            if (!title.trim() || !message.trim()) {
                alert('Vui lòng nhập tiêu đề và nội dung thông báo trước khi gửi!');
                return;
            }
            
            if (confirm('Bạn có chắc chắn muốn gửi thông báo này đến tất cả người dùng?')) {
                document.getElementById('allTitle').value = title;
                document.getElementById('allMessage').value = message;
                document.getElementById('sendToAllForm').submit();
            }
        }

        // Validation before submit
        document.querySelector('form[action*="notifications"]').addEventListener('submit', function(e) {
            const checkedBoxes = document.querySelectorAll('.user-checkbox-input:checked');
            if (checkedBoxes.length === 0) {
                e.preventDefault();
                alert('Vui lòng chọn ít nhất một người nhận!');
                return false;
            }
        });
    </script>
</body>
</html> 