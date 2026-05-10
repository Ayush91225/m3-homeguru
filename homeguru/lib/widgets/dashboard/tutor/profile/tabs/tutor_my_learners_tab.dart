import 'package:flutter/material.dart';
import '../../my_learners.dart';

class TutorMyLearnersTab extends StatelessWidget {
  const TutorMyLearnersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: MyLearners(showAll: true),
    );
  }
}
