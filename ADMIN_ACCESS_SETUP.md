# Admin Access Setup Guide

## ✅ Role-Based Routing Implemented!

---

## 🔐 **How It Works**:

The app now automatically detects user roles and routes them to the appropriate interface:

### **For Regular Users** (Citizens):
- Login → **Home Page** (with bottom navigation)
- Access to: Issues, Ideas, Map, Profile, etc.

### **For Admin Users** (Government Officials):
- Login → **Admin Dashboard** (with sidebar navigation)
- Access to: Overview, Announcements, Ideas Review, Issues Management
- **Cannot access** regular home page (auto-redirected to admin dashboard)

---

## 📝 **Step-by-Step Setup**:

### **Step 1: Create a New Account**
1. Open the app
2. Click **"Sign Up"**
3. Fill in your details:
   - Email: `admin@municipality.gov` (or any email)
   - Password: Your secure password
   - Name: Your full name
4. Complete the signup process

### **Step 2: Add Admin Role in Firestore**
1. Go to **Firebase Console**: https://console.firebase.google.com
2. Select your project
3. Click **Firestore Database** in the left menu
4. Navigate to **users** collection
5. Find the user document you just created (search by email)
6. Click on the document to open it
7. Click **"Add field"** button
8. Add the following field:
   ```
   Field: role
   Type: string
   Value: admin
   ```
9. Click **"Update"**

### **Step 3: Login with Admin Account**
1. Go back to the app
2. **Logout** if you're still logged in
3. Login with your admin credentials
4. You should now see the **Admin Dashboard** instead of the regular home page! 🎉

---

## 🎯 **Visual Guide**:

### **Firestore Structure**:
```javascript
users (collection)
  └── {userId} (document)
      ├── uid: "abc123..."
      ├── email: "admin@municipality.gov"
      ├── displayName: "John Admin"
      ├── role: "admin"  // ← ADD THIS FIELD
      ├── municipality: "City of Johannesburg"
      ├── ward: null
      ├── phoneNumber: "+27123456789"
      ├── photoURL: null
      ├── points: 0
      ├── createdAt: Timestamp
      ├── updatedAt: Timestamp
      └── isActive: true
```

---

## 🔒 **Security Features**:

### **Automatic Routing**:
✅ **Admins** are automatically redirected to Admin Dashboard
✅ **Regular users** cannot access Admin Dashboard (redirected to home)
✅ **Admins** cannot access regular home page (redirected to dashboard)
✅ **Unauthenticated users** are redirected to login

### **Route Protection**:
- `/admin-dashboard` → Only accessible by users with `role: "admin"`
- `/home` → Only accessible by regular users (non-admins)
- All other routes → Accessible by authenticated users

---

## 🧪 **Testing the Setup**:

### **Test 1: Regular User**
1. Create account without admin role
2. Login
3. Should see **Home Page** with bottom navigation
4. Try to access `/admin-dashboard` → Redirected to home

### **Test 2: Admin User**
1. Create account and add `role: "admin"` in Firestore
2. Login
3. Should see **Admin Dashboard** with sidebar navigation
4. Try to access `/home` → Redirected to admin dashboard

### **Test 3: Role Change**
1. Login as admin
2. Remove `role: "admin"` field in Firestore
3. Refresh app or logout/login
4. Should now see regular Home Page

---

## 🎨 **Interface Differences**:

### **Regular User Interface**:
```
┌─────────────────────────────┐
│         Home Page           │
│                             │
│  📍 Issues                  │
│  💡 Ideas                   │
│  🗺️ Map                     │
│                             │
├─────────────────────────────┤
│ [Home] [Issues] [Ideas]     │
│ [Map]  [Profile]            │
└─────────────────────────────┘
```

### **Admin Interface**:
```
┌──────────┬──────────────────┐
│ 📊       │  Dashboard       │
│ Overview │                  │
│          │  Statistics      │
│ 📢       │  Quick Actions   │
│ Announce │                  │
│          │                  │
│ 💡       │                  │
│ Ideas    │                  │
│ Review   │                  │
│          │                  │
│ ⚠️       │                  │
│ Issues   │                  │
└──────────┴──────────────────┘
```

---

## 🚀 **Quick Commands**:

### **Firebase Console**:
```
1. Go to: https://console.firebase.google.com
2. Select Project
3. Firestore Database → users → {userId}
4. Add field: role = "admin"
```

### **Field Details**:
```
Field name:  role
Field type:  string
Field value: admin
```

---

## ⚠️ **Important Notes**:

### **Role Values**:
- `"admin"` - Government official (Admin Dashboard)
- `"citizen"` or empty - Regular user (Home Page)
- Any other value - Treated as regular user

### **Case Sensitive**:
- Role must be exactly `"admin"` (lowercase)
- `"Admin"` or `"ADMIN"` will NOT work

### **Multiple Admins**:
- You can have multiple admin users
- Just add `role: "admin"` to each user document

### **Removing Admin Access**:
- Delete the `role` field OR
- Change `role` value to `"citizen"` OR
- Change to any value other than `"admin"`

---

## 🔧 **Troubleshooting**:

### **Problem: Still seeing Home Page after adding admin role**
**Solution**:
1. Make sure you logged out and logged back in
2. Check Firestore - field must be exactly `role: "admin"`
3. Try hot restart (not just hot reload)
4. Clear app data and login again

### **Problem: Can't access admin dashboard**
**Solution**:
1. Verify `role` field exists in Firestore
2. Verify value is exactly `"admin"` (lowercase)
3. Check that you're logged in with the correct account
4. Try logging out and back in

### **Problem: Regular users can access admin dashboard**
**Solution**:
1. Check their Firestore document
2. Remove or change the `role` field
3. They need to logout and login again

---

## 📊 **Role Management Best Practices**:

### **For Production**:
1. **Document admin users** - Keep a list of who has admin access
2. **Regular audits** - Review admin users periodically
3. **Principle of least privilege** - Only give admin access when necessary
4. **Activity logging** - Track admin actions (future feature)
5. **Two-factor authentication** - Add extra security (future feature)

### **For Development**:
1. **Test account** - Create a dedicated admin test account
2. **Regular user account** - Keep a regular account for testing citizen features
3. **Quick toggle** - Use Firestore console to quickly switch roles

---

## ✅ **Verification Checklist**:

Before deploying to production, verify:

- [ ] Admin routing works correctly
- [ ] Regular user routing works correctly
- [ ] Non-admins cannot access admin dashboard
- [ ] Admins are auto-redirected to dashboard
- [ ] Role field is properly set in Firestore
- [ ] Logout/login refreshes role correctly
- [ ] Admin dashboard displays properly
- [ ] All admin features are accessible

---

## 🎉 **You're All Set!**

Your app now has complete role-based access control:

✅ **Automatic routing** based on user role
✅ **Secure access** to admin features
✅ **Easy role management** via Firestore
✅ **Separate interfaces** for admins and citizens

**Next Steps**: Implement the remaining admin dashboard tabs (Announcements, Ideas Review, Issues Management)
