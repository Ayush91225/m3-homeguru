import 'package:flutter/material.dart';
import 'dart:async';

class StudyTimerScreen extends StatefulWidget {
  final VoidCallback onClose;

  const StudyTimerScreen({super.key, required this.onClose});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  int _totalSeconds = 25 * 60;
  int _remaining = 25 * 60;
  bool _isActive = false;
  String _mode = 'focus'; // 'focus' or 'break'
  int _sessions = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _presets = [
    {'label': '15m', 'minutes': 15},
    {'label': '25m', 'minutes': 25},
    {'label': '45m', 'minutes': 45},
    {'label': '60m', 'minutes': 60},
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_remaining <= 1) {
              _isActive = false;
              _timer?.cancel();
              
              // Switch mode
              final nextMode = _mode == 'focus' ? 'break' : 'focus';
              final nextTotal = nextMode == 'focus' ? 25 * 60 : 5 * 60;
              final nextSessions = _mode == 'focus' ? _sessions + 1 : _sessions;
              
              _mode = nextMode;
              _totalSeconds = nextTotal;
              _remaining = nextTotal;
              _sessions = nextSessions;
            } else {
              _remaining--;
            }
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _reset() {
    setState(() {
      _isActive = false;
      _remaining = _totalSeconds;
      _timer?.cancel();
    });
  }

  void _setPreset(int minutes) {
    setState(() {
      _isActive = false;
      _timer?.cancel();
      _totalSeconds = minutes * 60;
      _remaining = minutes * 60;
      _mode = 'focus';
    });
  }

  void _setBreak() {
    setState(() {
      _isActive = false;
      _timer?.cancel();
      _totalSeconds = 5 * 60;
      _remaining = 5 * 60;
      _mode = 'break';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mins = _remaining ~/ 60;
    final secs = _remaining % 60;
    final pct = _totalSeconds > 0 ? ((_totalSeconds - _remaining) / _totalSeconds) : 0.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _mode == 'focus' ? colorScheme.primaryContainer : colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _mode == 'focus' ? Icons.psychology : Icons.coffee,
                size: 16,
                color: _mode == 'focus' ? colorScheme.onPrimaryContainer : colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Study Timer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  _mode == 'focus' ? 'Focus mode' : 'Break time',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _mode == 'focus' ? colorScheme.primary : colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: _mode == 'break' ? Border.all(color: colorScheme.tertiary.withValues(alpha: 0.2)) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _mode == 'focus' ? Icons.psychology : Icons.coffee,
                    size: 12,
                    color: _mode == 'focus' ? colorScheme.onPrimary : colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _mode == 'focus' ? 'FOCUS' : 'BREAK',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: _mode == 'focus' ? colorScheme.onPrimary : colorScheme.onTertiaryContainer,
                    ),
                  ),
                  if (_sessions > 0) ...[
                    Text(
                      ' · $_sessions done',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: (_mode == 'focus' ? colorScheme.onPrimary : colorScheme.onTertiaryContainer).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Circular timer
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        _mode == 'focus' ? colorScheme.primary : colorScheme.tertiary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w300,
                          color: colorScheme.onSurface,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isActive ? 'RUNNING' : _remaining == _totalSeconds ? 'READY' : 'PAUSED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset
                IconButton(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: colorScheme.outline,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    minimumSize: const Size(44, 44),
                  ),
                ),
                const SizedBox(width: 16),
                // Play/Pause
                IconButton(
                  onPressed: _toggle,
                  icon: Icon(_isActive ? Icons.pause : Icons.play_arrow, size: 26),
                  style: IconButton.styleFrom(
                    backgroundColor: _mode == 'focus' ? colorScheme.primary : colorScheme.tertiary,
                    foregroundColor: _mode == 'focus' ? colorScheme.onPrimary : colorScheme.onTertiary,
                    minimumSize: const Size(64, 64),
                  ),
                ),
                const SizedBox(width: 16),
                // Break
                IconButton(
                  onPressed: _setBreak,
                  icon: const Icon(Icons.coffee, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: _mode == 'break' ? colorScheme.tertiaryContainer : Colors.transparent,
                    foregroundColor: _mode == 'break' ? colorScheme.onTertiaryContainer : colorScheme.outline,
                    side: BorderSide(
                      color: _mode == 'break' ? colorScheme.tertiary : colorScheme.outlineVariant,
                    ),
                    minimumSize: const Size(44, 44),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Presets
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _presets.map((p) {
                final isSelected = _totalSeconds == p['minutes'] * 60 && _mode == 'focus';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () => _setPreset(p['minutes']),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
                      foregroundColor: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                      side: BorderSide(
                        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      p['label'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
