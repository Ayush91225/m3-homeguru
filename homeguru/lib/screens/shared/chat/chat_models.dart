// ─── Shared models & seed data ────────────────────────────────────────────────

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isMe,
    this.imageUrl,
    this.isInCallMessage = false,
    this.meetingCode,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  final String text;
  final bool isMe;
  final String? imageUrl;
  final bool isInCallMessage;
  final String? meetingCode;
  final DateTime time;
}

class ChatTutor {
  const ChatTutor({
    required this.id,
    required this.name,
    required this.subject,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.isOnline = false,
    this.isVerified = false,
    this.isPast = false,
    this.rating = 0.0,
    this.students = 0,
    this.location = '',
    this.pricing = const {},
  });

  final String id;
  final String name;
  final String subject;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;
  final bool isVerified;
  final bool isPast;
  final double rating;
  final int students;
  final String location;
  final Map<String, int> pricing;
}

final seedInbox = <ChatTutor>[];

// Learner seed data for tutors — empty, populated from TutorData
final seedLearnerInbox = <ChatTutor>[];

final seedLearnerPast = <ChatTutor>[];

final seedLearnerArchived = <ChatTutor>[];

final seedPast = <ChatTutor>[];

final seedArchived = <ChatTutor>[];
