import 'package:flutter/material.dart';
import '../../my_tutors.dart';

class MyTutorsTab extends StatelessWidget {
  const MyTutorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: MyTutors(showAll: true),
    );
  }
}
