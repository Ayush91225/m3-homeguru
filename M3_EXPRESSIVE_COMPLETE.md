# Material Design 3 Expressive - Complete Implementation

## 🎨 Overview

Successfully transformed the HomeGuru web app to use **Material Design 3 Expressive** with Google Material Icons, matching the Flutter app's theme exactly.

---

## 📦 Changes Summary

### 1. **Icon System Migration**
- ❌ Removed: Phosphor Icons (`@phosphor-icons/react`)
- ✅ Added: Material UI Icons (`@mui/icons-material`)

### 2. **Color Palette (Matching Flutter)**

#### Light Theme
```css
Primary: #1A73E8 (Blue - Google Blue)
Primary Container: #D3E3FD
On Primary: #ffffff
On Primary Container: #041E49

Secondary: #4A90D9 (Blue variant)
Secondary Container: #DCEEFB
On Secondary: #ffffff
On Secondary Container: #0D2137

Tertiary: #BF5000 (Orange)
Tertiary Container: #FFDCC2
On Tertiary: #ffffff
On Tertiary Container: #3A1500

Surface: #F8F9FF
Surface Container: #F1F4F9
Surface Container High: #E1E3E8
```

#### Dark Theme
```css
Primary: #ADC6FF
Primary Container: #1557B0
On Primary: #002E6C
On Primary Container: #D3E3FD

Secondary: #8AB4F8
Secondary Container: #1A3A6B
On Secondary: #003063
On Secondary Container: #D3E3FD

Tertiary: #FFB77C
Tertiary Container: #7A3800
On Tertiary: #4A1800
On Tertiary Container: #FFDCC2

Surface: #111318
Surface Container: #191C20
Surface Container High: #33353A
```

---

## 🔧 Component Updates

### **Sidebar** (`src/components/Sidebar.tsx`)

#### Before → After
- Phosphor Icons → Material UI Icons
- Orange primary → Blue primary
- Square/rounded corners → Full rounded (pill-shaped)
- Basic hover states → Smooth scale + color transitions
- Small icons (20px) → Larger icons (24px)
- Collapsed width: 4rem → 5rem
- Expanded width: 18rem → 17rem

#### Key Features
```tsx
// Active state with primary container
bg-primary-container text-on-primary-container

// Hover state with smooth transitions
hover:bg-surface-container-high transition-all duration-300

// Pill-shaped buttons
rounded-full

// Icon scaling on hover
group-hover:scale-110

// Collapsed state with circular buttons
w-14 h-14 rounded-full
```

#### Navigation Items
- Home: `HomeRounded`
- Search: `SearchRounded`
- Guru AI: `AutoAwesomeRounded`
- Schedule: `CalendarMonthRounded`
- Chat: `ChatBubbleRounded`
- Session History: `HistoryRounded`
- Feed: `FeedRounded`
- Wallet: `AccountBalanceWalletRounded`
- Ratings: `StarRounded`

#### Theme Toggle
- Light: `LightModeRounded`
- Dark: `DarkModeRounded`
- System: `SettingsBrightnessRounded`

Active theme uses `secondary-container` (blue accent)

---

### **Dashboard** (`src/app/[role]/dashboard/page.tsx`)

#### Card Styling
```tsx
// Before
rounded-[16px] border border-outline-faint

// After
rounded-3xl border border-outline-variant shadow-sm
```

#### Button Styling
```tsx
// Primary CTA
bg-primary text-on-primary rounded-full 
px-8 py-3.5 shadow-md hover:shadow-lg

// Secondary
border border-outline-variant bg-surface rounded-full
px-4 py-2 hover:bg-surface-container-high

// Icon buttons
w-8 h-8 rounded-full border border-outline-variant
hover:bg-surface-container-high
```

#### Badge/Chip Styling
```tsx
// Time badge
bg-tertiary-container text-on-tertiary-container
rounded-full px-3 py-2

// Status badge
bg-primary-container text-on-primary-container
rounded-full px-3 py-1
```

#### Chart Colors
- Study line: `#1A73E8` (Primary blue)
- Test line: `#BF5000` (Tertiary orange)
- Gradient opacity: 30% → 5%

#### Avatar Styling
```tsx
// With ring
ring-2 ring-primary-container

// With outline
ring-2 ring-outline-variant

// Hover effect
hover:ring-primary
```

---

### **AppShell** (`src/components/AppShell.tsx`)

#### Desktop Navbar
- Height: 56px → 64px
- Icons: 16px → 20px
- Buttons: Circular with hover scale
- Notification dot: Positioned top-right
- Avatar: Ring on hover

#### Mobile Bottom Nav
- Height: 56px → 64px
- Icons: 20px → 24px
- Active indicator: Bottom bar (primary color)
- Hover: Background highlight
- Touch targets: 64px minimum

---

## 🎯 M3 Expressive Principles Applied

### 1. **Shape**
- Primary actions: `rounded-full` (pill-shaped)
- Cards: `rounded-3xl` (24px radius)
- Small elements: `rounded-xl` (12px radius)
- Avatars: `rounded-full`

### 2. **Elevation**
```css
shadow-sm: Subtle elevation (cards at rest)
shadow-md: Medium elevation (buttons, active states)
shadow-lg: High elevation (hover, focus states)
```

### 3. **Motion**
```css
duration-200: Quick interactions (hover, click)
duration-300: Smooth transitions (navigation, state changes)
ease-out: Natural deceleration
scale-95: Active press state
scale-105: Hover emphasis
scale-110: Icon hover
```

