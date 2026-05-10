# Web Learner Onboarding Issues & Fixes

## Critical Issues Found

### 1. ❌ Data NOT Being Saved to Database

**Problem**: Most onboarding steps only save to `sessionStorage`, NOT to DynamoDB

| Step | Page | Saves to DB? | API Endpoint |
|------|------|--------------|--------------|
| Source | `/register/learner/source` | ❌ NO | None - only sessionStorage |
| Interests | `/register/learner/interests` | ❌ NO | None - only sessionStorage |
| Subjects | `/register/learner/subjects` | ❌ NO | None - only sessionStorage |
| Level | `/register/learner/level` | ❌ MISSING | Page doesn't exist |
| Profile | `/register/learner/profile` | ✅ YES | `/api/onboarding/learner/profile` |
| Education | `/register/learner/education` | ✅ YES | `/api/onboarding/learner/education` |

**Impact**: When user logs in again, all their source/interests/subjects selections are lost

---

### 2. ❌ Login Always Redirects to `/teacher/dashboard`

**Problem**: In `src/app/login/page.tsx` (lines 56-57), BOTH learner and tutor redirect to teacher dashboard

**Current Code**:
```typescript
// Redirect based on onboarding status
if (data.onboardingComplete) {
  router.replace("/teacher/dashboard");  // ❌ WRONG!
} else {
  // Resume onboarding at last step
  const stepMap: Record<string, string> = {
    profile: "/register/tutor/profile",  // ❌ Only tutor steps!
    subjects: "/register/tutor/subjects",
    // ...
  };
}
```

**Impact**: Learners who complete onboarding are sent to teacher dashboard instead of student dashboard

---

### 3. ❌ Missing `/api/onboarding/learner/complete` Endpoint

**Problem**: No API endpoint to mark learner onboarding as complete

**Current Endpoints**:
- ✅ `/api/onboarding/tutor/complete` - EXISTS
- ❌ `/api/onboarding/learner/complete` - MISSING

**Impact**: Even if user completes all steps, `onboardingComplete` field in DynamoDB is never set to `true`

---

### 4. ❌ Missing Level/Proficiency Page

**Problem**: Subjects page redirects to `/register/learner/level` but this page doesn't exist

**Code in subjects page**:
```typescript
router.push(`/register/learner/level?category=${category}&subjects=${encodeURIComponent(list)}`);
```

**Impact**: User gets 404 error after selecting subjects

---

## Fixes Required

### Fix 1: Update Login Redirect Logic

**File**: `src/app/login/page.tsx`

**Change lines 56-70**:
```typescript
// Redirect based on onboarding status
if (data.onboardingComplete) {
  // ✅ FIX: Redirect based on role
  const dashboardPath = data.role === "learner" ? "/student/dashboard" : "/teacher/dashboard";
  router.replace(dashboardPath);
} else {
  // Resume onboarding at last step
  const stepMap: Record<string, string> = data.role === "learner" 
    ? {
        // Learner onboarding steps
        verify: "/register/learner/verify",
        source: "/register/learner/source",
        interests: "/register/learner/interests",
        subjects: "/register/learner/subjects",
        level: "/register/learner/level",
        profile: "/register/learner/profile",
        education: "/register/learner/education",
      }
    : {
        // Tutor onboarding steps
        profile: "/register/tutor/profile",
        subjects: "/register/tutor/subjects",
        overview: "/register/tutor/overview",
        id: "/register/tutor/id",
        test: "/register/tutor/test",
        fee: "/register/tutor/fee",
        bank: "/register/tutor/bank",
        golive: "/register/tutor/golive",
      };
  
  const redirectPath = stepMap[data.currentStep] || 
    (data.role === "learner" ? "/register/learner/source" : "/register/tutor/profile");
  router.replace(redirectPath);
}
```

---

### Fix 2: Create API Endpoints to Save Data

#### A. Create `/api/onboarding/learner/source/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { updateLearnerData } from '@/lib/dynamodb';

