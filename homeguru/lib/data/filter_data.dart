class FilterData {
  static const List<String> categoryOptions = [
    'School Education',
    'Competitive Exams',
    'Language Learning',
    'Study Abroad',
    'Non-Academic',
    'Others'
  ];

  static const Map<String, List<String>> boardOptions = {
    'School Education': ['CBSE', 'ICSE', 'IB', 'IGCSE', 'Others'],
  };

  static const Map<String, List<String>> gradeOptions = {
    'CBSE': ['Grade 1-5', 'Grade 6-8', 'Grade 9-10', 'Grade 11-12', 'Others'],
    'ICSE': ['Grade 1-5', 'Grade 6-8', 'Grade 9-10', 'Grade 11-12', 'Others'],
    'IB': ['Year 1-5', 'Year 6-8', 'Year 9-10', 'Year 11-12', 'Others'],
    'IGCSE': ['Year 1-8', 'Year 9-10', 'Year 11-12', 'Others'],
  };

  static const Map<String, List<String>> subjectOptions = {
    'CBSE-Grade 1-5': ['Mathematics', 'English', 'EVS', 'Hindi', 'Others'],
    'CBSE-Grade 6-8': ['Mathematics', 'Science', 'History', 'Geography', 'Civics', 'English', 'Hindi', 'Sanskrit', 'Others'],
    'CBSE-Grade 9-10': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'History', 'Geography', 'Civics', 'Economics', 'Hindi', 'Sanskrit', 'English', 'Spanish', 'French', 'Russian', 'German', 'Others'],
    'CBSE-Grade 11-12': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'History', 'Geography', 'Political Science', 'Psychology', 'Sociology', 'Computer Science', 'Economics', 'Accountancy', 'Business Studies', 'Physical Education', 'English', 'German', 'Russian', 'Spanish', 'French', 'Chinese', 'Sanskrit', 'Others'],
    'ICSE-Grade 1-5': ['General Science', 'Mathematics', 'English', 'Social Science', 'Hindi', 'Others'],
    'ICSE-Grade 6-8': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'History & Civics', 'Geography', 'English', 'Hindi', 'Sanskrit', 'Others'],
    'ICSE-Grade 9-10': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'History & Civics', 'Geography', 'Sociology', 'Psychology', 'Political Science', 'Computer Science', 'Economics', 'English', 'Hindi', 'Others'],
    'ICSE-Grade 11-12': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'History & Civics', 'Geography', 'Sociology', 'Political Science', 'Psychology', 'Economics', 'Accountancy', 'Business Studies', 'Computer Science', 'English', 'Sanskrit', 'Arabic', 'Others'],
    'IB-Year 1-5': ['Language', 'Social Studies', 'Mathematics', 'Science and Technology', 'Arts', 'Personal, Social and Physical Education', 'Others'],
    'IB-Year 6-8': ['English', 'History', 'Geography', 'Biology', 'Chemistry', 'Physics', 'Mathematics', 'Visual Arts', 'Technology (Computers)', 'Others'],
    'IB-Year 9-10': ['English', 'History', 'Geography', 'Biology', 'Chemistry', 'Physics', 'Algebra', 'Geometry', 'Mathematics', 'Discrete Mathematics', 'Visual Arts', 'Technology (Computers)', 'Others'],
    'IB-Year 11-12': ['English', 'History', 'Economics', 'Business and Management', 'Biology', 'Chemistry', 'Physics', 'Environmental Systems', 'Mathematics', 'Computer Science', 'Others'],
    'IGCSE-Year 1-8': ['English', 'Maths', 'Science', 'History', 'Geography', 'Art and Design', 'Others'],
    'IGCSE-Year 9-10': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'History', 'Geography', 'Accounts', 'Economics', 'Business Studies', 'English Language', 'English Literature', 'Others'],
    'IGCSE-Year 11-12': ['Mathematics', 'Accountancy', 'Business Studies', 'Economics', 'Physics', 'Chemistry', 'Biology', 'Geography', 'Others'],
    'Competitive Exams': ['JEE Mains', 'JEE Advanced', 'NEET', 'AIIMS', 'JIPMER', 'CMC Vellore', 'CMC Ludhiana', 'Manipal', 'BITSAT', 'VITEEE', 'SRMJEEE', 'WBJEE', 'MHT CET', 'KEAM', 'AP EAMCET', 'TS EAMCET', 'CLAT', 'LSAT India', 'DU LLB', 'AILET', 'UPSC CSE', 'IAS', 'UPSC CAPF', 'NDA', 'CDS', 'AFCAT', 'SSC CGL', 'SSC CHSL', 'SSC GD', 'SSC Stenographer', 'SSC MTS', 'IBPS PO', 'IBPS Clerk', 'SBI PO', 'SBI Clerk', 'RBI Grade B', 'RRB NTPC', 'RRB Group D', 'RRB ALP', 'CTET', 'UPTET', 'State TET', 'GATE', 'CAT', 'XAT', 'SNAP', 'NMAT', 'IIFT', 'CUET', 'IPMAT', 'BPSC', 'UPPSC', 'MPPSC', 'RPSC', 'GPSC', 'TNPSC', 'KPSC', 'Others'],
    'Language Learning-Foreign': ['English', 'German', 'French', 'Spanish', 'Russian', 'Chinese', 'Arabic', 'Others'],
    'Language Learning-Regional': ['Tamil', 'Punjabi', 'Sanskrit', 'Hindi', 'Kannada', 'Urdu', 'Marathi', 'Telugu', 'Assamese', 'Bangla', 'Dogri', 'Gujarati', 'Kashmiri', 'Konkani', 'Maithili', 'Malayalam', 'Manipuri', 'Nepali', 'Oriya', 'Santali', 'Sindhi', 'Others'],
    'Study Abroad': ['IELTS', 'TOEFL', 'GRE', 'GMAT', 'SAT', 'ACT', 'PSAT', 'MCAT', 'LSAT', 'Others'],
    'Non-Academic': ['Music - Vocal', 'Music - Tabla', 'Music - Guitar', 'Music - Piano', 'Music - Flute', 'Dance - Western', 'Dance - Indian', 'Yoga', 'Chess', 'Abacus', 'Vedic Maths', 'Basic Computer', 'C Programming', 'C++', 'Java', 'Python', 'Web Development', 'App Development', 'Data Science', 'Machine Learning', 'AI', 'Cybersecurity', 'Cloud Computing', 'Blockchain', 'Digital Marketing', 'Graphic Design', 'Adobe Photoshop', 'Adobe Illustrator', 'Video Editing', 'Animation', '3D Animation', 'VFX', 'Tally', 'MS Office', 'Excel', 'Others'],
  };

  static const List<String> budgetOptions = [
    'Under ₹300/hr',
    '₹300-500/hr',
    '₹500-800/hr',
    'Above ₹800/hr',
    'Others'
  ];
}
