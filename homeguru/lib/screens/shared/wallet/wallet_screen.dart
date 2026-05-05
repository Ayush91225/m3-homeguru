import 'package:flutter/material.dart';
import 'wallet_models.dart';
import 'wallet_balance_card.dart';
import 'wallet_filter_bar.dart';
import 'wallet_tx_tile.dart';
import 'refer_earn_sheet.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletFilters _filters = const WalletFilters();

  List<WalletTx> get _filtered {
    final list = _filters.apply(kMockTxs);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // Build month → day → txs structure
  List<_MonthGroup> get _groups {
    final txs = _filtered;
    if (txs.isEmpty) return [];

    final Map<String, Map<String, List<WalletTx>>> byMonth = {};
    for (final tx in txs) {
      final mk = _monthKey(tx.date);
      final dk = _dayKey(tx.date);
      byMonth.putIfAbsent(mk, () => {})[dk] ??= [];
      byMonth[mk]![dk]!.add(tx);
    }

    return byMonth.entries.map((me) {
      final dayGroups = me.value.entries
          .map((de) => _DayGroup(de.key, de.value))
          .toList();
      return _MonthGroup(me.key, dayGroups);
    }).toList();
  }

  String _monthKey(DateTime d) {
    const m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${m[d.month - 1]} ${d.year}';
  }

  String _dayKey(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${m[d.month - 1]}';
  }

  // Flat list items for SliverChildBuilderDelegate
  List<_ListItem> get _flatItems {
    final items = <_ListItem>[];
    for (final mg in _groups) {
      items.add(_ListItem.monthHeader(mg));
      for (final dg in mg.dayGroups) {
        items.add(_ListItem.dayHeader(dg.label));
        for (final tx in dg.txs) {
          items.add(_ListItem.tx(tx));
        }
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final items = _flatItems;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surface,
            surfaceTintColor: cs.surfaceTint,
            title: Text('Wallet', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            actions: [
              TextButton.icon(
                onPressed: () => ReferEarnSheet.show(context),
                icon: const Icon(Icons.card_giftcard_outlined, size: 16),
                label: const Text('Refer & Earn'),
                style: TextButton.styleFrom(
                  foregroundColor: cs.primary,
                  textStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                tooltip: 'How escrow works',
                onPressed: () => _showEscrowInfo(context),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: EscrowBalanceCard(txs: kMockTxs),
            ),
          ),

          // Sticky filter + label header
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterHeaderDelegate(
              child: Builder(builder: (context) {
                final cs = Theme.of(context).colorScheme;
                final tt = Theme.of(context).textTheme;
                return SizedBox(
                  height: 90,
                  child: ColoredBox(
                    color: cs.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                          child: Row(
                            children: [
                              Text('Transactions', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              if (_filters.hasAny)
                                Text(
                                  '${_filtered.length} result${_filtered.length == 1 ? '' : 's'}',
                                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                ),
                            ],
                          ),
                        ),
                        WalletFilterBar(
                          filters: _filters,
                          tutors: kMockTutors,
                          onChanged: (f) => setState(() => _filters = f),
                        ),
                        const SizedBox(height: 6),
                        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          if (items.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 52, color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
                    const SizedBox(height: 12),
                    Text('No transactions found', style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => setState(() => _filters = const WalletFilters()),
                      child: const Text('Clear filters'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = items[i];
                  return switch (item.kind) {
                    _Kind.monthHeader => _MonthHeaderTile(group: item.monthGroup!),
                    _Kind.dayHeader   => _DayHeaderTile(label: item.label!),
                    _Kind.tx          => WalletTxTile(tx: item.tx!),
                  };
                },
                childCount: items.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _showEscrowInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('How Escrow Works', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _EscrowStep(icon: Icons.add_card_outlined, color: cs.primaryContainer,   fg: cs.onPrimaryContainer,   title: 'Paid on Platform',   body: 'When you book sessions, the full amount is charged and held securely in your Escrow Wallet.', tt: tt, cs: cs),
            const SizedBox(height: 12),
            _EscrowStep(icon: Icons.school_outlined,   color: cs.secondaryContainer, fg: cs.onSecondaryContainer, title: 'Paid from Escrow',   body: 'After each session is completed, the per-session fee is automatically released to your tutor.', tt: tt, cs: cs),
            const SizedBox(height: 12),
            _EscrowStep(icon: Icons.undo_rounded,      color: cs.tertiaryContainer,  fg: cs.onTertiaryContainer,  title: 'Refunded to Escrow', body: 'If a session is cancelled, the amount is instantly returned to your Escrow Wallet.', tt: tt, cs: cs),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Data structures ──────────────────────────────────────────────────────────

class _DayGroup {
  final String label;
  final List<WalletTx> txs;
  const _DayGroup(this.label, this.txs);
}

class _MonthGroup {
  final String label;
  final List<_DayGroup> dayGroups;
  const _MonthGroup(this.label, this.dayGroups);

  double get totalSpent   => dayGroups.expand((d) => d.txs).where((t) => t.type == TxType.sessionDebit).fold(0.0, (s, t) => s + t.amount);
  double get totalAdded   => dayGroups.expand((d) => d.txs).where((t) => t.type == TxType.topUp).fold(0.0, (s, t) => s + t.amount);
  double get totalRefunds => dayGroups.expand((d) => d.txs).where((t) => t.type == TxType.refund).fold(0.0, (s, t) => s + t.amount);
}

enum _Kind { monthHeader, dayHeader, tx }

class _ListItem {
  final _Kind kind;
  final _MonthGroup? monthGroup;
  final String? label;
  final WalletTx? tx;

  const _ListItem._({required this.kind, this.monthGroup, this.label, this.tx});

  factory _ListItem.monthHeader(_MonthGroup g) => _ListItem._(kind: _Kind.monthHeader, monthGroup: g);
  factory _ListItem.dayHeader(String l)        => _ListItem._(kind: _Kind.dayHeader, label: l);
  factory _ListItem.tx(WalletTx t)             => _ListItem._(kind: _Kind.tx, tx: t);
}

// ── Tiles ────────────────────────────────────────────────────────────────────

class _MonthHeaderTile extends StatelessWidget {
  final _MonthGroup group;
  const _MonthHeaderTile({required this.group});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greenColor = isDark ? const Color(0xFF34A853) : const Color(0xFF1B5E20);

    return Container(
      color: cs.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.label, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (group.totalAdded > 0)
                _MonthStat(label: 'Added', value: '+₹${group.totalAdded.toStringAsFixed(0)}', color: greenColor, cs: cs, tt: tt),
              if (group.totalAdded > 0 && group.totalSpent > 0)
                const SizedBox(width: 8),
              if (group.totalSpent > 0)
                _MonthStat(label: 'Spent', value: '−₹${group.totalSpent.toStringAsFixed(0)}', color: cs.onSurfaceVariant, cs: cs, tt: tt),
              if (group.totalRefunds > 0) ...[
                const SizedBox(width: 8),
                _MonthStat(label: 'Refunded', value: '+₹${group.totalRefunds.toStringAsFixed(0)}', color: greenColor, cs: cs, tt: tt),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ColorScheme cs;
  final TextTheme tt;

  const _MonthStat({required this.label, required this.value, required this.color, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label  ', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10)),
            TextSpan(text: value, style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _DayHeaderTile extends StatelessWidget {
  final String label;
  const _DayHeaderTile({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Text(label, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
    );
  }
}

class _EscrowStep extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color fg;
  final String title;
  final String body;
  final TextTheme tt;
  final ColorScheme cs;

  const _EscrowStep({required this.icon, required this.color, required this.fg, required this.title, required this.body, required this.tt, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 18, color: fg),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(body, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _FilterHeaderDelegate({required this.child});

  @override double get minExtent => 90;
  @override double get maxExtent => 90;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox(height: maxExtent, child: child);

  @override
  bool shouldRebuild(_FilterHeaderDelegate old) => old.child != child;
}
