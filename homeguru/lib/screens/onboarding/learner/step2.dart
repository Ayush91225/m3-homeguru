import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LearnerStep2Body extends StatefulWidget {
  const LearnerStep2Body({super.key, required this.onNext});
  final void Function(String source) onNext;

  @override
  State<LearnerStep2Body> createState() => _LearnerStep2BodyState();
}

class _LearnerStep2BodyState extends State<LearnerStep2Body> {
  String? _selected;

  static const _options = [
    _Option('instagram', 'Instagram',        FontAwesomeIcons.instagram),
    _Option('youtube',   'YouTube',          FontAwesomeIcons.youtube),
    _Option('google',    'Google',           FontAwesomeIcons.google),
    _Option('friend',    'Friend / Family',  FontAwesomeIcons.userGroup),
    _Option('school',    'School / College', FontAwesomeIcons.graduationCap),
    _Option('other',     'Other',            FontAwesomeIcons.ellipsis),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: _options.map((opt) {
                final selected = _selected == opt.value;
                final fg = selected ? cs.onPrimaryContainer : cs.onSurface;
                final bg = selected ? cs.primaryContainer : cs.surfaceContainerLow;

                return Material(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = opt.value);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -12,
                            bottom: -12,
                            child: FaIcon(opt.icon, size: 80, color: fg.withValues(alpha: 0.07)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FaIcon(opt.icon, size: 26, color: fg),
                                Text(opt.label, style: tt.titleSmall?.copyWith(color: fg, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: FilledButton(
            onPressed: _selected == null ? null : () {
              HapticFeedback.mediumImpact();
              widget.onNext(_selected!);
            },
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}

class _Option {
  const _Option(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}
