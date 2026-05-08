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
    rating: 4.9,
    students: 45,
    location: 'Delhi',
    pricing: {'Mathematics': 800, 'Physics': 750},
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
    rating: 4.8,
    students: 38,
    location: 'Mumbai',
    pricing: {'Physics': 750, 'Chemistry': 700},
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
    rating: 4.9,
    students: 62,
    location: 'Bangalore',
    pricing: {'English': 650},
  ),
  ChatTutor(
    id: '4',
    name: 'Karan Mehta',
    subject: 'Chemistry',
    avatarUrl: 'https://i.pravatar.cc/150?img=68',
    lastMessage: 'Great work on the last assignment! 🎉',
    time: 'Yesterday',
    rating: 4.7,
    students: 51,
    location: 'Pune',
    pricing: {'Chemistry': 700, 'Biology': 650},
  ),
  ChatTutor(
    id: '5',
    name: 'Sneha Pillai',
    subject: 'Biology',
    avatarUrl: 'https://i.pravatar.cc/150?img=25',
    lastMessage: 'I have shared the notes in the chat.',
    time: 'Mon',
    isOnline: true,
    rating: 4.8,
    students: 55,
    location: 'Chennai',
    pricing: {'Biology': 850, 'Chemistry': 800},
  ),
  ChatTutor(
    id: '6',
    name: 'Amit Joshi',
    subject: 'History',
    avatarUrl: 'https://i.pravatar.cc/150?img=53',
    lastMessage: 'Let me know if you have any doubts.',
    time: 'Sun',
    rating: 4.6,
    students: 31,
    location: 'Jaipur',
    pricing: {'History': 500, 'Political Science': 500},
  ),
];

// Learner seed data for tutors
final seedLearnerInbox = [
  ChatTutor(
    id: 'l1',
    name: 'Aarav Kumar',
    subject: 'Class 12 - JEE',
    avatarUrl: 'https://i.pravatar.cc/150?img=33',
    lastMessage: 'Thank you for the session! Can we schedule another one?',
    time: '11:20 AM',
    unread: 1,
    isOnline: true,
    isVerified: false,
    rating: 0,
    students: 0,
    location: 'Delhi',
    pricing: {},
  ),
  ChatTutor(
    id: 'l2',
    name: 'Diya Patel',
    subject: 'Class 10 - CBSE',
    avatarUrl: 'https://i.pravatar.cc/150?img=45',
    lastMessage: 'I need help with quadratic equations.',
    time: '10:05 AM',
    unread: 2,
    isOnline: false,
    isVerified: false,
    rating: 0,
    students: 0,
    location: 'Mumbai',
    pricing: {},
  ),
  ChatTutor(
    id: 'l3',
    name: 'Rohan Singh',
    subject: 'Class 11 - NEET',
    avatarUrl: 'https://i.pravatar.cc/150?img=51',
    lastMessage: 'Can you explain the organic chemistry chapter again?',
    time: 'Yesterday',
    isOnline: true,
    isVerified: false,
    rating: 0,
    students: 0,
    location: 'Bangalore',
    pricing: {},
  ),
  ChatTutor(
    id: 'l4',
    name: 'Ananya Reddy',
    subject: 'Class 9 - ICSE',
    avatarUrl: 'https://i.pravatar.cc/150?img=26',
    lastMessage: 'The homework was really helpful!',
    time: 'Yesterday',
    isOnline: false,
    isVerified: false,
    rating: 0,
    students: 0,
    location: 'Hyderabad',
    pricing: {},
  ),
];

final seedLearnerPast = [
  ChatTutor(
    id: 'l5',
    name: 'Ishaan Sharma',
    subject: 'Class 12 - Boards',
    avatarUrl: 'https://i.pravatar.cc/150?img=60',
    lastMessage: 'Thanks for all your help! I passed with 95%!',
    time: '2 weeks ago',
    isPast: true,
    isVerified: false,
    rating: 0,
    students: 0,
    location: 'Pune',
    pricing: {},
  ),
];

final seedLearnerArchived = [
  ChatTutor(
    id: 'l6',
    name: 'Kavya Menon',
    subject: 'Class 8 - CBSE',
    avatarUrl: 'https://i.pravatar.cc/150?img=29',
    lastMessage: 'See you next year!',
    time: '1 month ago',
    isVerified: false,
    rating: 0,
    students: 0,
    location: 'Kochi',
    pricing: {},
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
    rating: 4.9,
    students: 44,
    location: 'Hyderabad',
    pricing: {'Python': 1000, 'Machine Learning': 1200},
  ),
  ChatTutor(
    id: '8',
    name: 'Vikram Singh',
    subject: 'Economics',
    avatarUrl: 'https://i.pravatar.cc/150?img=15',
    lastMessage: 'I specialise in JEE Economics. Interested?',
    time: '5h ago',
    isPast: true,
    rating: 4.7,
    students: 34,
    location: 'Delhi',
    pricing: {'Economics': 950, 'History': 900},
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
    rating: 4.8,
    students: 29,
    location: 'Kochi',
    pricing: {'Sanskrit': 600},
  ),
];
