# TheWedge — Setup Guide

## Prerequisites

- Flutter 3.16+
- Firebase project
- Kakao Developer account (for Kakao login)
- Apple Developer account (for Sign in with Apple)

## 1. Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This replaces `lib/firebase_options.dart` with real credentials.

## 2. Enable Firebase services

In the Firebase console:
- **Authentication**: Enable Google, Apple providers
- **Firestore**: Create database, deploy rules: `firebase deploy --only firestore`
- **Storage**: Deploy rules: `firebase deploy --only storage`

## 3. Kakao Login

See `docs/KAKAO_AUTH.md` for the full Cloud Function + Flutter setup.

## 4. Google Sign-In

Android: Place `google-services.json` in `android/app/`  
iOS: Place `GoogleService-Info.plist` in `ios/Runner/`

## 5. Sign in with Apple

In Apple Developer console:
- Enable "Sign In with Apple" capability for your App ID
- In Firebase Auth console, configure Apple provider with your Service ID and key

## 6. NICE Identity Verification (Pre-production)

NICE (나이스평가정보) provides the Korean government-certified identity verification API.
Contact NICE at https://www.niceid.co.kr to get API credentials.
Implementation will be added before production launch.

## 7. Making someone an admin

In Firestore console, find the user document and set `role: "admin"`.
Or use Firebase Admin SDK:
```javascript
admin.firestore().doc(`users/${uid}`).update({ role: 'admin' });
```

## 8. Deadline Snapshot

The `takeDeadlineSnapshot` method in `PollService` should be called at the poll
deadline. Options:
- Firebase Cloud Function with a Pub/Sub scheduled trigger
- Admin manually triggers via the admin dashboard (popup menu → "마감 스냅샷 저장")

## Data Model Overview

```
polls/{pollId}
  question: string
  imageUrl: string?
  answers: [{id, text, voteCount, deadlineVoteCount}]
  answerType: 'radio' | 'checkbox'
  deadline: timestamp
  status: 'active' | 'ended'
  totalVotes: number        ← real-time count
  deadlineTotalVotes: number ← snapshot at deadline
  deadlineSnapshotTaken: boolean
  createdAt: timestamp
  createdBy: uid

votes/{voteId}
  pollId: string
  userId: string
  answerIds: string[]
  isAfterDeadline: boolean
  changeComment: string?    ← required if isAfterDeadline
  previousAnswerIds: string[]?
  votedAt: timestamp
  updatedAt: timestamp

users/{uid}
  displayName: string?
  email: string?
  photoUrl: string?
  provider: 'google' | 'apple' | 'kakao'
  role: 'user' | 'admin'
  isNiceVerified: boolean
  createdAt: timestamp
```
