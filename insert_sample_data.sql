-- Insert sample data for testing stock take functionality

-- Insert test users first
INSERT INTO users (username, password_hash, full_name, email, phone, role, is_active, created_at, updated_at) VALUES
('admin1', '$2a$10$9pFz.Yp5EKZzfEP0UNmGK.H7YwA6BWQBX7jf6kUzLhDqWGhYvOzuG', 'Admin Test', 'admin@test.com', '0123456789', 'admin', 1, NOW(), NOW()),
('warehouse1', '$2a$10$9pFz.Yp5EKZzfEP0UNmGK.H7YwA6BWQBX7jf6kUzLhDqWGhYvOzuG', 'Warehouse Staff', 'warehouse@test.com', '0123456788', 'warehouse_staff', 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE username = VALUES(username);

-- Insert sample suppliers
INSERT INTO suppliers (supplier_name, contact_person, phone_number, email, address, created_at, updated_at) VALUES
('Nhà Cung Cấp A', 'Nguyễn Văn A', '0901234567', 'ncca@example.com', '123 Đường ABC, TP.HCM', NOW(), NOW()),
('Nhà Cung Cấp B', 'Trần Thị B', '0901234568', 'nccb@example.com', '456 Đường DEF, Hà Nội', NOW(), NOW())
ON DUPLICATE KEY UPDATE supplier_name = VALUES(supplier_name);

-- Insert sample products with quantity
INSERT INTO products (product_code, product_name, description, unit, quantity, purchase_price, sale_price, supplier_id, low_stock_threshold, is_active, created_at, updated_at) VALUES
('SP001', 'Áo sơ mi trắng nam', 'Áo sơ mi trắng chất liệu cotton', 'cái', '50', 150000, 200000, 1, 10, 1, NOW(), NOW()),
('SP002', 'Quần jean nữ', 'Quần jean nữ màu xanh', 'cái', '30', 200000, 280000, 1, 5, 1, NOW(), NOW()),
('SP003', 'Áo thun nam', 'Áo thun nam cotton 100%', 'cái', '75', 80000, 120000, 2, 15, 1, NOW(), NOW()),
('SP004', 'Váy đầm nữ', 'Váy đầm nữ dạ hội', 'cái', '20', 300000, 450000, 2, 5, 1, NOW(), NOW()),
('SP005', 'Áo khoác bomber nam', 'Áo khoác bomber chất liệu polyester', 'cái', '25', 250000, 350000, 1, 8, 1, NOW(), NOW()),
('SP006', 'Quần short nữ', 'Quần short nữ mùa hè', 'cái', '40', 120000, 180000, 2, 12, 1, NOW(), NOW()),
('SP007', 'Áo polo nam', 'Áo polo nam cổ bẻ', 'cái', '60', 100000, 150000, 1, 10, 1, NOW(), NOW()),
('SP008', 'Chân váy nữ', 'Chân váy nữ xếp ly', 'cái', '35', 180000, 250000, 2, 8, 1, NOW(), NOW()),
('SP009', 'Áo hoodie unisex', 'Áo hoodie unisex có mũ', 'cái', '45', 200000, 300000, 1, 10, 1, NOW(), NOW()),
('SP010', 'Quần tây nam', 'Quần tây nam công sở', 'cái', '28', 220000, 320000, 2, 6, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE product_code = VALUES(product_code);

-- Insert corresponding inventory records (optional, để sync với bảng inventory nếu cần)
INSERT INTO inventory (product_id, quantity_on_hand, last_updated)
SELECT p.product_id, CAST(p.quantity AS UNSIGNED), NOW()
FROM products p 
WHERE p.is_active = 1 AND p.quantity REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE quantity_on_hand = VALUES(quantity_on_hand), last_updated = VALUES(last_updated); 