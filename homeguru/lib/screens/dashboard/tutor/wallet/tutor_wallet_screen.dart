import 'package:flutter/material.dart';
import '../../../../services/tutor_data_model.dart';

/// Transaction types from tutor's perspective
enum TutorTxType { sessionEarning, payout, bonus }

extension TutorTxTypeExt on TutorTxType {
  String get label => switch (this) {
        TutorTxType.sessionEarning => 'Session Earning',
        TutorTxType.payout => 'Withdrawn',
        TutorTxType.bonus => 'Bonus',
      };

  IconData get icon => switch (this) {
        TutorTxType.sessionEarning => Icons.school_outlined,
        TutorTxType.payout => Icons.account_balance_outlined,
        TutorTxType.bonus => Icons.card_giftcard_outlined,
      };

  bool get isCredit => this == TutorTxType.sessionEarning || this == TutorTxType.bonus;
}

class TutorWalletTx {
  final String id;
  final TutorTxType type;
  final double amount;
  final DateTime date;
  final String learnerName;
  final String subject;
  final String description;

  const TutorWalletTx({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.learnerName,
    required this.subject,
    required this.description,
  });
}

class TutorWalletScreen extends StatefulWidget {
  const TutorWalletScreen({super.key});

  @override
  State<TutorWalletScreen> createState() => _TutorWalletScreenState();
}

class _TutorWalletScreenState extends State<TutorWalletScreen> {
  TutorTxType? _typeFilter;
  String? _learnerFilter;

