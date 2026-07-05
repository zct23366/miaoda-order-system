import { Outlet } from 'react-router-dom';
import { CartProvider } from '@/contexts/CartContext';

export default function UserLayout() {
  return (
    <CartProvider>
      {/* ✨ 散景光斑系统——7个多层次的虚化光环 */}
      <div className="ambient-lights" aria-hidden="true">
        <div className="ambient-light bokeh--gold-primary" />
        <div className="ambient-light bokeh--amber-large" />
        <div className="ambient-light bokeh--gold-mid" />
        <div className="ambient-light bokeh--cream-soft" />
        <div className="ambient-light bokeh--copper-small" />
        <div className="ambient-light bokeh--gold-micro-1" />
        <div className="ambient-light bokeh--gold-micro-2" />
      </div>

      <div className="relative z-10 min-h-screen bg-background">
        <Outlet />
      </div>
    </CartProvider>
  );
}
