import { TrendingUp, ShoppingBag, DollarSign, RefreshCw, Sparkles } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useStats } from '@/hooks/useData';
import { useLanguage } from '@/contexts/LanguageContext';

export default function AdminStatsPage() {
  const { totalRevenue, productStats, loading, reload } = useStats(5000);
  const { t } = useLanguage();
  const ts = t.adminStats;

  return (
    <div className="p-5 md:p-7 flex flex-col gap-6 page-enter">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Sparkles className="w-5 h-5 text-primary"
            style={{ filter: 'drop-shadow(0 0 8px rgba(217,152,59,0.35))' }} />
          <h1 className="text-2xl text-foreground" style={{ fontFamily: "'Noto Serif SC','STSong',serif" }}>
            {ts.title}
          </h1>
        </div>
        <Button variant="ghost" size="icon" onClick={reload}
          className="h-10 w-10 text-muted-foreground hover:text-foreground">
          <RefreshCw className="w-5 h-5" />
        </Button>
      </div>

      {/* 总营业额——黄金卡片 */}
      <div className="relative rounded-2xl p-6 flex items-center gap-5 overflow-hidden glass-card"
        style={{
          borderTopColor: 'rgba(217,152,59,0.35)',
          background: 'linear-gradient(135deg, rgba(217,152,59,0.12) 0%, rgba(184,113,58,0.06) 100%)',
          boxShadow: '0 8px 32px rgba(217,152,59,0.06), inset 0 1px 0 rgba(217,152,59,0.12)',
        }}>
        <div className="w-14 h-14 rounded-full flex items-center justify-center shrink-0"
          style={{
            background: 'rgba(217,152,59,0.12)',
            border: '1px solid rgba(217,152,59,0.28)',
            boxShadow: '0 0 20px rgba(217,152,59,0.12)',
          }}>
          <TrendingUp className="w-7 h-7 text-primary" />
        </div>
        <div>
          <p className="text-muted-foreground text-sm mb-1">{ts.totalRevenue}</p>
          <p className="text-foreground text-4xl font-medium glow-number highlight-number">
            ¥{totalRevenue.toFixed(2)}
          </p>
        </div>
      </div>

      {/* 汇总卡片 */}
      <div className="grid grid-cols-2 gap-4">
        <div className="glass-card rounded-2xl p-5 flex flex-col gap-2 overflow-hidden stat-card">
          <div className="flex items-center gap-2 text-muted-foreground text-sm">
            <ShoppingBag className="w-4 h-4" />{ts.productRanking}
          </div>
          <p className="stat-value text-foreground">{productStats.length}</p>
        </div>
        <div className="glass-card rounded-2xl p-5 flex flex-col gap-2 overflow-hidden stat-card">
          <div className="flex items-center gap-2 text-muted-foreground text-sm">
            <DollarSign className="w-4 h-4" />{ts.revenue}
          </div>
          <p className="stat-value text-foreground">
            {productStats.reduce((s, p) => s + p.quantity, 0)}
          </p>
        </div>
      </div>

      {/* 商品明细表 */}
      <div className="glass-card rounded-2xl overflow-hidden">
        <div className="px-5 py-4 flex items-center gap-2" style={{ borderBottom: '1px solid rgba(200,150,100,0.07)' }}>
          <span className="text-base font-medium flex-1 text-foreground">{ts.productRanking}</span>
        </div>
        {loading && productStats.length === 0 ? (
          <div className="py-12 text-center text-muted-foreground loading-elegant text-base">{ts.loading}</div>
        ) : productStats.length === 0 ? (
          <div className="py-12 text-center text-muted-foreground text-base">{ts.noData}</div>
        ) : (
          <div className="w-full overflow-x-auto">
            <table className="w-full min-w-[360px]">
              <thead>
                <tr style={{ background: 'rgba(200,150,100,0.03)', borderBottom: '1px solid rgba(200,150,100,0.07)' }}>
                  <th className="px-5 py-3.5 text-left text-sm text-muted-foreground font-medium whitespace-nowrap">商品名称</th>
                  <th className="px-5 py-3.5 text-right text-sm text-muted-foreground font-medium whitespace-nowrap">{ts.quantity}</th>
                  <th className="px-5 py-3.5 text-right text-sm text-muted-foreground font-medium whitespace-nowrap">{ts.revenue}</th>
                  <th className="px-5 py-3.5 text-right text-sm text-muted-foreground font-medium whitespace-nowrap">%</th>
                </tr>
              </thead>
              <tbody>
                {productStats.map((stat, i) => (
                  <tr key={stat.product_name}
                    style={{ borderBottom: i < productStats.length - 1 ? '1px solid rgba(200,150,100,0.04)' : 'none' }}>
                    <td className="px-5 py-4 text-sm md:text-base">
                      <div className="flex items-center gap-2.5">
                        {i < 3 && (
                          <span className={`text-sm font-medium w-5 shrink-0 ${
                            i === 0 ? 'text-primary' : i === 1 ? 'text-secondary' : 'text-muted-foreground'
                          }`}>{i + 1}</span>
                        )}
                        <span className="truncate max-w-[8rem] md:max-w-56 text-foreground">{stat.product_name}</span>
                      </div>
                    </td>
                    <td className="px-5 py-4 text-sm md:text-base text-right text-foreground whitespace-nowrap">{stat.quantity}</td>
                    <td className="px-5 py-4 text-sm md:text-base text-right text-primary font-medium highlight-number whitespace-nowrap">
                      ¥{stat.revenue.toFixed(2)}
                    </td>
                    <td className="px-5 py-4 text-sm md:text-base text-right text-muted-foreground whitespace-nowrap">
                      {totalRevenue > 0 ? `${((stat.revenue / totalRevenue) * 100).toFixed(1)}%` : '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
