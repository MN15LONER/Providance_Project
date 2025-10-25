# 🔧 Fix Corrupted User Document in Firebase

## Problem
User was created in Firebase Auth but the Firestore user profile is corrupted or incomplete.

## Solution: Delete the User from Firebase Console

### Step 1: Delete from Firebase Authentication
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Authentication** → **Users**
4. Find the user with your email
5. Click the **3 dots** menu → **Delete account**

### Step 2: Delete from Firestore Database
1. In Firebase Console, go to **Firestore Database**
2. Find the `users` collection
3. Find the document with your user ID
4. Click the document → **Delete document**

### Step 3: Sign Up Again
1. Run the app
2. Create a new account with the same or different email
3. Complete the profile setup (select role, ward, municipality)

## Alternative: Fix the Document Manually

If you want to keep the user, you can fix the document structure:

1. Go to **Firestore Database** → `users` collection
2. Click on your user document
3. Make sure it has these fields with correct types:

```
uid: string
email: string
displayName: string
role: string (empty "" or "citizen" or "official")
phoneNumber: string or null
ward: string or null
municipality: string or null
photoURL: string or null
points: number (0)
createdAt: timestamp
updatedAt: timestamp
isActive: boolean (true)
notificationTokens: array (empty [])
achievements: array (empty [])
lastLoginAt: timestamp or null
```

### Important:
- `notificationTokens` and `achievements` MUST be **arrays**, not strings or other types
- All timestamps must be **timestamp** type, not strings
- `points` must be a **number**, not a string

## After Fixing
1. Close the app completely
2. Reopen and try logging in
3. If still having issues, delete and recreate the account

---

**Note:** The app code has been updated with better error handling to prevent this issue in the future.
