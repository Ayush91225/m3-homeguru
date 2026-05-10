# LEARNER ONBOARDING FLOW - COMPLETE DOCUMENTATION

## Overview
Complete learner onboarding process for both Web (Next.js) and Mobile App (Flutter) with step saving, API integration, and DynamoDB storage.

---

## DATABASE STRUCTURE

### DynamoDB Table: `hg-learner-onboarding`
**Primary Key**: `learnerId`

**Schema**:
```json
{
  "learnerId": "learner_timestamp_randomid",
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "phone": "string",
  "password": "hashed_sha256",
  "phoneVerified": true,
  "emailVerified": false,
  "referralCode": "string (optional)",
  "currentStep": "verify|profile|education|subjects|interests|complete",
  "onboardingComplete": false,
  "onboardingCompletedAt": "ISO timestamp (when complete)",
  "createdAt": "ISO timestamp",
  "updatedAt": "ISO timestamp",
  
  "profile": {
    "name": "string",
    "dob": "YYYY-MM-DD",
    "gender": "male|female|other|prefer-not-to-say",
    "language": "english|hindi|spanish|french|other",
    "type": "school_student|college_student|aspirant|professional|hobbyist",
    "country": "string",
    "state": "string",
    "city": "string"
  },
  
  "education": {
    "type": "school|college|aspirant",
    // For school students:
    "board": "cbse|icse|state|international|other",
    "class": "1-12",
    "school": "string (optional)",
    // For college students:
    "field": "engineering|medicine|commerce|science|arts|...",
    "year": "1|2|3|4|5",
    // For aspirants:
    "field": "engineering|medical|govt|olympiad|law|business|other"
  },
  
  "subjects": {
    "academic": ["Maths", "Physics", "Chemistry", ...],
    "nonAcademic": ["Music", "Art & Craft", "Coding", ...]
  },
  
  "interests": {
    "learningGoals": ["string"],
    "preferredMode": "online|offline|both",
    "availability": ["string"]
  }
}
```

---

## ONBOARDING STEPS

### Step 0: Registration
**Web**: `/register/learner/page.tsx`
**Flutter**: `step0.dart`
**API**: `POST /api/onboarding/learner/register`

**Fields**:
- First Name
- Last Name
- Email
- Phone (with OTP verification)
- Password (min 6 characters)
- Referral Code (optional)

**Process**:
1. User enters details
2. Phone OTP verified via `/api/otp/send` and `/api/otp/verify`
3. API creates learner record with unique `learnerId`
4. Stores session data: `hg_learnerId`, `hg_token`, `hg_firstName`, `hg_lastName`, `hg_email`, `hg_phone`
5. Redirects to: `/register/learner/profile`

**API Response**:
```json
{
  "success": true,
  "data": {
    "learnerId": "learner_1234567890_abc123",
    "token": "base64_token",
    "firstName": "Aditi",
    "lastName": "Sharma",
    "email": "aditi@example.com",
    "phone": "+91 98765 43210",
    "currentStep": "verify"
  }
}
```

---

### Step 1: Profile Setup
**Web**: `/register/learner/profile/page.tsx`
**Flutter**: `step2.dart`
**API**: `POST /api/onboarding/learner/profile`

**Fields**:
- Full Name (pre-filled from registration)
- Date of Birth (date picker)
- Gender (Male, Female, Other, Prefer not to say)
- Language (English, Hindi, Spanish, French, Other)
- Type/Role:
  - School Student
  - College Student
  - Aspirant
  - Working Professional
  - Hobbyist / Lifelong Learner
- Country (searchable dropdown with 50+ countries)
- State/Province (dynamic based on country)
- City (dynamic based on state, or text input)

**Process**:
1. User fills profile details
2. API saves to `profile` object in DynamoDB
3. Updates `currentStep: 'education'`
4. **Conditional Redirect**:
   - If type is `school_student`, `college_student`, or `aspirant` → `/register/learner/education`
   - Else → `/register/learner/success` (skip education)

