<%@page import="model.User"%>
<%@page import="model.Role"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Quản Lý Kho Hàng - Quản lý Tài khoản</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
    </head>
    <body>
        <jsp:include page="/view/common/sidebar.jsp" />

        <div class="container-fluid">
            <div class="row">
                <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">

                    <%-- Xóa alert cũ, thay bằng toast --%>
                    <c:remove var="error"/>
                    <c:remove var="success"/>
                    <c:if test="${not empty sessionScope.toastMessage and fn:trim(sessionScope.toastMessage) != ''}">
                        <div aria-live="polite" aria-atomic="true" class="position-fixed top-0 end-0 p-3" style="z-index: 1080; min-width: 300px;">
                            <div id="liveToast" class="toast align-items-center text-bg-${sessionScope.toastType == 'success' ? 'success' : (sessionScope.toastType == 'error' ? 'danger' : (sessionScope.toastType == 'warning' ? 'warning' : 'info'))} border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
                                <div class="d-flex">
                                    <div class="toast-body">
                                        ${sessionScope.toastMessage}
                                    </div>
                                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                                </div>
                            </div>
                        </div>
                        <script>
                        document.addEventListener('DOMContentLoaded', function () {
                            var toastEl = document.getElementById('liveToast');
                            if (toastEl) {
                                var toast = new bootstrap.Toast(toastEl, { delay: 4000 });
                                toast.show();
                                toastEl.addEventListener('hidden.bs.toast', function () {
                                    fetch('${pageContext.request.contextPath}/remove-toast', {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded',
                                        },
                                    });
                                });
                            }
                        });
                        </script>
                    </c:if>

                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3>Quản lý Tài khoản</h3>
                        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addUserModal">+ Thêm người dùng</button>
                    </div>

                    <form method="get" action="${pageContext.request.contextPath}/UserServlet" class="mb-3 d-flex align-items-center gap-2">
                        <input type="text" name="keyword" placeholder="Tìm kiếm username, email, họ tên..."
                               value="${param.keyword != null ? param.keyword : ''}"
                               class="form-control" style="max-width: 300px;" />

                        <select name="sort" class="form-select" style="max-width: 180px;">
                            <option value="">-- Sắp xếp --</option>
                            <option value="username_asc" ${param.sort == 'username_asc' ? 'selected' : ''}>Username A-Z</option>
                            <option value="username_desc" ${param.sort == 'username_desc' ? 'selected' : ''}>Username Z-A</option>
                            <option value="created_asc" ${param.sort == 'created_asc' ? 'selected' : ''}>Ngày tạo tăng dần</option>
                            <option value="created_desc" ${param.sort == 'created_desc' ? 'selected' : ''}>Ngày tạo giảm dần</option>
                        </select>

                        <button type="submit" class="btn btn-primary">Lọc</button>
                    </form>

                    <div class="table-responsive">
                        <table id="userTable" class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Tên tài khoản</th>
                                    <th>Họ và tên</th>
                                    <th>Email</th>
                                    <th>Vai trò</th>
                                    <th>Trạng thái</th>
                                    <th>Lần cuối đăng nhập</th>
                                    <th>Lần cuối đăng xuất</th>
                                    <th>Ngày tạo</th>
                                    <th>Ngày cập nhật</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    List<User> userList = (List<User>) request.getAttribute("userList");
                                    List<Role> roleList = (List<Role>) request.getAttribute("roleList");
                                    if (userList == null) {
                                        userList = new java.util.ArrayList<>();
                                    }
                                    if (roleList == null) {
                                        roleList = new java.util.ArrayList<>();
                                    }

                                    for (User u : userList) {
                                        String roleName = "Không xác định";
                                        for (Role r : roleList) {
                                            if (r.getRoleId().equals(u.getRoleId())) {
                                                roleName = r.getRoleName();
                                                break;
                                            }
                                        }
                                %>
                                <tr class="<%= u.isActive() ? "" : "inactive"%>">
                                    <td><%= u.getUserId()%></td>
                                    <td><%= u.getUsername()%></td>
                                    <td><%= u.getFullName()%></td>
                                    <td><%= u.getEmail()%></td>
                                    <td><%= roleName%></td>
                                    <td><%= u.isActive() ? "Hoạt động" : "Không hoạt động"%></td>
                                    <td><%= u.getLastLogin() != null ? u.getLastLogin() : "Chưa đăng nhập"%></td>
                                    <td><%= u.getLastLogout() != null ? u.getLastLogout() : "Chưa đăng xuất"%></td>
                                    <td><%= u.getCreatedAt()%></td>
                                    <td><%= u.getUpdatedAt()%></td>
                                    <td>
                                        <button class="btn btn-sm btn-info" onclick="openEditModal('<%= u.getUserId()%>', '<%= u.getFullName()%>', '<%= u.getEmail()%>', '<%= u.getRoleId()%>', '<%= u.isActive()%>')">Sửa</button>
                                        <button class="btn btn-sm btn-danger" onclick="openInactiveModal('<%= u.getUserId()%>')">Vô Hiệu Hóa</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Phân trang -->
                    <nav aria-label="Page navigation example">
                        <ul class="pagination justify-content-center">
                            <%
                                Integer currentPage = (Integer) request.getAttribute("currentPage");
                                Integer totalPages = (Integer) request.getAttribute("totalPages");
                                if (currentPage == null) {
                                    currentPage = 1;
                                }
                                if (totalPages == null) {
                                    totalPages = 1;
                                }

                                String baseUrl = request.getContextPath() + "/UserServlet?page=";
                            %>
                            <li class="page-item <%= currentPage == 1 ? "disabled" : ""%>">
                                <a class="page-link" href="<%= currentPage > 1 ? baseUrl + (currentPage - 1) : "#"%>">Prev</a>
                            </li>
                            <%
                                int startPage = Math.max(1, currentPage - 2);
                                int endPage = Math.min(totalPages, currentPage + 2);
                                for (int i = startPage; i <= endPage; i++) {
                            %>
                            <li class="page-item <%= i == currentPage ? "active" : ""%>">
                                <a class="page-link" href="<%= baseUrl + i%>"><%= i%></a>
                            </li>
                            <% }%>
                            <li class="page-item <%= currentPage == totalPages ? "disabled" : ""%>">
                                <a class="page-link" href="<%= currentPage < totalPages ? baseUrl + (currentPage + 1) : "#"%>">Next</a>
                            </li>
                        </ul>
                    </nav>

                </main>
            </div>
        </div>

        <!-- Modal Thêm người dùng -->
        <div class="modal fade" id="addUserModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog">
                <form class="modal-content" method="post" action="${pageContext.request.contextPath}/UserServlet/AddUserServlet">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title">Thêm người dùng</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <label class="form-label">Username</label>
                        <input name="username" class="form-control mb-2" value="${formUsername}" required/>

                        <label class="form-label">Mật khẩu</label>
                        <input type="password" name="password" class="form-control mb-2" required/>

                        <label class="form-label">Họ tên</label>
                        <input name="fullName" class="form-control mb-2" value="${formFullName}" required/>

                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control mb-2" value="${formEmail}" required/>

                        <label class="form-label">Vai trò</label>
                        <select name="roleId" class="form-select mb-2" required>
                            <% for (Role r : roleList) { %>
                            <option value="<%= r.getRoleId() %>" <%= request.getAttribute("formRoleId") != null && request.getAttribute("formRoleId").equals(r.getRoleId()) ? "selected" : "" %>><%= r.getRoleName() %></option>
                            <% } %>
                        </select>

                        <label class="form-label">Trạng thái</label>
                        <select name="isActive" class="form-select" required>
                            <option value="true" ${formIsActive == 'true' ? 'selected' : ''}>Hoạt động</option>
                            <option value="false" ${formIsActive == 'false' ? 'selected' : ''}>Không hoạt động</option>
                        </select>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-success">Lưu</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Modal Sửa người dùng -->
        <div class="modal fade" id="editUserModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog">
                <form class="modal-content" method="post" action="${pageContext.request.contextPath}/UserServlet/EditUserServlet">
                    <input type="hidden" name="userId" id="editUserId"/>
                    <div class="modal-header bg-info text-white">
                        <h5 class="modal-title">Sửa người dùng</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <label class="form-label">Họ tên</label>
                        <input name="fullName" id="editFullName" class="form-control mb-2" required/>

                        <label class="form-label">Email</label>
                        <input type="email" name="email" id="editEmail" class="form-control mb-2" required/>

                        <label class="form-label">Vai trò</label>
                        <select id="editRole" name="roleId" class="form-select mb-2" required>
                            <% for (Role r : roleList) {%>
                            <option value="<%= r.getRoleId()%>"><%= r.getRoleName()%></option>
                            <% }%>
                        </select>

                        <label class="form-label">Trạng thái</label>
                        <select id="editIsActive" name="isActive" class="form-select mb-2" required>
                            <option value="true">Hoạt động</option>
                            <option value="false">Không hoạt động</option>
                        </select>

                        <button type="button" class="btn btn-warning" id="resetPasswordBtn">Đặt lại mật khẩu</button>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-info">Lưu thay đổi</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Modal Vô hiệu hóa -->
        <div class="modal fade" id="inactiveUserModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog">
                <form class="modal-content" method="post" action="${pageContext.request.contextPath}/UserServlet/InactiveUserServlet">
                    <input type="hidden" name="userId" id="inactiveUserId"/>
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title">Xác nhận vô hiệu hóa</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p>Bạn có chắc chắn muốn vô hiệu hóa tài khoản này không?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-danger">Vô hiệu hóa</button>
                    </div>
                </form>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        
        <script>
            function openEditModal(userId, fullName, email, roleId, isActive) {
                document.getElementById('editUserId').value = userId;
                document.getElementById('editFullName').value = fullName;
                document.getElementById('editEmail').value = email;
                document.getElementById('editRole').value = roleId;
                document.getElementById('editIsActive').value = isActive;
                
                var editModal = new bootstrap.Modal(document.getElementById('editUserModal'));
                editModal.show();
            }
            
            function openInactiveModal(userId) {
                document.getElementById('inactiveUserId').value = userId;
                var inactiveModal = new bootstrap.Modal(document.getElementById('inactiveUserModal'));
                inactiveModal.show();
            }
            
            function resetPassword() {
                var form = document.querySelector('#editUserModal form');
                var resetInput = document.createElement('input');
                resetInput.type = 'hidden';
                resetInput.name = 'resetPassword';
                resetInput.value = 'true';
                form.appendChild(resetInput);
                form.submit(); // Submit the form after adding the hidden input
            }

            document.addEventListener('DOMContentLoaded', function() {
                var resetBtn = document.getElementById('resetPasswordBtn');
                if (resetBtn) {
                    resetBtn.addEventListener('click', resetPassword);
                }
            });
        </script>
<% if (request.getAttribute("showAddForm") != null) { %>
<script>
    window.addEventListener('load', function () {
        var addModal = new bootstrap.Modal(document.getElementById('addUserModal'));
        addModal.show();
    });
</script>
<% } %>
    </body>
</html>
