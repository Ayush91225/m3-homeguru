# Tutor Card Interaction Flow

## User Journey

```
┌─────────────────────────────────────────────────────────────────┐
│                         SEARCH TAB                              │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │  Tutor   │  │  Tutor   │  │  Tutor   │  │  Tutor   │      │
│  │  Card 1  │  │  Card 2  │  │  Card 3  │  │  Card 4  │      │
│  │          │  │          │  │          │  │          │      │
│  │  [TAP]   │  │          │  │          │  │          │      │
│  └────┬─────┘  └──────────┘  └──────────┘  └──────────┘      │
│       │                                                         │
│       │ Tap anywhere on card                                   │
│       ▼                                                         │
│  ┌─────────────────────────────────────────────────────┐      │
│  │         BOTTOM SHEET (Action Sheet)                 │      │
│  │  ─────────────────────────────────────────────      │      │
│  │                                                      │      │
│  │  ┌────┐  Priya Sharma ✓                            │      │
│  │  │ 👤 │  Mathematics                                │      │
│  │  └────┘                                             │      │
│  │                                                      │      │
│  │  ┌──────────────────────────────────────────────┐  │      │
│  │  │  📅  Book Class                              │  │      │
│  │  └──────────────────────────────────────────────┘  │      │
│  │                                                      │      │
│  │  ┌──────────────────────────────────────────────┐  │      │
│  │  │  👤  View Profile                            │  │      │
│  │  └──────────────────────────────────────────────┘  │      │
│  │                                                      │      │
│  └──────────────┬───────────────────┬──────────────────┘      │
│                 │                   │                          │
│                 │                   │                          │
└─────────────────┼───────────────────┼──────────────────────────┘
                  │                   │
                  │                   │
        ┌─────────▼─────────┐  ┌──────▼──────────┐
        │  BOOKING PAGE     │  │  TUTOR PROFILE  │
        │                   │  │  (Coming Soon)  │
        │  • Demo Mode      │  │                 │
        │  • Paid Mode      │  │  • Bio          │
        │  • Subject Select │  │  • Reviews      │
        │  • Slot Picker    │  │  • Experience   │
        │  • Schedule       │  │  • Subjects     │
        │  • Frequency      │  │  • Availability │
        │  • Message        │  │  • Gallery      │
        │                   │  │                 │
        └───────────────────┘  └─────────────────┘
```

## Component Breakdown

### 1. Tutor Card (Grid Item)
```
┌─────────────────────┐
│  ⭐ 4.9      ✓      │  ← Rating & Verified badge
│                     │
│    [Tutor Photo]    │  ← Image with overlay badges
│                     │
│  ₹800/hr            │  ← Price tag
├─────────────────────┤
│ Priya Sharma        │  ← Name
│ Mathematics         │  ← Primary subject
│ +1 more             │  ← Additional subjects
│ 8y exp              │  ← Experience
└─────────────────────┘
     ↓ TAP ANYWHERE
```

### 2. Action Sheet (Bottom Sheet)
```
┌─────────────────────────────────────┐
│            ────                     │  ← Drag handle
│                                     │
│  ┌────┐  Priya Sharma ✓           │  ← Avatar + Name
│  │ 👤 │  Mathematics                │     + Verification
│  └────┘                             │     + Subject
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📅  Book Class              │   │  ← Primary action
│  └─────────────────────────────┘   │     (FilledButton)
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 👤  View Profile            │   │  ← Secondary action
│  └─────────────────────────────┘   │     (OutlinedButton)
│                                     │
└─────────────────────────────────────┘
```

## Interaction Details

### Tap Behavior
- **Target**: Entire tutor card (whole carousel item)
- **Feedback**: Light haptic feedback
- **Action**: Opens bottom sheet with slide-up animation
- **Background**: Dimmed overlay (scrim)

