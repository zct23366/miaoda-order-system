import { useCallback } from 'react';
import type { OrderWithItems, PrintConfig } from '@/types/types';
import type { Lang } from '@/i18n/translations';
import { TRANSLATIONS, PAYMENT_LABELS } from '@/i18n/translations';

/**
 * 打印小票 Hook
 *
 * 原理：向当前页注入隐藏 <iframe>，写入完整 HTML + CSS（含 @page 自定义纸张尺寸），
 * 然后调用 iframe.contentWindow.print()，由浏览器弹出系统打印对话框。
 * 使用 iframe 而非 window.open()，可避免 Realtime 异步回调触发时的弹窗拦截问题。
 */
export function usePrint(printConfig: PrintConfig) {
  const printOrder = useCallback(
    (order: OrderWithItems) => {
      const { print_width_mm: w, print_height_mm: h, print_copies: copies } = printConfig;
      // 以顾客下单时的语言为准，回退到中文
      const lang: Lang = (['zh', 'ja', 'en', 'ko'].includes(order.customer_lang)
        ? order.customer_lang
        : 'zh') as Lang;
      const tk = TRANSLATIONS[lang].ticket;
      const payLabels = PAYMENT_LABELS[lang];

      const dateStr = new Date(order.created_at).toLocaleString(
        lang === 'zh' ? 'zh-CN' : lang === 'ja' ? 'ja-JP' : lang === 'ko' ? 'ko-KR' : 'en-US',
        { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' }
      );

      const itemRows = (order.order_items ?? [])
        .map(
          item => `
          <tr>
            <td class="name">${item.product_name}</td>
            <td class="qty">×${item.quantity}</td>
            <td class="price">¥${Number(item.subtotal).toFixed(2)}</td>
          </tr>`
        )
        .join('');

      const payLabel = order.payment_method
        ? (payLabels[order.payment_method] ?? order.payment_method)
        : '—';

      const ticketHtml = /* html */ `<!DOCTYPE html>
<html lang="${lang}">
<head>
<meta charset="UTF-8">
<title>${tk.storeName} ${order.order_number}</title>
<style>
  /* ── 纸张设置 ── */
  @page {
    size: ${w}mm ${h}mm;
    margin: 3mm 3mm 4mm 3mm;
  }

  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: "Helvetica Neue", "Noto Sans SC", "Noto Sans JP", "Noto Sans KR", Arial, sans-serif;
    font-size: 8pt;
    color: #111;
    width: ${w - 6}mm;
    background: #fff;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  .store { font-size: 10pt; font-weight: 700; text-align: center; padding: 1mm 0 2mm; }
  .dashed { border: none; border-top: 1px dashed #888; margin: 1.5mm 0; }
  .solid  { border: none; border-top: 1px solid  #111; margin: 1.5mm 0; }
  .order-no {
    font-size: 14pt; font-weight: 900; text-align: center;
    letter-spacing: 0.05em; padding: 1mm 0;
  }
  .meta { font-size: 7pt; color: #555; display: flex; justify-content: space-between; padding: 0.5mm 0; }
  table { width: 100%; border-collapse: collapse; margin: 1mm 0; }
  th { font-size: 7pt; color: #555; text-align: left; padding-bottom: 0.8mm; }
  th:last-child, td:last-child { text-align: right; }
  th.qty, td.qty { text-align: center; width: 8mm; }
  td.name { font-size: 7.5pt; }
  td { padding: 0.6mm 0; }
  .total-row { display: flex; justify-content: space-between; align-items: baseline; padding: 1mm 0 0.5mm; }
  .total-label { font-size: 9pt; font-weight: 700; }
  .total-amount { font-size: 13pt; font-weight: 900; }
  .footer { font-size: 6.5pt; color: #888; text-align: center; padding: 1.5mm 0 0; }

  @media print {
    html, body { margin: 0; padding: 0; }
  }
</style>
</head>
<body>
  <div class="store">${tk.storeName}</div>
  <hr class="solid">

  <div class="order-no">${order.order_number.split('-').slice(-1)[0]}</div>
  <div class="meta">
    <span>${order.order_number}</span>
    <span>${payLabel}</span>
  </div>
  <div class="meta">
    <span>${dateStr}</span>
  </div>

  <hr class="dashed">

  <table>
    <thead>
      <tr>
        <th>${tk.product}</th>
        <th class="qty">${tk.qty}</th>
        <th>${tk.amount}</th>
      </tr>
    </thead>
    <tbody>${itemRows}</tbody>
  </table>

  <hr class="solid">

  <div class="total-row">
    <span class="total-label">${tk.total}</span>
    <span class="total-amount">¥${Number(order.total_amount).toFixed(2)}</span>
  </div>

  <hr class="dashed">
  <div class="footer">${tk.footer}</div>
</body>
</html>`;

      // 打印指定份数
      // 使用隐藏 iframe 方案：
      //   ① 不调用 window.open()，彻底绕开浏览器弹窗拦截（Realtime 异步回调无用户手势时会被拦截）
      //   ② document.write() 后立即设置 onload，无竞态问题
      const totalCopies = Math.max(1, copies);
      const printOne = (copyIdx: number) => {
        const iframe = document.createElement('iframe');
        iframe.style.cssText =
          'position:fixed;left:-9999px;top:-9999px;width:1px;height:1px;opacity:0;pointer-events:none';
        document.body.appendChild(iframe);

        const doc = iframe.contentDocument ?? iframe.contentWindow?.document;
        if (!doc) {
          iframe.remove();
          return;
        }

        // 先绑定 onload，再写入内容，避免同步触发竞态
        iframe.onload = () => {
          setTimeout(() => {
            try {
              iframe.contentWindow?.focus();
              iframe.contentWindow?.print();
            } finally {
              // 打印对话框关闭后再移除
              setTimeout(() => iframe.remove(), 3000);
            }
          }, 200);
        };

        doc.open();
        doc.write(ticketHtml);
        doc.close();

        // 若下一份需要错开时间，避免打印队列冲突
        if (copyIdx + 1 < totalCopies) {
          setTimeout(() => printOne(copyIdx + 1), 800);
        }
      };

      printOne(0);
    },
    [printConfig]
  );

  return { printOrder };
}
