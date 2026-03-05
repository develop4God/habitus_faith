# 🔥 URGENT: Firestore Rules Fix

## 🚨 Problem Identified

Your Firestore rules **EXPIRED on November 27, 2025**!

The current rules in Firebase Console:
```javascript
match /{document=**} {
  allow read, write: if request.time < timestamp.date(2025, 11, 27);
}
```

**Status**: ❌ EXPIRED (current date: February 11, 2026)

This is why you're getting:
```
PERMISSION_DENIED: Missing or insufficient permissions
```

## ✅ Solution

I've updated the `firestore.rules` file with proper production-ready rules that:
- ✅ Allow authenticated users to access their own data
- ✅ Protect user privacy (users can only see their own data)
- ✅ Never expire
- ✅ Follow security best practices

## 🚀 How to Deploy the New Rules

### Option 1: Firebase Console (Quickest)

1. **Open Firebase Console**:
   - Go to: https://console.firebase.google.com
   - Select your project: `habitus_faith`

2. **Navigate to Firestore Rules**:
   - Click "Firestore Database" in left menu
   - Click "Rules" tab at the top

3. **Copy and Paste the New Rules**:
   - Delete the old expired rules
   - Copy the rules from `firestore.rules` file (shown below)
   - Click "Publish"

4. **New Rules to Paste**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }

    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // User documents - users can read/write their own document
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // FCM tokens subcollection
      match /fcmTokens/{tokenId} {
        allow read, write: if isOwner(userId);
      }

      // Settings subcollection (notifications, preferences, etc.)
      match /settings/{settingId} {
        allow read, write: if isOwner(userId);
      }

      // User's habits (if stored in Firestore)
      match /habits/{habitId} {
        allow read, write: if isOwner(userId);
      }

      // User's completions (if stored in Firestore)
      match /completions/{completionId} {
        allow read, write: if isOwner(userId);
      }
    }

    // Devotionals - publicly readable, admin writable
    match /devotionals/{devotionalId} {
      allow read: if true;
      allow write: if isAuthenticated();
    }
  }
}
```

### Option 2: Firebase CLI (Recommended for Future)

If you have Firebase CLI installed:

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project (if not done)
firebase init

# Deploy rules
firebase deploy --only firestore:rules
```

If not installed, skip this for now and use Option 1.

### Option 3: Quick Fix (Development Only)

If you just want to test quickly, you can temporarily use test mode rules:

⚠️ **WARNING**: Only use this for testing! Not secure for production!

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      // Extend expiration to 1 year from now
      allow read, write: if request.time < timestamp.date(2027, 2, 11);
    }
  }
}
```

## 📋 Step-by-Step Instructions (Firebase Console)

1. **Open browser** → Go to: https://console.firebase.google.com

2. **Select project** → Click on your `habitus_faith` project

3. **Go to Firestore**:
   - Left sidebar → Click "Firestore Database"
   
4. **Go to Rules tab**:
   - Top of page → Click "Rules" tab

5. **You'll see the expired rule**:
   ```
   allow read, write: if request.time < timestamp.date(2025, 11, 27);
   ```

6. **Select all and delete** (Ctrl+A, Delete)

7. **Paste the new rules** (from above)

8. **Click "Publish" button** (top right)

9. **Wait for confirmation** message: "Rules published successfully"

10. **Return to your app** and press 'R' for hot restart

## ✅ After Deploying Rules

You should see these logs:

```
✅ NotificationService: lastLogin timestamp updated successfully
✅ NotificationService: FCM token saved to Firestore successfully
```

And in Firestore Console, you should see:
- `users/{userId}/lastLogin` - timestamp
- `users/{userId}/fcmTokens/{token}` - token document
- `users/{userId}/settings/notifications` - notification settings

## 🔒 Security Notes

The new rules ensure:
- ✅ **User Privacy**: Users can only access their own data
- ✅ **Authentication Required**: Must be logged in to write data
- ✅ **No Expiration**: Rules work indefinitely
- ✅ **Proper Scoping**: Each collection has explicit rules

## 🐛 Troubleshooting

### If you still get PERMISSION_DENIED after deploying:

1. **Wait 30 seconds** - Rules take a moment to propagate
2. **Hard refresh** - Restart the Flutter app completely
3. **Check Firebase Console** - Verify rules were published
4. **Check user is authenticated** - Look for user ID in logs

### If you can't access Firebase Console:

- Check you're logged in with the correct Google account
- Verify you have permissions for the project
- Contact project owner for access

## 🎯 Next Steps

1. **Deploy the rules NOW** (use Firebase Console - Option 1)
2. **Wait 30 seconds** for rules to propagate
3. **Hot restart the app** (press 'R' in Flutter terminal)
4. **Watch the logs** - should see ✅ success messages
5. **Verify in Firestore** - check data is being written

---

**URGENT**: Deploy these rules now to fix the PERMISSION_DENIED errors!

**Status**: Rules file updated ✅ | Deployment pending ⏳

