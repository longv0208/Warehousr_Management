# Báo Cáo Sản Phẩm Sắp Hết Hàng

## Tổng quan
Tính năng báo cáo sản phẩm sắp hết hàng giúp quản lý kho hàng theo dõi và cảnh báo khi sản phẩm có số lượng tồn kho thấp hơn hoặc bằng ngưỡng cảnh báo đã thiết lập.

## Các file đã tạo/cập nhật

### 1. Model Layer
- **`src/main/java/model/LowStockProduct.java`**: Model chứa thông tin sản phẩm sắp hết hàng
  - Chứa tất cả thông tin sản phẩm, số lượng tồn kho và nhà cung cấp
  - Có method `getStatusDisplay()` và `getStatusClass()` để hiển thị trạng thái

### 2. Data Access Layer  
- **`src/main/java/dao/LowStockProductDAO.java`**: DAO xử lý truy vấn database
  - `getLowStockProducts(String sortBy)`: Lấy danh sách sản phẩm sắp hết hàng với sắp xếp
  - `getTotalLowStockProducts()`: Đếm tổng số sản phẩm sắp hết hàng
  - `getOutOfStockProducts()`: Lấy danh sách sản phẩm hết hàng hoàn toàn

### 3. Controller Layer
- **`src/main/java/controller/LowStockReportServlet.java`**: Servlet xử lý request
  - URL mapping: `/low-stock-report`
  - Hỗ trợ 2 loại báo cáo: sắp hết hàng và hết hàng hoàn toàn
  - Kiểm tra quyền truy cập (chỉ admin và warehouse_staff)

### 4. View Layer
- **`src/main/webapp/view/low-stock/report.jsp`**: Giao diện báo cáo
  - Hiển thị danh sách sản phẩm với thông tin chi tiết
  - Có thể chuyển đổi giữa 2 loại báo cáo
  - Hỗ trợ sắp xếp theo nhiều tiêu chí
  - Giao diện đồng bộ với các trang khác trong hệ thống

### 5. Navigation
- **`src/main/webapp/view/common/sidebar.jsp`**: Thêm link menu
  - Link "Sắp hết hàng" trong sidebar cho admin và warehouse_staff

## Truy vấn SQL chính

```sql
SELECT p.product_id, p.product_code, p.product_name, p.description, 
       p.unit, p.purchase_price, p.sale_price, p.low_stock_threshold, 
       i.quantity_on_hand, s.supplier_name 
FROM products p 
INNER JOIN inventory i ON p.product_id = i.product_id 
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id 
WHERE p.is_active = true AND i.quantity_on_hand <= p.low_stock_threshold 
ORDER BY i.quantity_on_hand ASC
```

## Các tính năng chính

### 1. Báo cáo sắp hết hàng
- Hiển thị sản phẩm có `quantity_on_hand <= low_stock_threshold`
- Sắp xếp theo số lượng tăng dần, tên sản phẩm, hoặc ngưỡng cảnh báo
- Hiển thị thông tin: mã SP, tên SP, số lượng hiện tại, ngưỡng cảnh báo, nhà cung cấp

### 2. Báo cáo hết hàng
- Hiển thị sản phẩm có `quantity_on_hand = 0`
- Sắp xếp theo tên sản phẩm

### 3. Trạng thái màu sắc
- **Đỏ (bg-danger)**: Hết hàng hoàn toàn
- **Cam (bg-warning)**: Sắp hết hàng
- **Xanh (bg-success)**: Đủ hàng

### 4. Hành động
- **Admin**: Có thể chỉnh sửa sản phẩm và tạo yêu cầu mua hàng
- **Purchasing Staff**: Có thể tạo yêu cầu mua hàng
- **Warehouse Staff**: Chỉ xem báo cáo

## Quyền truy cập
- **Admin**: Toàn quyền truy cập và thao tác
- **Warehouse Staff**: Chỉ xem báo cáo
- **Sales Staff**: Không có quyền truy cập
- **Purchasing Staff**: Không có quyền truy cập trực tiếp (nhưng có thể tạo đơn mua hàng từ link trong báo cáo)

## Cách sử dụng

### 1. Truy cập báo cáo
- Đăng nhập với tài khoản admin hoặc warehouse_staff
- Nhấp vào menu "Sắp hết hàng" trong sidebar

### 2. Xem báo cáo sắp hết hàng
- URL: `/low-stock-report`
- Sử dụng dropdown để sắp xếp theo tiêu chí mong muốn

### 3. Xem báo cáo hết hàng
- Nhấp nút "Hết Hàng" hoặc truy cập URL: `/low-stock-report?action=out-of-stock`

### 4. Thực hiện hành động
- **Chỉnh sửa sản phẩm**: Nhấp biểu tượng bút chì (admin only)
- **Tạo yêu cầu mua hàng**: Nhấp biểu tượng giỏ hàng (admin/purchasing_staff)

## Demo dữ liệu
Sử dụng file `demo-low-stock-report.sql` để:
1. Xem các truy vấn SQL mẫu
2. Cập nhật dữ liệu để tạo tình huống sắp hết hàng cho demo
3. Kiểm tra kết quả báo cáo

## Lưu ý kỹ thuật
- Sử dụng Jakarta EE (không phải javax)
- Tương thích với Bootstrap 5.3.3
- Sử dụng Lombok để giảm boilerplate code
- Tuân thủ pattern MVC của dự án hiện có
- Responsive design cho mobile/tablet 