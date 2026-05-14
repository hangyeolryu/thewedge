import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PollAnswerType { radio, checkbox }

enum PollStatus { active, ended }

enum PollCategory {
  coreValues('가치관', '💡'),
  relationships('관계', '❤️'),
  career('직장/커리어', '💼'),
  society('사회/이슈', '🌐'),
  culture('문화/취미', '🎨'),
  economy('경제', '💰'),
  other('기타', '📌');

  final String label;
  final String emoji;
  const PollCategory(this.label, this.emoji);

  static PollCategory fromString(String? value) {
    if (value == 'values') return PollCategory.coreValues;
    return PollCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => PollCategory.other,
    );
  }
}

class PollAnswer extends Equatable {
  final String id;
  final String text;
  final int voteCount; // real-time count, denormalized
  final int deadlineVoteCount; // snapshot taken at deadline

  const PollAnswer({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.deadlineVoteCount = 0,
  });

  factory PollAnswer.fromMap(Map<String, dynamic> map) {
    return PollAnswer(
      id: map['id'] as String,
      text: map['text'] as String,
      voteCount: (map['voteCount'] as num?)?.toInt() ?? 0,
      deadlineVoteCount: (map['deadlineVoteCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'voteCount': voteCount,
        'deadlineVoteCount': deadlineVoteCount,
      };

  PollAnswer copyWith({
    String? id,
    String? text,
    int? voteCount,
    int? deadlineVoteCount,
  }) =>
      PollAnswer(
        id: id ?? this.id,
        text: text ?? this.text,
        voteCount: voteCount ?? this.voteCount,
        deadlineVoteCount: deadlineVoteCount ?? this.deadlineVoteCount,
      );

  @override
  List<Object?> get props => [id, text, voteCount, deadlineVoteCount];
}

class Poll extends Equatable {
  final String id;
  final String question;
  final String? imageUrl;
  final List<PollAnswer> answers;
  final PollAnswerType answerType;
  final DateTime deadline;
  final PollStatus status;
  final int totalVotes; // real-time
  final int deadlineTotalVotes; // snapshot
  final bool deadlineSnapshotTaken;
  final DateTime createdAt;
  final String createdBy;
  final PollCategory category;
  final List<String> tags;

  const Poll({
    required this.id,
    required this.question,
    this.imageUrl,
    required this.answers,
    required this.answerType,
    required this.deadline,
    required this.status,
    this.totalVotes = 0,
    this.deadlineTotalVotes = 0,
    this.deadlineSnapshotTaken = false,
    required this.createdAt,
    required this.createdBy,
    this.category = PollCategory.other,
    this.tags = const [],
  });

  bool get isActive =>
      status == PollStatus.active && deadline.isAfter(DateTime.now());

  bool get isPastDeadline => deadline.isBefore(DateTime.now());

  factory Poll.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Poll(
      id: doc.id,
      question: data['question'] as String,
      imageUrl: data['imageUrl'] as String?,
      answers: (data['answers'] as List<dynamic>)
          .map((a) => PollAnswer.fromMap(a as Map<String, dynamic>))
          .toList(),
      answerType: data['answerType'] == 'checkbox'
          ? PollAnswerType.checkbox
          : PollAnswerType.radio,
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: data['status'] == 'ended' ? PollStatus.ended : PollStatus.active,
      totalVotes: (data['totalVotes'] as num?)?.toInt() ?? 0,
      deadlineTotalVotes: (data['deadlineTotalVotes'] as num?)?.toInt() ?? 0,
      deadlineSnapshotTaken: data['deadlineSnapshotTaken'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String,
      category: PollCategory.fromString(data['category'] as String?),
      tags: List<String>.from(data['tags'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'question': question,
        'imageUrl': imageUrl,
        'answers': answers.map((a) => a.toMap()).toList(),
        'answerType': answerType == PollAnswerType.checkbox ? 'checkbox' : 'radio',
        'deadline': Timestamp.fromDate(deadline),
        'status': status == PollStatus.ended ? 'ended' : 'active',
        'totalVotes': totalVotes,
        'deadlineTotalVotes': deadlineTotalVotes,
        'deadlineSnapshotTaken': deadlineSnapshotTaken,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
        'category': category.name,
        'tags': tags,
      };

  Poll copyWith({
    String? id,
    String? question,
    String? imageUrl,
    List<PollAnswer>? answers,
    PollAnswerType? answerType,
    DateTime? deadline,
    PollStatus? status,
    int? totalVotes,
    int? deadlineTotalVotes,
    bool? deadlineSnapshotTaken,
    DateTime? createdAt,
    String? createdBy,
    PollCategory? category,
    List<String>? tags,
  }) =>
      Poll(
        id: id ?? this.id,
        question: question ?? this.question,
        imageUrl: imageUrl ?? this.imageUrl,
        answers: answers ?? this.answers,
        answerType: answerType ?? this.answerType,
        deadline: deadline ?? this.deadline,
        status: status ?? this.status,
        totalVotes: totalVotes ?? this.totalVotes,
        deadlineTotalVotes: deadlineTotalVotes ?? this.deadlineTotalVotes,
        deadlineSnapshotTaken:
            deadlineSnapshotTaken ?? this.deadlineSnapshotTaken,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        category: category ?? this.category,
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [id, question, imageUrl, answers, answerType,
      deadline, status, totalVotes, deadlineTotalVotes, deadlineSnapshotTaken,
      createdAt, createdBy, category, tags];
}
