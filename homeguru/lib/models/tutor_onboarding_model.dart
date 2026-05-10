class TutorOnboarding {
  final Map<String, dynamic> _data = {};
  String? tutorId;
  int? currentStep;

  TutorOnboarding({this.tutorId, this.currentStep});

  // Set any field dynamically
  void set(String key, dynamic value) {
    _data[key] = value;
  }

  // Get any field dynamically
  dynamic get(String key) {
    return _data[key];
  }

  // Set multiple fields at once
  void setAll(Map<String, dynamic> data) {
    _data.addAll(data);
  }

  // Get all data
  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(_data);
  }

  // Load from JSON
  factory TutorOnboarding.fromJson(Map<String, dynamic> json) {
    final onboarding = TutorOnboarding(
      tutorId: json['tutorId'],
      currentStep: json['currentStep'],
    );
    
    // Remove metadata fields and add rest to _data
    final data = Map<String, dynamic>.from(json);
    data.remove('tutorId');
    data.remove('currentStep');
    data.remove('currentStepStatus');
    data.remove('stepsCompleted');
    data.remove('createdAt');
    data.remove('updatedAt');
    data.remove('createdDate');
    data.remove('createdTime');
    
    onboarding.setAll(data);
    return onboarding;
  }

  // Clear all data
  void clear() {
    _data.clear();
  }

  // Check if field exists
  bool has(String key) {
    return _data.containsKey(key);
  }
}
