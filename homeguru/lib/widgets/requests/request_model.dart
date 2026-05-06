enum RequestType { demo, paid, paidDemo }
enum RequestStatus { pending, accepted, rejected }

class BookingRequest {
  final String id;
  final String tutor;
  final String tutorImage;
  final String subject;
  final String level;
  final RequestType type;
  final RequestStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? preferredSlot;
  final String? schedule;
  final int? sessionsBooked;
  final double? perHourPrice;
  final int? classesPerWeek;
  final int? durationMonths;
  final bool? isPaid;
  final DateTime? bookingAcceptedAt;
  final String? rejectionReason;

  const BookingRequest({
    required this.id,
    required this.tutor,
    required this.tutorImage,
    required this.subject,
    required this.level,
    required this.type,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.preferredSlot,
    this.schedule,
    this.sessionsBooked,
    this.perHourPrice,
    this.classesPerWeek,
    this.durationMonths,
    this.isPaid,
    this.bookingAcceptedAt,
    this.rejectionReason,
  });

  bool get isConfirmed {
    if (status != RequestStatus.accepted) return false;
    if (type == RequestType.demo) return true;
    return isPaid == true;
  }
}
