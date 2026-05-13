import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum AuthProvider { google, apple, kakao }

class AppUser extends Equatable {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final AuthProvider provider;
  final String role; // 'user' | 'admin'
  final bool isNiceVerified;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    required this.provider,
    this.role = 'user',
    this.isNiceVerified = false,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      displayName: data['displayName'] as String?,
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      provider: _providerFromString(data['provider'] as String?),
      role: data['role'] as String? ?? 'user',
      isNiceVerified: data['isNiceVerified'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'provider': provider.name,
        'role': role,
        'isNiceVerified': isNiceVerified,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static AuthProvider _providerFromString(String? s) {
    switch (s) {
      case 'apple':
        return AuthProvider.apple;
      case 'kakao':
        return AuthProvider.kakao;
      default:
        return AuthProvider.google;
    }
  }

  AppUser copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    AuthProvider? provider,
    String? role,
    bool? isNiceVerified,
    DateTime? createdAt,
  }) =>
      AppUser(
        uid: uid ?? this.uid,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        provider: provider ?? this.provider,
        role: role ?? this.role,
        isNiceVerified: isNiceVerified ?? this.isNiceVerified,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [uid, displayName, email, photoUrl, provider, role, isNiceVerified, createdAt];
}
