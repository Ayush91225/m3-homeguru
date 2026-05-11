import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tutor_profile_service.dart';

/// Centralized tutor data — loaded once, accessible everywhere.
/// Call TutorData.of(context) to read, .refresh() after edits.
class TutorDataModel extends ChangeNotifier {
  Map<String, dynamic> _data = {};
  bool _loaded = false;
  bool _loading = false;
  String? _tutorId;

  // Getters
  bool get loaded => _loaded;
  bool get loading => _loading;
  String? get tutorId => _tutorId;
  Map<String, dynamic> get raw => _data;

  // Common fields
  String get firstName => _data['firstName']?.toString() ?? '';
  String get lastName => _data['lastName']?.toString() ?? '';
  String get fullName => '$firstName $lastName'.trim();
  String get shortName {
    if (firstName.isEmpty) return 'Tutor';
    return firstName.length > 12 ? '${firstName.substring(0, 12)}…' : firstName;
  }

  String get email => _data['email']?.toString() ?? '';
  String get phone => _data['phone']?.toString() ?? _data['phoneNumber']?.toString() ?? '';
  String get profilePhoto => _data['profilePhoto']?.toString() ?? '';
  String get coverPhoto => _data['coverPhoto']?.toString() ?? '';
  String get youtubeVideoLink => _data['youtubeVideoLink']?.toString() ?? '';
  bool get isActive => _data['isActive'] == true;
  bool get isVerified => _data['isVerified'] == true;

  // Profile sub-object
  Map<String, dynamic> get profile => _data['profile'] as Map<String, dynamic>? ?? {};
  String get bio => profile['bio']?.toString() ?? '';

  // Subjects
  Map<String, dynamic> get subjects => _data['subjects'] as Map<String, dynamic>? ?? {};

  // Experience
  List<Map<String, String>> get experience {
    final raw = _data['experience'];
    if (raw is List) {
      return raw.map((e) => Map<String, String>.from(
        (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
      )).toList();
    }
    if (raw is String && raw.isNotEmpty) {
      return [{'title': 'Teaching', 'org': '', 'period': raw}];
    }
    return [];
  }

  // Education
  List<Map<String, String>> get education {
    final raw = _data['education'];
    if (raw is List) {
      return raw.map((e) => Map<String, String>.from(
        (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
      )).toList();
    }
    return [];
  }

  // Rates
  List<Map<String, dynamic>> get rates {
    final raw = _data['rates'];
    if (raw is List) return raw.map((r) => Map<String, dynamic>.from(r)).toList();
    return [];
  }

  // Availability
  Map<String, List<Map<String, String>>> get availability {
    final result = <String, List<Map<String, String>>>{
      'monday': [], 'tuesday': [], 'wednesday': [],
      'thursday': [], 'friday': [], 'saturday': [], 'sunday': [],
    };
    final raw = _data['availability'];
    if (raw is Map) {
      for (final day in result.keys) {
        if (raw[day] is List) {
          result[day] = (raw[day] as List).map((s) => Map<String, String>.from(s)).toList();
        }
      }
    }
    return result;
  }

  // Learners (from API when available)
  List<Map<String, dynamic>> get learners {
    final raw = _data['learners'];
    if (raw is List) return raw.map((l) => Map<String, dynamic>.from(l)).toList();
    return [];
  }

  // Today's schedule (from API when available)
  List<Map<String, dynamic>> get todaySchedule {
    final raw = _data['todaySchedule'];
    if (raw is List) return raw.map((s) => Map<String, dynamic>.from(s)).toList();
    return [];
  }

  // Pending requests (from API when available)
  List<Map<String, dynamic>> get pendingRequests {
    final raw = _data['pendingRequests'];
    if (raw is List) return raw.map((r) => Map<String, dynamic>.from(r)).toList();
    return [];
  }

  TutorDataModel._();

  /// Create and load
  static Future<TutorDataModel> load() async {
    final model = TutorDataModel._();
    await model._fetch();
    return model;
  }

  /// Refresh from API (call after edits)
  Future<void> refresh() async {
    await _fetch();
  }

  /// Update local data + notify (for optimistic UI without re-fetching)
  void updateLocal(Map<String, dynamic> fields) {
    _data.addAll(fields);
    notifyListeners();
  }

  /// Update API + local
  Future<bool> updateAndSave(Map<String, dynamic> fields) async {
    if (_tutorId == null) return false;
    final result = await TutorProfileService.updateProfile(_tutorId!, fields);
    if (result['success'] == true) {
      _data.addAll(fields);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _fetch() async {
    if (_loading) return;
    _loading = true;

    final prefs = await SharedPreferences.getInstance();
    _tutorId = prefs.getString('userId');
    if (_tutorId == null) {
      _loading = false;
      return;
    }

    final result = await TutorProfileService.getTutorProfile(_tutorId!);
    if (result['success'] == true) {
      _data = result['data'] as Map<String, dynamic>;
      _loaded = true;
    }
    _loading = false;
    notifyListeners();
  }
}

/// InheritedWidget — use TutorData.of(context) anywhere
class TutorData extends InheritedNotifier<TutorDataModel> {
  const TutorData({
    super.key,
    required TutorDataModel model,
    required super.child,
  }) : super(notifier: model);

  static TutorDataModel of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<TutorData>();
    assert(w != null, 'No TutorData found in widget tree');
    return w!.notifier!;
  }

  /// Non-listening access (for callbacks/event handlers)
  static TutorDataModel read(BuildContext context) {
    final w = context.getElementForInheritedWidgetOfExactType<TutorData>()?.widget as TutorData?;
    assert(w != null, 'No TutorData found in widget tree');
    return w!.notifier!;
  }
}
