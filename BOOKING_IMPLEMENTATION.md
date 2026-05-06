# Booking Page Implementation

## Overview
Implemented a comprehensive booking page that allows learners to book demo or paid classes with tutors. The page follows Material 3 design patterns and integrates seamlessly with the existing app architecture.

## File Structure
```
lib/screens/dashboard/learner/booking/
└── book.dart - Main booking page with demo/paid/paid-demo logic
```

## Features Implemented

### 1. Booking Modes
- **Demo Mode**: Book a demo class with slot selection
- **Paid Mode**: Book regular paid classes with schedule selection
- **Paid Demo**: Paid demo option when free demo is exhausted

### 2. Mode Toggle
- Segmented control in app bar to switch between Demo/Paid modes
- Badge display for free/paid demo status
- Automatic state reset when switching modes

### 3. Tutor Information Header
- Tutor avatar with cached network image
- Name with verification badge
- Selected subject display
- Rating, student count, location stats
- Hourly rate badge

### 4. Subject Selection
- Multi-subject support from tutor pricing map
- Chip-based selection UI
- Dynamic pricing based on selected subject

### 5. Level Input
- Text field for learner's current level
- Placeholder suggestions (Class 11 CBSE, JEE Aspirant, etc.)
- Optional field with edit icon

### 6. Slot Selection (Demo Mode)
- Date picker integration
- Time picker integration
- Selected slot display with formatted date/time

### 7. Schedule Selection (Paid Mode)
- Day selector with circular chips (M, T, W, T, F, S, S)
- Multi-day selection support
- Time picker for preferred class time
- Automatic classes per week calculation based on selected days

### 8. Frequency Configuration
- Classes per week stepper (1-7)
- Months stepper (1-12)
- Total sessions calculation
- Total price calculation for paid mode
- Summary card with calendar icon

### 9. Message Input
- Optional message text field
- Multi-line support (3 lines)
- Placeholder for goals and topics

### 10. Info Banners
- Contextual information based on booking mode
- Color-coded (primary for free, error for paid)
- Icons for visual clarity
- Different messages for demo/paid/paid-demo

### 11. Request Submission
- Validation before sending
- Loading state with circular progress indicator
- Haptic feedback on button press
- Success view after submission

### 12. Success View
- Full-screen success message
- Check icon in circular container
- Contextual message based on booking mode
- Done button to return to previous screen

## Data Flow

### Input Parameters
```dart
BookingPage({
  required String tutorId,
  required String tutorName,
  required String tutorImage,
  double tutorRating = 0,
  int tutorStudents = 0,
  String tutorBio = '',
  String tutorLocation = '',
  Map<String, int> tutorPricing = const {},
  bool canBookDemo = true,
  bool canBookPaid = true,
  bool isPaidDemo = false,
  int demoPrice = 0,
})
```

### State Management
- Local state using StatefulWidget
- TextEditingController for level and message inputs
- Boolean flags for mode, sending, sent states
- Nullable types for optional selections
- Lists for multi-selection (days)

### Validation Logic
```dart
bool get _canSend {
  if (_selectedSubjectIdx == null) return false;
  if (_demoMode) {
    return _selectedSlotKey != null;
  } else {
    return _selectedDays.isNotEmpty && _preferredTime != null;
  }
}
```

### Calculations
- Current price: Based on selected subject from pricing map
- Total sessions: classesPerWeek × months × 4
- Total price: currentPrice × totalSessions

## Integration Points

### 1. TutorCard Action Sheet
Updated `tutor_card.dart` to show a bottom sheet with options when tapped:
```dart
onTap: () {
  showModalBottomSheet(
    context: context,
    builder: (context) => _TutorActionSheet(
      tutor: tutor,
      subjects: subjects,
    ),
  );
}
```

**Bottom Sheet Options:**
- **Book Class** (FilledButton with calendar icon) → Opens BookingPage
- **View Profile** (OutlinedButton with person icon) → TODO: Navigate to profile

**Sheet Design:**
- Rounded top corners (28px radius)
- Drag handle at top
- Tutor avatar and name with verification badge
- Primary subject display
- Full-width action buttons (56px height)
- Material 3 colors throughout

### 2. Search Tab
Removed TODO comment since navigation is now handled in TutorCard.

## UI/UX Patterns

### Material 3 Design
- Dynamic color scheme usage throughout
- Surface containers for elevated sections
- Outline variants for subtle borders
- Proper color roles (primary, onPrimary, surface, etc.)

### Typography
- Outfit font for headings (titleLarge, titleMedium, titleSmall)
- Inter font for body text
- Consistent font weights (w700 for bold, w600 for semibold)

### Spacing
- 20px padding for main content
- 12-16px spacing between sections
- 8px spacing for chips and small elements
- 56px minimum height for buttons

### Animations
- 200ms duration for mode toggle
- 200ms duration for chip selection
- Smooth transitions with AnimatedContainer
- Haptic feedback on interactions

### Components
- Stadium-shaped buttons (inherited from theme)
- Rounded containers (12-20px radius)
- Circular avatars and day selectors
- Outlined buttons for secondary actions

## Future Enhancements

### API Integration
Currently uses mock data and simulated API calls. To integrate with backend:

1. Replace `_sendRequest()` with actual API service call
2. Add error handling and retry logic
3. Implement payment gateway integration (Razorpay)
4. Add real-time slot availability checking
5. Implement tutor availability calendar

### Additional Features
- Tutor profile view before booking
- Slot availability calendar view
- Multiple subject selection
- Recurring schedule patterns
- Booking history
- Cancellation and rescheduling
- Payment method selection
- Discount code application

### Validation Improvements
- Level input validation
- Message character limit
- Slot conflict checking
- Minimum booking duration
- Maximum advance booking period

### Accessibility
- Screen reader support
- Keyboard navigation
- High contrast mode
- Font scaling support

## Testing Checklist

- [ ] Demo mode booking flow
- [ ] Paid mode booking flow
- [ ] Paid demo flow
- [ ] Mode switching
- [ ] Subject selection
- [ ] Slot selection
- [ ] Schedule selection
- [ ] Frequency configuration
- [ ] Form validation
- [ ] Success view
- [ ] Navigation back
- [ ] Error handling
- [ ] Loading states
- [ ] Responsive layout
- [ ] Dark mode support

## Dependencies

### Existing
- flutter/material.dart
- flutter/services.dart (HapticFeedback)
- cached_network_image (tutor avatar)

### Required for Full Implementation
- API service for booking requests
- Payment gateway SDK (Razorpay)
- Real-time database for slot availability
- Push notifications for booking updates

## Notes

- All UI follows existing app patterns
- Uses Material 3 dynamic color scheme
- Maintains consistency with payment_pending_sheet.dart
- Integrates with existing navigation structure
- Ready for backend integration
- Supports both demo and paid booking flows
- Handles paid demo scenario
- Calculates pricing dynamically
- Validates user input before submission
