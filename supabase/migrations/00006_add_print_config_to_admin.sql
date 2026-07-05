
-- 在 admin_config 表添加打印配置字段
ALTER TABLE admin_config
  ADD COLUMN IF NOT EXISTS print_width_mm  INTEGER NOT NULL DEFAULT 50,
  ADD COLUMN IF NOT EXISTS print_height_mm INTEGER NOT NULL DEFAULT 70,
  ADD COLUMN IF NOT EXISTS print_auto      BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS print_copies    INTEGER NOT NULL DEFAULT 1;

-- 更新现有行的默认值（以防数据库里已有行）
UPDATE admin_config
SET
  print_width_mm  = COALESCE(print_width_mm,  50),
  print_height_mm = COALESCE(print_height_mm, 70),
  print_auto      = COALESCE(print_auto,      false),
  print_copies    = COALESCE(print_copies,    1);
