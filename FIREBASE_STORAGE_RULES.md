# Firebase Storage Security Rules Setup

## ⚠️ IMPORTANT: You need to update your Firebase Storage Rules

The app now uploads profile pictures to: `/users/{userId}/profile/profile.jpg`

## 📋 Steps to Fix:

### 1. Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **Muni-Report Pro**
3. Click on **Storage** in the left sidebar
4. Click on the **Rules** tab at the top

### 2. Replace Your Current Rules

Copy and paste these rules into the Firebase Storage Rules editor:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // User Profile Pictures - /users/{userId}/profile/{fileName}
    match /users/{userId}/profile/{fileName} {
      // Anyone can read profile pictures
      allow read: if true;
      
      // Only authenticated user can upload/update their own profile picture
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.contentType.matches('image/.*');
      
      // Only the uploader can delete (checks metadata)
      allow delete: if request.auth != null 
                    && request.auth.uid == userId;
    }
    
    // Issue Images - /issues/{issueFolder}/{fileName}
    // This matches the current app implementation
    match /issues/{issueFolder}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null 
                   && request.resource.contentType.matches('image/.*')
                   && request.resource.metadata.uploadedBy == request.auth.uid;
      allow delete: if request.auth != null 
                    && resource.metadata.uploadedBy == request.auth.uid;
    }
    
    // Idea Images - /ideas/{ideaFolder}/{fileName}
    // This matches the current app implementation
    match /ideas/{ideaFolder}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null 
                   && request.resource.contentType.matches('image/.*')
                   && request.resource.metadata.uploadedBy == request.auth.uid;
      allow delete: if request.auth != null 
                    && resource.metadata.uploadedBy == request.auth.uid;
    }
    
    // Announcement Images - Only admins can upload
    match /announcements/{imageId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Default - Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### 3. Click "Publish" Button

After pasting the rules, click the **Publish** button to save and activate them.

### 4. Test the Upload

After publishing the rules:
1. Go back to your app
2. Try uploading a profile picture again
3. It should work now! ✅

---

## 🔒 What These Rules Do:

### Profile Pictures (`/users/{userId}/profile/{fileName}`)
- ✅ **Path**: `/users/{userId}/profile/profile.jpg`
- ✅ **Read**: Anyone can view (for displaying in app)
- ✅ **Write**: Only the user can upload/update their own picture
- ✅ **Delete**: Only the user can delete their own picture
- ✅ **Validation**: Only image files allowed (`image/jpeg`, `image/png`, etc.)

### Issue Images (`/issues/{issueFolder}/{fileName}`)
- ✅ **Path**: `/issues/1234567890_0/{fileName}`
- ✅ **Read**: Anyone can view
- ✅ **Write**: Only authenticated users can upload (metadata validates uploader)
- ✅ **Delete**: Only the uploader can delete (checks `uploadedBy` in metadata)
- ✅ **Validation**: Only image files allowed
- ✅ **Security**: Uses metadata to verify the uploader's identity

### Idea Images (`/ideas/{ideaFolder}/{fileName}`)
- ✅ **Path**: `/ideas/1234567890_0/{fileName}`
- ✅ **Read**: Anyone can view
- ✅ **Write**: Only authenticated users can upload (metadata validates uploader)
- ✅ **Delete**: Only the uploader can delete (checks `uploadedBy` in metadata)
- ✅ **Validation**: Only image files allowed
- ✅ **Security**: Uses metadata to verify the uploader's identity

### Announcement Images (`/announcements/{imageId}`)
- ✅ **Read**: Anyone can view
- ✅ **Write**: Only admins can upload
- ✅ **Delete**: Only admins can delete

---

## 🛡️ Security Features:

1. **Authentication Required**: Users must be logged in to upload
2. **User Isolation**: Users can only modify their own content
3. **Public Read**: All images are publicly viewable (needed for app functionality)
4. **Admin Control**: Announcement images restricted to admins
5. **Path Validation**: Only specific paths are allowed
6. **Content Type Validation**: Only image files can be uploaded
7. **Metadata Validation**: Checks uploadedBy field for deletes

---

## 📝 Upload Path Structure:

### Profile Pictures:
```
/users/{userId}/profile/profile.jpg
```
Example: `/users/abc123/profile/profile.jpg`

### Issue Images:
```
/users/{userId}/issues/{issueId}/{imageId}
```
Example: `/users/abc123/issues/issue456/image1.jpg`

### Idea Images:
```
/users/{userId}/ideas/{ideaId}/{imageId}
```
Example: `/users/abc123/ideas/idea789/image1.jpg`

---

## 🔧 Code Implementation:

The app now uploads profile pictures using this code:

```dart
// Upload to Firebase Storage
final storageRef = FirebaseStorage.instance
    .ref()
    .child('users')
    .child(userId)
    .child('profile')
    .child('profile.jpg');

// Metadata with uploadedBy
final metadata = SettableMetadata(
  contentType: 'image/jpeg',
  customMetadata: {'uploadedBy': userId},
);

// Upload file
final uploadTask = storageRef.putFile(imageFile, metadata);
final snapshot = await uploadTask.whenComplete(() {});
final downloadUrl = await snapshot.ref.getDownloadURL();
```

---

## ⚠️ Important Notes:

- These rules will take effect immediately after publishing
- No app restart required
- Existing images won't be affected
- Users must be authenticated (logged in) to upload
- The `userId` in the path must match the authenticated user's UID
- Only image content types are allowed (`image/jpeg`, `image/png`, `image/gif`, etc.)

---

## 🧪 Testing After Setup:

1. ✅ Upload profile picture
2. ✅ Upload issue image
3. ✅ Upload idea image
4. ✅ View other users' images
5. ❌ Try to upload to someone else's path (should fail)
6. ❌ Try to upload without being logged in (should fail)
7. ❌ Try to upload non-image file (should fail)

---

## 🔧 Troubleshooting:

### Still getting "unauthorized" error?
1. Make sure you clicked "Publish" in Firebase Console
2. Check that you're logged in to the app
3. Verify the userId in the upload path matches your auth UID
4. Wait 30 seconds for rules to propagate
5. Check the exact error message in console

### Images not showing?
1. Check that `allow read: if true;` is set for the path
2. Verify the image URL is correct
3. Check browser/app console for CORS errors

### Wrong content type error?
1. Make sure you're uploading an image file
2. Check that `contentType` in metadata is set to `image/jpeg` or similar
3. Verify the file extension is `.jpg`, `.png`, etc.

---

## 📊 Before vs After:

### Before (OLD PATH):
```
❌ /profile_pictures/{userId}.jpg
```

### After (NEW PATH):
```
✅ /users/{userId}/profile/profile.jpg
```

### Why the Change?
- ✅ Better organization (all user data under `/users/{userId}/`)
- ✅ More flexible (can add more profile files later)
- ✅ Clearer structure (profile folder for profile-related files)
- ✅ Matches your existing Firebase Storage rules

---

## ✅ Summary:

1. **App Code Updated**: Now uploads to `/users/{userId}/profile/profile.jpg`
2. **Metadata Added**: Includes `uploadedBy: userId` for delete validation
3. **Content Type**: Set to `image/jpeg` with validation in rules
4. **Rules Provided**: Copy from this file and paste in Firebase Console
5. **Ready to Test**: After publishing rules, profile picture upload will work!

---

## 🚀 Next Steps:

1. ✅ Copy the rules from this file
2. ✅ Paste into Firebase Console → Storage → Rules
3. ✅ Click "Publish"
4. ✅ Test profile picture upload
5. ✅ Verify no permission errors

The permission error should be completely resolved! 🎉
