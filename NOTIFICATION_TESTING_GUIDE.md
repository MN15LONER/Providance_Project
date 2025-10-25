# 🧪 Notification Testing Guide

## Quick Start Testing

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Rebuild App
```bash
# For Android
flutter run

# For iOS (if on Mac)
flutter run
```

### Step 3: Get FCM Token
1. Open app on physical device
2. Check debug console/logs
3. Look for: `FCM Token: YOUR_TOKEN_HERE`
4. Copy the token

### Step 4: Send Test Notification

**Go to Firebase Console**:
1. Navigate to: https://console.firebase.google.com
2. Select your project
3. Go to: **Cloud Messaging** (left sidebar)
4. Click: **Send your first message** (or **New campaign**)

**Fill in the form**:
```
Notification title: Test Notification
Notification text: This is a test from Firebase Console
```

**Send to specific device**:
1. Click **Send test message**
2. Paste your FCM token
3. Click **Test**

---

## Test Scenarios

### ✅ Test 1: Foreground Notification
**Setup**: App is open and active

**Steps**:
1. Keep app open
2. Send notification from Firebase Console
3. Observe local notification banner

**Expected**:
- ✅ Notification banner appears
- ✅ Tap opens Notification Center
- ✅ Notification saved to Firestore
- ✅ Appears in Notification Center list

---

### ✅ Test 2: Background Notification
**Setup**: App is in background

**Steps**:
1. Open app
2. Press home button (don't close app)
3. Send notification from Firebase Console
4. Tap notification when it appears

**Expected**:
- ✅ Notification appears in system tray
- ✅ Tap brings app to foreground
- ✅ Navigation works (if relatedId provided)
- ✅ Notification marked as read

---

### ✅ Test 3: Terminated App
**Setup**: App is completely closed

**Steps**:
1. Force close app (swipe away from recent apps)
2. Send notification from Firebase Console
3. Tap notification

**Expected**:
- ✅ App launches
- ✅ Navigation works (if relatedId provided)
- ✅ Notification marked as read

---

### ✅ Test 4: Navigation - Issue Status Update

**Notification Payload**:
```json
{
  "notification": {
    "title": "Issue Status Updated",
    "body": "Your pothole report has been reviewed"
  },
  "data": {
    "type": "status_update",
    "relatedType": "issue",
    "relatedId": "PASTE_REAL_ISSUE_ID_HERE"
  }
}
```

**Steps**:
1. Create an issue in the app first
2. Copy the issue ID
3. Send notification with issue ID
4. Tap notification

**Expected**:
- ✅ Navigates to Issue Detail page
- ✅ Shows correct issue
- ✅ Notification marked as read

---

### ✅ Test 5: Navigation - Idea Response

**Notification Payload**:
```json
{
  "notification": {
    "title": "Official Response Received",
    "body": "Municipality responded to your park improvement idea"
  },
  "data": {
    "type": "idea_response",
    "relatedType": "idea",
    "relatedId": "PASTE_REAL_IDEA_ID_HERE"
  }
}
```

**Steps**:
1. Create an idea in the app first
2. Copy the idea ID
3. Send notification with idea ID
4. Tap notification

**Expected**:
- ✅ Navigates to Idea Detail page
- ✅ Shows correct idea
- ✅ Notification marked as read

---

### ✅ Test 6: Notification Center UI

**Steps**:
1. Send 3-5 test notifications
2. Open app
3. Navigate to Notification Center
4. Test interactions:
   - Tap notification → Navigate
   - Swipe notification → Delete
   - Tap "Mark all read" → All marked
   - Menu → "Delete all" → Confirm → All deleted

**Expected**:
- ✅ All notifications display
- ✅ Unread notifications highlighted
- ✅ Swipe to delete works
- ✅ Mark all as read works
- ✅ Delete all works
- ✅ Navigation works

---

### ✅ Test 7: Token Management

**Steps**:
1. Open app and login
2. Check Firestore console
3. Navigate to: `users/{userId}`
4. Verify `notificationTokens` field exists

**Expected**:
```javascript
{
  "notificationTokens": ["fcm_token_here"],
  "lastTokenUpdate": Timestamp
}
```

---

## 🔧 Troubleshooting

### Issue: No FCM Token in Logs
**Solution**:
1. Check permissions granted
2. Verify Firebase configuration
3. Rebuild app
4. Check internet connection

### Issue: Notification Not Received
**Solution**:
1. Verify FCM token is correct
2. Check Firebase Console for errors
3. Verify app is not in battery optimization
4. Check notification permissions

### Issue: Navigation Not Working
**Solution**:
1. Verify `relatedId` is correct
2. Check route exists in router
3. Verify data payload structure
4. Check logs for errors

### Issue: Local Notification Not Showing (Foreground)
**Solution**:
1. Check notification permissions
2. Verify channel configuration
3. Check Android notification settings
4. Rebuild app

---

## 📱 Platform-Specific Notes

### Android:
- Notifications work on emulator and physical device
- Requires Google Play Services
- Check notification channel settings
- Battery optimization may affect delivery

### iOS:
- Requires physical device (simulator won't work)
- Requires Apple Developer account
- Check notification permissions in Settings
- Background modes must be enabled

---

## 🎯 Success Criteria

- [x] FCM token generated and saved
- [ ] Foreground notifications display
- [ ] Background notifications work
- [ ] Terminated app notifications work
- [ ] Navigation works for all types
- [ ] Mark as read works
- [ ] Delete works
- [ ] Mark all as read works
- [ ] Delete all works
- [ ] UI displays correctly

---

## 📊 Test Results Template

```
Test Date: ___________
Device: ___________
OS Version: ___________

Foreground:     ✅ / ❌
Background:     ✅ / ❌
Terminated:     ✅ / ❌
Navigation:     ✅ / ❌
Mark as Read:   ✅ / ❌
Delete:         ✅ / ❌
UI Display:     ✅ / ❌

Notes:
_______________________________
_______________________________
```

---

## 🚀 Ready to Test!

1. Run `flutter pub get`
2. Rebuild app
3. Get FCM token from logs
4. Send test notification
5. Verify all scenarios work

**Good luck with testing!** 🎉
