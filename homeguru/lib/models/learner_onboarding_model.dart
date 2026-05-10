class LearnerOnboarding {
  String? learnerId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? phoneCountry;
  String? referralCode;
  
  // Profile
  String? name;
  String? dob;
  String? gender;
  String? language;
  String? type; // school_student, college_student, aspirant, professional, hobbyist
  String? country;
  String? state;
  String? city;
  
  // Education
  String? educationType; // school, college, aspirant
  String? board; // For school students
  String? studentClass; // For school students
  String? school; // For school students
  String? field; // For college/aspirant
  String? year; // For college students
  
  // Subjects & Interests
  List<String>? subjects;
  String? subjectsCategory; // academic, non-academic
  List<String>? interests;
  
  // Onboarding status
  int currentStep;
  bool onboardingComplete;
  String? token;

  LearnerOnboarding({
    this.learnerId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.phoneCountry,
    this.referralCode,
    this.name,
    this.dob,
    this.gender,
    this.language,
    this.type,
    this.country,
    this.state,
    this.city,
    this.educationType,
    this.board,
    this.studentClass,
    this.school,
    this.field,
    this.year,
    this.subjects,
    this.subjectsCategory,
    this.interests,
    this.currentStep = 0,
    this.onboardingComplete = false,
    this.token,
  });

  factory LearnerOnboarding.fromJson(Map<String, dynamic> json) {
    return LearnerOnboarding(
      learnerId: json['learnerId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      phoneCountry: json['phoneCountry'],
      referralCode: json['referralCode'],
      name: json['profile']?['name'],
      dob: json['profile']?['dob'],
      gender: json['profile']?['gender'],
      language: json['profile']?['language'],
      type: json['profile']?['type'],
      country: json['profile']?['country'],
      state: json['profile']?['state'],
      city: json['profile']?['city'],
      educationType: json['education']?['type'],
      board: json['education']?['board'],
      studentClass: json['education']?['class'],
      school: json['education']?['school'],
      field: json['education']?['field'],
      year: json['education']?['year'],
      subjects: json['subjects']?['subjects'] != null
          ? List<String>.from(json['subjects']['subjects'])
          : null,
      subjectsCategory: json['subjects']?['category'],
      interests: json['interests']?['interests'] != null
          ? List<String>.from(json['interests']['interests'])
          : null,
      currentStep: json['currentStep'] ?? 0,
      onboardingComplete: json['onboardingComplete'] ?? false,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (learnerId != null) 'learnerId': learnerId,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (phoneCountry != null) 'phoneCountry': phoneCountry,
      if (referralCode != null) 'referralCode': referralCode,
      if (name != null || dob != null || gender != null || language != null || 
          type != null || country != null || state != null || city != null)
        'profile': {
          if (name != null) 'name': name,
          if (dob != null) 'dob': dob,
          if (gender != null) 'gender': gender,
          if (language != null) 'language': language,
          if (type != null) 'type': type,
          if (country != null) 'country': country,
          if (state != null) 'state': state,
          if (city != null) 'city': city,
        },
      if (educationType != null || board != null || studentClass != null || 
          school != null || field != null || year != null)
        'education': {
          if (educationType != null) 'type': educationType,
          if (board != null) 'board': board,
          if (studentClass != null) 'class': studentClass,
          if (school != null) 'school': school,
          if (field != null) 'field': field,
          if (year != null) 'year': year,
        },
      if (subjects != null || subjectsCategory != null)
        'subjects': {
          if (subjects != null) 'subjects': subjects,
          if (subjectsCategory != null) 'category': subjectsCategory,
        },
      if (interests != null)
        'interests': {
          'interests': interests,
        },
      'currentStep': currentStep,
      'onboardingComplete': onboardingComplete,
      if (token != null) 'token': token,
    };
  }

  LearnerOnboarding copyWith({
    String? learnerId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? phoneCountry,
    String? referralCode,
    String? name,
    String? dob,
    String? gender,
    String? language,
    String? type,
    String? country,
    String? state,
    String? city,
    String? educationType,
    String? board,
    String? studentClass,
    String? school,
    String? field,
    String? year,
    List<String>? subjects,
    String? subjectsCategory,
    List<String>? interests,
    int? currentStep,
    bool? onboardingComplete,
    String? token,
  }) {
    return LearnerOnboarding(
      learnerId: learnerId ?? this.learnerId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneCountry: phoneCountry ?? this.phoneCountry,
      referralCode: referralCode ?? this.referralCode,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      type: type ?? this.type,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      educationType: educationType ?? this.educationType,
      board: board ?? this.board,
      studentClass: studentClass ?? this.studentClass,
      school: school ?? this.school,
      field: field ?? this.field,
      year: year ?? this.year,
      subjects: subjects ?? this.subjects,
      subjectsCategory: subjectsCategory ?? this.subjectsCategory,
      interests: interests ?? this.interests,
      currentStep: currentStep ?? this.currentStep,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      token: token ?? this.token,
    );
  }
}
