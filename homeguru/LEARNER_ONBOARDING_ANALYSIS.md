# 🔍 DEEP ANALYSIS: TUTOR vs LEARNER ONBOARDING FLOWS

## Date: 2026-05-10
## Status: LEARNER FLOW IS BROKEN - NEEDS FIXING

---

## 📊 COMPARISON TABLE

| Feature | Tutor | Learner | Status |
|---------|-------|---------|--------|
| **Resume Onboarding** | ✅ YES | ❌ NO | BROKEN |
| **Login Persistence** | ✅ YES | ⚠️ PARTIAL | BROKEN |
| **API Check on App Start** | ✅ YES | ❌ NO | BROKEN |
| **currentStep Tracking** | ✅ YES | ✅ YES | OK |
| **onboardingComplete Flag** | ✅ YES | ✅ YES | OK |

---

## 🎯 TUTOR FLOW (WORKING CORRECTLY)

### **1. FLUTTER APP - Tutor Onboarding**

**File**: `lib/screens/onboarding/tutor_onboarding_screen.dart`

```dart
class TutorOnboardingScreen extends StatefulWidget {
  final String? resumeStep;  // ✅ HAS RESUME PARAMETER
  const TutorOnboardingScreen({super.key, this.resumeStep});
  
  @override
  void initState() {
    super.initState();
    if (widget.resumeStep != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resumeFromStep(widget.resumeStep!);  // ✅ RESUMES FROM STEP
      });
    }
  }
  
  void _resumeFromStep(String step) {
    switch (step) {
      case 'subjects': _goStep4(); break;
      case 'overview': _goStep3(); break;
      case 'id': _goStep8(); break;
      case 'test': _goStep5(); break;
      case 'fee': _goStep7(); break;
      case 'bank': _goStep9(); break;
      default: _goStep2();
    }
  }
}
```

**✅ FEATURES:**
- Accepts `resumeStep` parameter
- Has `_resumeFromStep()` method
- Maps step names to navigation methods
- Automatically resumes on init

---

### **2. FLUTTER APP - main.dart Login Persistence**

```dart
Future<void> _checkLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('authToken');
  final userId = prefs.getString('userId');
  final userRole = prefs.getString('userRole');
  
  if (authToken != null && userId != null && userRole != null) {
    if (userRole == 'tutor') {
      // ✅ CHECK ONBOARDING STATUS VIA API
      try {
        final response = await http.get(
          Uri.parse('https://app.homeguruworld.com/api/onboarding/tutor/register?tutorId=$userId'),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data']['onboardingComplete'] == true) {
            _initialRoute = const TutorDashboard();  // ✅ GO TO DASHBOARD
          } else {
            // ✅ RESUME ONBOARDING
            final step = data['data']['currentStep'] ?? 'profile';
            _initialRoute = TutorOnboardingScreen(resumeStep: step);
          }
        }
      } catch (e) {
        _initialRoute = const TutorDashboard();  // Fallback
      }
    }
  }
}
```

**✅ FEATURES:**
- Checks API for onboarding status
- Gets `currentStep` from API
- Passes `resumeStep` to onboarding screen
- Falls back to dashboard on error

---

### **3. API - Tutor Registration GET Endpoint**

**File**: `src/app/api/onboarding/tutor/register/route.ts`

```typescript
export async function GET(request: NextRequest) {
  try {
    const tutorId = request.nextUrl.searchParams.get('tutorId') || 
                    request.headers.get('x-tutor-id');

    if (!tutorId) {
      return NextResponse.json(
        { error: 'Tutor ID is required' },
        { status: 400 }
      );
    }

    const tutorData = await getTutorData(tutorId);

    if (!tutorData) {
      return NextResponse.json(
        { error: 'Tutor not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      data: tutorData,  // ✅ INCLUDES currentStep, onboardingComplete
    });

  } catch (error) {
    console.error('Get registration error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

**✅ FEATURES:**
- GET endpoint exists
- Returns full tutor data
- Includes `currentStep` and `onboardingComplete`

---

## ❌ LEARNER FLOW (BROKEN)

### **1. FLUTTER APP - Learner Onboarding**

**File**: `lib/screens/onboarding/learner_onboarding_screen.dart`

```dart
class LearnerOnboardingScreen extends StatefulWidget {
  const LearnerOnboardingScreen({super.key});  // ❌ NO RESUME PARAMETER
  
