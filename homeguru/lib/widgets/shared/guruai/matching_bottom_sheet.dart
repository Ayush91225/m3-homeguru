import 'package:flutter/material.dart';

class MatchingBottomSheet extends StatefulWidget {
  const MatchingBottomSheet({super.key});

  @override
  State<MatchingBottomSheet> createState() => _MatchingBottomSheetState();
}

class _MatchingBottomSheetState extends State<MatchingBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _smallSuggestions = [
    'Maths tutor',
    'Under ₹500/hr',
    'English teacher',
    'Physics help',
  ];

  final List<String> _largeSuggestions = [
    'JEE preparation tutor',
    'NEET coaching expert',
    'IELTS speaking practice',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_controller.text.trim().isNotEmpty) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'What are you looking for?',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Describe your requirements...',
                  hintStyle: TextStyle(color: cs.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.arrow_forward_rounded, color: cs.primary),
                    onPressed: _submitRequest,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitRequest(),
                style: TextStyle(fontSize: 15, color: cs.onSurface),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _smallSuggestions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final suggestion = _smallSuggestions[index];
                  return ActionChip(
                    label: Text(suggestion, style: const TextStyle(fontSize: 13)),
                    onPressed: () => _selectSuggestion(suggestion),
                    backgroundColor: cs.surfaceContainerHighest,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _largeSuggestions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final suggestion = _largeSuggestions[index];
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () => _selectSuggestion(suggestion),
                    backgroundColor: cs.surfaceContainerHighest,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
