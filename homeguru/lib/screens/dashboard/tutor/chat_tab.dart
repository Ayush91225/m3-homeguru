import 'package:flutter/material.dart';
import '../../shared/chat/chat_screen.dart';

class TutorChatTab extends StatelessWidget {
  const TutorChatTab({super.key});

  @override
  Widget build(BuildContext context) => const ChatScreen(isTutor: true);
}