  // ❌ NO initState WITH RESUME LOGIC
  // ❌ NO _resumeFromStep() METHOD
}
```

**❌ PROBLEMS:**
- No `resumeStep` parameter
- No resume logic
- Always starts from step 0
- User loses progress

---

### **2. FLUTTER APP - main.dart Login Persistence**

```dart
Future<void> _checkLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('authToken');
  final userId = prefs.getString('userId');
  final userRole = prefs.getString('userRole');
  
  if (authToken != null && userId != null && userRole != null) {
    if (userRole == 'learner') {
      // ❌ NO API CHECK - JUST GO TO DASHBOARD
      if (mounted) {
        setState(() => _initialRoute = const LearnerDashboard());
      }
    }
  }
}
```

**❌ PROBLEMS:**
- No API call to check onboarding status
- Always goes to dashboard
- Doesn't check if onboarding is complete
- User can access dashboard without completing onboarding

---

### **3. API - Learner Registration GET Endpoint**

**File**: `src/app/api/onboarding/learner/register/route.ts`

```typescript
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const learnerId = searchParams.get('learnerId');

    if (!learnerId) {
      return NextResponse.json(
        { error: 'Learner ID is required' },
        { status: 400 }
      );
    }

    const learnerData = await getLearnerData(learnerId);

    if (!learnerData) {
      return NextResponse.json(
        { error: 'Learner not found' },
        { status: 404 }
      );
    }

    // Remove sensitive data
    const { password, ...safeData } = learnerData;

    return NextResponse.json({
      success: true,
      data: safeData,  // ✅ INCLUDES currentStep, onboardingComplete
    });
  } catch (error: any) {
    console.error('[LEARNER-REGISTER-GET] Error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch learner data', details: error.message },
      { status: 500 }
    );
  }
}
```

**✅ API IS OK:**
- GET endpoint exists
- Returns learner data
- Includes `currentStep` and `onboardingComplete`

---

## 🐛 ROOT CAUSES OF BROKEN LEARNER FLOW

### **Issue 1: No Resume Parameter**
**Problem**: `LearnerOnboardingScreen` doesn't accept `resumeStep` parameter
**Impact**: Can't resume from specific step
**Location**: `lib/screens/onboarding/learner_onboarding_screen.dart`

### **Issue 2: No Resume Logic**
**Problem**: No `_resumeFromStep()` method to navigate to specific step
**Impact**: Always starts from beginning
**Location**: `lib/screens/onboarding/learner_onboarding_screen.dart`

### **Issue 3: No API Check on App Start**
**Problem**: `main.dart` doesn't check learner onboarding status via API
**Impact**: Always goes to dashboard, even if onboarding incomplete
**Location**: `lib/main.dart` - `_checkLoginState()` method

### **Issue 4: No Onboarding Resume on Login**
**Problem**: Login doesn't navigate to onboarding if incomplete
**Impact**: User stuck, can't complete onboarding
**Location**: `lib/screens/login/login_screen.dart`

---

## 🔧 FIXES NEEDED

### **FIX 1: Add Resume Parameter to LearnerOnboardingScreen**

```dart
class LearnerOnboardingScreen extends StatefulWidget {
  final String? resumeStep;  // ✅ ADD THIS
  const LearnerOnboardingScreen({super.key, this.resumeStep});  // ✅ ADD THIS
  
