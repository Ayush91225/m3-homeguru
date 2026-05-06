import 'package:flutter/material.dart';
import 'calendar_types.dart';

class RescheduleSheet extends StatefulWidget {
  final CalendarEvent event;

  const RescheduleSheet({super.key, required this.event});

  @override
  State<RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<RescheduleSheet> {
  DateTime? _selectedDate;
  int? _selectedTimeSlot;
  final List<String> _timeSlots = [
    '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM',
    '5:00 PM', '6:00 PM', '7:00 PM', '8:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.event.date;
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
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Icon(Icons.schedule_rounded, color: cs.primary),
              const SizedBox(width: 12),
              Text('Reschedule Class', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Request will be sent to tutor. Class will be rescheduled only if tutor accepts.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Select Date', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 20, color: cs.onSurface),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select date',
                    style: tt.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Select Time', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTimeSlot == index;
                return InkWell(
                  onTap: () => setState(() => _selectedTimeSlot = index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? cs.primary : cs.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _timeSlots[index],
                        style: tt.labelMedium?.copyWith(
                          color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _selectedDate != null && _selectedTimeSlot != null
                      ? () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reschedule request sent to tutor'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
