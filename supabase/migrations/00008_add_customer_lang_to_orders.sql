ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_lang TEXT NOT NULL DEFAULT 'zh';
COMMENT ON COLUMN orders.customer_lang IS '顾客下单时的界面语言（zh/ja/en/ko）';