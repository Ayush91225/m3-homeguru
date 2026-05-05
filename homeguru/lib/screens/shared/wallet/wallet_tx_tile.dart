import 'package:flutter/material.dart';
import 'wallet_models.dart';

class WalletTxTile extends StatelessWidget {
  final WalletTx tx;

  const WalletTxTile({super.key, required this.tx});

  Color _chipBg(TxType t, ColorScheme cs) => switch (t) {
        TxType.topUp        => cs.primaryContainer,
        TxType.sessionDebit => cs.secondaryContainer,
        TxType.refund       => cs.tertiaryContainer,
      };

  Color _chipFg(TxType t, ColorScheme cs) => switch (t) {
        TxType.topUp        => cs.onPrimaryContainer,
        TxType.sessionDebit => cs.onSecondaryContainer,
        TxType.refund       => cs.onTertiaryContainer,
      };

  // First letter of tutor name for avatar
  String get _initial => tx.tutorName.isNotEmpty ? tx.tutorName[0] : '?';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCredit = tx.type.isCredit;
    final amountStr = '${isCredit ? '+' : '−'}₹${tx.amount.toStringAsFixed(2)}';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greenColor = isDark ? const Color(0xFF34A853) : const Color(0xFF1B5E20);
    final amountColor = isCredit ? greenColor : cs.onSurface;

    return InkWell(
      onTap: tx.type == TxType.topUp ? () => _showInvoice(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: _chipBg(tx.type, cs),
              child: Text(
                _initial,
                style: tt.titleMedium?.copyWith(color: _chipFg(tx.type, cs), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 14),
            // Middle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.tutorName,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tx.description,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _chipBg(tx.type, cs),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tx.type.icon, size: 10, color: _chipFg(tx.type, cs)),
                            const SizedBox(width: 4),
                            Text(
                              tx.type.label,
                              style: tt.labelSmall?.copyWith(color: _chipFg(tx.type, cs), fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (tx.type == TxType.topUp) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showInvoice(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 10, color: cs.primary),
                                const SizedBox(width: 4),
                                Text('Invoice', style: tt.labelSmall?.copyWith(color: cs.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Amount
            Text(
              amountStr,
              style: tt.titleSmall?.copyWith(color: amountColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InvoiceSheet(tx: tx),
    );
  }
}

class _InvoiceSheet extends StatelessWidget {
  final WalletTx tx;
  const _InvoiceSheet({required this.tx});

  String _fmtDate(DateTime d) {
    const m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final perSession = tx.sessionCount != null ? tx.amount / tx.sessionCount! : tx.amount;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.receipt_long_outlined, color: cs.onPrimaryContainer, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoice', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  Text(tx.invoiceNumber ?? '', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                child: Text('Paid', style: tt.labelSmall?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF34A853) : const Color(0xFF2E7D32), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Row('Date',         _fmtDate(tx.date),                   tt, cs),
          _Row('Tutor',        tx.tutorName,                         tt, cs),
          _Row('Subject',      tx.subject,                           tt, cs),
          _Row('Sessions',     '${tx.sessionCount ?? 1} sessions',   tt, cs),
          _Row('Rate/session', '₹${perSession.toStringAsFixed(2)}',  tt, cs),
          Divider(height: 28, color: cs.outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Paid', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text('₹${tx.amount.toStringAsFixed(2)}', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Amount added to your Escrow Wallet and will be debited as sessions are completed.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Download Invoice'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme tt;
  final ColorScheme cs;
  const _Row(this.label, this.value, this.tt, this.cs);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          Text(value, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
