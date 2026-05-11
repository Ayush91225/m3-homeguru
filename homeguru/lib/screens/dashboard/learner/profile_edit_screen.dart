import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/learner_profile_service.dart';

class LearnerProfileEditScreen extends StatefulWidget {
  const LearnerProfileEditScreen({super.key});

  @override
  State<LearnerProfileEditScreen> createState() => _LearnerProfileEditScreenState();
}

class _LearnerProfileEditScreenState extends State<LearnerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  
  String? _gender;
  String? _grade;
  String? _board;
  List<String> _subjects = [];
  List<String> _goals = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final learnerId = prefs.getString('userId');
      if (learnerId == null) {
        setState(() => _loading = false);
        return;
      }

      final profile = await LearnerProfileService.fetchProfile(learnerId);
      if (profile != null && mounted) {
        setState(() {
          _firstNameController.text = profile['firstName']?.toString() ?? '';
          _lastNameController.text = profile['lastName']?.toString() ?? '';
          _bioController.text = profile['bio']?.toString() ?? '';
          _phoneController.text = profile['phone']?.toString() ?? '';
          _dobController.text = profile['dob']?.toString() ?? '';
          _gender = profile['gender']?.toString();
          _grade = profile['grade']?.toString();
          _board = profile['board']?.toString();
          _subjects = (profile['subjects'] as List?)?.map((e) => e.toString()).toList() ?? [];
          _goals = (profile['goals'] as List?)?.map((e) => e.toString()).toList() ?? [];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final learnerId = prefs.getString('userId');
      if (learnerId == null) {
        throw Exception('User ID not found');
      }

      final updates = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'gender': _gender,
        'grade': _grade,
        'board': _board,
        'subjects': _subjects,
        'goals': _goals,
      };

      final success = await LearnerProfileService.updateProfile(learnerId, updates);

      if (mounted) {
        setState(() => _saving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text('Edit Profile', style: tt.titleMedium),
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _saving ? null : _saveProfile,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Save', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                      hintText: 'YYYY-MM-DD',
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        _dobController.text = date.toIso8601String().split('T')[0];
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _grade,
                    decoration: const InputDecoration(
                      labelText: 'Grade',
                      border: OutlineInputBorder(),
                    ),
                    items: ['6th', '7th', '8th', '9th', '10th', '11th', '12th']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _grade = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _board,
                    decoration: const InputDecoration(
                      labelText: 'Board',
                      border: OutlineInputBorder(),
                    ),
                    items: ['CBSE', 'ICSE', 'State Board', 'IB', 'IGCSE']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) => setState(() => _board = v),
                  ),
                  const SizedBox(height: 24),
                  Text('Subjects', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'English', 'Hindi', 'Social Science']
                        .map((s) => FilterChip(
                              label: Text(s),
                              selected: _subjects.contains(s),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _subjects.add(s);
                                  } else {
                                    _subjects.remove(s);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }
}
