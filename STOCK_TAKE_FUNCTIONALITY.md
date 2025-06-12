# Chức Năng Kiểm Kê Hàng Hóa (Stock Take)

Đã hoàn thành tạo chức năng kiểm kê hàng hóa với phân quyền theo vai trò người dùng.

## Cấu trúc đã tạo

### 1. Model Classes
- **StockTake.java**: Entity cho bảng `stocktakes`
- **StockTakeDetail.java**: Entity cho bảng `stocktakedetails`

### 2. DAO Classes
- **StockTakeDAO.java**: Xử lý CRUD operations cho bảng `stocktakes`
- **StockTakeDetailDAO.java**: Xử lý CRUD operations cho bảng `stocktakedetails`

### 3. Controller
- **StockTakeController.java**: Xử lý các request từ client với URL pattern `/stock-take`

### 4. JSP Views
- **list.jsp**: Danh sách phiếu kiểm kê
- **create.jsp**: Form tạo phiếu kiểm kê mới (warehouse staff)
- **perform.jsp**: Thực hiện kiểm kê (warehouse staff)
- **view.jsp**: Xem chi tiết phiếu kiểm kê
- **report.jsp**: Báo cáo kiểm kê (admin)

## Phân quyền chức năng

### Warehouse Staff
- Tạo phiếu kiểm kê mới
- Thực hiện kiểm kê (nhập số lượng thực tế)
- Xem danh sách phiếu kiểm kê của mình
- Xem chi tiết phiếu kiểm kê

### Admin
- Xem tất cả phiếu kiểm kê
- Xem báo cáo chi tiết với thống kê
- Cập nhật trạng thái phiếu kiểm kê (đối soát)
- Xem chi tiết và báo cáo

## Quy trình kiểm kê

1. **Tạo phiếu**: Warehouse staff tạo phiếu kiểm kê mới
2. **Hệ thống tự động**: Tạo chi tiết cho tất cả sản phẩm active với số lượng từ bảng inventory
3. **Thực hiện kiểm kê**: Staff nhập số lượng thực tế cho từng sản phẩm
4. **Tự động tính chênh lệch**: Hệ thống tự động tính toán sự khác biệt
5. **Hoàn thành**: Khi tất cả sản phẩm đã được kiểm, trạng thái chuyển thành "completed"
6. **Đối soát**: Admin xem báo cáo và đánh dấu "reconciled"

## Tính năng chính

### Danh sách phiếu kiểm kê
- Hiển thị thông tin phiếu kiểm kê
- Lọc theo trạng thái
- Hiển thị tiến độ kiểm kê
- Phân quyền xem theo role

### Thực hiện kiểm kê
- Giao diện thân thiện cho warehouse staff
- Tìm kiếm và lọc sản phẩm
- Nhập số lượng thực tế
- Hiển thị chênh lệch real-time
- Thống kê tiến độ

### Báo cáo cho Admin
- Thống kê tổng quan
- Danh sách sản phẩm có chênh lệch
- Chi tiết đầy đủ tất cả sản phẩm
- Tính toán tỷ lệ chênh lệch
- Chức năng in báo cáo

## Database Schema

### Bảng stocktakes
- stock_take_id (PK)
- stock_take_code (unique)
- user_id (FK to users)
- stock_take_date
- status (pending, in_progress, completed, reconciled)
- notes
- created_at

### Bảng stocktakedetails
- stock_take_detail_id (PK)
- stock_take_id (FK)
- product_id (FK)
- system_quantity
- counted_quantity
- discrepancy (calculated column)

## URLs và Actions

- `GET /stock-take` - Danh sách phiếu kiểm kê
- `GET /stock-take?action=create` - Form tạo phiếu mới
- `POST /stock-take` với action=create - Tạo phiếu kiểm kê
- `GET /stock-take?action=perform&id=X` - Thực hiện kiểm kê
- `POST /stock-take` với action=update-count - Cập nhật số lượng kiểm đếm
- `GET /stock-take?action=view&id=X` - Xem chi tiết
- `GET /stock-take?action=report&id=X` - Báo cáo (admin)
- `POST /stock-take` với action=update-status - Cập nhật trạng thái (admin)

## Ghi chú kỹ thuật

- Sử dụng wrapper types (Integer) thay vì primitive types
- Generated column cho discrepancy trong database
- Transaction handling trong các phương thức DAO
- Responsive design với Bootstrap 5
- JavaScript cho tương tác real-time
- JSTL tags cho template rendering

## Cách sử dụng

1. Đảm bảo database đã có dữ liệu trong bảng products và inventory
2. Truy cập `/stock-take` với user có role warehouse_staff hoặc admin
3. Warehouse staff tạo phiếu kiểm kê mới và thực hiện kiểm đếm
4. Admin có thể xem báo cáo và đối soát

Chức năng này tuân thủ đầy đủ các quy tắc được yêu cầu và cung cấp giao diện thân thiện cho cả warehouse staff và admin. 