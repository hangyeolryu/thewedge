import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Vote extends Equatable {
  final String id;
  final String pollId;
  final String userId;
  final List<String> answerIds;
  final bool isAfterDeadline;
  final String? changeComment; // required when isAfterDeadline
  final List<String>? previousAnswerIds;
  final DateTime votedAt;
  final DateTime? updatedAt;

  const Vote({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.answerIds,
    this.isAfterDeadline = false,
    this.changeComment,
    this.previousAnswerIds,
    required this.votedAt,
    this.updatedAt,
  });

  factory Vote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vote(
      id: doc.id,
      pollId: data['pollId'] as String,
      userId: data['userId'] as String,
      answerIds: List<String>.from(data['answerIds'] as List),
      isAfterDeadline: data['isAfterDeadline'] as bool? ?? false,
      changeComment: data['changeComment'] as String?,
      previousAnswerIds: data['previousAnswerIds'] != null
          ? List<String>.from(data['previousAnswerIds'] as List)
          : null,
      votedAt: (data['votedAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'pollId': pollId,
        'userId': userId,
        'answerIds': answerIds,
        'isAfterDeadline': isAfterDeadline,
        'changeComment': changeComment,
        'previousAnswerIds': previousAnswerIds,
        'votedAt': Timestamp.fromDate(votedAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };

  Vote copyWith({
    String? id,
    String? pollId,
    String? userId,
    List<String>? answerIds,
    bool? isAfterDeadline,
    String? changeComment,
    List<String>? previousAnswerIds,
    DateTime? votedAt,
    DateTime? updatedAt,
  }) =>
      Vote(
        id: id ?? this.id,
        pollId: pollId ?? this.pollId,
        userId: userId ?? this.userId,
        answerIds: answerIds ?? this.answerIds,
        isAfterDeadline: isAfterDeadline ?? this.isAfterDeadline,
        changeComment: changeComment ?? this.changeComment,
        previousAnswerIds: previousAnswerIds ?? this.previousAnswerIds,
        votedAt: votedAt ?? this.votedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, pollId, userId, answerIds, isAfterDeadline,
      changeComment, previousAnswerIds, votedAt, updatedAt];
}
