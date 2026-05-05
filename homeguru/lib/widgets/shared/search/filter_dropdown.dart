import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final Function(String?) onSelect;

  const FilterDropdown({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  static void show(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String? selected,
    required Function(String?) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterDropdown(
        title: title,
        options: options,
        selected: selected,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = selected == option;
                return ListTile(
                  title: Text(option),
                  trailing: isSelected ? Icon(Icons.check_rounded, color: cs.primary) : null,
                  selected: isSelected,
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(option);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
