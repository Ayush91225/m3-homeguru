enum TutorRequestType { paid, demo, reschedule }
enum TutorRequestStatus { pending, accepted, declined }

class TutorBookingRequest {
  final String id;
  final String studentName;
  final String studentImage;
  final String subject;
  final String level;
  final TutorRequestType type;
  final TutorRequestStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? preferredSlot;
  final String? schedule;
  final int? totalSessions;
  final double? perHourRate;
  final int? classesPerWeek;
  final double? totalPrice;
  final double? inHandAmount;
  final String? note;
  final DateTime? originalDate;
  final String? originalTime;
  final DateTime? newDate;
  final String? newTime;

  const TutorBookingRequest({
    required this.id,
    required this.studentName,
    required this.studentImage,
    required this.subject,
    required this.level,
    required this.type,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.preferredSlot,
    this.schedule,
    this.totalSessions,
    this.perHourRate,
    this.classesPerWeek,
    this.totalPrice,
    this.inHandAmount,
    this.note,
    this.originalDate,
    this.originalTime,
    this.newDate,
    this.newTime,
  });
}
