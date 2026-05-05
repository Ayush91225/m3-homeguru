// ─── Shared models & seed data ────────────────────────────────────────────────

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isMe,
    this.imageUrl,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  final String text;
  final bool isMe;
  final String? imageUrl;
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
}

final seedInbox = [
  ChatTutor(
    id: '1',
    name: 'Priya Sharma',
    subject: 'Mathematics',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    lastMessage: 'Sure! I can help you with integration by parts.',
    time: '10:42 AM',
    unread: 2,
    isOnline: true,
    isVerified: true,
  ),
  ChatTutor(
    id: '2',
    name: 'Rahul Verma',
    subject: 'Physics',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    lastMessage: 'The session is confirmed for tomorrow at 5 PM.',
    time: '9:15 AM',
    isOnline: true,
    isVerified: true,
  ),
  ChatTutor(
    id: '3',
    name: 'Ananya Iyer',
    subject: 'English Literature',
    avatarUrl: 'https://i.pravatar.cc/150?img=32',
    lastMessage: 'Please go through Chapter 4 before our next class.',
    time: 'Yesterday',
    unread: 1,
    isVerified: true,
  ),
  ChatTutor(
    id: '4',
    name: 'Karan Mehta',
    subject: 'Chemistry',
    avatarUrl: 'https://i.pravatar.cc/150?img=68',
    lastMessage: 'Great work on the last assignment! 🎉',
    time: 'Yesterday',
  ),
  ChatTutor(
    id: '5',
    name: 'Sneha Pillai',
    subject: 'Biology',
    avatarUrl: 'https://i.pravatar.cc/150?img=25',
    lastMessage: 'I have shared the notes in the chat.',
    time: 'Mon',
    isOnline: true,
  ),
  ChatTutor(
    id: '6',
    name: 'Amit Joshi',
    subject: 'History',
    avatarUrl: 'https://i.pravatar.cc/150?img=53',
    lastMessage: 'Let me know if you have any doubts.',
    time: 'Sun',
  ),
];

final seedPast = [
  ChatTutor(
    id: '7',
    name: 'Deepa Nair',
    subject: 'Computer Science',
    avatarUrl: 'https://i.pravatar.cc/150?img=44',
    lastMessage: 'Hi! I saw your profile and would love to teach you Python.',
    time: '2h ago',
    isVerified: true,
    isPast: true,
  ),
  ChatTutor(
    id: '8',
    name: 'Vikram Singh',
    subject: 'Economics',
    avatarUrl: 'https://i.pravatar.cc/150?img=15',
    lastMessage: 'I specialise in JEE Economics. Interested?',
    time: '5h ago',
    isPast: true,
  ),
];

final seedArchived = [
  ChatTutor(
    id: '9',
    name: 'Meera Krishnan',
    subject: 'Sanskrit',
    avatarUrl: 'https://i.pravatar.cc/150?img=38',
    lastMessage: 'It was a pleasure teaching you!',
    time: '3 weeks ago',
    isVerified: true,
  ),
];
