import React, { createContext, useContext, useState, useCallback } from 'react';

interface AdminContextValue {
  isLoggedIn: boolean;
  login: () => void;
  logout: () => void;
}

const AdminContext = createContext<AdminContextValue | null>(null);

export function AdminProvider({ children }: { children: React.ReactNode }) {
  const [isLoggedIn, setIsLoggedIn] = useState(
    () => sessionStorage.getItem('admin_auth') === 'true'
  );

  const login = useCallback(() => {
    sessionStorage.setItem('admin_auth', 'true');
    setIsLoggedIn(true);
  }, []);

  const logout = useCallback(() => {
    sessionStorage.removeItem('admin_auth');
    setIsLoggedIn(false);
  }, []);

  return (
    <AdminContext.Provider value={{ isLoggedIn, login, logout }}>
      {children}
    </AdminContext.Provider>
  );
}

export function useAdmin() {
  const ctx = useContext(AdminContext);
  if (!ctx) throw new Error('useAdmin must be used within AdminProvider');
  return ctx;
}
