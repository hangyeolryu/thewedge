import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum Persona {
  newcomer,    // < 5 votes
  openMinded,  // changes opinions often (>= 40%)
  conviction,  // rarely changes (< 10%)
  passionate,  // high engagement, sometimes heated
  calm,        // thoughtful, low toxicity
  observer,    // votes but rarely comments
  balanced,    // default
}

extension PersonaInfo on Persona {
  String get id {
    switch (this) {
      case Persona.openMinded:
        return 'open_minded';
      case Persona.conviction:
        return 'conviction';
      case Persona.passionate:
        return 'passionate';
      case Persona.calm:
        return 'calm';
      case Persona.observer:
        return 'observer';
      case Persona.balanced:
        return 'balanced';
      case Persona.newcomer:
        return 'newcomer';
    }
  }

  static Persona fromId(String? id) {
    switch (id) {
      case 'open_minded':
        return Persona.openMinded;
      case 'conviction':
        return Persona.conviction;
      case 'passionate':
        return Persona.passionate;
      case 'calm':
        return Persona.calm;
      case 'observer':
        return Persona.observer;
      case 'balanced':
        return Persona.balanced;
      default:
        return Persona.newcomer;
    }
  }

  String get emoji {
    switch (this) {
      case Persona.openMinded: return '🔄';
      case Persona.conviction: return '🧱';
      case Persona.passionate: return '🔥';
      case Persona.calm: return '🧘';
      case Persona.observer: return '👀';
      case Persona.balanced: return '⚖️';
      case Persona.newcomer: return '🌱';
    }
  }

  String get label {
    switch (this) {
      case Persona.openMinded: return '열린마음';
      case Persona.conviction: return '소신파';
      case Persona.passionate: return '열정파';
      case Persona.calm: return '냉정파';
      case Persona.observer: return '관찰자';
      case Persona.balanced: return '균형파';
      case Persona.newcomer: return '새싹';
    }
  }

  String get description {
    switch (this) {
      case Persona.openMinded:
        return '다른 사람의 의견을 듣고 자주 생각을 바꾸는 편입니다.';
      case Persona.conviction:
        return '자신의 신념이 뚜렷하고 의견이 잘 흔들리지 않습니다.';
      case Persona.passionate:
        return '주제에 깊이 몰입하며 적극적으로 의견을 표현합니다.';
      case Persona.calm:
        return '차분하고 사려 깊은 댓글로 토론에 기여합니다.';
      case Persona.observer:
        return '조용히 투표하며 흐름을 지켜보는 편입니다.';
      case Persona.balanced:
        return '균형 잡힌 시각으로 다양한 주제에 참여합니다.';
      case Persona.newcomer:
        return '아직 데이터가 적습니다. 5개 이상 투표하면 성향이 분석됩니다.';
    }
  }

  Color get color {
    switch (this) {
      case Persona.openMinded: return const Color(0xFF6C8EBF);
      case Persona.conviction: return const Color(0xFF8B6F47);
      case Persona.passionate: return const Color(0xFFE94560);
      case Persona.calm: return const Color(0xFF7DAA92);
      case Persona.observer: return const Color(0xFF9E9E9E);
      case Persona.balanced: return const Color(0xFF0F3460);
      case Persona.newcomer: return const Color(0xFF8BC34A);
    }
  }
}

class UserStats extends Equatable {
  final String uid;
  final int totalVotes;
  final int voteChanges;
  final int postDeadlineChanges;
  final int totalComments;
  final int blockedComments;
  final List<double> recentToxicityScores;
  final Persona persona;
  final List<String> topicsVoted;
  final DateTime? lastVotedAt;
  final DateTime? lastUpdated;

  const UserStats({
    required this.uid,
    this.totalVotes = 0,
    this.voteChanges = 0,
    this.postDeadlineChanges = 0,
    this.totalComments = 0,
    this.blockedComments = 0,
    this.recentToxicityScores = const [],
    this.persona = Persona.newcomer,
    this.topicsVoted = const [],
    this.lastVotedAt,
    this.lastUpdated,
  });

  double get voteChangeRate =>
      totalVotes > 0 ? voteChanges / totalVotes : 0;

  double get commentRate =>
      totalVotes > 0 ? totalComments / totalVotes : 0;

  double get avgToxicityScore => recentToxicityScores.isEmpty
      ? 0
      : recentToxicityScores.reduce((a, b) => a + b) /
          recentToxicityScores.length;

  /// Emotional temperature label based on avg toxicity.
  String get emotionalTemperature {
    final t = avgToxicityScore;
    if (t < 0.15) return '😌 차분';
    if (t < 0.30) return '😐 평온';
    if (t < 0.50) return '😤 격앙';
    return '🔥 과열';
  }

  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStats(
      uid: doc.id,
      totalVotes: (data['totalVotes'] as num?)?.toInt() ?? 0,
      voteChanges: (data['voteChanges'] as num?)?.toInt() ?? 0,
      postDeadlineChanges:
          (data['postDeadlineChanges'] as num?)?.toInt() ?? 0,
      totalComments: (data['totalComments'] as num?)?.toInt() ?? 0,
      blockedComments: (data['blockedComments'] as num?)?.toInt() ?? 0,
      recentToxicityScores:
          (data['recentToxicityScores'] as List?)
                  ?.cast<num>()
                  .map((n) => n.toDouble())
                  .toList() ??
              [],
      persona: PersonaInfo.fromId(data['persona'] as String?),
      topicsVoted: (data['topicsVoted'] as List?)?.cast<String>() ?? [],
      lastVotedAt: data['lastVotedAt'] != null
          ? (data['lastVotedAt'] as Timestamp).toDate()
          : null,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  List<Object?> get props => [
        uid, totalVotes, voteChanges, postDeadlineChanges,
        totalComments, blockedComments, recentToxicityScores,
        persona, topicsVoted, lastVotedAt, lastUpdated,
      ];
}
