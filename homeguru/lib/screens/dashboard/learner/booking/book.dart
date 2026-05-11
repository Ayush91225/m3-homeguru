import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookingPage extends StatefulWidget {
  final String tutorId;
  final String tutorName;
  final String tutorImage;
  final double tutorRating;
  final int tutorStudents;
  final String tutorBio;
  final String tutorLocation;
  final Map<String, int> tutorPricing;
  final List<dynamic> tutorRates;
  final List<dynamic> tutorLanguages;
  final bool canBookDemo;
  final bool canBookPaid;
  final bool isPaidDemo;
  final int demoPrice;

  const BookingPage({
    super.key,
    required this.tutorId,
    required this.tutorName,
    required this.tutorImage,
    this.tutorRating = 0,
    this.tutorStudents = 0,
    this.tutorBio = '',
    this.tutorLocation = '',
    this.tutorPricing = const {},
    this.tutorRates = const [],
    this.tutorLanguages = const [],
    this.canBookDemo = true,
    this.canBookPaid = true,
    this.isPaidDemo = false,
    this.demoPrice = 0,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool _demoMode = true;
  int? _selectedSubjectIdx;
  String? _selectedSlotKey;
  DateTime? _selectedSlotDate;
  int _classesPerWeek = 1;
  int _months = 1;
  List<int> _selectedDays = [];
  TimeOfDay? _preferredTime;
  bool _sending = false;
  bool _sent = false;

  final _levelController = TextEditingController();
  final _messageController = TextEditingController();

  List<String> get _subjects => widget.tutorPricing.keys.toList();

  int get _currentPrice {
    if (_selectedSubjectIdx == null) return 500;
    if (widget.tutorRates.isNotEmpty && _selectedSubjectIdx! < widget.tutorRates.length) {
      final rate = widget.tutorRates[_selectedSubjectIdx!] as Map<String, dynamic>;
      return rate['inr'] as int? ?? 500;
    }
    if (_selectedSubjectIdx! < _subjects.length) {
      return widget.tutorPricing[_subjects[_selectedSubjectIdx!]] ?? 500;
    }
    return 500;
  }

  int get _totalSessions => _classesPerWeek * _months * 4;
  int get _totalPrice => _currentPrice * _totalSessions;

  bool get _canSend {
    if (_selectedSubjectIdx == null) return false;
    if (_demoMode) {
      return _selectedSlotKey != null;
    } else {
      return _selectedDays.isNotEmpty && _preferredTime != null;
    }
  }

  @override
  void initState() {
    super.initState();
    _demoMode = widget.canBookDemo;
  }

  @override
  void dispose() {
    _levelController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _toggleMode(bool isDemoMode) {
    setState(() {
      _demoMode = isDemoMode;
      _selectedSlotKey = null;
      _selectedSlotDate = null;
      if (!isDemoMode) {
        _selectedDays = [1, 3, 5];
        _classesPerWeek = 3;
        _preferredTime = const TimeOfDay(hour: 17, minute: 0);
      } else {
        _selectedDays = [];
        _classesPerWeek = 1;
        _preferredTime = null;
      }
    });
  }

  Future<void> _sendRequest() async {
    if (!_canSend || _sending) return;
    
    HapticFeedback.mediumImpact();
    setState(() => _sending = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _sending = false;
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_sent) {
      return _buildSuccessView(cs, tt);
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _demoMode ? 'Book Demo' : 'Book Class',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (widget.canBookDemo && widget.canBookPaid)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeTab('Demo', true, cs, tt),
                    _buildModeTab('Paid', false, cs, tt),
                  ],
                ),
              ),
            )
          else if (widget.canBookDemo)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.isPaidDemo
                      ? cs.errorContainer.withValues(alpha: 0.5)
                      : cs.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isPaidDemo ? Icons.currency_rupee_rounded : Icons.card_giftcard_rounded,
                      size: 14,
                      color: widget.isPaidDemo ? cs.error : cs.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isPaidDemo ? '₹${widget.demoPrice}' : 'Free',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.isPaidDemo ? cs.error : cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildTutorHeader(cs, tt),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_demoMode && widget.isPaidDemo) ...[
                  _buildInfoBanner(
                    cs,
                    tt,
                    icon: Icons.info_outline_rounded,
                    color: cs.error,
                    title: 'Paid Demo (₹${widget.demoPrice})',
                    body: 'You\'ve already used your 1 free demo this month. Subsequent demos cost ₹${widget.demoPrice} and are paid upfront.',
                  ),
                  const SizedBox(height: 20),
                ],
                _buildSubjectSelector(cs, tt),
                if (_selectedSubjectIdx != null) ...[
                  const SizedBox(height: 20),
                  _buildLevelInput(cs, tt),
                ],
                const SizedBox(height: 20),
                if (_demoMode)
                  _buildSlotPicker(cs, tt)
                else
                  _buildScheduleSelector(cs, tt),
                const SizedBox(height: 20),
                _buildFrequencySelector(cs, tt),
                const SizedBox(height: 20),
                _buildMessageInput(cs, tt),
                const SizedBox(height: 20),
                _buildInfoBanner(
                  cs,
                  tt,
                  icon: _demoMode
                      ? (widget.isPaidDemo ? Icons.currency_rupee_rounded : Icons.info_outline_rounded)
                      : Icons.currency_rupee_rounded,
                  color: _demoMode
                      ? (widget.isPaidDemo ? cs.error : cs.primary)
                      : cs.error,
                  title: _demoMode
                      ? (widget.isPaidDemo ? '₹${widget.demoPrice} Paid Demo' : '1 Free Demo per month')
                      : '₹$_currentPrice/hr · Pay after acceptance',
                  body: _demoMode
                      ? (widget.isPaidDemo
                          ? 'Paid upfront. This fee is non-refundable.'
                          : 'This is your free demo for the month. Your slot is held once the request is sent.')
                      : 'Once the tutor accepts, you have 4 hours to pay. Amount will be held in Escrow Wallet.',
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _canSend && !_sending ? _sendRequest : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    disabledBackgroundColor: cs.surfaceContainerHighest,
                    disabledForegroundColor: cs.onSurfaceVariant,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: _sending
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : Text(
                          _demoMode
                              ? (widget.isPaidDemo ? 'Pay ₹${widget.demoPrice} & Request' : 'Send Demo Request')
                              : 'Send Class Request',
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(ColorScheme cs, TextTheme tt) {
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Request Sent!',
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                _demoMode
                    ? 'Your demo request has been sent to ${widget.tutorName}. You\'ll be notified once they respond.'
                    : 'Your class request has been sent to ${widget.tutorName}. You\'ll have 4 hours to pay once they accept.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorHeader(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: CachedNetworkImageProvider(widget.tutorImage),
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
                        widget.tutorName,
                        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified_rounded, size: 16, color: cs.primary),
                  ],
                ),
                if (_selectedSubjectIdx != null) ...[
                  const SizedBox(height: 4),
                  if (widget.tutorRates.isNotEmpty && _selectedSubjectIdx! < widget.tutorRates.length)
                    Builder(
                      builder: (context) {
                        final rate = widget.tutorRates[_selectedSubjectIdx!] as Map<String, dynamic>;
                        final subject = rate['subject']?.toString() ?? '';
                        final board = rate['board']?.toString() ?? '';
                        final grade = rate['grade']?.toString() ?? '';
                        final meta = board.isNotEmpty ? ' • $board • $grade' : '';
                        return Text(
                          '$subject$meta',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        );
                      },
                    )
                  else
                    Text(
                      _subjects[_selectedSubjectIdx!],
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (widget.tutorRating > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Text(
                            widget.tutorRating.toStringAsFixed(1),
                            style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    if (widget.tutorStudents > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.tutorStudents}',
                            style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    if (widget.tutorLocation.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            widget.tutorLocation,
                            style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    if (widget.tutorLanguages.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.language_rounded, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            widget.tutorLanguages.map((l) => l is Map ? l['name'] ?? '' : l.toString()).take(2).join(', '),
                            style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_currentPrice > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '₹$_currentPrice',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '/hr',
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, bool isDemo, ColorScheme cs, TextTheme tt) {
    final selected = _demoMode == isDemo;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _toggleMode(isDemo);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: tt.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSelector(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you need help with?',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (widget.tutorRates.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.tutorRates.length, (i) {
              final rate = widget.tutorRates[i] as Map<String, dynamic>;
              final selected = _selectedSubjectIdx == i;
              final subject = rate['subject']?.toString() ?? '';
              final board = rate['board']?.toString() ?? '';
              final grade = rate['grade']?.toString() ?? '';
              final meta = board.isNotEmpty ? '$board • $grade' : '';
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedSubjectIdx = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subject,
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          meta,
                          style: tt.labelSmall?.copyWith(
                            fontSize: 10,
                            color: selected ? cs.onPrimary.withValues(alpha: 0.8) : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_subjects.length, (i) {
              final selected = _selectedSubjectIdx == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedSubjectIdx = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _subjects[i],
                    style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected ? cs.onPrimary : cs.onSurface,
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildLevelInput(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your current level',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _levelController,
          decoration: InputDecoration(
            hintText: 'e.g. Class 11 CBSE, JEE Aspirant, Beginner...',
            suffixIcon: const Icon(Icons.edit_outlined, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotPicker(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick a date & time',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Mock slot picker - replace with actual implementation
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null && mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (time != null && mounted) {
                      setState(() {
                        _selectedSlotDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        _selectedSlotKey = _selectedSlotDate!.toIso8601String();
                      });
                    }
                  }
                },
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(_selectedSlotDate != null
                    ? '${_selectedSlotDate!.day}/${_selectedSlotDate!.month}/${_selectedSlotDate!.year} at ${_selectedSlotDate!.hour}:${_selectedSlotDate!.minute.toString().padLeft(2, '0')}'
                    : 'Select Date & Time'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSelector(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select preferred days & time',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final day = i + 1;
                  final selected = _selectedDays.contains(day);
                  final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (selected) {
                          _selectedDays.remove(day);
                        } else {
                          _selectedDays.add(day);
                        }
                        _selectedDays.sort();
                        if (!_demoMode) {
                          _classesPerWeek = _selectedDays.isNotEmpty ? _selectedDays.length : 1;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : cs.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected ? cs.onPrimary : cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _preferredTime ?? const TimeOfDay(hour: 17, minute: 0),
                  );
                  if (time != null) {
                    setState(() => _preferredTime = time);
                  }
                },
                icon: const Icon(Icons.access_time_rounded),
                label: Text(_preferredTime != null
                    ? '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}'
                    : 'Select Time'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How often do you want classes?',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              if (_demoMode) ...[
                _buildStepper(
                  label: 'Classes per week',
                  value: _classesPerWeek,
                  min: 1,
                  max: 7,
                  onChanged: (v) => setState(() => _classesPerWeek = v),
                  cs: cs,
                  tt: tt,
                ),
                const SizedBox(height: 16),
              ],
              _buildStepper(
                label: 'Months',
                value: _months,
                min: 1,
                max: 12,
                onChanged: (v) => setState(() => _months = v),
                cs: cs,
                tt: tt,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _demoMode
                            ? 'Min $_totalSessions classes · ${_classesPerWeek}x/week · $_months month${_months > 1 ? 's' : ''}'
                            : '${_classesPerWeek}x/week · $_months month${_months > 1 ? 's' : ''} · ₹$_totalPrice total',
                        style: tt.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepper({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: value > min
              ? () {
                  HapticFeedback.selectionClick();
                  onChanged(value - 1);
                }
              : null,
          icon: const Icon(Icons.remove_rounded),
          style: IconButton.styleFrom(
            backgroundColor: cs.surfaceContainerHighest,
            disabledBackgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(
          width: 48,
          child: Center(
            child: Text(
              '$value',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        IconButton(
          onPressed: value < max
              ? () {
                  HapticFeedback.selectionClick();
                  onChanged(value + 1);
                }
              : null,
          icon: const Icon(Icons.add_rounded),
          style: IconButton.styleFrom(
            backgroundColor: cs.surfaceContainerHighest,
            disabledBackgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message (optional)',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tell the tutor your goals, topics you need help with...',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner(
    ColorScheme cs,
    TextTheme tt, {
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: tt.bodySmall?.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
