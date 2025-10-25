# 🔐 Apply Firebase Security Rules

## ⚠️ IMPORTANT: Your Database is Currently Insecure!

If you created your Firestore database in **test mode**, it's currently **open to anyone**. You need to apply security rules immediately.

---

## 📋 What Was Created

I've created two security rules files:

1. **firestore.rules** - Database security rules
2. **storage.rules** - Storage bucket security rules

---

## 🚀 How to Apply Rules

### **Method 1: Firebase Console (Easiest)**

#### **For Firestore Rules**:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **muni-report-pro**
3. Click **Firestore Database** in left menu
4. Click **Rules** tab
5. **Copy the entire content** from `firestore.rules` file
6. **Paste** it into the rules editor
7. Click **Publish**

#### **For Storage Rules**:

1. In Firebase Console, click **Storage** in left menu
2. Click **Rules** tab
3. **Copy the entire content** from `storage.rules` file
4. **Paste** it into the rules editor
5. Click **Publish**

---

### **Method 2: Firebase CLI (Advanced)**

If you have Firebase CLI installed:

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init

# Select:
# - Firestore
# - Storage
# - Use existing project: muni-report-pro

# Deploy rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

---

## 🔍 What These Rules Do

### **Firestore Rules**:

#### **Users Collection**:
- ✅ Anyone authenticated can read user profiles
- ✅ Users can create/update their own profile
- ❌ Only admins can delete users

#### **Issues Collection**:
- ✅ Anyone authenticated can read issues
- ✅ Anyone authenticated can create issues
- ✅ Owners and officials can update issues
- ❌ Only admins can delete issues

#### **Ideas Collection**:
- ✅ Anyone authenticated can read ideas
- ✅ Anyone authenticated can create ideas
- ✅ Owners and officials can update ideas
- ✅ Owners and admins can delete ideas

#### **Votes**:
- ✅ Users can vote on ideas (one vote per user)
- ✅ Users can change their vote
- ✅ Users can remove their vote

#### **Verifications**:
- ✅ Users can verify issues
- ❌ Verifications are immutable (can't be changed)

#### **Announcements**:
- ✅ Anyone can read announcements
- ❌ Only officials/admins can create/update
- ❌ Only admins can delete

#### **Notifications**:
- ✅ Users can only read their own notifications
- ✅ Users can mark notifications as read
- ✅ Users can delete their own notifications

---

### **Storage Rules**:

#### **Issue Photos**:
- ✅ Anyone authenticated can view
- ✅ Anyone authenticated can upload (max 10MB)
- ✅ Only uploader can delete
- ❌ Must be image type

#### **Idea Photos**:
- ✅ Anyone authenticated can view
- ✅ Anyone authenticated can upload (max 10MB)
- ✅ Only uploader can delete

#### **Profile Photos**:
- ✅ Anyone authenticated can view
- ✅ Users can only upload their own profile photo
- ✅ Users can update/delete their own photo

#### **Verification Photos**:
- ✅ Anyone authenticated can view
- ✅ Anyone authenticated can upload
- ✅ Only uploader can delete

---

## ✅ Verification

After applying rules, test them:

### **Test 1: Unauthenticated Access**
Try to read data without logging in → Should be **denied** ❌

### **Test 2: Authenticated Read**
Log in and try to read issues → Should **work** ✅

### **Test 3: Create Issue**
Log in and create an issue → Should **work** ✅

### **Test 4: Update Other User's Data**
Try to update another user's profile → Should be **denied** ❌

---

## 🎯 Quick Apply Steps

1. **Open Firebase Console**: https://console.firebase.google.com/
2. **Select Project**: muni-report-pro
3. **Go to Firestore Database → Rules**
4. **Copy content from `firestore.rules`**
5. **Paste and Publish**
6. **Go to Storage → Rules**
7. **Copy content from `storage.rules`**
8. **Paste and Publish**

---

## 📊 Rules Summary

| Resource | Read | Create | Update | Delete |
|----------|------|--------|--------|--------|
| Users | ✅ Auth | ✅ Own | ✅ Own | ❌ Admin only |
| Issues | ✅ Auth | ✅ Auth | ✅ Owner/Official | ❌ Admin only |
| Ideas | ✅ Auth | ✅ Auth | ✅ Owner/Official | ✅ Owner/Admin |
| Votes | ✅ Auth | ✅ Own | ✅ Own | ✅ Own |
| Announcements | ✅ Auth | ❌ Official only | ❌ Official only | ❌ Admin only |
| Storage | ✅ Auth | ✅ Auth (10MB max) | ❌ No | ✅ Uploader |

---

## 🔐 Security Features

### **Role-Based Access**:
- **Citizen**: Can report issues, propose ideas, vote, verify
- **Official**: All citizen features + update issues, create announcements
- **Admin**: All features + delete anything

### **Data Validation**:
- ✅ Users can only create data with their own user ID
- ✅ File size limits (10MB for images)
- ✅ File type validation (images only)
- ✅ Immutable verifications

### **Privacy**:
- ✅ Users can only see their own notifications
- ✅ Users can only see their own points history
- ✅ Users can only see their own achievements

---

## ⚠️ Important Notes

1. **Apply rules ASAP** - Your database is currently insecure
2. **Test thoroughly** - Make sure rules work as expected
3. **Monitor usage** - Check Firebase Console for unauthorized access attempts
4. **Update as needed** - Rules can be updated anytime

---

## 🆘 Troubleshooting

### "Permission denied" errors after applying rules:
- Make sure user is authenticated
- Check user role in Firestore
- Verify user ID matches document owner

### Rules not taking effect:
- Wait 1-2 minutes after publishing
- Clear app cache
- Restart app

### Can't publish rules:
- Check for syntax errors
- Make sure you're on the correct project
- Verify you have owner/editor permissions

---

**Apply these rules now to secure your Firebase project!** 🔐
