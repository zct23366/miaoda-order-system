-- ── product_options：商品自定义选项 ─────────────────────────────────
CREATE TABLE IF NOT EXISTS product_options (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id   UUID REFERENCES products(id) ON DELETE CASCADE,
  name_zh      TEXT NOT NULL DEFAULT '',
  name_ja      TEXT NOT NULL DEFAULT '',
  name_en      TEXT NOT NULL DEFAULT '',
  name_ko      TEXT NOT NULL DEFAULT '',
  image_url    TEXT,
  price        NUMERIC(10,2) NOT NULL DEFAULT 0,
  default_qty  INT NOT NULL DEFAULT 0,
  sort_order   INT NOT NULL DEFAULT 0,
  enabled      BOOLEAN NOT NULL DEFAULT TRUE,
  deleted_at   TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── order_item_options：订单明细中已选选项快照 ───────────────────────
CREATE TABLE IF NOT EXISTS order_item_options (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_item_id  UUID REFERENCES order_items(id) ON DELETE CASCADE,
  option_id      UUID REFERENCES product_options(id) ON DELETE SET NULL,
  option_name    TEXT NOT NULL DEFAULT '',
  quantity       INT NOT NULL DEFAULT 1,
  unit_price     NUMERIC(10,2) NOT NULL DEFAULT 0,
  subtotal       NUMERIC(10,2) NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── RLS ─────────────────────────────────────────────────────────────
ALTER TABLE product_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_item_options ENABLE ROW LEVEL SECURITY;

-- product_options：所有人可读（已启用且未软删除），管理通过 service_role
CREATE POLICY "anon_read_product_options" ON product_options
  FOR SELECT USING (deleted_at IS NULL AND enabled = TRUE);

CREATE POLICY "service_all_product_options" ON product_options
  FOR ALL USING (TRUE) WITH CHECK (TRUE);

-- order_item_options：所有人可插入（下单时用匿名 key），管理可全读
CREATE POLICY "anon_insert_order_item_options" ON order_item_options
  FOR INSERT WITH CHECK (TRUE);

CREATE POLICY "anon_read_order_item_options" ON order_item_options
  FOR SELECT USING (TRUE);

CREATE POLICY "service_all_order_item_options" ON order_item_options
  FOR ALL USING (TRUE) WITH CHECK (TRUE);

-- ── 全局默认选项模板（product_id = NULL，新建商品时复制） ────────────
INSERT INTO product_options (id, product_id, name_zh, name_ja, name_en, name_ko, price, default_qty, sort_order)
VALUES
  (gen_random_uuid(), NULL, '加糖',       'シュガー追加', 'Add Sugar',          '설탕 추가',    0,   0, 1),
  (gen_random_uuid(), NULL, '加浓缩咖啡', 'エスプレッソ追加', 'Add Espresso',   '에스프레소 추가', 150, 0, 2),
  (gen_random_uuid(), NULL, '加冰',       'アイス追加',  'Add Ice',            '얼음 추가',    0,   1, 3)
ON CONFLICT DO NOTHING;