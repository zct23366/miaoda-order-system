
-- categories: 多语言名称
ALTER TABLE categories
  ADD COLUMN IF NOT EXISTS name_ja text,
  ADD COLUMN IF NOT EXISTS name_en text,
  ADD COLUMN IF NOT EXISTS name_ko text;

-- products: 多语言名称 + 简介
ALTER TABLE products
  ADD COLUMN IF NOT EXISTS name_ja text,
  ADD COLUMN IF NOT EXISTS name_en text,
  ADD COLUMN IF NOT EXISTS name_ko text,
  ADD COLUMN IF NOT EXISTS description_ja text,
  ADD COLUMN IF NOT EXISTS description_en text,
  ADD COLUMN IF NOT EXISTS description_ko text;
