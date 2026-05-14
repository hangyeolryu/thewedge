import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum CommentStatus { visible, blurred, blocked }

class Comment extends Equatable {
  final String id;
  final String pollId;
  final String userId;
  final String? userDisplayName;
  final String? userPhotoUrl;
  final String text;
  final double toxicityScore; // 0.0 ~ 1.0
  final Map<String, double> toxicityScores; // per-attribute breakdown
  final CommentStatus status;
  final List<String> flaggedBy;
  final String? answerChangeFromId; // optional: tied to a vote change
  final String? answerChangeToId;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.pollId,
    required this.userId,
    this.userDisplayName,
    this.userPhotoUrl,
    required this.text,
    this.toxicityScore = 0.0,
    this.toxicityScores = const {},
    this.status = CommentStatus.visible,
    this.flaggedBy = const [],
    this.answerChangeFromId,
    this.answerChangeToId,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      pollId: data['pollId'] as String,
      userId: data['userId'] as String,
      userDisplayName: data['userDisplayName'] as String?,
      userPhotoUrl: data['userPhotoUrl'] as String?,
      text: data['text'] as String,
      toxicityScore: (data['toxicityScore'] as num?)?.toDouble() ?? 0.0,
      toxicityScores: (data['toxicityScores'] as Map?)?.map(
            (k, v) => MapEntry(k as String, (v as num).toDouble()),
          ) ??
          {},
      status: _statusFromString(data['status'] as String?),
      flaggedBy: (data['flaggedBy'] as List?)?.cast<String>() ?? [],
      answerChangeFromId: data['answerChangeFromId'] as String?,
      answerChangeToId: data['answerChangeToId'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'pollId': pollId,
        'userId': userId,
        'userDisplayName': userDisplayName,
        'userPhotoUrl': userPhotoUrl,
        'text': text,
        'toxicityScore': toxicityScore,
        'toxicityScores': toxicityScores,
        'status': status.name,
        'flaggedBy': flaggedBy,
        'answerChangeFromId': answerChangeFromId,
        'answerChangeToId': answerChangeToId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static CommentStatus _statusFromString(String? s) {
    switch (s) {
      case 'blocked':
        return CommentStatus.blocked;
      case 'blurred':
        return CommentStatus.blurred;
      default:
        return CommentStatus.visible;
    }
  }

  @override
  List<Object?> get props => [
        id, pollId, userId, text, toxicityScore, status,
        flaggedBy, answerChangeFromId, answerChangeToId, createdAt,
      ];
}