### Bottom Sheet
- **Animation**: Slide up from bottom (Material motion)
- **Dismissal**: 
  - Tap outside (on scrim)
  - Swipe down on sheet
  - Tap back button
  - Select an option (auto-dismiss)
- **Height**: Wraps content (not full screen)
- **Corners**: Rounded top (28px radius)

### Button Actions

#### Book Class Button
- **Style**: FilledButton (primary color)
- **Icon**: Calendar icon (left)
- **Action**: 
  1. Close bottom sheet
  2. Navigate to BookingPage
  3. Pass tutor data (id, name, image, pricing, etc.)

#### View Profile Button
- **Style**: OutlinedButton (secondary)
- **Icon**: Person icon (left)
- **Action**: 
  1. Close bottom sheet
  2. Show "Coming soon" snackbar (temporary)
  3. TODO: Navigate to tutor profile page

## Design Specifications

### Colors (Material 3)
- **Sheet Background**: `cs.surface`
- **Drag Handle**: `cs.onSurfaceVariant` (40% opacity)
- **Primary Button**: `cs.primary` background, `cs.onPrimary` text
- **Secondary Button**: `cs.outline` border, `cs.onSurface` text
- **Verification Badge**: `cs.primary`

### Spacing
- **Sheet Padding**: 24px all sides
- **Drag Handle**: 40px width, 4px height
- **Top Spacing**: 20px below drag handle
- **Avatar Size**: 56px diameter (28px radius)
- **Avatar-Text Gap**: 16px
- **Button Height**: 56px minimum
- **Button Gap**: 12px between buttons

### Typography
- **Name**: `titleMedium`, fontWeight 700
- **Subject**: `bodySmall`, onSurfaceVariant color
- **Button Text**: `labelLarge`, fontWeight 700

## Code Structure

### TutorCard Widget
```dart
class TutorCard extends StatelessWidget {
  final Map<String, dynamic> tutor;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => _TutorActionSheet(
            tutor: tutor,
            subjects: subjects,
          ),
        );
      },
      child: // ... card UI
    );
  }
}
```

### Action Sheet Widget
```dart
class _TutorActionSheet extends StatelessWidget {
  final Map<String, dynamic> tutor;
  final List<dynamic> subjects;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          // Tutor info
          // Book Class button
          // View Profile button
        ],
      ),
    );
  }
}
```

## Benefits of This Approach

### User Experience
✅ **Clear Intent**: User sees options before committing to an action
✅ **Quick Access**: Both booking and profile are one tap away
✅ **Reversible**: Easy to dismiss without navigating away
✅ **Familiar Pattern**: Bottom sheets are standard in mobile apps
✅ **Visual Feedback**: Haptic + animation confirms interaction

### Technical
✅ **Flexible**: Easy to add more actions (Message, Share, Save, etc.)
✅ **Maintainable**: Separate widget for action sheet
✅ **Reusable**: Can be used from other places (search results, recommendations)
✅ **Performant**: Sheet only builds when needed
✅ **Accessible**: Proper focus management and screen reader support

### Design
✅ **Material 3**: Follows Material Design guidelines
✅ **Consistent**: Matches other sheets in app (payment, class details)
✅ **Branded**: Uses app's dynamic color scheme
✅ **Responsive**: Adapts to content and screen size
✅ **Polished**: Smooth animations and proper spacing

## Future Enhancements

### Additional Actions
- **Message Tutor**: Direct chat button
- **Save/Bookmark**: Add to favorites
- **Share**: Share tutor profile
- **Report**: Report inappropriate content
- **Compare**: Add to comparison list

### Enhanced Info
- **Quick Stats**: Show rating breakdown, response time
- **Availability**: Show next available slot
- **Pricing**: Show all subject prices
- **Reviews**: Show latest review snippet
- **Badges**: Show achievements, certifications

### Smart Features
- **Recommended**: Highlight if tutor is recommended for user
- **Discount**: Show if any offers available
- **Urgency**: Show if slots filling up fast
- **Match Score**: Show compatibility percentage
