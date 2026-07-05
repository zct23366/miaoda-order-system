## Vibe
- Warm Organic Craft — 手工咖啡馆质感，麻布纸纹底 × 浓缩咖啡色文字，editorial serif 标题配圆润无衬线正文，呈现文化祭小摊的手作温度

## Color
- Primary: #D49653
- On Primary: #0F172A
- Accent: #EFA680
- On Accent: #0F172A
- Background: #FDF6ED
- Foreground: #1C120A
- Muted: #EFE6D8
- Border: #D9C9B4
- Secondary: #C08440

## Typography
- Heading: 寒蝉有机体 (family: ChillOrganic, weight: Medium, url: https://resource-static.bj.bcebos.com/fonts-skill/ChillOrganic_Medium.woff2)
- Body: 有爱黑体 CN (family: NowarHansCN, weight: Light, url: https://resource-static.bj.bcebos.com/fonts-skill/NowarHansCN_Light.ttf)

## Visual Language
- 核心视觉签名：细颗粒噪点纹理叠加在卡片与页面背景上（CSS noise SVG filter），模拟日本活版印刷纸张质感；配合 1px 虚线描边分隔区域，避免通用实线框
- 材质与深度：轻微内嵌阴影 inset 模拟纸张压印；卡片用 Muted 底色而非白色，与 Background 形成 2 层层次；无大面积投影
- 容器与按钮：卡片圆角 8px，边框用 Border 色虚线；主操作按钮 Primary 填充 + On Primary 文字，扁平无渐变；次要按钮 Muted 底色；状态徽章用 Accent 浅色填充
- 布局节奏：留白充裕，菜单分类区采用水平滚动标签条；商品卡片 2~3 列网格，图片区 4:3 比例；管理后台左侧固定导航栏，内容区白纸感

## Animation
- 入场：页面切换 fade + 上移 12px，150ms ease-out
- 交互：按钮 scale 0.97 + 80ms；购物车加购时 badge 弹跳 scale 1→1.3→1，200ms
- 滚动/过渡：分类标签选中时下划线滑动过渡 200ms ease

## Forbidden
- 禁大块 Primary/Accent 色铺满 Hero 或操作区背景
- 禁圆角卡片 + 白底 + 通用投影作为唯一视觉层次
- 禁 Emoji 作为图标或导航装饰

## Additional Notes
- 所有用户可见文案使用中文
- 管理员登录页：深色麻布纹全幅背景 + 中央白卡片表单，避免纯白底孤立表单
- 出餐展示屏（展示模块）：使用深色背景 + 大号粗体订单编号，适合远距离识别
- 噪点纹理实现：SVG feTurbulence filter 叠加在 ::before 伪元素，opacity 0.04~0.06
