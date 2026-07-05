import { Navigate, Outlet } from 'react-router-dom';
import { useAdmin } from '@/contexts/AdminContext';
import type { ReactNode } from 'react';

interface Props {
  children?: ReactNode;
}

export default function AdminGuard({ children }: Props) {
  const { isLoggedIn } = useAdmin();
  if (!isLoggedIn) return <Navigate to="/admin/login" replace />;
  return children ? <>{children}</> : <Outlet />;
}
