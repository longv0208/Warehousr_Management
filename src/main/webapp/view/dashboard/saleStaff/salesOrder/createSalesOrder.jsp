<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- 
  =============================================================================
  ==                           BACKEND NOTICE                                ==
  =============================================================================
  Để chức năng hiển thị tồn kho chính xác hoạt động, bạn cần thực hiện 
  một số thay đổi ở phía backend:

  1. Trong `InventoryDAO.java`, thêm phương thức sau để lấy tồn kho
     theo sản phẩm và nhà kho:

    public Inventory getInventoryByProductAndWarehouse(int productId, int warehouseId) {
        String sql = "SELECT * FROM Inventory WHERE product_id = ? AND warehouse_id = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, productId);
            st.setInt(2, warehouseId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return new Inventory(
                        rs.getInt("inventory_id"),
                        rs.getInt("product_id"),
                        rs.getInt("warehouse_id"),
                        rs.getInt("quantity"),
                        rs.getTimestamp("last_updated")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace(); // Log error
        }
        return null; // Return null if not found
    }

  2. Trong `SalesOrderController.java`, cập nhật phương thức `doGet` 
     để xử lý action "get-inventory":

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action") == null ? "list" : request.getParameter("action");
        switch(action) {
            // ... các case khác
            case "get-inventory":
                getInventory(request, response);
                break;
            // ...
        }
    }

    private void getInventory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            int warehouseId = Integer.parseInt(request.getParameter("warehouseId"));
            InventoryDAO inventoryDAO = new InventoryDAO();
            Inventory inventory = inventoryDAO.getInventoryByProductAndWarehouse(productId, warehouseId);
            int quantity = (inventory != null) ? inventory.getQuantity() : 0;
            response.getWriter().write("{\"quantity\": " + quantity + "}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid request\"}");
        }
    }

  3. Trong `doPost` của `SalesOrderController.java` (khi xử lý action "create"), 
     bạn cần đọc các tham số dưới dạng mảng vì giờ đây chúng có tên `productId[]`, `quantity[]`, v.v...
     Ví dụ:
     String[] productIds = request.getParameterValues("productId[]");
     String[] quantities = request.getParameterValues("quantity[]");
  
  =============================================================================
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Tạo Đơn Bán Hàng - Sale Staff</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/index.css" rel="stylesheet"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <jsp:include page="../../../common/sidebar.jsp"></jsp:include>

    <!-- Main Content -->
    <main class="col-md-10 ms-sm-auto col-lg-10 px-md-4 py-4">
      
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Tạo Đơn Bán Hàng</h3>
        <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=list" class="btn btn-secondary">← Quay lại</a>
      </div>
      

      
      <c:if test="${empty products}">
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
          <strong>Cảnh báo:</strong> Không có sản phẩm nào có sẵn để tạo đơn hàng. Vui lòng thêm sản phẩm trước khi tạo đơn hàng.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/sale-staff/sales-order" method="POST" class="needs-validation" novalidate>
        <input type="hidden" name="action" value="create">
        
        <div class="row">
          <div class="col-md-6">
            <div class="card mb-4">
              <div class="card-header">
                <h5 class="card-title mb-0">Thông tin đơn hàng</h5>
              </div>
              <div class="card-body">
                <div class="row mb-3">
                  <div class="col-md-6">
                    <label for="customerName" class="form-label">Tên khách hàng</label>
                    <input type="text" class="form-control" id="customerName" name="customerName" required>
                  </div>
                  <div class="col-md-6">
                    <label for="orderDate" class="form-label">Ngày đặt hàng</label>
                    <input type="date" class="form-control" id="orderDate" name="orderDate" value="<%= java.time.LocalDate.now() %>" required>
                  </div>
                </div>
                
                <div class="row mb-3">
                  <div class="col-md-6">
                    <label for="warehouseId" class="form-label">Kho xuất hàng</label>
                    <select class="form-select" id="warehouseId" name="warehouseId" required>
                      <option value="" selected disabled>-- Chọn kho --</option>
                      <c:forEach var="warehouse" items="${warehouses}">
                        <option value="${warehouse.warehouseId}">${warehouse.warehouseName}</option>
                      </c:forEach>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label for="notes" class="form-label">Ghi chú</label>
                    <textarea class="form-control" id="notes" name="notes" rows="1"></textarea>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="col-md-6">
            <div class="card mb-4">
              <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0">Chi tiết sản phẩm</h5>
                <button type="button" class="btn btn-sm btn-success" onclick="addProductRow()">+ Thêm sản phẩm</button>
              </div>
              <div class="card-body">
                <!-- Product Table Header -->
                <div class="row fw-bold border-bottom mb-2 pb-2 d-none d-md-flex">
                  <div class="col-md-4">Sản phẩm</div>
                  <div class="col-md-2">Số lượng</div>
                  <div class="col-md-2">Đơn giá</div>
                  <div class="col-md-2">Thành tiền</div>
                  <div class="col-md-2">Thao tác</div>
                </div>

                <div id="productContainer">
                  <!-- Product rows will be added here -->
                </div>
                <div class="row mt-3">
                  <div class="col-md-6 offset-md-6">
                    <div class="d-flex justify-content-between">
                      <strong>Tổng tiền:</strong>
                      <strong id="totalAmount">0 đ</strong>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="row">
          <div class="col-12">
            <div class="d-flex justify-content-end">
              <a href="${pageContext.request.contextPath}/sale-staff/sales-order?action=list" class="btn btn-secondary me-2">Hủy</a>
              <button type="submit" class="btn btn-primary">Tạo đơn hàng</button>
            </div>
          </div>
        </div>
      </form>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