  @override
  State<LearnerOnboardingScreen> createState() => _LearnerOnboardingScreenState();
}
```

---

### **FIX 2: Add Resume Logic in initState**

```dart
class _LearnerOnboardingScreenState extends State<LearnerOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ ADD THIS
    if (widget.resumeStep != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resumeFromStep(widget.resumeStep!);
      });
    }
  }
  
  // ✅ ADD THIS METHOD
  void _resumeFromStep(String step) {
    switch (step) {
      case 'verify':
        _goStep1a();  // Email verification
        break;
      case 'source':
        _goStep2();  // Where did you hear about us
        break;
      case 'interests':
        _goStep3();  // Academic/Non-academic
        break;
      case 'subjects':
        _goStep4();  // Subject selection
        break;
      case 'level':
        // Need to load subjects first
        _goStep4();
        break;
      case 'profile':
        _goStep7();  // About you
        break;
      case 'education':
        _goStep8();  // School/College details
        break;
      default:
        _goStep2();  // Default to source
    }
  }
}
```

---

### **FIX 3: Add API Check in main.dart**

```dart
Future<void> _checkLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('authToken');
  final userId = prefs.getString('userId');
  final userRole = prefs.getString('userRole');
  
  if (authToken != null && userId != null && userRole != null) {
    if (userRole == 'learner') {
      // ✅ ADD API CHECK LIKE TUTOR
      try {
        final response = await http.get(
          Uri.parse('https://app.homeguruworld.com/api/onboarding/learner/register?learnerId=$userId'),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (mounted) {
            setState(() {
              if (data['success'] == true && data['data']['onboardingComplete'] == true) {
                _initialRoute = const LearnerDashboard();
              } else {
                // Resume onboarding
                final step = data['data']['currentStep'] ?? 'source';
                _initialRoute = LearnerOnboardingScreen(resumeStep: step);
              }
            });
          }
        } else {
          // API error, go to dashboard
          if (mounted) {
            setState(() => _initialRoute = const LearnerDashboard());
          }
        }
      } catch (e) {
        // Network error, go to dashboard
        if (mounted) {
          setState(() => _initialRoute = const LearnerDashboard());
        }
      }
    }
  }
}
```

---

### **FIX 4: Update onGenerateRoute in main.dart**

```dart
if (settings.name == '/learner-onboarding') {
  // ✅ PASS RESUME STEP LIKE TUTOR
  final args = settings.arguments as Map<String, dynamic>?;
  final resumeStep = args?['resumeStep'] as String?;
  return MaterialPageRoute(
    builder: (context) => LearnerOnboardingScreen(resumeStep: resumeStep),
  );
}
```

---

## 📋 STEP-BY-STEP IMPLEMENTATION PLAN

### **Step 1: Update LearnerOnboardingScreen**
- [ ] Add `resumeStep` parameter to constructor
- [ ] Add `initState` with resume logic
- [ ] Add `_resumeFromStep()` method
- [ ] Map all step names to navigation methods

### **Step 2: Update main.dart**
- [ ] Add API check for learner in `_checkLoginState()`
- [ ] Get `currentStep` from API response
- [ ] Pass `resumeStep` to `LearnerOnboardingScreen`
- [ ] Update `onGenerateRoute` to accept `resumeStep`

### **Step 3: Test Complete Flow**
- [ ] Register new learner
- [ ] Stop at middle step (e.g., subjects)
- [ ] Close app
- [ ] Reopen app
- [ ] Should resume from subjects step

---

## 🎯 EXPECTED BEHAVIOR AFTER FIX

### **Scenario 1: New Learner**
1. User registers
2. Completes email verification
3. Stops at "interests" step
4. Closes app
5. **Reopens app** → Should resume at "interests" step ✅

### **Scenario 2: Returning Learner (Incomplete)**
1. User logged in previously
2. Onboarding incomplete (currentStep: 'profile')
3. Opens app
4. **Should go to onboarding at 'profile' step** ✅

### **Scenario 3: Returning Learner (Complete)**
1. User logged in previously
2. Onboarding complete (onboardingComplete: true)
3. Opens app
4. **Should go directly to dashboard** ✅

---

## 📊 CURRENT vs EXPECTED BEHAVIOR

| Scenario | Current (Broken) | Expected (Fixed) |
|----------|------------------|------------------|
| **New learner stops mid-onboarding** | Loses progress, starts from beginning | Resumes from last step |
| **Learner reopens app (incomplete)** | Goes to dashboard | Goes to onboarding |
| **Learner reopens app (complete)** | Goes to dashboard ✅ | Goes to dashboard ✅ |
| **Login with incomplete onboarding** | Goes to dashboard | Goes to onboarding |

---

## 🚀 PRIORITY

**CRITICAL** - This breaks the entire learner onboarding experience!

Users cannot:
- Resume their onboarding
- Complete registration properly
- Have a smooth experience

**Must fix immediately!**
