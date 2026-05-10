import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../services/tutor_onboarding_service.dart';
import '../../../models/tutor_onboarding_model.dart';

class TutorStep2Body extends StatefulWidget {
  const TutorStep2Body({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phoneCountry,
    required this.onNext,
  });
  final String firstName;
  final String lastName;
  final String phoneCountry;
  final void Function(Map<String, dynamic> profile) onNext;

  @override
  State<TutorStep2Body> createState() => _TutorStep2BodyState();
}

class _TutorStep2BodyState extends State<TutorStep2Body> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  DateTime? _dob;
  String? _gender;

  // Location
  List<csc.Country> _allCountries = [];
  List<csc.State> _states = [];
  List<csc.City> _cities = [];
  csc.Country? _country;
  csc.State? _state;
  csc.City? _city;
  bool _loadingCountries = true;
  bool _loadingStates = false;
  bool _loadingCities = false;

  // Languages with proficiency
  final List<Map<String, String>> _languages = []; // [{name, proficiency}]
  List<String> _allLanguages = [];
  bool _loadingLanguages = true;

  // Certificates
  final List<PlatformFile> _certs = [];

  static const _genders = ['Male', 'Female', 'Other'];
  static const _proficiencies = ['Native', 'Professional', 'Good', 'Intermediate', 'Beginner'];

  static const _fallbackLanguages = [
    'English', 'Hindi', 'Bengali', 'Telugu', 'Marathi', 'Tamil',
    'Gujarati', 'Kannada', 'Malayalam', 'Punjabi', 'Odia', 'Urdu',
    'Sanskrit', 'Assamese', 'Maithili', 'French', 'German', 'Spanish',
    'Portuguese', 'Italian', 'Dutch', 'Russian', 'Polish', 'Ukrainian',
    'Arabic', 'Persian', 'Turkish', 'Hebrew', 'Swahili',
    'Japanese', 'Mandarin', 'Cantonese', 'Korean', 'Vietnamese',
    'Thai', 'Indonesian', 'Malay', 'Tagalog', 'Burmese',
    'Nepali', 'Sinhala', 'Khmer', 'Lao',
  ];

  @override
  void initState() {
    super.initState();
    _firstNameCtrl.text = widget.firstName;
    _lastNameCtrl.text = widget.lastName;
    _loadCountries();
    _fetchLanguages();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLanguages() async {
    try {
      final res = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=languages'),
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final Set<String> langs = {};
        for (final item in data) {
          final languages = item['languages'];
          if (languages is Map) {
            langs.addAll(languages.values.cast<String>());
          }
        }
        final sorted = langs.toList()..sort();
        if (mounted) setState(() { _allLanguages = sorted; _loadingLanguages = false; });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() { _allLanguages = List.from(_fallbackLanguages)..sort(); _loadingLanguages = false; });
  }

  Future<void> _loadCountries() async {
    final countries = await csc.getAllCountries();
    if (!mounted) return;
    final phone = widget.phoneCountry.toLowerCase();
    final match = countries.where((c) =>
      c.name.toLowerCase().contains(phone) ||
      phone.contains(c.name.toLowerCase())
    ).firstOrNull;
    setState(() {
      _allCountries = countries;
      _loadingCountries = false;
      if (match != null) _country = match;
    });
    if (match != null) _loadStates(match);
  }

  Future<void> _loadStates(csc.Country country) async {
    setState(() => _loadingStates = true);
    final states = await csc.getStatesOfCountry(country.isoCode);
    if (!mounted) return;
    setState(() { _states = states; _state = null; _cities = []; _city = null; _loadingStates = false; });
  }

  Future<void> _loadCities(csc.State state) async {
    setState(() => _loadingCities = true);
    final cities = await csc.getStateCities(_country!.isoCode, state.isoCode);
    if (!mounted) return;
    setState(() { _cities = cities; _city = null; _loadingCities = false; });
  }

  String? get _age {
    if (_dob == null) return null;
    final now = DateTime.now();
    int age = now.year - _dob!.year;
    if (now.month < _dob!.month || (now.month == _dob!.month && now.day < _dob!.day)) age--;
    return '$age years';
  }

  bool get _isAgeValid {
    if (_dob == null) return false;
    final now = DateTime.now();
    int age = now.year - _dob!.year;
    if (now.month < _dob!.month || (now.month == _dob!.month && now.day < _dob!.day)) age--;
    return age >= 20;
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      helpText: 'Select date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) { _showSnack('Please select your date of birth'); return; }
    if (!_isAgeValid) { _showSnack('You must be at least 20 years old to register as a tutor'); return; }
    if (_gender == null) { _showSnack('Please select your gender'); return; }
    if (_country == null) { _showSnack('Please select your country'); return; }
    if (_languages.isEmpty) { _showSnack('Please add at least one language'); return; }
    if (_bioCtrl.text.trim().length < 200) { _showSnack('Bio must be at least 200 characters'); return; }
    
    HapticFeedback.mediumImpact();
    
    // Get tutorId from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final tutorId = prefs.getString('tutorId');
    
    if (tutorId == null) {
      _showSnack('Session expired. Please start over.');
      return;
    }
    
    // Save to API
    final tutorData = TutorOnboarding();
    tutorData.tutorId = tutorId;
    tutorData.set('firstName', _firstNameCtrl.text.trim());
    tutorData.set('lastName', _lastNameCtrl.text.trim());
    tutorData.set('dob', _dob!.toIso8601String());
    tutorData.set('gender', _gender);
    tutorData.set('country', _country?.name);
    tutorData.set('state', _state?.name);
    tutorData.set('city', _city?.name);
    tutorData.set('languages', _languages);
    tutorData.set('bio', _bioCtrl.text.trim());
    tutorData.set('certificates', _certs.map((f) => f.path).toList());
    
    final result = await TutorOnboardingService.updateProfile(tutorId, tutorData);
    
    if (result['success'] == true) {
      widget.onNext({
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'dob': _dob!.toIso8601String(),
        'gender': _gender,
        'country': _country?.name,
        'state': _state?.name,
        'city': _city?.name,
        'languages': _languages,
        'bio': _bioCtrl.text.trim(),
        'certificates': _certs.map((f) => f.path).toList(),
      });
    } else {
      _showSnack(result['error'] ?? 'Failed to save profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 20.0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _nameCard(tt),
                  const SizedBox(height: 16),
                  _personalCard(tt),
                  const SizedBox(height: 16),
                  _locationCard(tt),
                  const SizedBox(height: 16),
                  _languagesCard(tt),
                  const SizedBox(height: 16),
                  _bioCard(tt),
                  const SizedBox(height: 16),
                  _certificatesCard(tt),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.tertiary, foregroundColor: Theme.of(context).colorScheme.onTertiary),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  // ── Name ──────────────────────────────────────────────────────────────────
  Widget _nameCard(TextTheme tt) {
    final cs = Theme.of(context).colorScheme;
    return _Card(cs: cs, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CardTitle('Name', cs, tt),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: TextFormField(
          controller: _firstNameCtrl,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'First name'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (v.trim().length < 2) return 'Min 2 characters';
            return null;
          },
        )),
        const SizedBox(width: 12),
        Expanded(child: TextFormField(
          controller: _lastNameCtrl,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Last name'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (v.trim().length < 2) return 'Min 2 characters';
            return null;
          },
        )),
      ]),
    ],
  ));
  }

  // ── Personal (DOB + Gender) ────────────────────────────────────────────────
  Widget _personalCard(TextTheme tt) {
    final cs = Theme.of(context).colorScheme;
    return _Card(cs: cs, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CardTitle('Personal', cs, tt),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: _pickDob,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(Icons.cake_outlined, color: cs.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(
              _dob == null ? 'Date of birth' : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
              style: tt.bodyMedium?.copyWith(
                color: _dob == null ? cs.onSurfaceVariant : cs.onSurface,
              ),
            )),
            if (_age != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isAgeValid ? cs.tertiaryContainer : cs.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_age!, style: tt.labelSmall?.copyWith(
                  color: _isAgeValid ? cs.onTertiaryContainer : cs.onErrorContainer,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ],
            if (_dob == null) Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ]),
        ),
      ),
      if (_dob != null && !_isAgeValid) ...[
        const SizedBox(height: 6),
        Text('Tutors must be at least 20 years old.',
          style: tt.bodySmall?.copyWith(color: cs.error)),
      ],
      const SizedBox(height: 12),
      Row(children: _genders.map((g) {
        final sel = _gender == g;
        return Expanded(child: Padding(
          padding: EdgeInsets.only(right: g != _genders.last ? 8 : 0),
          child: GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _gender = g); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? cs.tertiaryContainer : cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? cs.tertiary : Colors.transparent, width: 2),
              ),
              child: Text(g, textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color: sel ? cs.onTertiaryContainer : cs.onSurface,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                )),
            ),
          ),
        ));
      }).toList()),
    ],
  ));
  }

  // ── Location ──────────────────────────────────────────────────────────────
  Widget _locationCard(TextTheme tt) {
    final cs = Theme.of(context).colorScheme;
    return _Card(cs: cs, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CardTitle('Location', cs, tt),
      const SizedBox(height: 16),
      _PickerTile(
        icon: Icons.public_rounded,
        label: 'Country',
        value: _country?.name,
        loading: _loadingCountries,
        onTap: () async {
          if (_loadingCountries) return;
          final result = await showModalBottomSheet<csc.Country>(
            context: context, isScrollControlled: true, useSafeArea: true,
            useRootNavigator: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            builder: (_) => _CscSheet<csc.Country>(title: 'Country', items: _allCountries, label: (c) => c.name, flag: (c) => c.flag),
          );
          if (result != null) { setState(() { _country = result; _state = null; _city = null; }); _loadStates(result); }
        },
        cs: cs, tt: tt,
      ),
      if (_country != null) ...[
        const SizedBox(height: 12),
        _PickerTile(
          icon: Icons.map_outlined,
          label: 'State / Province',
          value: _state?.name,
          loading: _loadingStates,
          onTap: () async {
            if (_loadingStates || _states.isEmpty) return;
            final result = await showModalBottomSheet<csc.State>(
              context: context, isScrollControlled: true, useSafeArea: true,
              useRootNavigator: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              builder: (_) => _CscSheet<csc.State>(title: 'State / Province', items: _states, label: (s) => s.name),
            );
            if (result != null) { setState(() { _state = result; _city = null; }); _loadCities(result); }
          },
          cs: cs, tt: tt,
        ),
      ],
      if (_state != null) ...[
        const SizedBox(height: 12),
        _PickerTile(
          icon: Icons.location_city_rounded,
          label: 'City',
          value: _city?.name,
          loading: _loadingCities,
          onTap: () async {
            if (_loadingCities || _cities.isEmpty) return;
            final result = await showModalBottomSheet<csc.City>(
              context: context, isScrollControlled: true, useSafeArea: true,
              useRootNavigator: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              builder: (_) => _CscSheet<csc.City>(title: 'City', items: _cities, label: (c) => c.name),
            );
            if (result != null) setState(() => _city = result);
          },
          cs: cs, tt: tt,
        ),
      ],
    ],
  ));
  }

  // ── Languages ─────────────────────────────────────────────────────────────
  Widget _languagesCard(TextTheme tt) {
    final cs = Theme.of(context).colorScheme;
    return _Card(cs: cs, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
                    GestureDetector(
                      onTap: _pickLanguages,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
                        child: _loadingLanguages
                            ? Row(children: [
                                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cs.tertiary)),
                                const SizedBox(width: 12),
                                Text('Loading languages...', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                              ])
                            : _languages.isEmpty
                                ? Row(children: [
                                    Icon(Icons.language_rounded, color: cs.onSurfaceVariant, size: 20),
                                    const SizedBox(width: 12),
                                    Text('Select languages', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                                    const Spacer(),
                                    Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                                  ])
                                : Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ..._languages.map((l) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(20)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(l['name']!, style: tt.labelSmall?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w700)),
                                                GestureDetector(
                                                  onTap: () => _pickProficiency(l),
                                                  child: Text(l['proficiency']!, style: tt.labelSmall?.copyWith(color: cs.tertiary, fontSize: 8, decoration: TextDecoration.underline)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () => setState(() => _languages.remove(l)),
                                              child: Icon(Icons.close_rounded, size: 14, color: cs.tertiary),
                                            ),
                                          ],
                                        ),
                                      )),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: cs.tertiary, width: 1.5),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          Icon(Icons.add_rounded, size: 14, color: cs.tertiary),
                                          const SizedBox(width: 4),
                                          Text('Add', style: tt.labelSmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w600)),
                                        ]),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
    ],
  ));
  }

  void _pickLanguages() async {
    if (_loadingLanguages) return;
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _MultiSelectSheet(
        title: 'Select languages',
        options: _allLanguages,
        selected: _languages.map((l) => l['name']!).toList(),
      ),
    );

    if (result != null) {
      final List<Map<String, String>> newLangs = [];
      final currentNames = _languages.map((l) => l['name']!).toSet();
      
      for (final name in result) {
        if (currentNames.contains(name)) {
          newLangs.add(_languages.firstWhere((l) => l['name'] == name));
        } else {
          // It's a new language, ask for proficiency
          final p = await _pickProficiencyFor(name);
          newLangs.add({'name': name, 'proficiency': p ?? 'Professional'});
        }
      }
      setState(() {
        _languages.clear();
        _languages.addAll(newLangs);
      });
    }
  }

  Future<String?> _pickProficiencyFor(String langName) async {
    final tt = Theme.of(context).textTheme;

    return await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Level for $langName', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ..._proficiencies.map((p) => ListTile(
                onTap: () => Navigator.pop(ctx, p),
                title: Text(p),
              )),
            ],
          ),
        );
      },
    );
  }

  void _pickProficiency(Map<String, String> lang) async {
    final res = await _pickProficiencyFor(lang['name']!);
    if (res != null) {
      setState(() {
        lang['proficiency'] = res;
      });
    }
  }

  // ── Bio ───────────────────────────────────────────────────────────────────
  Widget _bioCard(TextTheme tt) {
    final cs = Theme.of(context).colorScheme;
    return _Card(cs: cs, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CardTitle('About / Bio', cs, tt),
      const SizedBox(height: 12),
      TextFormField(
        controller: _bioCtrl,
        maxLines: 5,
        minLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Tell us about your teaching experience, methodology, and background...',
          alignLabelWithHint: true,
        ),
        onChanged: (_) => setState(() {}),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (v.trim().length < 200) return 'Bio must be at least 200 characters (${v.trim().length}/200)';
          return null;
        },
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerRight,
        child: Text('${_bioCtrl.text.trim().length} / 200 min',
          style: tt.labelSmall?.copyWith(color: _bioCtrl.text.trim().length >= 200 ? Colors.green : cs.onSurfaceVariant)),
      ),
    ],
  ));
  }

  // ── Certificates ──────────────────────────────────────────────────────────
  Widget _certificatesCard(TextTheme tt) {
    final cs = Theme.of(context).colorScheme;
    return _Card(cs: cs, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        _CardTitle('Certificates & Qualifications', cs, tt),
        const Spacer(),
        TextButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('Upload'),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact, foregroundColor: cs.tertiary),
        ),
      ]),
      const SizedBox(height: 4),
      Text('Upload any teaching certificates, degrees or relevant documents (Optional).', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      if (_certs.isNotEmpty) ...[
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _certs.map((f) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isImage(f.extension) ? Icons.image_outlined : Icons.description_outlined,
                          size: 20,
                          color: cs.tertiary,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _certs.remove(f)),
                          child: Icon(Icons.cancel_rounded, size: 18, color: cs.error.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      f.name,
                      style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${(f.size / 1024).toStringAsFixed(1)} KB',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 9),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    ],
  ));
  }

  void _pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    if (result != null) {
      setState(() => _certs.addAll(result.files));
    }
  }

  bool _isImage(String? ext) {
    if (ext == null) return false;
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext.toLowerCase());
  }
}

