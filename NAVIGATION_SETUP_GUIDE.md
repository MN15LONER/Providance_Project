# Navigation Setup Guide

## ✅ Completed Tasks

### 1. Bottom Navigation Bar
- **Created**: `lib/core/widgets/main_scaffold.dart`
- **Features**:
  - 5 navigation tabs: Home, Issues, Ideas, Map, Profile
  - Persistent bottom navigation across main screens
  - Active tab highlighting with primary color
  - Smooth navigation without page transitions

### 2. Fixed Back Button Behavior
- **Problem**: Pressing back button closed the entire app
- **Solution**: Implemented smart back navigation:
  - ✅ If on any tab except Home → Navigate to Home tab
  - ✅ If on Home tab → Show "Press back again to exit" message
  - ✅ Double-tap back on Home → Exit app
  - ✅ Prevents accidental app closure

### 3. Router Architecture
- **Updated**: `lib/core/config/router.dart`
- **Structure**:
  - **Auth Routes** (no bottom nav): Login, Signup, Role Selection, Profile Setup
  - **Main Routes** (with bottom nav): Home, Issues List, Ideas Hub, Map, Profile
  - **Secondary Routes** (no bottom nav): Detail pages, Edit pages, Settings, etc.

## 🎯 Navigation Structure

### Main Tabs (with Bottom Navigation):
1. **Home** (`/home`)
   - Dashboard with quick actions
   - User welcome section
   - Recent activity

2. **Issues** (`/issues`)
   - List of all reported issues
   - Filter and search functionality
   - Quick access to report new issue

3. **Ideas** (`/ideas`)
   - Ideas hub with all community ideas
   - Voting and commenting
   - Quick access to propose new idea

4. **Map** (`/map`)
   - Interactive map view
   - Issue and idea locations
   - Geolocation features

5. **Profile** (`/profile`)
   - User profile information
   - Statistics and achievements
   - Account management

### Secondary Pages (without Bottom Navigation):
- Report Issue (`/report-issue`)
- Issue Detail (`/issue/:id`)
- Propose Idea (`/propose-idea`)
- Idea Detail (`/idea/:id`)
- Edit Profile (`/profile/edit`)
- My Contributions (`/profile/contributions`)
- Settings (`/settings`)
- Announcements (`/announcements`)
- Notifications (`/notifications`)
- Leaderboard (`/leaderboard`)
- Points History (`/points-history`)
- Admin Dashboard (`/admin`)

## 🔧 How It Works

### ShellRoute Architecture:
```dart
ShellRoute(
  builder: (context, state, child) {
    return MainScaffold(
      currentPath: state.matchedLocation,
      child: child,
    );
  },
  routes: [
    // Main navigation routes
  ],
)
```

### Back Button Logic:
```
User presses back button
  ↓
Is user on Home tab?
  ├─ NO → Navigate to Home tab
  └─ YES → Is this second press within 2 seconds?
      ├─ NO → Show "Press back again to exit" message
      └─ YES → Exit app
```

### Navigation Flow:
```
User taps bottom nav item
  ↓
context.go(route)
  ↓
GoRouter navigates without animation (NoTransitionPage)
  ↓
MainScaffold updates selected tab
  ↓
Page content updates
```

## 🎨 UI/UX Features

### Bottom Navigation Bar:
- **Type**: Fixed (always visible)
- **Selected Color**: Primary app color
- **Unselected Color**: Grey
- **Icons**: Material Design icons
- **Labels**: Short, descriptive text

### Back Button Behavior:
- **Smart Navigation**: Always returns to Home first
- **Exit Confirmation**: Double-tap to exit
- **User Feedback**: SnackBar message for exit prompt
- **No Accidental Exits**: Prevents closing app by mistake

### Page Transitions:
- **Main Tabs**: No transition (instant switch)
- **Secondary Pages**: Material page transition
- **Smooth Experience**: Fast and responsive

## 📱 User Experience

### Navigation Patterns:

1. **Tab Switching**:
   - Tap any bottom nav icon
   - Instant switch to that screen
   - Previous tab state is preserved

2. **Deep Navigation**:
   - From Home → Tap "Report Issue" → Opens report page (no bottom nav)
   - Press back → Returns to Home
   - Bottom nav reappears

3. **Back Button**:
   - On Profile tab → Press back → Navigate to Home tab
   - On Home tab → Press back → Show exit message
   - Press back again quickly → Exit app

4. **Direct Navigation**:
   - Use `context.go(Routes.profile)` from anywhere
   - Bottom nav automatically highlights correct tab
   - Works from any screen

