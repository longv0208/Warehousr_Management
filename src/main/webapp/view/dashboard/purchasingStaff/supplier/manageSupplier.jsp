<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Supplier" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.TreeSet" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Quản Lý Kho Hàng - Nhà Cung Cấp</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="./styles/index.css" rel="stylesheet"/>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <jsp:include page="../common/sidebar.jsp" />
    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Danh sách Nhà Cung Cấp</h3>
        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addSupplierModal">+ Thêm Nhà Cung Cấp</button>
      </div>

      <div class="row mb-4">
        <div class="col-md-6">
          <input type="text" id="searchInput" class="form-control" placeholder="Tìm theo tên hoặc email..." onkeyup="filterSuppliers()"/>
        </div>
        <div class="col-md-3">
          <%
            List<Supplier> list = (List<Supplier>) request.getAttribute("supplierList");
            Set<String> citySet = new TreeSet<>();
            if (list != null) {
              for (Supplier s : list) {
                String address = s.getAddress();
                if (address != null && !address.trim().isEmpty()) {
                  String[] parts = address.split(",");
                  String city = parts[parts.length - 1].trim();
                  if (!city.isEmpty()) {
                    citySet.add(city);
                  }
                }
              }
            }
          %>
          <select id="cityFilter" class="form-select" onchange="filterSuppliers()">
            <option value="">-- Lọc theo thành phố --</option>
            <% for (String city : citySet) { %>
              <option value="<%= city %>"><%= city %></option>
            <% } %>
          </select>
        </div>
      </div>

      <div class="table-responsive">
        <table class="table table-bordered table-hover" id="supplierTable">
          <thead class="table-light">
            <tr>
              <th>#</th>
              <th>Tên nhà cung cấp</th>
              <th>Người liên hệ</th>
              <th>Điện thoại</th>
              <th>Email</th>
              <th>Địa chỉ</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <%
              if (list != null) {
                int index = 1;
                for (Supplier s : list) {
            %>
            <tr>
              <td><%= index++ %></td>
              <td><%= s.getSupplierName() %></td>
              <td><%= s.getContactPerson() %></td>
              <td><%= s.getPhoneNumber() %></td>
              <td><%= s.getEmail() %></td>
              <td><%= s.getAddress() %></td>
              <td>
                <button class="btn btn-sm btn-info"
                  onclick="openEditSupplierModal(
                    '<%= s.getSupplierId() %>',
                    '<%= s.getSupplierName() == null ? "" : s.getSupplierName().replace("'", "\\'") %>',
                    '<%= s.getContactPerson() == null ? "" : s.getContactPerson().replace("'", "\\'") %>',
                    '<%= s.getPhoneNumber() == null ? "" : s.getPhoneNumber().replace("'", "\\'") %>',
                    '<%= s.getEmail() == null ? "" : s.getEmail().replace("'", "\\'") %>',
                    '<%= s.getAddress() == null ? "" : s.getAddress().replace("'", "\\'") %>'
                  )">Sửa</button>
                <button class="btn btn-sm btn-danger"
                  onclick="openDeleteSupplierModal(
                    '<%= s.getSupplierId() %>',
                    '<%= s.getSupplierName() == null ? "" : s.getSupplierName().replace("'", "\\'") %>'
                  )">Xóa</button>
              </td>
            </tr>
            <%
                }
              }
            %>
          </tbody>
        </table>
      </div>
    </main>
  </div>
</div>

<!-- Modal Thêm -->
<div class="modal fade" id="addSupplierModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="AddSupplierServlet">
      <div class="modal-header bg-success text-white">
        <h5 class="modal-title">Thêm Nhà Cung Cấp</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <label class="form-label">Tên nhà cung cấp</label>
        <input name="name" class="form-control mb-2" required/>
        <label class="form-label">Người liên hệ</label>
        <input name="contactPerson" class="form-control mb-2" required/>
        <label class="form-label">Số điện thoại</label>
        <input name="phone" class="form-control mb-2" required/>
        <label class="form-label">Email</label>
        <input type="email" name="email" class="form-control mb-2"/>
        <label class="form-label">Địa chỉ</label>
        <textarea name="address" class="form-control" rows="2"></textarea>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
        <button type="submit" class="btn btn-success">Lưu</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal Sửa -->
<div class="modal fade" id="editSupplierModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="EditSupplierServlet">
      <div class="modal-header bg-info text-white">
        <h5 class="modal-title">Chỉnh sửa Nhà Cung Cấp</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" name="supplierId" id="editSupplierId"/>
        <label class="form-label">Tên nhà cung cấp</label>
        <input name="name" id="editName" class="form-control mb-2" required/>
        <label class="form-label">Người liên hệ</label>
        <input name="contactPerson" id="editContact" class="form-control mb-2" required/>
        <label class="form-label">Số điện thoại</label>
        <input name="phone" id="editPhone" class="form-control mb-2" required/>
        <label class="form-label">Email</label>
        <input type="email" name="email" id="editEmail" class="form-control mb-2"/>
        <label class="form-label">Địa chỉ</label>
        <textarea name="address" id="editAddress" class="form-control" rows="2"></textarea>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
        <button type="submit" class="btn btn-info">Cập nhật</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal Xóa -->
<div class="modal fade" id="deleteSupplierModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="DeleteSupplierServlet">
      <div class="modal-header bg-danger text-white">
        <h5 class="modal-title">Xác nhận xóa Nhà Cung Cấp</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" name="supplierId" id="deleteSupplierId"/>
        <p>Bạn có chắc muốn xóa nhà cung cấp <b id="deleteSupplierName"></b> không?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
        <button type="submit" class="btn btn-danger">Xóa</button>
      </div>
    </form>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function openEditSupplierModal(id, name, contact, phone, email, address) {
    document.getElementById('editSupplierId').value = id;
    document.getElementById('editName').value = name;
    document.getElementById('editContact').value = contact;
    document.getElementById('editPhone').value = phone;
    document.getElementById('editEmail').value = email;
    document.getElementById('editAddress').value = address;
    new bootstrap.Modal(document.getElementById('editSupplierModal')).show();
  }

  function openDeleteSupplierModal(id, name) {
    document.getElementById('deleteSupplierId').value = id;
    document.getElementById('deleteSupplierName').textContent = name;
    new bootstrap.Modal(document.getElementById('deleteSupplierModal')).show();
  }

  function filterSuppliers() {
    const searchValue = document.getElementById('searchInput').value.toLowerCase();
    const cityFilter = document.getElementById('cityFilter').value.toLowerCase();
    const table = document.getElementById('supplierTable');
    const trs = table.tBodies[0].getElementsByTagName('tr');

    for (let tr of trs) {
      const name = tr.cells[1].textContent.toLowerCase();
      const email = tr.cells[4].textContent.toLowerCase();
      const address = tr.cells[5].textContent.toLowerCase();

      const matchesSearch = name.includes(searchValue) || email.includes(searchValue);
      const matchesCity = cityFilter === "" || address.endsWith(cityFilter);

      tr.style.display = (matchesSearch && matchesCity) ? "" : "none";
    }
  }
</script>
</body>
</html>
