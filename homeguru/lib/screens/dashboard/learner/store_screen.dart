import 'package:flutter/material.dart';

const _storeItems = [
  // Premium Badges
  (icon: Icons.workspace_premium_rounded, title: 'Premium Badge', desc: 'Exclusive premium member badge', xp: 500, category: 'badges', colorIndex: 0, rarity: 'rare'),
  (icon: Icons.diamond_rounded, title: 'Diamond Badge', desc: 'Ultra-rare diamond collector badge', xp: 1000, category: 'badges', colorIndex: 1, rarity: 'legendary'),
  (icon: Icons.stars_rounded, title: 'Star Badge', desc: 'Shining star achievement badge', xp: 750, category: 'badges', colorIndex: 2, rarity: 'epic'),
  (icon: Icons.emoji_events_rounded, title: 'Trophy Badge', desc: 'Championship trophy badge', xp: 800, category: 'badges', colorIndex: 3, rarity: 'epic'),
  (icon: Icons.auto_awesome_rounded, title: 'Sparkle Badge', desc: 'Magical sparkle effect badge', xp: 600, category: 'badges', colorIndex: 4, rarity: 'rare'),
  (icon: Icons.military_tech_rounded, title: 'Elite Badge', desc: 'Top performer elite badge', xp: 900, category: 'badges', colorIndex: 5, rarity: 'epic'),
  
  // Premium Themes
  (icon: Icons.palette_rounded, title: 'Ocean Blue', desc: 'Deep ocean blue color theme', xp: 300, category: 'themes', colorIndex: 1, rarity: 'common'),
  (icon: Icons.palette_rounded, title: 'Royal Purple', desc: 'Elegant royal purple theme', xp: 300, category: 'themes', colorIndex: 2, rarity: 'common'),
  (icon: Icons.palette_rounded, title: 'Forest Green', desc: 'Natural forest green theme', xp: 300, category: 'themes', colorIndex: 0, rarity: 'common'),
  (icon: Icons.palette_rounded, title: 'Sunset Orange', desc: 'Warm sunset orange theme', xp: 300, category: 'themes', colorIndex: 3, rarity: 'common'),
  (icon: Icons.palette_rounded, title: 'Cherry Blossom', desc: 'Soft cherry blossom pink theme', xp: 350, category: 'themes', colorIndex: 4, rarity: 'rare'),
  (icon: Icons.palette_rounded, title: 'Midnight Black', desc: 'Premium midnight black theme', xp: 400, category: 'themes', colorIndex: 6, rarity: 'rare'),
  
  // Animation Effects
  (icon: Icons.celebration_rounded, title: 'Confetti Burst', desc: 'Celebration confetti animation', xp: 400, category: 'effects', colorIndex: 3, rarity: 'rare'),
  (icon: Icons.auto_awesome_rounded, title: 'Sparkle Trail', desc: 'Magical sparkle trail effect', xp: 350, category: 'effects', colorIndex: 4, rarity: 'common'),
  (icon: Icons.bolt_rounded, title: 'Lightning Strike', desc: 'Electric lightning animation', xp: 450, category: 'effects', colorIndex: 7, rarity: 'rare'),
  (icon: Icons.favorite_rounded, title: 'Heart Burst', desc: 'Lovely heart burst animation', xp: 350, category: 'effects', colorIndex: 8, rarity: 'common'),
  (icon: Icons.local_fire_department_rounded, title: 'Flame Effect', desc: 'Blazing flame animation', xp: 400, category: 'effects', colorIndex: 6, rarity: 'rare'),
  (icon: Icons.ac_unit_rounded, title: 'Frost Effect', desc: 'Icy frost animation', xp: 400, category: 'effects', colorIndex: 1, rarity: 'rare'),
  
  // Special Items
  (icon: Icons.card_giftcard_rounded, title: 'Mystery Box', desc: 'Random premium reward box', xp: 1500, category: 'special', colorIndex: 5, rarity: 'legendary'),
  (icon: Icons.redeem_rounded, title: 'Mega Pack', desc: 'Bundle of 5 random items', xp: 2000, category: 'special', colorIndex: 2, rarity: 'legendary'),
  (icon: Icons.star_border_purple500_rounded, title: 'Booster Pack', desc: 'XP multiplier for 7 days', xp: 1200, category: 'special', colorIndex: 7, rarity: 'epic'),
];

