import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/dashboard/learner/booking/book.dart';
import '../../services/demo_eligibility_service.dart';

/// Reusable action sheet for tutor interactions
/// Shows options: Book Class, View Profile
class TutorActionSheet extends StatelessWidget {
  final String tutorId;
  final String tutorName;
  final String tutorImage;
  final bool isVerified;
  final String primarySubject;
  final double tutorRating;
  final int tutorStudents;
  final String tutorLocation;
  final Map<String, int> tutorPricing;
  final List<dynamic> tutorRates;
  final List<dynamic> tutorLanguages;
  final List<dynamic> tutorAvailability;

  const TutorActionSheet({
    super.key,
    required this.tutorId,
    required this.tutorName,
    required this.tutorImage,
    this.isVerified = false,
    this.primarySubject = '',
    this.tutorRating = 0,
    this.tutorStudents = 0,
    this.tutorLocation = '',
    this.tutorPricing = const {},
    this.tutorRates = const [],
    this.tutorLanguages = const [],
    this.tutorAvailability = const [],
  });

  /// Show the action sheet
  static void show(
    BuildContext context, {
    required String tutorId,
    required String tutorName,
    required String tutorImage,
    bool isVerified = false,
    String primarySubject = '',
    double tutorRating = 0,
    int tutorStudents = 0,
    String tutorLocation = '',
    Map<String, int> tutorPricing = const {},
    List<dynamic> tutorRates = const [],
    List<dynamic> tutorLanguages = const [],
    List<dynamic> tutorAvailability = const [],
  }) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TutorActionSheet(
        tutorId: tutorId,
        tutorName: tutorName,
        tutorImage: tutorImage,
        isVerified: isVerified,
        primarySubject: primarySubject,
        tutorRating: tutorRating,
        tutorStudents: tutorStudents,
        tutorLocation: tutorLocation,
        tutorPricing: tutorPricing,
        tutorRates: tutorRates,
        tutorLanguages: tutorLanguages,
        tutorAvailability: tutorAvailability,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(tutorImage),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tutorName,
                            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (isVerified)
                          Icon(Icons.verified_rounded, size: 16, color: cs.primary),
                      ],
                    ),
                    if (primarySubject.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        primarySubject,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              // Check demo eligibility
              bool isPaidDemo = false;
              int demoPrice = 99;
              
              try {
                final prefs = await SharedPreferences.getInstance();
                final learnerId = prefs.getString('userId') ?? '';
                
                if (learnerId.isNotEmpty) {
                  final eligibility = await DemoEligibilityService.checkEligibility(
                    learnerId: learnerId,
                    tutorId: tutorId,
                  );
                  isPaidDemo = eligibility['isPaidDemo'] ?? false;
                  demoPrice = eligibility['demoPrice'] ?? 99;
                }
              } catch (e) {
                print('Error checking eligibility: $e');
              }
              
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingPage(
                      tutorId: tutorId,
                      tutorName: tutorName,
                      tutorImage: tutorImage,
                      tutorRating: tutorRating,
                      tutorStudents: tutorStudents,
                      tutorLocation: tutorLocation,
                      tutorPricing: tutorPricing,
                      tutorRates: tutorRates,
                      tutorLanguages: tutorLanguages,
                      tutorAvailability: tutorAvailability,
                      isPaidDemo: isPaidDemo,
                      demoPrice: demoPrice,
                    ),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              minimumSize: const Size.fromHeight(56),
            ),
            icon: const Icon(Icons.calendar_today_rounded),
            label: const Text('Book Class'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to tutor profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tutor profile coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            icon: const Icon(Icons.person_outline_rounded),
            label: const Text('View Profile'),
          ),
        ],
      ),
    );
  }
}
