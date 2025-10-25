# Profile Page Setup Guide

## ✅ Completed Tasks

### 1. Fixed Routing Issue
- **Problem**: Profile route was nested under `/home/profile` but code was navigating to `/profile`
- **Solution**: Changed profile routes from nested to standalone in `router.dart`
- **Routes**:
  - `/profile` - Profile Page
  - `/profile/edit` - Edit Profile Page
  - `/profile/contributions` - My Contributions Page

### 2. Created Profile Service
- **File**: `lib/features/profile/data/services/profile_service.dart`
- **Features**:
  - Fetches user statistics (issues count, ideas count, total upvotes)
  - Updates profile picture URL in Firestore
  - Updates user profile data

### 3. Enhanced Profile Page
- **File**: `lib/features/profile/presentation/pages/profile_page.dart`
- **Features**:
  - ✅ Profile picture with edit functionality
  - ✅ User information display (name, email, role, municipality, ward)
  - ✅ Member since date
  - ✅ Real-time statistics (Points, Reports, Ideas, Upvotes)
  - ✅ Change password via Firebase Auth password reset
  - ✅ Edit profile navigation
  - ✅ My contributions navigation
  - ✅ Settings navigation
  - ✅ Logout with confirmation dialog
  - ✅ Loading states and error handling

### 4. Enhanced Edit Profile Page
- **File**: `lib/features/profile/presentation/pages/edit_profile_page.dart`
- **Features**:
  - ✅ Profile picture upload with preview
  - ✅ Edit name, phone, role, municipality, ward
  - ✅ Image compression (512x512, 75% quality)
  - ✅ Firebase Storage integration
  - ✅ Real-time updates

## 🔧 Firebase Storage Rules

To enable profile picture uploads, ensure your Firebase Storage rules allow authenticated users to upload to the `profile_pictures` folder:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_pictures/{userId}.jpg {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📦 Dependencies

All required dependencies are already in `pubspec.yaml`:
- `image_picker: ^1.0.5` - For selecting images from gallery
- `firebase_storage: ^11.5.6` - For uploading images
- `firebase_auth: ^4.15.1` - For password reset
- `cloud_firestore: ^4.13.6` - For user data

## 🎨 Features Overview

### Profile Page Features:
1. **Profile Header**
   - Circular profile picture with camera icon overlay
   - Upload indicator during image upload
   - User name, email, role badge
   - Member since date

2. **Statistics Row**
   - Points (from user document)
   - Reports count (from issues collection)
   - Ideas count (from ideas collection)
   - Total upvotes (sum of voteCount from user's ideas)

3. **Profile Information Card**
   - Full name
   - Email address
   - Phone number (if available)
   - Role
   - Municipality (if available)
   - Ward (if available)

4. **Account Management**
   - Edit Profile - Navigate to edit page
   - Change Password - Send password reset email
   - My Contributions - View user's reports and ideas
   - Settings - App preferences

5. **Logout Button**
   - Confirmation dialog before logout
   - Redirects to login page

### Edit Profile Page Features:
1. **Profile Picture Upload**
   - Click camera icon to select image
   - Image compression for optimal storage
   - Upload to Firebase Storage
   - Real-time preview

2. **Editable Fields**
   - Full name (with validation)
   - Phone number (with validation)
   - Role (dropdown: Citizen, Government Official)
   - Municipality (dropdown)
   - Ward (dropdown)

3. **Save Functionality**
   - Updates Firestore user document
   - Refreshes user data provider
   - Shows success/error messages
   - Returns to profile page on success

## 🚀 How to Use

### Navigate to Profile:
1. From Home Page: Click the menu icon (top-right) → Select "Profile"
2. From anywhere: Use `context.go(Routes.profile)`

### Upload Profile Picture:
1. Go to Profile Page or Edit Profile Page
2. Click the camera icon on the profile picture
3. Select an image from gallery
4. Image uploads automatically and updates in real-time

### Change Password:
1. Go to Profile Page
2. Click "Change Password"
3. Confirm the email address
4. Check email for password reset link

### Edit Profile:
1. Go to Profile Page
2. Click "Edit Profile" or the edit icon in app bar
3. Update desired fields
4. Click "Save" or "Save Changes"

## 📊 Data Flow

### User Statistics:
```
ProfileService.getUserStatistics(userId)
  ↓
Queries Firestore:
  - issues collection (where createdBy == userId)
  - ideas collection (where createdBy == userId)
  ↓
Returns UserStatistics object
  ↓
Displayed in Profile Page
```

### Profile Picture Upload:
```
User selects image
  ↓
Image compressed (512x512, 75%)
  ↓
Upload to Firebase Storage (/profile_pictures/{userId}.jpg)
  ↓
Get download URL
  ↓
Update Firestore user document (photoURL field)
  ↓
Refresh currentUserModelProvider
  ↓
UI updates automatically
```

## 🎯 Testing Checklist

- [ ] Navigate to profile from home page
- [ ] View user information correctly
- [ ] Statistics load and display correctly
- [ ] Upload profile picture
- [ ] Edit profile information
- [ ] Send password reset email
- [ ] Navigate to My Contributions
- [ ] Navigate to Settings
- [ ] Logout with confirmation
- [ ] All loading states work
- [ ] Error handling works properly

## 📝 Notes

- Profile pictures are stored in Firebase Storage at `profile_pictures/{userId}.jpg`
- Images are automatically compressed to 512x512 pixels at 75% quality
- Password reset uses Firebase Auth's built-in functionality
- All navigation uses GoRouter for type-safe routing
- User statistics are fetched on-demand and cached by Riverpod
- Profile data updates are reflected immediately across the app

## 🔒 Security Considerations

1. **Firebase Storage**: Only authenticated users can upload their own profile pictures
2. **Firestore**: User can only update their own profile data (enforced by security rules)
3. **Password Reset**: Uses Firebase Auth's secure password reset flow
4. **Image Upload**: Images are compressed before upload to prevent large file attacks

## 🎨 UI/UX Highlights

- Clean, modern Material Design
- Consistent color scheme using `AppColors.primary`
- Loading indicators for async operations
- Error messages with retry options
- Confirmation dialogs for destructive actions
- Smooth navigation transitions
- Responsive layout with `SingleChildScrollView`
- Icons for better visual hierarchy
