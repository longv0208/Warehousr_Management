-- Script để sửa dữ liệu stock take hiện tại và đồng bộ với database mới

-- 1. Update existing stock take details với system_quantity đúng từ products.quantity
UPDATE stocktakedetails std 
JOIN products p ON std.product_id = p.product_id 
SET std.system_quantity = COALESCE(p.quantity, 0) 
WHERE std.system_quantity = 0;

-- 2. Đảm bảo inventory table được sync với products
-- Xóa dữ liệu cũ trong inventory nếu có
DELETE FROM inventory;

-- Insert lại dữ liệu inventory từ products
INSERT INTO inventory (product_id, quantity_on_hand, last_updated)
SELECT product_id, COALESCE(quantity, 0), NOW()
FROM products 
WHERE is_active = 1;

-- 3. Hiển thị kết quả để kiểm tra
SELECT 
    st.stock_take_code,
    st.status,
    COUNT(std.stock_take_detail_id) as total_items,
    SUM(std.system_quantity) as total_system_quantity,
    COUNT(CASE WHEN std.counted_quantity IS NOT NULL THEN 1 END) as counted_items
FROM stocktakes st
JOIN stocktakedetails std ON st.stock_take_id = std.stock_take_id
GROUP BY st.stock_take_id, st.stock_take_code, st.status;

-- 4. Hiển thị chi tiết một vài sản phẩm để verify
SELECT 
    p.product_code,
    p.product_name,
    p.quantity as product_quantity,
    std.system_quantity,
    std.counted_quantity,
    std.discrepancy
FROM products p
JOIN stocktakedetails std ON p.product_id = std.product_id
WHERE std.stock_take_id = 1
LIMIT 10; 