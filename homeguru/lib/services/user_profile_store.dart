import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tutor_profile_service.dart';

class SubProfile {
  final String name;
  SubProfile({required this.name});
  factory SubProfile.fromJson(Map<String, dynamic> j) => SubProfile(name: j['name'] as String);
  Map<String, dynamic> toJson() => {'name': name};
}

class UserProfileStore extends ChangeNotifier {
  static const _kAvatar          = 'profile_avatar_path';
  static const _kCover           = 'profile_cover_path';
  static const _kSubProfiles     = 'profile_sub_profiles';
  static const _kGuardianWarning = 'profile_guardian_warning_shown';
  static const _kName            = 'profile_name';
  static const _kHandle          = 'profile_handle';
  static const _kBio             = 'profile_bio';
  static const _kPhone           = 'profile_phone';

  File? _avatar;
  File? _cover;
  List<SubProfile> _subProfiles = [];
  bool _guardianWarningShown = false;
  String _name   = 'Ravi Kumar';
  String _handle = '@ravi.learns';
  String _bio    = 'Class 11 · PCM · JEE 2026';
  String _phone  = '9999999999';

  File? get avatar => _avatar;
  File? get cover  => _cover;
  List<SubProfile> get subProfiles => List.unmodifiable(_subProfiles);
  bool get guardianWarningShown => _guardianWarningShown;
  String get name   => _name;
  String get handle => _handle;
  String get bio    => _bio;
  String get phone  => _phone;

  UserProfileStore._();

  static Future<UserProfileStore> load() async {
    final store = UserProfileStore._();
    final prefs = await SharedPreferences.getInstance();
    final a = prefs.getString(_kAvatar);
    final c = prefs.getString(_kCover);
    if (a != null && File(a).existsSync()) store._avatar = File(a);
    if (c != null && File(c).existsSync()) store._cover  = File(c);
    store._guardianWarningShown = prefs.getBool(_kGuardianWarning) ?? false;
    store._name   = prefs.getString(_kName)   ?? store._name;
    store._handle = prefs.getString(_kHandle) ?? store._handle;
    store._bio    = prefs.getString(_kBio)    ?? store._bio;
    store._phone  = prefs.getString(_kPhone)  ?? store._phone;
    final raw = prefs.getString(_kSubProfiles);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      store._subProfiles = list.map((e) => SubProfile.fromJson(e as Map<String, dynamic>)).toList();
    }
    return store;
  }

  Future<void> updateProfile({required String name, required String handle, required String bio, String? phone}) async {
    _name   = name;
    _handle = handle;
    _bio    = bio;
    if (phone != null) _phone = phone;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName,   name);
    await prefs.setString(_kHandle, handle);
    await prefs.setString(_kBio,    bio);
    if (phone != null) await prefs.setString(_kPhone, phone);
  }

  Future<void> setAvatar(File file) async {
    _avatar = file;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatar, file.path);

    // Upload to S3 and update DB
    final url = await TutorProfileService.uploadFile(file, 'profile-photos');
    print('[ProfileStore] Avatar upload result: $url');
    if (url != null) {
      final tutorId = prefs.getString('userId');
      if (tutorId != null) {
        final result = await TutorProfileService.updateProfile(tutorId, {'profilePhoto': url});
        print('[ProfileStore] Avatar DB update result: $result');
      }
    }
  }

  Future<void> setCover(File file) async {
    _cover = file;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCover, file.path);

    // Upload to S3 and update DB
    final url = await TutorProfileService.uploadFile(file, 'covers');
    print('[ProfileStore] Cover upload result: $url');
    if (url != null) {
      final tutorId = prefs.getString('userId');
      if (tutorId != null) {
        final result = await TutorProfileService.updateProfile(tutorId, {'coverPhoto': url});
        print('[ProfileStore] Cover DB update result: $result');
      }
    }
  }

  Future<void> addSubProfile(SubProfile profile) async {
    _subProfiles.add(profile);
    notifyListeners();
    await _saveSubProfiles();
  }

  Future<void> removeSubProfile(int index) async {
    if (index < 0 || index >= _subProfiles.length) return;
    _subProfiles.removeAt(index);
    notifyListeners();
    await _saveSubProfiles();
  }

  Future<void> _saveSubProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSubProfiles, jsonEncode(_subProfiles.map((e) => e.toJson()).toList()));
  }

  Future<void> markGuardianWarningSeen() async {
    _guardianWarningShown = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kGuardianWarning, true);
  }
}

// InheritedWidget — call ProfileStore.of(context) anywhere in the tree
class ProfileStore extends InheritedNotifier<UserProfileStore> {
  const ProfileStore({
    super.key,
    required UserProfileStore store,
    required super.child,
  }) : super(notifier: store);

  static UserProfileStore of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<ProfileStore>();
    assert(w != null, 'No ProfileStore found in widget tree');
    return w!.notifier!;
  }
}
