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
  <meta name="context-path" content="${pageContext.request.contextPath}">
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
                     <div class="d-flex justify-content-between align-items-center border-top pt-3">
                      <h5 class="mb-0 text-primary">Tổng tiền:</h5>
                      <h5 class="mb-0 text-success fw-bold" id="totalAmount">0 đ</h5>
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

<!-- Pass data to JavaScript -->
<script type="text/javascript">
  // Pass JSP data to JavaScript without using template literals
  const hasProducts = <c:out value="${not empty products}" default="false"/>;
  const productCount = <c:out value="${fn:length(products)}" default="0"/>;
</script>

<!-- Include external JavaScript -->
<script src="${pageContext.request.contextPath}/js/sales-order-create.js"></script>

  </body>
</html> 