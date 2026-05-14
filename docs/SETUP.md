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

The deadline snapshot is taken automatically by the `takeDeadlineSnapshot`
Cloud Function (runs every 5 minutes via Pub/Sub schedule). Admins can also
trigger manually from the admin dashboard.

## 9. Cloud Functions

```bash
cd functions
npm install

# Set Perspective API key (get from Google Cloud Console)
firebase functions:config:set perspective.key="YOUR_PERSPECTIVE_API_KEY"

# Deploy all functions
firebase deploy --only functions
```

Functions:
- `moderateComment` (callable) — pre-check toxicity before posting
- `onCommentWritten` (Firestore trigger) — score comment, update status, update user stats
- `onVoteWritten` (Firestore trigger) — increment user stats, recompute persona
- `recalculatePersona` (callable) — manual persona refresh
- `takeDeadlineSnapshot` (Pub/Sub schedule, every 5 min) — freeze deadline results
- `kakaoCustomToken` (callable) — exchange Kakao token → Firebase custom token

## 10. Perspective API Setup

1. Go to https://perspectiveapi.com/ and request access
2. Enable the API in Google Cloud Console for your Firebase project
3. Create an API key restricted to Perspective Comment Analyzer API
4. Set it as a function config (see step 9)

Korean is fully supported. Free tier: 1 QPS, sufficient for early stage.

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
