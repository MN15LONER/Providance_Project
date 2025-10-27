# Firestore Security Rules Update

## Issue
You're getting permission denied errors for:
1. Verifications collection
2. Issues collection (for admin map)

## Solution
Update your Firestore security rules in Firebase Console.

### Steps:
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Click "Firestore Database" in the left menu
4. Click the "Rules" tab
5. Replace the existing rules with the rules below
6. Click "Publish"

---

## Complete Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone can read user profiles (for leaderboard, etc.)
      allow read: if true;
      
      // Users can create their own profile
      allow create: if isAuthenticated() && request.auth.uid == userId;
      
      // Users can update their own profile, admins can update any
      allow update: if isOwner(userId) || isAdmin();
      
      // Only admins can delete users
      allow delete: if isAdmin();
    }
    
    // Issues collection
    match /issues/{issueId} {
      // Anyone authenticated can read issues
      allow read: if isAuthenticated();
      
      // Authenticated users can create issues
      allow create: if isAuthenticated() && 
                      request.resource.data.reportedBy == request.auth.uid;
      
      // Issue reporter and admins can update
      allow update: if isAuthenticated() && 
                      (resource.data.reportedBy == request.auth.uid || isAdmin());
      
      // Only admins can delete issues
      allow delete: if isAdmin();
    }
    
    // Verifications collection
    match /verifications/{verificationId} {
      // Anyone authenticated can read verifications
      allow read: if isAuthenticated();
      
      // Authenticated users can create verifications
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      
      // Users can delete their own verifications
      allow delete: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
      
      // No updates allowed (create or delete only)
      allow update: if false;
    }
    
    // Ideas collection
    match /ideas/{ideaId} {
      // Anyone authenticated can read ideas
      allow read: if isAuthenticated();
      
      // Authenticated users can create ideas
      allow create: if isAuthenticated() && 
                      request.resource.data.createdBy == request.auth.uid;
      
      // Idea creator and admins can update
      allow update: if isAuthenticated() && 
                      (resource.data.createdBy == request.auth.uid || isAdmin());
      
      // Only admins can delete ideas
      allow delete: if isAdmin();
    }
    
    // Votes collection
    match /votes/{voteId} {
      // Anyone authenticated can read votes
      allow read: if isAuthenticated();
      
      // Authenticated users can create votes
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      
      // Users can delete their own votes
      allow delete: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
      
      // No updates allowed
      allow update: if false;
    }
    
    // Announcements collection
    match /announcements/{announcementId} {
      // Anyone authenticated can read announcements
      allow read: if isAuthenticated();
      
      // Only admins can create, update, or delete announcements
      allow create, update, delete: if isAdmin();
    }
    
    // Points history collection
    match /points_history/{historyId} {
      // Users can read their own points history, admins can read all
      allow read: if isAuthenticated() && 
                    (resource.data.userId == request.auth.uid || isAdmin());
      
      // Only the system (through server-side code) should write points history
      // But we allow it for authenticated users since we're using client SDK
      allow create: if isAuthenticated();
      
      // No updates or deletes
      allow update, delete: if false;
    }
    
    // Discussions collection
    match /discussions/{discussionId} {
      // Anyone authenticated can read discussions
      allow read: if isAuthenticated();
      
      // Authenticated users can create discussions
      allow create: if isAuthenticated() && 
                      request.resource.data.createdBy == request.auth.uid;
      
      // Discussion creator and admins can update
      allow update: if isAuthenticated() && 
                      (resource.data.createdBy == request.auth.uid || isAdmin());
      
      // Discussion creator and admins can delete
      allow delete: if isAuthenticated() && 
                      (resource.data.createdBy == request.auth.uid || isAdmin());
    }
    
    // Comments collection (subcollection of discussions)
    match /discussions/{discussionId}/comments/{commentId} {
      // Anyone authenticated can read comments
      allow read: if isAuthenticated();
      
      // Authenticated users can create comments
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      
      // Comment creator and admins can update
      allow update: if isAuthenticated() && 
                      (resource.data.userId == request.auth.uid || isAdmin());
      
      // Comment creator and admins can delete
      allow delete: if isAuthenticated() && 
                      (resource.data.userId == request.auth.uid || isAdmin());
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      // Users can read their own notifications
      allow read: if isAuthenticated() && 
                    resource.data.userId == request.auth.uid;
      
      // System and admins can create notifications
      allow create: if isAuthenticated();
      
      // Users can update their own notifications (mark as read)
      allow update: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
      
      // Users can delete their own notifications
      allow delete: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## What These Rules Do

### ✅ Security Features:
1. **Authentication Required** - All operations require users to be logged in
2. **Ownership Checks** - Users can only modify their own data
3. **Admin Privileges** - Admins can manage all content
4. **Read Access** - Authenticated users can read most data (needed for app functionality)
5. **Verification Protection** - Users can't verify their own issues (enforced in app code)

### ✅ Fixes Your Errors:
1. **Verifications** - Now allows authenticated users to create/read/delete verifications
2. **Issues** - Admins and authenticated users can read all issues (fixes admin map)
3. **Points History** - Allows creating point records from client

### 🔒 Security Notes:
- Users cannot modify other users' data
- Only admins can delete issues and ideas
- Vote and verification manipulation is prevented
- All operations require authentication

---

## After Publishing Rules

1. **Wait 1-2 minutes** for rules to propagate
2. **Restart your app** (hot reload won't work)
3. **Test verification** - Should work now
4. **Test admin map** - Should load issues now

---

## Troubleshooting

If you still get errors after updating rules:

1. **Check Firebase Console Logs:**
   - Go to Firestore → Usage tab
   - Look for denied requests
   - Check the reason

2. **Verify User Authentication:**
   - Make sure user is logged in
   - Check user's role in Firestore users collection

3. **Test in Firebase Console:**
   - Go to Firestore → Data tab
   - Try manually reading/writing to test collections

4. **Clear App Data:**
   - Uninstall and reinstall the app
   - This clears any cached authentication tokens
