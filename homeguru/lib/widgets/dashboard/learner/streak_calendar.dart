import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StreakCalendar extends StatefulWidget {
  const StreakCalendar({super.key});

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  final ScreenshotController _screenshotController = ScreenshotController();

  late final List<List<int>> _yearData = _generateYearData();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<List<int>> _generateYearData() {
    final random = math.Random(42);
    return List.generate(53, (week) {
      return List.generate(7, (day) {
        if (week < 10) return random.nextInt(5);
        if (week < 20) return random.nextInt(4);
        if (week < 30) return 0;
        return random.nextInt(3);
      });
    });
  }

  Color _getColorForLevel(int level, ColorScheme cs) {
    switch (level) {
      case 0:
        return cs.surfaceContainer;
      case 1:
        return const Color(0xFFBBDEFB);
      case 2:
        return const Color(0xFF90CAF9);
      case 3:
        return const Color(0xFF42A5F5);
      case 4:
        return const Color(0xFF1E88E5);
      default:
        return cs.surfaceContainer;
    }
  }

  int _calculateStreak() => 12;
  int _calculateTotalDays() => 89;

  Future<void> _shareStreak() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/streak_calendar.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Check out my learning streak! 🔥',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final yearData = _yearData;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Each cell is 11px wide + 3px gap = 14px per week column.
    // Day-label column is 22px + 6px gap = 28px offset before weeks start.
    const cellStep = 14.0;
    const dayColOffset = 28.0;

    // Find the week index where each month first appears.
    // _yearData has 53 weeks starting from the current week ~1 year ago.
    // We approximate: month i starts at week floor(i * 365/12 / 7).
    List<double> monthOffsets = List.generate(12, (i) {
      final dayOfYear = (i * 365.0 / 12).round();
      final week = (dayOfYear / 7).floor().clamp(0, 52);
      return dayColOffset + week * cellStep;
    });

    return Column(
      children: [
        Screenshot(
          controller: _screenshotController,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded, size: 15, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${_calculateStreak()} day streak',
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_calculateTotalDays()}/365 days',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: const [0.0, 0.82, 1.0],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month labels pinned to exact week columns
                        SizedBox(
                          width: dayColOffset + 53 * cellStep,
                          height: 16,
                          child: Stack(
                            children: List.generate(12, (i) {
                              return Positioned(
                                left: monthOffsets[i],
                                top: 0,
                                child: Text(
                                  months[i],
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 11),
                                _DayLabel('Tue', tt, cs),
                                const SizedBox(height: 11),
                                _DayLabel('Thu', tt, cs),
                                const SizedBox(height: 11),
                                _DayLabel('Sat', tt, cs),
                                const SizedBox(height: 3),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Row(
                              children: yearData.map((week) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Column(
                                    children: week.map((level) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 3),
                                        child: Container(
                                          width: 11,
                                          height: 11,
                                          decoration: BoxDecoration(
                                            color: _getColorForLevel(level, cs),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Less', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
                    const SizedBox(width: 4),
                    _LegendBox(_getColorForLevel(0, cs)),
                    const SizedBox(width: 2),
                    _LegendBox(const Color(0xFFBBDEFB)),
                    const SizedBox(width: 2),
                    _LegendBox(const Color(0xFF90CAF9)),
                    const SizedBox(width: 2),
                    _LegendBox(const Color(0xFF42A5F5)),
                    const SizedBox(width: 2),
                    _LegendBox(const Color(0xFF1E88E5)),
                    const SizedBox(width: 4),
                    Text('More', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _shareStreak,
            icon: Icon(Icons.share_rounded, size: 16),
            label: Text('Share Streak'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  final TextTheme tt;
  final ColorScheme cs;

  const _DayLabel(this.label, this.tt, this.cs);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 11,
      width: 22,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 9,
          ),
        ),
      ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;

  const _LegendBox(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