**API Request**:
```json
{
  "learnerId": "learner_xxx",
  "name": "Aditi Sharma",
  "dob": "2005-03-15",
  "gender": "female",
  "language": "english",
  "type": "school_student",
  "country": "india",
  "state": "Maharashtra",
  "city": "Mumbai"
}
```

---

### Step 2: Education Details (Conditional)
**Web**: `/register/learner/education/page.tsx`
**Flutter**: `step3.dart`
**API**: `POST /api/onboarding/learner/education`

**Only shown if**: `type` is `school_student`, `college_student`, or `aspirant`

**Fields by Type**:

**School Student**:
- Board: CBSE, ICSE, State Board, IB/Cambridge, Other
- Current Class: 1-12
- School Name (optional)

**College Student**:
- Field of Study: Engineering, Medicine, Commerce, Science, Arts, Computer Applications, Law, Architecture, Other
- Current Year: 1st, 2nd, 3rd, 4th, 5th or higher

**Aspirant**:
- Target Field: Engineering (JEE), Medical (NEET), Government Jobs (UPSC/SSC), Olympiads, Law (CLAT), Business & Management, Other

**Process**:
1. User selects education details based on their type
2. API saves to `education` object
3. Updates `currentStep: 'subjects'`
4. Redirects to: `/register/learner/success`

**API Request (School Student)**:
```json
{
  "learnerId": "learner_xxx",
  "type": "school",
  "board": "cbse",
  "class": "10",
  "school": "Delhi Public School"
}
```

---

### Step 3: Success & Completion
**Web**: `/register/learner/success/page.tsx`
**Flutter**: `step8.dart`

**Purpose**: Congratulations screen with auto-redirect

**Process**:
1. Shows success message
2. Auto-redirects after 3 seconds to `/student/dashboard`
3. Onboarding marked as complete

---

## ADDITIONAL PAGES (Not Yet Integrated)

### Subjects Selection
**Web**: `/register/learner/subjects/page.tsx`
**Flutter**: `step4.dart`
**API**: `POST /api/onboarding/learner/subjects`

**Categories**:
1. **Academic Subjects**:
   - Math & Sciences: Maths, Physics, Chemistry, Biology, Computer Sc.
   - Humanities & Social: History, Geography, Economics, Psychology, Law
   - Languages: English, Hindi, French, Spanish
   - Business: Accounting, Business Studies, Finance

2. **Non-Academic Skills**:
   - Creative Arts: Music, Art & Craft, Photography, Dance
   - Tech & Coding: Web Dev, Game Design, Robotics
   - Sports & Wellness: Sports, Yoga, Meditation
   - Life Skills: Chess, Public Speaking, Cooking, Personal Finance

**Process**:
- Multi-select interface
- Can select from both academic and non-academic
- Redirects to level selection

---

### Interests & Preferences
**Web**: `/register/learner/interests/page.tsx`
**Flutter**: `step5.dart`
**API**: `POST /api/onboarding/learner/interests`

**Fields**:
- Learning Goals
- Preferred Mode (Online/Offline/Both)
- Availability

**Process**:
- Final step of onboarding
- Sets `onboardingComplete: true`
- Sets `currentStep: 'complete'`

---

## API ENDPOINTS

### 1. Register Learner
**Endpoint**: `POST /api/onboarding/learner/register`
**File**: `src/app/api/onboarding/learner/register/route.ts`

**Request**:
```json
{
  "firstName": "Aditi",
  "lastName": "Sharma",
  "email": "aditi@example.com",
  "phone": "+91 98765 43210",
  "password": "password123",
  "referralCode": "HOMEGURU50"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Learner registered successfully",
  "data": {
    "learnerId": "learner_1234567890_abc123",
    "token": "base64_token",
    "firstName": "Aditi",
    "lastName": "Sharma",
    "email": "aditi@example.com",
    "phone": "+91 98765 43210",
    "currentStep": "verify"
  }
}
```

---