export async function POST(request: NextRequest) {
  try {
    const { learnerId, source } = await request.json();

    if (!learnerId || !source) {
      return NextResponse.json(
        { error: 'learnerId and source are required' },
        { status: 400 }
      );
    }

    await updateLearnerData(learnerId, {
      source,
      currentStep: 'interests',
      updatedAt: new Date().toISOString(),
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error saving source:', error);
    return NextResponse.json(
      { error: 'Failed to save source' },
      { status: 500 }
    );
  }
}
```

#### B. Create `/api/onboarding/learner/interests/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { updateLearnerData } from '@/lib/dynamodb';

export async function POST(request: NextRequest) {
  try {
    const { learnerId, interest } = await request.json();

    if (!learnerId || !interest) {
      return NextResponse.json(
        { error: 'learnerId and interest are required' },
        { status: 400 }
      );
    }

    await updateLearnerData(learnerId, {
      interest,
      currentStep: 'subjects',
      updatedAt: new Date().toISOString(),
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error saving interest:', error);
    return NextResponse.json(
      { error: 'Failed to save interest' },
      { status: 500 }
    );
  }
}
```

#### C. Update existing `/api/onboarding/learner/subjects/route.ts`

Add POST method if it doesn't exist:

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { updateLearnerData } from '@/lib/dynamodb';

export async function POST(request: NextRequest) {
  try {
    const { learnerId, subjects, category } = await request.json();

    if (!learnerId || !subjects) {
      return NextResponse.json(
        { error: 'learnerId and subjects are required' },
        { status: 400 }
      );
    }

    await updateLearnerData(learnerId, {
      subjects,
      category,
      currentStep: 'level',
      updatedAt: new Date().toISOString(),
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error saving subjects:', error);
    return NextResponse.json(
      { error: 'Failed to save subjects' },
      { status: 500 }
    );
  }
}
```

#### D. Create `/api/onboarding/learner/complete/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { updateLearnerData } from '@/lib/dynamodb';

export async function POST(request: NextRequest) {
  try {
    const { learnerId } = await request.json();

    if (!learnerId) {
      return NextResponse.json(
        { error: 'learnerId is required' },
        { status: 400 }
      );
    }

    await updateLearnerData(learnerId, {
      onboardingComplete: true,
      currentStep: 'completed',
      updatedAt: new Date().toISOString(),
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error completing onboarding:', error);
    return NextResponse.json(
      { error: 'Failed to complete onboarding' },
      { status: 500 }
    );
  }
}
```

---

### Fix 3: Update Frontend Pages to Save Data

#### A. Update `src/app/register/learner/source/page.tsx`

**Change the `handleContinue` function** (around line 32):

```typescript
async function handleContinue() {
  if (!selected || loading) return;
  
  setLoading(true);
  const learnerId = sessionStorage.getItem('hg_learnerId');
  
  if (!learnerId) {
    alert('Session expired. Please register again.');
    router.push('/register/learner');
    return;
  }
  
  try {
    // ✅ Save to database
    const response = await fetch('/api/onboarding/learner/source', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ learnerId, source: selected }),
    });
    
    const data = await response.json();
    
    if (data.success) {
      sessionStorage.setItem("learner_source", selected);
      router.push("/register/learner/interests");
    } else {
      alert(data.error || 'Failed to save source');
      setLoading(false);
    }
  } catch (error) {
    alert('Error saving source. Please try again.');
    setLoading(false);
  }
}
```

#### B. Update `src/app/register/learner/interests/page.tsx`

**Change the `handleContinue` function** (around line 38):

```typescript
async function handleContinue() {
  if (!selected || loading) return;
  
  setLoading(true);
  const learnerId = sessionStorage.getItem('hg_learnerId');
  
  if (!learnerId) {
    alert('Session expired. Please register again.');
    router.push('/register/learner');
    return;
  }
  
  try {
    // ✅ Save to database
    const response = await fetch('/api/onboarding/learner/interests', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ learnerId, interest: selected }),
    });
    
    const data = await response.json();
    
    if (data.success) {
      sessionStorage.setItem("learner_interest", selected);
      router.push(`/register/learner/subjects?category=${selected}`);
    } else {
      alert(data.error || 'Failed to save interest');
      setLoading(false);
    }
  } catch (error) {
    alert('Error saving interest. Please try again.');
    setLoading(false);
  }
}
```

#### C. Update `src/app/register/learner/subjects/page.tsx`

**Change the `handleContinue` function** (around line 95):

```typescript
async function handleContinue() {
  if (!selected.size || loading) return;
  
  setLoading(true);
  setError("");
  const learnerId = sessionStorage.getItem('hg_learnerId');
  
  if (!learnerId) {
    setError('Session expired. Please register again.');
    router.push('/register/learner');
    return;
  }
  
  try {
    const subjectsList = Array.from(selected);
    
    // ✅ Save to database
    const response = await fetch('/api/onboarding/learner/subjects', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        learnerId, 
        subjects: subjectsList,
        category 
      }),
    });
    
    const data = await response.json();
    
    if (data.success) {
      // ✅ Skip level page for now, go directly to profile
      router.push("/register/learner/profile");
    } else {
      setError(data.error || 'Failed to save subjects');
      setLoading(false);
    }
  } catch (error) {
    setError('Error saving subjects. Please try again.');
    setLoading(false);
  }
}
```

#### D. Update `src/app/register/learner/success/page.tsx`

**Add API call before redirect** (around line 12):

```typescript
useEffect(() => {
  // ✅ Mark onboarding as complete
  const completeOnboarding = async () => {
    const learnerId = sessionStorage.getItem('hg_learnerId');
    
    if (learnerId) {
      try {
        await fetch('/api/onboarding/learner/complete', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ learnerId }),
        });
      } catch (error) {
        console.error('Error completing onboarding:', error);
      }
    }
  };
  
  completeOnboarding();
  
  const timer = setTimeout(() => {
    router.push("/student/dashboard");
  }, 3000);
  
  return () => clearTimeout(timer);
}, [router]);
```

---

## Summary of Changes

### Backend (API Routes)
1. ✅ Create `/api/onboarding/learner/source/route.ts`
2. ✅ Create `/api/onboarding/learner/interests/route.ts`  
3. ✅ Update `/api/onboarding/learner/subjects/route.ts` (add POST if missing)
4. ✅ Create `/api/onboarding/learner/complete/route.ts`

### Frontend (Pages)
1. ✅ Fix `src/app/login/page.tsx` - role-based dashboard redirect
2. ✅ Update `src/app/register/learner/source/page.tsx` - save to DB
3. ✅ Update `src/app/register/learner/interests/page.tsx` - save to DB
4. ✅ Update `src/app/register/learner/subjects/page.tsx` - save to DB & skip level page
5. ✅ Update `src/app/register/learner/success/page.tsx` - mark onboarding complete

---

## Testing Checklist

After implementing fixes:

- [ ] Register new learner account
- [ ] Complete all onboarding steps
- [ ] Verify data is saved in DynamoDB after each step
- [ ] Check `onboardingComplete` is set to `true` after success page
- [ ] Logout and login again
- [ ] Verify redirect goes to `/student/dashboard` (not `/teacher/dashboard`)
- [ ] Verify all saved data is still present in database

---

## Database Fields to Check

After onboarding completion, learner record should have:

```json
{
  "learnerId": "uuid",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890",
  "source": "google",              // ✅ Should be saved
  "interest": "academic",          // ✅ Should be saved
  "subjects": ["Maths", "Physics"], // ✅ Should be saved
  "category": "academic",          // ✅ Should be saved
  "name": "John Doe",
  "dob": "2005-01-15",
  "gender": "male",
  "language": "english",
  "type": "school_student",
  "country": "india",
  "state": "Maharashtra",
  "city": "Mumbai",
  "onboardingComplete": true,      // ✅ Should be true
  "currentStep": "completed",      // ✅ Should be "completed"
  "createdAt": "2025-01-23T...",
  "updatedAt": "2025-01-23T..."
}
```
