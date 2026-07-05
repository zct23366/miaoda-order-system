// 路由配置由 App.tsx 直接管理，此文件仅保留类型定义
import type { ReactNode } from 'react';

export interface RouteConfig {
  name: string;
  path: string;
  element: ReactNode;
  public?: boolean;
}

