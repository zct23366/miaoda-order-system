// RouteGuard 已由 AdminGuard 替代，此文件保留以免破坏引用
import type { ReactNode } from 'react';

interface RouteGuardProps {
  children: ReactNode;
}

export function RouteGuard({ children }: RouteGuardProps) {
  return <>{children}</>;
}