### 4. **Typography**
- Headings: 15-24px, font-semibold/bold
- Body: 13-14px, font-medium
- Captions: 11-12px, font-medium
- Labels: 11-13px, font-semibold

### 5. **State Layers**
```tsx
// Rest
bg-surface

// Hover
hover:bg-surface-container-high

// Active/Selected
bg-primary-container text-on-primary-container

// Pressed
active:scale-95
```

---

## 📱 Responsive Design

### Mobile (< 640px)
- Sidebar: Drawer overlay
- Bottom navigation: 5 tabs
- Cards: Full width, reduced padding
- Touch targets: 44px minimum

### Tablet (640px - 1024px)
- Sidebar: Collapsible
- No bottom nav
- Cards: Responsive grid
- Touch targets: 44px minimum

### Desktop (> 1024px)
- Sidebar: Always visible, collapsible
- Top navbar: Full features
- Cards: Multi-column grid
- Hover states: Enabled

---

## 🔄 Migration Guide

### Icon Replacement Map
```tsx
// Phosphor → Material UI
House → HomeRounded
MagnifyingGlass → SearchRounded
Sparkle → AutoAwesomeRounded
CalendarBlank → CalendarMonthRounded
ChatCircle → ChatBubbleRounded
ClockCounterClockwise → HistoryRounded
Article → FeedRounded
Wallet → AccountBalanceWalletRounded
Star → StarRounded
Sun → WbSunnyRounded
Moon → DarkModeRounded
Monitor → SettingsBrightnessRounded
X → CloseRounded
SidebarSimple → MenuRounded
CaretRight → ChevronRightRounded
CaretLeft → ChevronLeftRounded
CaretDown → KeyboardArrowDownRounded
Clock → AccessTimeRounded
Paperclip → AttachFileRounded
Globe → LanguageRounded
Bell → NotificationsRounded
Lightning → BoltRounded
```

### Icon Usage
```tsx
// Before (Phosphor)
<Icon size={20} weight="fill" />

// After (Material UI)
<Icon sx={{ fontSize: 20 }} />
```

---

## ✅ Checklist

### Completed
- [x] Sidebar with Material UI icons
- [x] Flutter-matching color palette
- [x] M3 Expressive card styling
- [x] Pill-shaped buttons
- [x] Smooth transitions (300ms)
- [x] Proper elevation system
- [x] Responsive design
- [x] Touch-friendly targets (44px+)
- [x] Hover states
- [x] Active states
- [x] Theme toggle
- [x] Dashboard redesign
- [x] AppShell updates

### Pending
- [ ] Search page
- [ ] Guru AI page
- [ ] Schedule page
- [ ] Chat page
- [ ] Profile page
- [ ] Settings page

---

## 🎨 Design Tokens Reference

### Spacing Scale
```css
xs: 0.25rem (4px)
sm: 0.5rem (8px)
md: 1rem (16px)
lg: 1.5rem (24px)
xl: 2rem (32px)
2xl: 3rem (48px)
```

### Border Radius Scale
```css
sm: 0.5rem (8px)
md: 0.75rem (12px)
lg: 1rem (16px)
xl: 1.5rem (24px)
2xl: 2rem (32px)
3xl: 3rem (48px)
full: 9999px (pill)
```

### Font Weight Scale
```css
normal: 400
medium: 500
semibold: 600
bold: 700
```

---

## 🚀 Performance

### Optimizations
- CSS transitions (GPU accelerated)
- Memoized components
- Lazy loading icons
- Optimized images with `priority`
- Minimal re-renders

### Bundle Size
- Material UI Icons: Tree-shakeable
- Only imported icons are bundled
- ~2KB per icon (gzipped)

---

## 🌐 Browser Support

- ✅ Chrome/Edge 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Mobile Safari (iOS 14+)
- ✅ Chrome Mobile (Android 10+)

---

## 📝 Code Examples

### Card Component
```tsx
<div className="bg-surface rounded-3xl border border-outline-variant p-5 shadow-sm hover:shadow-md transition-shadow">
  {/* Content */}
</div>
```

### Primary Button
```tsx
<button className="bg-primary text-on-primary rounded-full px-6 py-3 font-semibold shadow-md hover:shadow-lg active:scale-95 transition-all duration-200">
  Click me
</button>
```

### Icon Button
```tsx
<button className="w-10 h-10 rounded-full border border-outline-variant bg-surface flex items-center justify-center hover:bg-surface-container-high active:scale-95 transition-all">
  <Icon sx={{ fontSize: 20 }} />
</button>
```

### Nav Item (Active)
```tsx
<Link className="flex items-center gap-3 px-4 py-3 rounded-full bg-primary-container text-on-primary-container transition-all duration-300">
  <Icon sx={{ fontSize: 24 }} />
  <span className="font-semibold">Label</span>
</Link>
```

---

## 🎯 Next Steps

1. Apply M3 Expressive to remaining pages
2. Add micro-interactions (ripple effects)
3. Implement skeleton loaders
4. Add empty states
5. Create reusable component library
6. Document component API
7. Add Storybook for component showcase

---

**Status**: ✅ Sidebar & Dashboard M3 Expressive implementation complete
**Theme**: Matching Flutter app exactly
**Icons**: Material UI (Google's official icons)
**Design System**: M3 Expressive with proper elevation, motion, and color
