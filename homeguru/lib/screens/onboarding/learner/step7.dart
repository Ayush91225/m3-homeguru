import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:http/http.dart' as http;

class LearnerStep7Body extends StatefulWidget {
  const LearnerStep7Body({
    super.key,
    required this.phoneCountry,
    required this.firstName,
    required this.lastName,
    required this.onNext,
  });
  final String phoneCountry;
  final String firstName;
  final String lastName;
  final void Function(Map<String, dynamic> profile) onNext;

  @override
  State<LearnerStep7Body> createState() => _LearnerStep7BodyState();
}

class _LearnerStep7BodyState extends State<LearnerStep7Body> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  DateTime? _dob;
  String? _gender;
  String? _category;
  final List<String> _languages = [];

  List<csc.Country> _allCountries = [];
  List<csc.State> _states = [];
  List<csc.City> _cities = [];

  csc.Country? _country;
  csc.State? _state;
  csc.City? _city;

  bool _loadingCountries = true;
  bool _loadingStates = false;
  bool _loadingCities = false;

  static const _genders = ['Male', 'Female', 'Other'];
  static const _categories = [
    'Student', 'Aspirant', 'College Student',
    'Working Professional', 'Homemaker', 'Sr. Citizen',
  ];
  List<String> _allLanguages = [];
  bool _loadingLanguages = true;

  // Comprehensive fallback language list
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
    // Prefill name from step 1
    _firstNameCtrl.text = widget.firstName;
    _lastNameCtrl.text = widget.lastName;
    _loadCountries();
    _fetchLanguages();
  }

  Future<void> _fetchLanguages() async {
    try {
      final res = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=languages'),
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final Set<String> langs = {};
        for (final country in data) {
          final languages = country['languages'];
          if (languages is Map) {
            langs.addAll(languages.values.cast<String>());
          }
        }
        final sorted = langs.toList()..sort();
        if (mounted) setState(() { _allLanguages = sorted; _loadingLanguages = false; });
        return;
      }
    } catch (_) {}
    // Fallback to static list
    if (mounted) setState(() { _allLanguages = List.from(_fallbackLanguages)..sort(); _loadingLanguages = false; });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
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

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      helpText: 'Select date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickLanguages() async {
    if (_loadingLanguages) return;
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _MultiSelectSheet(title: 'Preferred languages', options: _allLanguages, selected: List.from(_languages)),
    );
    if (result != null) setState(() { _languages.clear(); _languages.addAll(result); });
  }

  Future<void> _pickCountry() async {
    if (_loadingCountries) return;
    final result = await showModalBottomSheet<csc.Country>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _CscSheet<csc.Country>(
        title: 'Country',
        items: _allCountries,
        label: (c) => c.name,
        flag: (c) => c.flag,
      ),
    );
    if (result != null) { setState(() => _country = result); _loadStates(result); }
  }

  Future<void> _pickState() async {
    if (_loadingStates || _states.isEmpty) return;
    final result = await showModalBottomSheet<csc.State>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _CscSheet<csc.State>(
        title: 'State / Province',
        items: _states,
        label: (s) => s.name,
      ),
    );
    if (result != null) { setState(() => _state = result); _loadCities(result); }
  }

  Future<void> _pickCity() async {
    if (_loadingCities || _cities.isEmpty) return;
    final result = await showModalBottomSheet<csc.City>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _CscSheet<csc.City>(
        title: 'City',
        items: _cities,
        label: (c) => c.name,
      ),
    );
    if (result != null) setState(() => _city = result);
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) { _showSnack('Please select your date of birth'); return; }
    if (_gender == null) { _showSnack('Please select your gender'); return; }
    if (_category == null) { _showSnack('Please select what you are'); return; }
    if (_languages.isEmpty) { _showSnack('Please select at least one language'); return; }
    if (_country == null) { _showSnack('Please select your country'); return; }
    HapticFeedback.mediumImpact();
    widget.onNext({
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'dob': _dob!.toIso8601String(),
      'gender': _gender,
      'category': _category,
      'categoryIndex': _categories.indexOf(_category!),
      'languages': _languages,
      'country': _country?.name,
      'state': _state?.name,
      'city': _city?.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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

                  // ── Name ──────────────────────────────────────────────
                  _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  ])),

                  const SizedBox(height: 16),

                  // ── DOB + Gender ──────────────────────────────────────
                  _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            style: tt.bodyMedium?.copyWith(color: _dob == null ? cs.onSurfaceVariant : cs.onSurface),
                          )),
                          if (_age != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
                              child: Text(_age!, style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
                            ),
                          if (_dob == null) Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                        ]),
                      ),
                    ),
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
                              color: sel ? cs.primaryContainer : cs.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                            ),
                            child: Text(g, textAlign: TextAlign.center,
                              style: tt.bodyMedium?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                          ),
                        ),
                      ));
                    }).toList()),
                  ])),

                  const SizedBox(height: 16),

                  // ── Category ──────────────────────────────────────────
                  _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _CardTitle('I am a...', cs, tt),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: _categories.map((c) {
                      final sel = _category == c;
                      return GestureDetector(
                        onTap: () { HapticFeedback.selectionClick(); setState(() => _category = c); },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? cs.primaryContainer : cs.surface,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: sel ? cs.primary : Colors.transparent, width: 2),
                          ),
                          child: Text(c, style: tt.bodyMedium?.copyWith(color: sel ? cs.onPrimaryContainer : cs.onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                        ),
                      );
                    }).toList()),
                  ])),

                  const SizedBox(height: 16),

                  // ── Languages ─────────────────────────────────────────
                  _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _CardTitle('Preferred languages', cs, tt),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickLanguages,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
                        child: _loadingLanguages
                            ? Row(children: [
                                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary)),
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
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      ..._languages.map((l) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
                                        child: Text(l, style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                                      )),
                                      GestureDetector(
                                        onTap: _pickLanguages,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: cs.primary, width: 1.5),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                                            Icon(Icons.add_rounded, size: 14, color: cs.primary),
                                            const SizedBox(width: 4),
                                            Text('Add', style: tt.labelMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ])),

                  const SizedBox(height: 16),

                  // ── Location ──────────────────────────────────────────
                  _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _CardTitle('Location', cs, tt),
                    const SizedBox(height: 16),
                    // Country
                    _PickerTile(
                      icon: Icons.public_rounded,
                      label: 'Country',
                      value: _country?.name,
                      loading: _loadingCountries,
                      onTap: _pickCountry,
                      cs: cs, tt: tt,
                    ),
                    if (_country != null) ...[
                      const SizedBox(height: 12),
                      _PickerTile(
                        icon: Icons.map_outlined,
                        label: 'State / Province',
                        value: _state?.name,
                        loading: _loadingStates,
                        onTap: _pickState,
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
                        onTap: _pickCity,
                        cs: cs, tt: tt,
                      ),
                    ],
                  ])),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: FilledButton(onPressed: _submit, child: const Text('Continue')),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic CSC bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CscSheet<T> extends StatefulWidget {
  const _CscSheet({required this.title, required this.items, required this.label, this.flag});
  final String title;
  final List<T> items;
  final String Function(T) label;
  final String Function(T)? flag;

  @override
  State<_CscSheet<T>> createState() => _CscSheetState<T>();
}

class _CscSheetState<T> extends State<_CscSheet<T>> {
  final _ctrl = TextEditingController();
  late List<T> _filtered;

  @override
  void initState() { super.initState(); _filtered = widget.items; }
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
          child: Text(widget.title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (q) => setState(() {
              _filtered = q.isEmpty ? widget.items : widget.items.where((i) => widget.label(i).toLowerCase().contains(q.toLowerCase())).toList();
            }),
            decoration: const InputDecoration(hintText: 'Search...', prefixIcon: Icon(Icons.search_rounded)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 340,
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final item = _filtered[i];
              return ListTile(
                leading: widget.flag != null
                    ? Text(widget.flag!(item), style: const TextStyle(fontSize: 22))
                    : null,
                title: Text(widget.label(item), style: tt.bodyMedium),
                onTap: () => Navigator.pop(context, item),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Multi-select sheet
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
                trailing: sel ? Icon(Icons.check_circle_rounded, color: cs.primary) : Icon(Icons.circle_outlined, color: cs.outlineVariant),
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

// ─────────────────────────────────────────────────────────────────────────────
// Picker tile
// ─────────────────────────────────────────────────────────────────────────────

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
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary))
            : Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared local widgets
// ─────────────────────────────────────────────────────────────────────────────

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
