# TheWedge · 대국민투표

A real-time national polling platform for all Koreans.

## Features

- **소셜 로그인**: Kakao, Google, Apple
- **본인인증**: NICE 본인인증 (출시 전 추가 예정)
- **실시간 투표**: Firestore 실시간 동기화로 즉시 결과 반영
- **투표 형식**: 단일 선택(라디오), 복수 선택(체크박스)
- **마감 전/후 투표**: 마감 전 자유 수정, 마감 후 사유 입력 후 변경 가능
- **이중 결과**: 마감 시점 스냅샷 + 실시간 결과 동시 표시
- **투표 아카이브**: 모든 투표의 기록 보관
- **관리자 패널**: 투표 생성/수정/삭제, 이미지 업로드, 마감 스냅샷 수동 저장

## Tech Stack

- **Frontend**: Flutter 3.x (iOS, Android, Web)
- **Backend**: Firebase (Firestore, Auth, Storage)
- **State**: Riverpod 2.x
- **Navigation**: GoRouter
- **Charts**: fl_chart

## Setup

See [docs/SETUP.md](docs/SETUP.md) for full setup instructions.

## Project Structure

```
lib/
  main.dart                    Entry point
  app.dart                     App widget + router config
  firebase_options.dart        Firebase config (replace with flutterfire configure)
  core/
    constants/                 App-wide constants
    theme/                     AppTheme, AppColors
    routing/                   GoRouter setup
  features/
    auth/                      Login screen, auth provider, AppUser model
    polls/                     Poll list, detail, result screens + providers
    admin/                     Admin dashboard + create/edit poll
    profile/                   User profile screen
  shared/
    widgets/                   MainScaffold (bottom nav + app bar)
docs/
  SETUP.md                     Full setup guide
  KAKAO_AUTH.md                Kakao login Cloud Function setup
firestore.rules                Firestore security rules
firestore.indexes.json         Firestore composite indexes
storage.rules                  Firebase Storage security rules
firebase.json                  Firebase CLI config
```
