import 'package:flutter/material.dart';
import 'package:homeguru/widgets/schedule/calendar_app.dart';

class TutorScheduleTab extends StatelessWidget {
  const TutorScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalendarApp(isTutor: true);
  }
}
