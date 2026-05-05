import 'package:flutter/material.dart';
import 'wallet_models.dart';

class EscrowBalanceCard extends StatefulWidget {
  final List<WalletTx> txs;
  const EscrowBalanceCard({super.key, required this.txs});

  @override
  State<EscrowBalanceCard> createState() => _EscrowBalanceCardState();
}

class _EscrowBalanceCardState extends State<EscrowBalanceCard> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat();

  late final Animation<double> _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
    CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  double get _balance {
    double b = 0;
    for (final tx in widget.txs) {
      b += tx.type.isCredit ? tx.amount : -tx.amount;
    }
    return b;
  }

  double get _totalAdded   => widget.txs.where((t) => t.type == TxType.topUp).fold(0.0, (s, t) => s + t.amount);
  double get _totalSpent   => widget.txs.where((t) => t.type == TxType.sessionDebit).fold(0.0, (s, t) => s + t.amount);
  double get _totalRefunds => widget.txs.where((t) => t.type == TxType.refund).fold(0.0, (s, t) => s + t.amount);

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
            _GradientBlob(top: -100, right: -100, size: 300, color: const Color(0xFF4A90E2), opacity: isDark ? 0.5 : 0.25),
            _GradientBlob(bottom: -80, left: -80,  size: 260, color: const Color(0xFF7C4DFF), opacity: isDark ? 0.45 : 0.2),
            _GradientBlob(top: -60,  left: -40,   size: 500, color: const Color(0xFFA8C5FF), opacity: isDark ? 0.2 : 0.1),
            // shimmer sweep
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (_, __) => Positioned.fill(
                child: Transform.translate(
                  offset: Offset(_shimmerAnimation.value * 200, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: isDark ? 0.03 : 0.15),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Escrow Wallet', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(
                    '₹${_balance.toStringAsFixed(2)}',
                    style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -1),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatChip(label: 'Added',    value: '₹${_totalAdded.toStringAsFixed(0)}',   cs: cs, tt: tt),
                      const SizedBox(width: 8),
                      _StatChip(label: 'Spent',    value: '₹${_totalSpent.toStringAsFixed(0)}',   cs: cs, tt: tt),
                      const SizedBox(width: 8),
                      _StatChip(label: 'Refunded', value: '₹${_totalRefunds.toStringAsFixed(0)}', cs: cs, tt: tt),
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;

  const _StatChip({required this.label, required this.value, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
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

class _GradientBlob extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final double opacity;

  const _GradientBlob({this.top, this.bottom, this.left, this.right, required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)],
            stops: const [0.0, 0.85],
          ),
        ),
      ),
    );
  }
}
