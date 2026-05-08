import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color fgColor;
  final Color accentColor;
  final bool showValue;
  final bool showLabel;
  final double iconSize;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.fgColor,
    required this.accentColor,
    this.showValue = true,
    this.showLabel = true,
    this.iconSize = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: showLabel && showValue
          ? _buildLargeCard(tt)
          : !showLabel && showValue
              ? _buildMediumCard(tt)
              : _buildSmallCard(),
    );
  }

  Widget _buildLargeCard(TextTheme tt) {
    return Stack(
      children: [
        Positioned(
          right: -8,
          bottom: -8,
          child: Icon(
            icon,
            size: 80,
            color: accentColor.withValues(alpha: 0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label.toUpperCase(),
                  style: tt.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    fontSize: 9,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: tt.headlineMedium?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediumCard(TextTheme tt) {
    return Stack(
      children: [
        Positioned(
          right: -8,
          bottom: -8,
          child: Icon(
            icon,
            size: 80,
            color: accentColor.withValues(alpha: 0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor, size: iconSize),
              const Spacer(),
              Text(
                value,
                style: tt.titleLarge?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
 
  Widget _buildSmallCard() {
    return Center(
      child: Icon(icon, color: accentColor, size: iconSize),
    );
  }
}