// ── Components ──────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.cs, required this.child});
  final ColorScheme cs;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
    child: child,
  );
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.label, this.cs, this.tt);
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => Text(label, style: tt.titleSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700));
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.icon, required this.label, required this.value, required this.loading, required this.onTap, required this.cs, required this.tt});
  final IconData icon;
  final String label;
  final String? value;
  final bool loading;
  final VoidCallback onTap;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: cs.onSurfaceVariant, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(value ?? label, style: tt.bodyMedium?.copyWith(color: value != null ? cs.onSurface : cs.onSurfaceVariant))),
        loading
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cs.tertiary))
            : Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Multi-select sheet (matching student's)
// ─────────────────────────────────────────────────────────────────────────────

class _MultiSelectSheet extends StatefulWidget {
  const _MultiSelectSheet({required this.title, required this.options, required this.selected});
  final String title;
  final List<String> options;
  final List<String> selected;

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  final _ctrl = TextEditingController();
  late List<String> _filtered;
  late Set<String> _selected;

  @override
  void initState() { super.initState(); _filtered = widget.options; _selected = Set.from(widget.selected); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 32, height: 4, decoration: BoxDecoration(color: cs.onSurfaceVariant.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(children: [
            Expanded(child: Text(widget.title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
            TextButton(onPressed: () => Navigator.pop(context, _selected.toList()), child: const Text('Done')),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _ctrl,
            onChanged: (q) => setState(() {
              _filtered = q.isEmpty ? widget.options : widget.options.where((o) => o.toLowerCase().contains(q.toLowerCase())).toList();
            }),
            decoration: const InputDecoration(hintText: 'Search...', prefixIcon: Icon(Icons.search_rounded)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 320,
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final item = _filtered[i];
              final sel = _selected.contains(item);
              return ListTile(
                title: Text(item, style: tt.bodyMedium),
                trailing: sel ? Icon(Icons.check_circle_rounded, color: cs.tertiary) : Icon(Icons.circle_outlined, color: cs.outlineVariant),
                onTap: () => setState(() { sel ? _selected.remove(item) : _selected.add(item); }),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _CscSheet<T> extends StatefulWidget {
  const _CscSheet({required this.title, required this.items, required this.label, this.flag, super.key});
  final String title;
  final List<T> items;
  final String Function(T) label;
  final String Function(T)? flag;

  @override
  State<_CscSheet<T>> createState() => _CscSheetState<T>();
}

class _CscSheetState<T> extends State<_CscSheet<T>> {
  final _search = TextEditingController();
  List<T> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  void _onSearch(String v) {
    setState(() {
      _filtered = widget.items.where((i) => widget.label(i).toLowerCase().contains(v.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Expanded(child: Text(widget.title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), iconSize: 20),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              autofocus: true,
              onChanged: _onSearch,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 340,
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final item = _filtered[i];
                return ListTile(
                  onTap: () => Navigator.pop(context, item),
                  title: Text(widget.label(item), style: tt.bodyMedium),
                  leading: widget.flag != null ? Text(widget.flag!(item), style: const TextStyle(fontSize: 22)) : null,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
