import 'package:flutter/material.dart';
import '../../../services/tutor_data_model.dart';
import 'reports/payout_report.dart';
import 'reports/earnings_report.dart';
import 'reports/sessions_report.dart';
import 'reports/students_report.dart';
import 'reports/attendance_report.dart';
import 'reports/ratings_report.dart';
import 'reports/subjects_report.dart';
import 'reports/time_slots_report.dart';
import 'reports/conversion_report.dart';

enum ReportType {
  payout,
  earnings,
  sessions,
  students,
  attendance,
  ratings,
  subjects,
  timeSlots,
  conversion,
}

class TutorReports extends StatefulWidget {
  const TutorReports({super.key});

  @override
  State<TutorReports> createState() => _TutorReportsState();
}

class _TutorReportsState extends State<TutorReports> {
  ReportType _selectedReport = ReportType.payout;

  String _getReportLabel(ReportType type) {
    switch (type) {
      case ReportType.payout:
        return 'Payout';
      case ReportType.earnings:
        return 'Earnings';
      case ReportType.sessions:
        return 'Sessions';
      case ReportType.students:
        return 'Students';
      case ReportType.attendance:
        return 'Attendance';
      case ReportType.ratings:
        return 'Ratings';
      case ReportType.subjects:
        return 'Subjects';
      case ReportType.timeSlots:
        return 'Time Slots';
      case ReportType.conversion:
        return 'Conversion';
    }
  }

  IconData _getReportIcon(ReportType type) {
    switch (type) {
      case ReportType.payout:
        return Icons.payments_rounded;
      case ReportType.earnings:
        return Icons.currency_rupee_rounded;
      case ReportType.sessions:
        return Icons.event_rounded;
      case ReportType.students:
        return Icons.people_rounded;
      case ReportType.attendance:
        return Icons.check_circle_rounded;
      case ReportType.ratings:
        return Icons.star_rounded;
      case ReportType.subjects:
        return Icons.menu_book_rounded;
      case ReportType.timeSlots:
        return Icons.schedule_rounded;
      case ReportType.conversion:
        return Icons.trending_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.assessment_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Reports',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              _ReportSelector(
                selectedReport: _selectedReport,
                onReportChanged: (type) {
                  setState(() => _selectedReport = type);
                },
                cs: cs,
                tt: tt,
                getLabel: _getReportLabel,
                getIcon: _getReportIcon,
              ),
            ],
          ),
        ),
        _buildReportContent(cs, tt),
      ],
    );
  }

  Widget _buildReportContent(ColorScheme cs, TextTheme tt) {
    final data = TutorData.of(context);
    final reports = data.raw['reports'] as Map<String, dynamic>? ?? {};

    switch (_selectedReport) {
      case ReportType.payout:
        return PayoutReport(cs: cs, tt: tt, data: reports['payout'] as Map<String, dynamic>? ?? {});
      case ReportType.earnings:
        return EarningsReport(cs: cs, tt: tt, data: reports['earnings'] as Map<String, dynamic>? ?? {});
      case ReportType.sessions:
        return SessionsReport(cs: cs, tt: tt, data: reports['sessions'] as Map<String, dynamic>? ?? {});
      case ReportType.students:
        return StudentsReport(cs: cs, tt: tt, data: reports['students'] as Map<String, dynamic>? ?? {});
      case ReportType.attendance:
        return AttendanceReport(cs: cs, tt: tt, data: reports['attendance'] as Map<String, dynamic>? ?? {});
      case ReportType.ratings:
        return RatingsReport(cs: cs, tt: tt, data: reports['ratings'] as Map<String, dynamic>? ?? {});
      case ReportType.subjects:
        return SubjectsReport(cs: cs, tt: tt, data: reports['subjects'] as Map<String, dynamic>? ?? {});
      case ReportType.timeSlots:
        return TimeSlotsReport(cs: cs, tt: tt, data: reports['timeSlots'] as Map<String, dynamic>? ?? {});
      case ReportType.conversion:
        return ConversionReport(cs: cs, tt: tt, data: reports['conversion'] as Map<String, dynamic>? ?? {});
    }
  }
}

class _ReportSelector extends StatelessWidget {
  final ReportType selectedReport;
  final Function(ReportType) onReportChanged;
  final ColorScheme cs;
  final TextTheme tt;
  final String Function(ReportType) getLabel;
  final IconData Function(ReportType) getIcon;

  const _ReportSelector({
    required this.selectedReport,
    required this.onReportChanged,
    required this.cs,
    required this.tt,
    required this.getLabel,
    required this.getIcon,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(cs.surfaceContainer),
        elevation: const WidgetStatePropertyAll(3),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        maximumSize: const WidgetStatePropertyAll(Size(200, 400)),
      ),
      menuChildren: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ReportType.values.map((type) => MenuItemButton(
                onPressed: () => onReportChanged(type),
                leadingIcon: Icon(getIcon(type), size: 18, color: cs.onSurface),
                child: Text(getLabel(type), style: TextStyle(color: cs.onSurface)),
              )).toList(),
            ),
          ),
        ),
      ],
      builder: (context, controller, child) {
        return SizedBox(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: cs.tertiaryContainer,
                  foregroundColor: cs.onTertiaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(999),
                      bottomLeft: Radius.circular(999),
                    ),
                  ),
                  minimumSize: const Size(0, 36),
                  maximumSize: const Size(double.infinity, 36),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(getIcon(selectedReport), size: 14, color: cs.onTertiaryContainer),
                    const SizedBox(width: 6),
                    Text(
                      getLabel(selectedReport),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: cs.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: cs.onTertiaryContainer.withValues(alpha: 0.2),
              ),
              InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(999),
                  bottomRight: Radius.circular(999),
                ),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(999),
                      bottomRight: Radius.circular(999),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: cs.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