### 2. Save Profile
**Endpoint**: `POST /api/onboarding/learner/profile`
**File**: `src/app/api/onboarding/learner/profile/route.ts`

**Request**:
```json
{
  "learnerId": "learner_xxx",
  "name": "Aditi Sharma",
  "dob": "2005-03-15",
  "gender": "female",
  "language": "english",
  "type": "school_student",
  "country": "india",
  "state": "Maharashtra",
  "city": "Mumbai"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Profile saved successfully"
}
```

**Updates**: `currentStep: 'education'`

---

### 3. Save Education
**Endpoint**: `POST /api/onboarding/learner/education`
**File**: `src/app/api/onboarding/learner/education/route.ts`

**Request**:
```json
{
  "learnerId": "learner_xxx",
  "type": "school",
  "board": "cbse",
  "class": "10",
  "school": "Delhi Public School"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Education details saved successfully"
}
```

**Updates**: `currentStep: 'subjects'`

---

### 4. Save Subjects
**Endpoint**: `POST /api/onboarding/learner/subjects`
**File**: `src/app/api/onboarding/learner/subjects/route.ts`

**Request**:
```json
{
  "learnerId": "learner_xxx",
  "academic": ["Maths", "Physics", "Chemistry"],
  "nonAcademic": ["Music", "Coding"]
}
```

**Response**:
```json
{
  "success": true,
  "message": "Subject preferences saved successfully"
}
```

**Updates**: `currentStep: 'interests'`

---

### 5. Save Interests & Complete Onboarding
**Endpoint**: `POST /api/onboarding/learner/interests`
**File**: `src/app/api/onboarding/learner/interests/route.ts`

**Request**:
```json
{
  "learnerId": "learner_xxx",
  "learningGoals": ["Improve grades", "Prepare for exams"],
  "preferredMode": "online",
  "availability": ["weekends", "evenings"]
}
```

**Response**:
```json
{
  "success": true,
  "message": "Interests saved and onboarding completed successfully"
}
```

**Updates**: 
- `currentStep: 'complete'`
- `onboardingComplete: true`
- `onboardingCompletedAt: ISO timestamp`

---

### 6. Get Learner Data
**Endpoint**: `GET /api/onboarding/learner/register?learnerId={id}`
**File**: `src/app/api/onboarding/learner/register/route.ts`

**Response**:
```json
{
  "success": true,
  "data": {
    "learnerId": "learner_xxx",
    "firstName": "Aditi",
    "lastName": "Sharma",
    "email": "aditi@example.com",
    "phone": "+91 98765 43210",
    "currentStep": "education",
    "onboardingComplete": false,
    "profile": {...},
    "education": {...}
  }
}
```

---

## LOGIN FLOW

**Web**: `/login/page.tsx`
**API**: `POST /api/auth/login`

**Request**:
```json
{
  "email": "aditi@example.com",
  "password": "password123",
  "role": "learner"
}
```

**Response**:
```json
{
  "success": true,
  "token": "base64_token",
  "userId": "learner_xxx",
  "role": "learner",
  "onboardingComplete": true,
  "currentStep": "complete",
  "learnerData": {
    "name": "Aditi Sharma",
    "email": "aditi@example.com",
    "phone": "+91 98765 43210"
  }
}
```

**Redirect Logic**:
- If `onboardingComplete === true` → `/student/dashboard`
- Else → `/register/learner/{currentStep}` (resume onboarding)

**Note**: Learner login by email is currently not fully implemented (requires DynamoDB GSI on email). For now, learners should use learnerId or implement email-based lookup.

---

## SESSION STORAGE KEYS (Web)

**Learner-specific keys**:
- `hg_learnerId` - Unique learner ID
- `hg_token` - Auth token
- `hg_firstName`, `hg_lastName` - User name
- `hg_email`, `hg_phone` - Contact info
- `hg_learner_role` - Type (school_student, college_student, etc.)

---

## DYNAMODB FUNCTIONS

**File**: `src/lib/dynamodb.ts`