  List<TutorWalletTx> get _transactions {
    try {
      final data = TutorData.of(context);
      final raw = data.raw['wallet']?['transactions'];
      if (raw is List) {
        return raw.map((t) {
          final typeStr = t['type']?.toString() ?? 'sessionEarning';
          final type = TutorTxType.values.firstWhere(
            (e) => e.name == typeStr,
            orElse: () => TutorTxType.sessionEarning,
          );
          return TutorWalletTx(
            id: t['id']?.toString() ?? '',
            type: type,
            amount: (t['amount'] as num?)?.toDouble() ?? 0,
            date: DateTime.tryParse(t['date']?.toString() ?? '') ?? DateTime.now(),
            learnerName: t['learnerName']?.toString() ?? '',
            subject: t['subject']?.toString() ?? '',
            description: t['description']?.toString() ?? '',
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  double get _totalEarned {
    try {
      final data = TutorData.of(context);
      final val = data.raw['wallet']?['totalEarned'];
      if (val is num) return val.toDouble();
    } catch (_) {}
    return _transactions
        .where((t) => t.type.isCredit)
        .fold(0.0, (s, t) => s + t.amount);
  }

  double get _pendingClearance {
    try {
      final data = TutorData.of(context);
      final val = data.raw['wallet']?['pendingClearance'];
      if (val is num) return val.toDouble();
    } catch (_) {}
    return 0;
  }

  double get _withdrawn {
    try {
      final data = TutorData.of(context);
      final val = data.raw['wallet']?['withdrawn'];
      if (val is num) return val.toDouble();
    } catch (_) {}
    return _transactions
        .where((t) => t.type == TutorTxType.payout)
        .fold(0.0, (s, t) => s + t.amount);
  }

  double get _availableBalance => _totalEarned - _withdrawn;

  List<String> get _learnerNames {
    try {
      final data = TutorData.of(context);
      return data.learners
          .map((l) => l['name']?.toString() ?? l['firstName']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
    } catch (_) {}
    return [];
  }

  bool get _hasAnyFilter => _typeFilter != null || _learnerFilter != null;

  List<TutorWalletTx> get _filtered {
    var list = _transactions;
    if (_typeFilter != null) list = list.where((t) => t.type == _typeFilter).toList();
    if (_learnerFilter != null) list = list.where((t) => t.learnerName == _learnerFilter).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final txs = _filtered;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surface,
            surfaceTintColor: cs.surfaceTint,
            title: Text('Earnings', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                tooltip: 'How payouts work',
                onPressed: () => _showPayoutInfo(context),
              ),
            ],
          ),

          // Balance card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: _BalanceCard(
                available: _availableBalance,
                totalEarned: _totalEarned,
                pending: _pendingClearance,
                withdrawn: _withdrawn,
              ),
            ),
          ),

          // Payout cycle note
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.tertiary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: cs.onTertiaryContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Payouts are processed Monday to Monday',
                          style: tt.labelMedium?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter bar + label
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              child: Container(
                height: 80,
                color: cs.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                      child: Row(
                        children: [
                          Text('Transactions', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          if (_hasAnyFilter)
                            Text('${txs.length} result${txs.length == 1 ? '' : 's'}',
                                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Learner filter
                          _LearnerChip(
                            learners: _learnerNames,
                            selected: _learnerFilter,
                            onSelected: (l) => setState(() => _learnerFilter = l),
                            onClear: _learnerFilter != null ? () => setState(() => _learnerFilter = null) : null,
                          ),
                          const SizedBox(width: 8),
                          // Type filters
                          ...TutorTxType.values.map((t) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _ChipBtn(
                                  label: t.label,
                                  icon: t.icon,
                                  active: _typeFilter == t,
                                  onTap: () => setState(() => _typeFilter = _typeFilter == t ? null : t),
                                ),
                              )),
                          if (_hasAnyFilter)
                            _ChipBtn(
                              label: 'Clear all',
                              icon: Icons.close_rounded,
                              active: false,
                              onTap: () => setState(() { _typeFilter = null; _learnerFilter = null; }),
                              isDestructive: true,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          ),

          // Transactions list or empty state
          if (txs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 52, color: cs.onSurfaceVariant.withValues(alpha: 0.35)),
                    const SizedBox(height: 12),
                    Text('No earnings yet', style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('Complete sessions to start earning',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _TxTile(tx: txs[i]),
                childCount: txs.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _showPayoutInfo(BuildContext context) {
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
            Text('How Payouts Work', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _InfoStep(icon: Icons.school_outlined, color: cs.tertiaryContainer, fg: cs.onTertiaryContainer, title: 'Session Completed', body: 'After each session, the fee is released from the learner\'s escrow to your earnings.', tt: tt, cs: cs),
            const SizedBox(height: 12),
            _InfoStep(icon: Icons.hourglass_top_rounded, color: cs.secondaryContainer, fg: cs.onSecondaryContainer, title: 'Clearance Period', body: 'Earnings are held for 24 hours before becoming available for withdrawal.', tt: tt, cs: cs),
            const SizedBox(height: 12),
            _InfoStep(icon: Icons.account_balance_outlined, color: cs.primaryContainer, fg: cs.onPrimaryContainer, title: 'Withdraw', body: 'Transfer your available balance to your bank account anytime.', tt: tt, cs: cs),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Balance Card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatefulWidget {
  final double available, totalEarned, pending, withdrawn;
  const _BalanceCard({required this.available, required this.totalEarned, required this.pending, required this.withdrawn});

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
  late final Animation<double> _shimmerAnim = Tween<double>(begin: -2, end: 2).animate(CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut));

  @override
  void dispose() { _shimmer.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            _Blob(top: -100, right: -100, size: 300, color: cs.tertiary, opacity: isDark ? 0.4 : 0.2),
            _Blob(bottom: -80, left: -80, size: 260, color: cs.primary, opacity: isDark ? 0.3 : 0.15),
            AnimatedBuilder(
              animation: _shimmerAnim,
              builder: (_, __) => Positioned.fill(
                child: Transform.translate(
                  offset: Offset(_shimmerAnim.value * 200, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.white.withValues(alpha: isDark ? 0.03 : 0.12), Colors.transparent],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Balance', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text('₹${widget.available.toStringAsFixed(2)}',
                      style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -1)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Stat(label: 'Earned', value: '₹${widget.totalEarned.toStringAsFixed(0)}', cs: cs, tt: tt),
                      const SizedBox(width: 8),
                      _Stat(label: 'Pending', value: '₹${widget.pending.toStringAsFixed(0)}', cs: cs, tt: tt),
                      const SizedBox(width: 8),
                      _Stat(label: 'Withdrawn', value: '₹${widget.withdrawn.toStringAsFixed(0)}', cs: cs, tt: tt),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final ColorScheme cs;
  final TextTheme tt;
  const _Stat({required this.label, required this.value, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: tt.labelLarge?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final double opacity;
  const _Blob({this.top, this.bottom, this.left, this.right, required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)], stops: const [0.0, 0.85]),
        ),
      ),
    );
  }
}

// ── Transaction Tile ─────────────────────────────────────────────────────────

class _TxTile extends StatelessWidget {
  final TutorWalletTx tx;
  const _TxTile({required this.tx});

  Color _bg(TutorTxType t, ColorScheme cs) => switch (t) {
        TutorTxType.sessionEarning => cs.tertiaryContainer,
        TutorTxType.payout => cs.primaryContainer,
        TutorTxType.bonus => cs.secondaryContainer,
      };

  Color _fg(TutorTxType t, ColorScheme cs) => switch (t) {
        TutorTxType.sessionEarning => cs.onTertiaryContainer,
        TutorTxType.payout => cs.onPrimaryContainer,
        TutorTxType.bonus => cs.onSecondaryContainer,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greenColor = isDark ? const Color(0xFF34A853) : const Color(0xFF1B5E20);
    final isCredit = tx.type.isCredit;
    final amountStr = '${isCredit ? '+' : '−'}₹${tx.amount.toStringAsFixed(2)}';
    final amountColor = isCredit ? greenColor : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _bg(tx.type, cs),
            child: Icon(tx.type.icon, size: 18, color: _fg(tx.type, cs)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.learnerName.isNotEmpty ? tx.learnerName : tx.type.label,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(tx.description.isNotEmpty ? tx.description : tx.subject,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _bg(tx.type, cs), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tx.type.icon, size: 10, color: _fg(tx.type, cs)),
                      const SizedBox(width: 4),
                      Text(tx.type.label, style: tt.labelSmall?.copyWith(color: _fg(tx.type, cs), fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(amountStr, style: tt.titleSmall?.copyWith(color: amountColor, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Filter chip ──────────────────────────────────────────────────────────────

class _ChipBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool isDestructive;
  const _ChipBtn({required this.label, required this.icon, required this.active, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bg = isDestructive ? cs.errorContainer.withValues(alpha: 0.5) : active ? cs.tertiaryContainer : cs.surfaceContainerHighest;
    final fg = isDestructive ? cs.error : active ? cs.onTertiaryContainer : cs.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: active ? Border.all(color: cs.tertiary.withValues(alpha: 0.4)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(label, style: tt.labelSmall?.copyWith(color: fg, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Learner picker chip ──────────────────────────────────────────────────────

class _LearnerChip extends StatelessWidget {
  final List<String> learners;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final VoidCallback? onClear;
  const _LearnerChip({required this.learners, required this.selected, required this.onSelected, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final active = selected != null;
    final bg = active ? cs.tertiaryContainer : cs.surfaceContainerHighest;
    final fg = active ? cs.onTertiaryContainer : cs.onSurfaceVariant;

    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<String>(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text('Select Learner', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (learners.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('No learners yet', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  )
                else
                  ...learners.map((l) => ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.tertiaryContainer,
                          child: Text(l[0], style: tt.labelMedium?.copyWith(color: cs.onTertiaryContainer)),
                        ),
                        title: Text(l, style: tt.bodyMedium),
                        trailing: selected == l ? Icon(Icons.check_rounded, color: cs.tertiary) : null,
                        onTap: () => Navigator.pop(ctx, l),
                      )),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: active ? Border.all(color: cs.tertiary.withValues(alpha: 0.4)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline_rounded, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(selected ?? 'Learner', style: tt.labelSmall?.copyWith(color: fg, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
            const SizedBox(width: 4),
            if (onClear != null)
              GestureDetector(onTap: onClear, child: Icon(Icons.close_rounded, size: 13, color: fg))
            else
              Icon(Icons.expand_more_rounded, size: 14, color: fg),
          ],
        ),
      ),
    );
  }
}

// ── Info step (payout info sheet) ────────────────────────────────────────────

class _InfoStep extends StatelessWidget {
  final IconData icon;
  final Color color, fg;
  final String title, body;
  final TextTheme tt;
  final ColorScheme cs;
  const _InfoStep({required this.icon, required this.color, required this.fg, required this.title, required this.body, required this.tt, required this.cs});

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

// ── Header delegate ──────────────────────────────────────────────────────────

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _HeaderDelegate({required this.child});

  @override double get minExtent => 80;
  @override double get maxExtent => 80;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox(height: maxExtent, child: child);

  @override
  bool shouldRebuild(_HeaderDelegate old) => old.child != child;
}
