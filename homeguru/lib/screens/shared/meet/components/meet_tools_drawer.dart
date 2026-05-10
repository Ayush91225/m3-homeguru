import 'package:flutter/material.dart';
import '../whiteboard_screen.dart';
import '../study_timer_screen.dart';
import '../scientific_calculator_screen.dart';
import '../graphing_calculator_screen.dart';
import '../shared_notes_screen.dart';
import '../polls_screen.dart';
import '../library_screen.dart';
import '../slides_screen.dart';
import '../flashcards_screen.dart';
import '../youtube_player_screen.dart';
import '../ai_notes_screen.dart';
import '../academy_screen.dart';
import 'quiz_screen.dart';

class MeetToolsDrawer extends StatefulWidget {
  final Function(String type, dynamic content)? onShareMedia;

  const MeetToolsDrawer({super.key, this.onShareMedia});

  static Future<void> show(BuildContext context, {Function(String type, dynamic content)? onShareMedia}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tools',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => MeetToolsDrawer(onShareMedia: onShareMedia),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  State<MeetToolsDrawer> createState() => _MeetToolsDrawerState();
}

class _MeetToolsDrawerState extends State<MeetToolsDrawer> {
  String _searchQuery = '';

  bool _matchesSearch(String text) {
    if (_searchQuery.isEmpty) return true;
    return text.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Filter tools based on search
    final showWhiteboard = _matchesSearch('Whiteboard') || _matchesSearch('Draw together');
    final showTimer = _matchesSearch('Timer');
    final showQuiz = _matchesSearch('Quiz');
    final showSciCalc = _matchesSearch('Sci Calc') || _matchesSearch('Calculator');
    final showYouTube = _matchesSearch('YouTube') || _matchesSearch('Watch together');
    final showAINotes = _matchesSearch('AI Notes') || _matchesSearch('Transcription');
    final showAcademy = _matchesSearch('Academy') || _matchesSearch('Image library');
    final showGraphCalc = _matchesSearch('Graph Calc') || _matchesSearch('Desmos');
    final showSharedNotes = _matchesSearch('Shared Notes') || _matchesSearch('Collaborate');
    final showPolls = _matchesSearch('Polls') || _matchesSearch('Live Poll');
    final showLibrary = _matchesSearch('Library') || _matchesSearch('Documents');
    final showSlides = _matchesSearch('Slides') || _matchesSearch('Slideshow');
    final showFlashcards = _matchesSearch('Flashcards') || _matchesSearch('Study cards');

    final hasResults = showWhiteboard || showTimer || showQuiz || showSciCalc || 
                       showYouTube || showAINotes || showAcademy || showGraphCalc || 
                       showSharedNotes || showPolls || showLibrary || showSlides || showFlashcards;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screenWidth * 0.88,
          height: double.infinity,
          decoration: BoxDecoration(
            color: cs.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search tools...',
                        hintStyle: tt.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded,
                                    color: cs.onSurfaceVariant),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: hasResults
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: Column(
                            children: [
                              // Hero Pill: Whiteboard
                              if (showWhiteboard)...[
                                _HeroPill(
                                  icon: Icons.brush_rounded,
                                  iconColor: cs.primary,
                                  iconBg: cs.primaryContainer,
                                  title: 'Whiteboard',
                                  subtitle: 'Draw together in real-time',
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Quick Action Circles
                              if (showTimer || showQuiz || showSciCalc)...[
                                Row(
                                  children: [
                                    if (showTimer)
                                      Expanded(
                                        child: _CircleButton(
                                          icon: Icons.timer_rounded,
                                          label: 'Timer',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => StudyTimerScreen(
                                                  onClose: () => Navigator.pop(ctx),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (showTimer && (showQuiz || showSciCalc))
                                      const SizedBox(width: 8),
                                    if (showQuiz)
                                      Expanded(
                                        child: _CircleButton(
                                          icon: Icons.quiz_rounded,
                                          label: 'Quiz',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => Scaffold(
                                                  appBar: AppBar(
                                                    title: const Text('Quiz'),
                                                    leading: IconButton(
                                                      icon: const Icon(Icons.close),
                                                      onPressed: () => Navigator.pop(ctx),
                                                    ),
                                                  ),
                                                  body: const QuizScreen(isHost: true),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (showQuiz && showSciCalc)
                                      const SizedBox(width: 8),
                                    if (showSciCalc)
                                      Expanded(
                                        child: _CircleButton(
                                          icon: Icons.calculate_rounded,
                                          label: 'Sci Calc',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => ScientificCalculatorScreen(
                                                  onClose: () => Navigator.pop(ctx),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Tool Cards
                              if (showYouTube || showAINotes)...[
                                Row(
                                  children: [
                                    if (showYouTube)
                                      Expanded(
                                        child: _RectCard(
                                          icon: Icons.play_circle_rounded,
                                          iconColor: cs.error,
                                          iconBg: cs.errorContainer,
                                          title: 'YouTube',
                                          subtitle: 'Watch together',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => Scaffold(
                                                  appBar: AppBar(
                                                    title: const Text('YouTube'),
                                                    leading: IconButton(
                                                      icon: const Icon(Icons.close),
                                                      onPressed: () => Navigator.pop(ctx),
                                                    ),
                                                  ),
                                                  body: const YouTubePlayerScreen(),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (showYouTube && showAINotes)
                                      const SizedBox(width: 8),
                                    if (showAINotes)
                                      Expanded(
                                        child: _RectCard(
                                          icon: Icons.psychology_rounded,
                                          iconColor: cs.tertiary,
                                          iconBg: cs.tertiaryContainer,
                                          title: 'AI Notes',
                                          subtitle: 'Transcription',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => const AINotesScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Hero Pill: Academy
                              if (showAcademy) ...[
                                _HeroPill(
                                  icon: Icons.menu_book_rounded,
                                  iconColor: cs.secondary,
                                  iconBg: cs.secondaryContainer,
                                  title: 'Academy',
                                  subtitle: 'Browse image library',
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await Future.delayed(const Duration(milliseconds: 100));
                                    if (!context.mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => AcademyScreen(
                                          onShareMedia: widget.onShareMedia,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Utility Cards
                              if (showGraphCalc || showSharedNotes) ...[
                                Row(
                                  children: [
                                    if (showGraphCalc)
                                      Expanded(
                                        child: _RectCard(
                                          icon: Icons.show_chart_rounded,
                                          iconColor: cs.primary,
                                          iconBg: cs.primaryContainer,
                                          title: 'Graph Calc',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => GraphingCalculatorScreen(
                                                  onClose: () => Navigator.pop(ctx),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (showGraphCalc && showSharedNotes)
                                      const SizedBox(width: 8),
                                    if (showSharedNotes)
                                      Expanded(
                                        child: _RectCard(
                                          icon: Icons.note_alt_rounded,
                                          iconColor: cs.tertiary,
                                          iconBg: cs.tertiaryContainer,
                                          title: 'Shared Notes',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => const SharedNotesScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Small Utility Circles
                              if (showPolls || showLibrary || showSlides) ...[
                                Row(
                                  children: [
                                    if (showPolls)
                                      Expanded(
                                        child: _CircleButton(
                                          icon: Icons.bar_chart_rounded,
                                          label: 'Polls',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => const PollsScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (showPolls && (showLibrary || showSlides))
                                      const SizedBox(width: 8),
                                    if (showLibrary)
                                      Expanded(
                                        child: _CircleButton(
                                          icon: Icons.folder_rounded,
                                          label: 'Library',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => const LibraryScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (showLibrary && showSlides)
                                      const SizedBox(width: 8),
                                    if (showSlides)
                                      Expanded(
                                        child: _CircleButton(
                                          icon: Icons.monitor_rounded,
                                          label: 'Slides',
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            if (!context.mounted) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => const SlidesScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Flashcards Card
                              if (showFlashcards)
                                _RectCard(
                                  icon: Icons.style_rounded,
                                  iconColor: cs.secondary,
                                  iconBg: cs.secondaryContainer,
                                  title: 'Flashcards',
                                  subtitle: 'Study cards',
                                  fullWidth: true,
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await Future.delayed(const Duration(milliseconds: 100));
                                    if (!context.mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => const FlashcardsScreen(),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 48, color: cs.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text(
                                'No tools found',
                                style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Hero Pill - Large full-width button
class _HeroPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _HeroPill({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () async {
          if (title == 'Whiteboard') {
            Navigator.pop(context);
            await Future.delayed(const Duration(milliseconds: 100));
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => WhiteboardScreen(
                  onClose: () => Navigator.pop(ctx),
                ),
              ),
            );
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Circle Button - Small circular quick action
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _CircleButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(100),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: cs.onSurfaceVariant, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Rectangular Card - Tool card with icon and text
class _RectCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final bool fullWidth;
  final VoidCallback? onTap;

  const _RectCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    this.fullWidth = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