const _itemColors = [
  (light: Color(0xFF81C784), dark: Color(0xFF81C784)), // Green
  (light: Color(0xFF64B5F6), dark: Color(0xFF64B5F6)), // Blue
  (light: Color(0xFF9575CD), dark: Color(0xFF9575CD)), // Purple
  (light: Color(0xFFFFB74D), dark: Color(0xFFFFB74D)), // Orange
  (light: Color(0xFFF06292), dark: Color(0xFFF06292)), // Pink
  (light: Color(0xFF4DB6AC), dark: Color(0xFF4DB6AC)), // Teal
  (light: Color(0xFFE57373), dark: Color(0xFFEF5350)), // Red
  (light: Color(0xFFFFD54F), dark: Color(0xFFFFD54F)), // Amber
  (light: Color(0xFF90CAF9), dark: Color(0xFF90CAF9)), // Light Blue
];

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedCategory = 'all';
  final int _userXP = 2500;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final filteredItems = _selectedCategory == 'all'
        ? _storeItems
        : _storeItems.where((item) => item.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── app bar ──
          SliverAppBar(
            floating: true,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            title: Text('HG Store', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),

          // ── XP balance card ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.stars_rounded, color: cs.onPrimaryContainer, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Balance',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_userXP XP',
                            style: tt.headlineMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── category title ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text('Categories', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),

          // ── category filters ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryChip(
                    label: 'All',
                    icon: Icons.grid_view_rounded,
                    selected: _selectedCategory == 'all',
                    onTap: () => setState(() => _selectedCategory = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Badges',
                    icon: Icons.workspace_premium_rounded,
                    selected: _selectedCategory == 'badges',
                    onTap: () => setState(() => _selectedCategory = 'badges'),
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Themes',
                    icon: Icons.palette_rounded,
                    selected: _selectedCategory == 'themes',
                    onTap: () => setState(() => _selectedCategory = 'themes'),
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Effects',
                    icon: Icons.auto_awesome_rounded,
                    selected: _selectedCategory == 'effects',
                    onTap: () => setState(() => _selectedCategory = 'effects'),
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Special',
                    icon: Icons.card_giftcard_rounded,
                    selected: _selectedCategory == 'special',
                    onTap: () => setState(() => _selectedCategory = 'special'),
                  ),
                ],
              ),
            ),
          ),

          // ── items title ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                _selectedCategory == 'all' ? 'All Items' : '${_selectedCategory[0].toUpperCase()}${_selectedCategory.substring(1)}',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),

          // ── store items grid ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final item = filteredItems[i];
                  return _StoreItemCard(item: item, userXP: _userXP);
                },
                childCount: filteredItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.secondaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? cs.secondary.withValues(alpha: 0.3)
                : cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: tt.labelLarge?.copyWith(
                color: selected ? cs.onSecondaryContainer : cs.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final ({IconData icon, String title, String desc, int xp, String category, int colorIndex, String rarity}) item;
  final int userXP;

  const _StoreItemCard({
    required this.item,
    required this.userXP,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final canAfford = userXP >= item.xp;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 160;
        
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              // ── icon section ──
              Container(
                height: isCompact ? 80 : 90,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(isCompact ? 10 : 12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, size: isCompact ? 28 : 32, color: cs.primary),
                  ),
                ),
              ),
              // ── details section ──
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 10 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: (isCompact ? tt.bodySmall : tt.bodyMedium)?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isCompact ? 2 : 4),
                      Expanded(
                        child: Text(
                          item.desc,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: isCompact ? 10 : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: isCompact ? 6 : 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 6 : 8,
                                vertical: isCompact ? 3 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stars_rounded, size: isCompact ? 10 : 12, color: cs.primary),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      '${item.xp}',
                                      style: tt.labelSmall?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w700,
                                        fontSize: isCompact ? 9 : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          FilledButton.tonal(
                            onPressed: canAfford ? () => _showPurchaseDialog(context, item) : null,
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 8 : 12,
                                vertical: isCompact ? 4 : 6,
                              ),
                              minimumSize: Size(0, isCompact ? 28 : 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Buy',
                              style: tt.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: isCompact ? 10 : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPurchaseDialog(BuildContext context, item) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Purchase ${item.title}?'),
        content: Text('This will cost ${item.xp} XP. You will have ${userXP - item.xp} XP remaining.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.title} purchased successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }
}