### Learner Functions:
```typescript
// Save learner data
saveLearnerData(learnerData: any): Promise<{success: boolean}>

// Get learner data by learnerId
getLearnerData(learnerId: string): Promise<any | null>

// Update learner data
updateLearnerData(learnerId: string, updates: any): Promise<any>

// Check if learner exists
learnerExists(learnerId: string): Promise<boolean>
```

---

## CURRENT IMPLEMENTATION STATUS

### ✅ Completed:
1. **Registration** - Full API integration
2. **Profile Setup** - Full API integration
3. **Education Details** - Full API integration
4. **DynamoDB Functions** - All learner functions implemented
5. **Login API** - Supports learner role
6. **Session Management** - learnerId stored and used
7. **Step Saving** - currentStep tracked in DynamoDB

### ⚠️ Partially Implemented:
1. **Subjects Selection** - Page exists, API exists, but not integrated
2. **Interests** - Page exists, API exists, but not integrated
3. **Email Verification** - Page exists, but no API integration
4. **Login by Email** - Requires DynamoDB GSI implementation

### 🔄 Flow Simplification:
Current simplified flow skips subjects/interests and goes directly to success after education. This can be expanded later.

**Current Flow**:
```
Register → Profile → Education (conditional) → Success → Dashboard
```

**Full Flow (when subjects/interests integrated)**:
```
Register → Email Verify → Profile → Education → Subjects → Interests → Success → Dashboard
```

---

## COMPARISON: TUTOR vs LEARNER ONBOARDING

| Feature | Tutor | Learner |
|---------|-------|---------|
| **Steps** | 10 steps | 3-4 steps (simplified) |
| **Verification** | Email, Phone, DigiLocker, Bank | Email, Phone only |
| **Payment** | ₹499 annual fee | Free |
| **Test** | 15-min proctored assessment | None |
| **Complexity** | High (compliance required) | Low (quick signup) |
| **Primary Key** | `tutorId` | `learnerId` |
| **Table** | `hg-tutor-onboarding` | `hg-learner-onboarding` |
| **Dashboard** | `/teacher/dashboard` | `/student/dashboard` |

---

## FLUTTER APP STRUCTURE

**Learner Onboarding Steps**:
- `step0.dart` - Registration
- `step1.dart` - Email Verification
- `step1a.dart` - Overview
- `step2.dart` - Profile
- `step3.dart` - Education
- `step4.dart` - Subjects
- `step5.dart` - Interests
- `step6.dart` - Learning Goals
- `step7.dart` - Preferences
- `step8.dart` - Success

**Note**: Flutter app has more detailed steps than web. Web uses simplified flow.

---

## NEXT STEPS TO COMPLETE

1. **Integrate Subjects Page**:
   - Add API call to save selected subjects
   - Update redirect logic

2. **Integrate Interests Page**:
   - Add API call to save interests
   - Mark onboarding as complete

3. **Email Verification**:
   - Create verification email API
   - Add verification link handling

4. **Login by Email**:
   - Create DynamoDB GSI on email field
   - Implement email-based lookup in login API

5. **Dashboard**:
   - Create `/student/dashboard` page
   - Show personalized content based on profile

6. **Resume Onboarding**:
   - Update login to redirect to correct step
   - Pre-fill forms with saved data

---

## TESTING CHECKLIST

- [ ] Register new learner
- [ ] Verify phone OTP
- [ ] Complete profile (all fields)
- [ ] Complete education (school student)
- [ ] Complete education (college student)
- [ ] Complete education (aspirant)
- [ ] Skip education (professional/hobbyist)
- [ ] Check DynamoDB data saved correctly
- [ ] Login with learner credentials
- [ ] Resume incomplete onboarding
- [ ] Redirect to dashboard when complete

---

## ERROR HANDLING

All APIs return consistent error format:
```json
{
  "error": "Error message",
  "details": "Detailed error information"
}
```

Common errors:
- `400` - Missing required fields
- `404` - Learner not found
- `500` - Server error
- `501` - Feature not implemented (email login)

---

END OF DOCUMENTATION