## 🔒 Route Protection

### Authentication Flow:
```
User opens app
  ↓
Is user logged in?
  ├─ NO → Redirect to Login (no bottom nav)
  └─ YES → Show Home with bottom nav
```

### Route Guards:
- Auth routes (Login, Signup) → No bottom nav
- Main routes (Home, Issues, etc.) → With bottom nav
- Detail routes (Issue Detail, etc.) → No bottom nav
- All routes protected by auth state

## 🚀 Usage Examples

### Navigate to a Tab:
```dart
// From anywhere in the app
context.go(Routes.home);      // Home tab
context.go(Routes.issuesList); // Issues tab
context.go(Routes.ideasHub);   // Ideas tab
context.go(Routes.mapView);    // Map tab
context.go(Routes.profile);    // Profile tab
```

### Navigate to Secondary Page:
```dart
// These pages won't show bottom nav
context.go(Routes.reportIssue);
context.go(Routes.editProfile);
context.go(Routes.settings);
```

### Navigate with Parameters:
```dart
// Issue detail
context.go('${Routes.issueDetail}/123');

// Idea detail
context.go('${Routes.ideaDetail}/456');
```

### Programmatic Navigation:
```dart
// Navigate and replace
context.go(Routes.home);

// Navigate with push (keeps history)
context.push(Routes.reportIssue);

// Go back
context.pop();
```

## 📊 Navigation State

### Current Tab Detection:
The `MainScaffold` automatically detects the current tab based on the route path:
- `/home` → Home tab (index 0)
- `/issues` → Issues tab (index 1)
- `/ideas` → Ideas tab (index 2)
- `/map` → Map tab (index 3)
- `/profile` → Profile tab (index 4)

### State Preservation:
- Each tab maintains its own state
- Switching tabs doesn't reset page state
- Scroll position is preserved
- Form data is maintained

## 🎯 Testing Checklist

- [ ] Bottom navigation bar appears on main screens
- [ ] Tapping nav items switches screens correctly
- [ ] Active tab is highlighted properly
- [ ] Back button on non-home tabs goes to home
- [ ] Back button on home shows exit message
- [ ] Double-tap back on home exits app
- [ ] Secondary pages don't show bottom nav
- [ ] Navigation from anywhere works correctly
- [ ] Deep links work properly
- [ ] Auth flow redirects correctly

## 🔧 Customization

### Change Navigation Items:
Edit `main_scaffold.dart`:
```dart
items: const [
  BottomNavigationBarItem(
    icon: Icon(Icons.your_icon),
    label: 'Your Label',
  ),
  // Add more items
],
```

### Change Colors:
Edit `main_scaffold.dart`:
```dart
selectedItemColor: AppColors.primary,  // Change this
unselectedItemColor: Colors.grey,      // Change this
```

### Change Back Button Behavior:
Edit `_onWillPop()` method in `main_scaffold.dart`:
```dart
Future<bool> _onWillPop() async {
  // Customize logic here
}
```

### Add More Main Routes:
Edit `router.dart` inside `ShellRoute`:
```dart
GoRoute(
  path: Routes.yourRoute,
  name: RouteNames.yourRoute,
  pageBuilder: (context, state) => NoTransitionPage(
    key: state.pageKey,
    child: const YourPage(),
  ),
),
```

## 📝 Notes

- Bottom navigation only shows on main app screens
- Auth screens (login, signup) don't have bottom nav
- Detail pages and forms don't have bottom nav
- Back button behavior is smart and user-friendly
- No accidental app closures
- Smooth navigation without jarring transitions
- State is preserved across tab switches
- Works with both gesture and button navigation

## 🎨 Design Decisions

1. **5 Tabs**: Core features easily accessible
2. **Fixed Type**: All tabs always visible
3. **No Transitions**: Instant tab switching
4. **Smart Back**: Navigate to home before exiting
5. **Exit Confirmation**: Prevent accidental closes
6. **Selective Bottom Nav**: Only on main screens
7. **State Preservation**: Better UX, no data loss

## 🔍 Troubleshooting

### Bottom nav not showing:
- Check if route is inside `ShellRoute`
- Verify route path matches navigation logic

### Back button closes app:
- Ensure `PopScope` is implemented
- Check `_onWillPop()` logic

### Navigation not working:
- Verify route is defined in `router.dart`
- Check route constants in `route_constants.dart`
- Ensure proper auth state

### Wrong tab highlighted:
- Check `_calculateSelectedIndex()` logic
- Verify route path matches expected pattern
