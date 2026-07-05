
-- 分类表
CREATE TABLE categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 商品表
CREATE TABLE products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid NOT NULL REFERENCES categories(id),
  name text NOT NULL,
  description text,
  price numeric(10, 2) NOT NULL DEFAULT 0,
  image_url text,
  is_available boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 订单表（状态：created, pending_payment, making, ready, completed, cancelled, deleted）
CREATE TABLE orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number text UNIQUE NOT NULL,
  status text NOT NULL DEFAULT 'created',
  payment_method text,
  total_amount numeric(10, 2) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 订单明细表
CREATE TABLE order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES products(id),
  product_name text NOT NULL,
  product_price numeric(10, 2) NOT NULL,
  quantity integer NOT NULL DEFAULT 1,
  subtotal numeric(10, 2) NOT NULL DEFAULT 0
);

-- 支付配置表（单行配置）
CREATE TABLE payment_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  wechat_enabled boolean NOT NULL DEFAULT true,
  wechat_qrcode_url text,
  alipay_enabled boolean NOT NULL DEFAULT true,
  alipay_qrcode_url text,
  paypay_enabled boolean NOT NULL DEFAULT false,
  paypay_qrcode_url text,
  cash_enabled boolean NOT NULL DEFAULT true,
  admin_password_hash text NOT NULL DEFAULT 'admin123',
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 管理员配置表（用于存储管理员密码）
CREATE TABLE admin_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  password text NOT NULL DEFAULT 'admin123',
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 自动生成订单号触发器
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.order_number := 'ORD-' || TO_CHAR(now(), 'YYYYMMDD') || '-' || LPAD(FLOOR(random() * 9000 + 1000)::text, 4, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number
BEFORE INSERT ON orders
FOR EACH ROW
WHEN (NEW.order_number IS NULL OR NEW.order_number = '')
EXECUTE FUNCTION generate_order_number();

-- 更新订单 updated_at 触发器
CREATE OR REPLACE FUNCTION update_order_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_order_updated_at();

-- Storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('menu-images', 'menu-images', true),
       ('payment-qrcodes', 'payment-qrcodes', true)
ON CONFLICT (id) DO NOTHING;

-- RLS 启用
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_config ENABLE ROW LEVEL SECURITY;

-- categories：所有人可读，不允许前端写入（通过edge function管理）
CREATE POLICY "anon_select_categories" ON categories FOR SELECT TO anon USING (true);
CREATE POLICY "authenticated_select_categories" ON categories FOR SELECT TO authenticated USING (true);
CREATE POLICY "anon_insert_categories" ON categories FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_update_categories" ON categories FOR UPDATE TO anon USING (true);
CREATE POLICY "anon_delete_categories" ON categories FOR DELETE TO anon USING (true);

-- products：所有人可读
CREATE POLICY "anon_select_products" ON products FOR SELECT TO anon USING (true);
CREATE POLICY "authenticated_select_products" ON products FOR SELECT TO authenticated USING (true);
CREATE POLICY "anon_insert_products" ON products FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_update_products" ON products FOR UPDATE TO anon USING (true);
CREATE POLICY "anon_delete_products" ON products FOR DELETE TO anon USING (true);

-- orders：所有人可读写（无用户登录体系）
CREATE POLICY "anon_select_orders" ON orders FOR SELECT TO anon USING (true);
CREATE POLICY "anon_insert_orders" ON orders FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_update_orders" ON orders FOR UPDATE TO anon USING (true);
CREATE POLICY "anon_delete_orders" ON orders FOR DELETE TO anon USING (false);
CREATE POLICY "authenticated_all_orders" ON orders FOR ALL TO authenticated USING (true);

-- order_items：所有人可读写
CREATE POLICY "anon_select_order_items" ON order_items FOR SELECT TO anon USING (true);
CREATE POLICY "anon_insert_order_items" ON order_items FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_update_order_items" ON order_items FOR UPDATE TO anon USING (true);
CREATE POLICY "authenticated_all_order_items" ON order_items FOR ALL TO authenticated USING (true);

-- payment_config：所有人可读，前端可更新
CREATE POLICY "anon_select_payment_config" ON payment_config FOR SELECT TO anon USING (true);
CREATE POLICY "anon_update_payment_config" ON payment_config FOR UPDATE TO anon USING (true);
CREATE POLICY "anon_insert_payment_config" ON payment_config FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "authenticated_all_payment_config" ON payment_config FOR ALL TO authenticated USING (true);

-- admin_config：所有人可读（密码校验用）
CREATE POLICY "anon_select_admin_config" ON admin_config FOR SELECT TO anon USING (true);
CREATE POLICY "anon_update_admin_config" ON admin_config FOR UPDATE TO anon USING (true);
CREATE POLICY "authenticated_all_admin_config" ON admin_config FOR ALL TO authenticated USING (true);

-- Storage policies
CREATE POLICY "public_read_menu_images" ON storage.objects FOR SELECT TO anon USING (bucket_id = 'menu-images');
CREATE POLICY "anon_upload_menu_images" ON storage.objects FOR INSERT TO anon WITH CHECK (bucket_id = 'menu-images');
CREATE POLICY "anon_update_menu_images" ON storage.objects FOR UPDATE TO anon USING (bucket_id = 'menu-images');
CREATE POLICY "anon_delete_menu_images" ON storage.objects FOR DELETE TO anon USING (bucket_id = 'menu-images');
CREATE POLICY "public_read_payment_qrcodes" ON storage.objects FOR SELECT TO anon USING (bucket_id = 'payment-qrcodes');
CREATE POLICY "anon_upload_payment_qrcodes" ON storage.objects FOR INSERT TO anon WITH CHECK (bucket_id = 'payment-qrcodes');
CREATE POLICY "anon_update_payment_qrcodes" ON storage.objects FOR UPDATE TO anon USING (bucket_id = 'payment-qrcodes');
CREATE POLICY "anon_delete_payment_qrcodes" ON storage.objects FOR DELETE TO anon USING (bucket_id = 'payment-qrcodes');