<!-- Hidden template for product options -->
<template id="productOptionsTemplate">
    <option value="">-- Chọn sản phẩm --</option>
    <c:forEach var="p" items="${products}">
        <option value="${p['productId']}"
                data-price="${p['salePrice']}"
                data-unit="${p['unit']}">
            ${p['productCode']} - ${p['productName']} (${p['unit']})
        </option>
    </c:forEach>
</template>

<script>
  let productRowIndex = 0;
  const hasProducts = <c:out value="${not empty products}" default="false"/>;
  const productCount = <c:out value="${fn:length(products)}" default="0"/>;
  
  document.addEventListener('DOMContentLoaded', function() {
    if (hasProducts) {
      addProductRow();
    } else {
      iziToast.error({
        title: 'Lỗi',
        message: 'Không có sản phẩm nào có sẵn để tạo đơn hàng.'
      });
    }
  });

  function addProductRow() {
    const tpl = document.getElementById('productOptionsTemplate');
    if (!tpl) return;

    const container = document.getElementById('productContainer');
    const rowIndex = productRowIndex++;
    const rowWrapper = document.createElement('div');
    rowWrapper.className = 'product-row row mb-3 align-items-center';
    rowWrapper.id = 'productRow' + rowIndex;

    rowWrapper.innerHTML = `
        <div class="col-md-4">
            <label class="form-label d-md-none">Sản phẩm</label>
            <select class="form-select" name="productId[]" onchange="updateProductInfo(this, ${rowIndex})" required></select>
        </div>
        <div class="col-md-2">
            <label class="form-label d-md-none">Số lượng</label>
            <input type="number" class="form-control" name="quantity[]" min="1" oninput="calculateRowTotal(${rowIndex})" required>
            <small class="text-muted">Tồn: <span id="stockQuantity${rowIndex}">0</span></small>
        </div>
        <div class="col-md-2">
            <label class="form-label d-md-none">Đơn giá</label>
            <input type="number" class="form-control" name="unitPrice[]" step="any" min="0" oninput="calculateRowTotal(${rowIndex})" required>
        </div>
        <div class="col-md-2">
            <label class="form-label d-md-none">Thành tiền</label>
            <div class="form-control-plaintext fw-bold" id="rowTotal${rowIndex}">0 đ</div>
        </div>
        <div class="col-md-2">
            <label class="form-label d-md-none">&nbsp;</label>
            <button type="button" class="btn btn-danger btn-sm d-block w-100" onclick="removeProductRow(${rowIndex})">Xóa</button>
        </div>
    `;

    container.appendChild(rowWrapper);

    const selectElement = rowWrapper.querySelector('select[name="productId[]"]');
    const optionsFragment = document.importNode(tpl.content, true);
    selectElement.appendChild(optionsFragment);
    
    // Trigger warehouse check for the new row if a warehouse is already selected
    const warehouseId = document.getElementById('warehouseId').value;
    if (warehouseId) {
        updateProductInfo(selectElement, rowIndex);
    }
  }

  function removeProductRow(index) {
    const row = document.getElementById('productRow' + index);
    if (row) {
      row.remove();
      calculateTotal();
    }
  }
  
  function updateAllStockQuantities() {
    const productRows = document.querySelectorAll('.product-row');
    productRows.forEach(row => {
        const select = row.querySelector('select[name^="productId"]');
        if (select.value) {
            const index = parseInt(row.id.replace('productRow', ''));
            fetchInventory(select.value, index);
        }
    });
  }

  function updateProductInfo(selectElement, index) {
    const selectedOption = selectElement.options[selectElement.selectedIndex];
    const row = selectElement.closest('.product-row');
    const priceInput = row.querySelector('input[name^="unitPrice"]');
    const quantityInput = row.querySelector('input[name^="quantity"]');
    const rowTotalDiv = row.querySelector('#rowTotal' + index);

    if (!selectedOption || !selectedOption.value) {
        priceInput.value = '';
        quantityInput.value = '';
        rowTotalDiv.textContent = '0 đ';
        document.getElementById('stockQuantity' + index).textContent = '0';
        calculateTotal();
        return;
    }
    
    const price = selectedOption.getAttribute('data-price');
    priceInput.value = price || '0';
    
    fetchInventory(selectElement.value, index);
    calculateRowTotal(index);
  }
  
  function fetchInventory(productId, index) {
      const warehouseId = document.getElementById('warehouseId').value;
      const stockSpan = document.getElementById('stockQuantity' + index);
      const quantityInput = document.getElementById('productRow' + index).querySelector('input[name^="quantity"]');

      if (!warehouseId) {
          stockSpan.textContent = 'Chọn kho';
          stockSpan.className = 'text-danger';
          quantityInput.max = null;
          return;
      }
      if (!productId) {
          stockSpan.textContent = '0';
          quantityInput.max = null;
          return;
      }

      stockSpan.textContent = '...';
      stockSpan.className = 'text-muted';

      const url = `${pageContext.request.contextPath}/sale-staff/sales-order?action=get-inventory&productId=${productId}&warehouseId=${warehouseId}`;

      fetch(url)
          .then(response => {
              if (!response.ok) throw new Error('Network response was not ok');
              return response.json();
          })
          .then(data => {
              if (data.error) throw new Error(data.error);
              
              const stock = data.quantity || 0;
              stockSpan.textContent = stock;
              quantityInput.max = stock; // Set max attribute for validation

              quantityInput.addEventListener('input', () => {
                  if (parseInt(quantityInput.value, 10) > stock) {
                      stockSpan.classList.add('text-danger', 'fw-bold');
                  } else {
                      stockSpan.classList.remove('text-danger', 'fw-bold');
                  }
              });
          })
          .catch(error => {
              console.error('Error fetching inventory:', error);
              stockSpan.textContent = 'Lỗi';
              stockSpan.className = 'text-danger';
          });
  }

  function calculateRowTotal(index) {
    const row = document.getElementById('productRow' + index);
    const quantity = parseFloat(row.querySelector('input[name^="quantity"]').value) || 0;
    const unitPrice = parseFloat(row.querySelector('input[name^="unitPrice"]').value) || 0;
    const total = quantity * unitPrice;
    
    const rowTotalEl = document.getElementById('rowTotal' + index);
    rowTotalEl.textContent = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(total);
    
    calculateTotal();
  }

  function calculateTotal() {
    let totalAmount = 0;
    const rows = document.querySelectorAll('.product-row');
    rows.forEach(row => {
      const quantity = parseFloat(row.querySelector('input[name^="quantity"]').value) || 0;
      const unitPrice = parseFloat(row.querySelector('input[name^="unitPrice"]').value) || 0;
      totalAmount += quantity * unitPrice;
    });

    const totalAmountEl = document.getElementById('totalAmount');
    totalAmountEl.textContent = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(totalAmount);
  }

  // Bootstrap form validation
  (function () {
    'use strict'
    var forms = document.querySelectorAll('.needs-validation')
    Array.prototype.slice.call(forms)
      .forEach(function (form) {
        form.addEventListener('submit', function (event) {
          if (!form.checkValidity()) {
            event.preventDefault()
            event.stopPropagation()
          }
          form.classList.add('was-validated')
        }, false)
      })
  })()
</script>

  </body>
</html> 