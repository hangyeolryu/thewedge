import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../models/poll_model.dart';
import '../models/vote_model.dart';

class OpinionChangeChart extends StatefulWidget {
  final Poll poll;
  final List<Vote> changelog; // post-deadline vote changes, sorted by updatedAt desc

  const OpinionChangeChart({
    super.key,
    required this.poll,
    required this.changelog,
  });

  @override
  State<OpinionChangeChart> createState() => _OpinionChangeChartState();
}

class _OpinionChangeChartState extends State<OpinionChangeChart> {
  int? _touchedAnswerIndex;

  // Build timeline: group changes by hour bucket, compute cumulative distribution
  List<_Snapshot> _buildSnapshots() {
    if (widget.changelog.isEmpty) return [];

    // Start from deadline, bucket every hour
    final deadline = widget.poll.deadline;
    final votes = widget.changelog.toList()
      ..sort((a, b) {
        final aTime = a.updatedAt ?? a.votedAt;
        final bTime = b.updatedAt ?? b.votedAt;
        return aTime.compareTo(bTime);
      });

    // Initialize counts from deadline snapshot
    final Map<String, int> counts = {};
    for (final answer in widget.poll.answers) {
      counts[answer.id] = answer.deadlineVoteCount;
    }

    // Build hourly buckets
    final now = DateTime.now();
    final totalHours = now.difference(deadline).inHours.clamp(1, 168); // max 1 week
    final bucketSize = (totalHours / 8).ceil().clamp(1, 24); // 8 data points max

    final snapshots = <_Snapshot>[];
    snapshots.add(_Snapshot(time: deadline, counts: Map.from(counts)));

    DateTime bucketEnd = deadline.add(Duration(hours: bucketSize));
    int voteIdx = 0;

    while (bucketEnd.isBefore(now) || bucketEnd == now) {
      // Apply all votes up to bucketEnd
      while (voteIdx < votes.length) {
        final v = votes[voteIdx];
        final vTime = v.updatedAt ?? v.votedAt;
        if (vTime.isAfter(bucketEnd)) break;

        // Subtract previous answers, add new answers
        for (final prevId in (v.previousAnswerIds ?? [])) {
          counts[prevId] = ((counts[prevId] ?? 0) - 1).clamp(0, 999999);
        }
        for (final newId in v.answerIds) {
          counts[newId] = (counts[newId] ?? 0) + 1;
        }
        voteIdx++;
      }
      snapshots.add(_Snapshot(time: bucketEnd, counts: Map.from(counts)));
      bucketEnd = bucketEnd.add(Duration(hours: bucketSize));
    }

    return snapshots;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.poll.deadlineSnapshotTaken || widget.changelog.isEmpty) {
      return const SizedBox.shrink();
    }

    final snapshots = _buildSnapshots();
    if (snapshots.length < 2) return const SizedBox.shrink();

    final answers = widget.poll.answers;
    final colors = _answerColors(answers.length);

    // Build line data
    final lineBarsData = answers.asMap().entries.map((entry) {
      final idx = entry.key;
      final answer = entry.value;
      final spots = snapshots.asMap().entries.map((sEntry) {
        final snap = sEntry.value;
        final total = snap.counts.values.fold(0, (a, b) => a + b);
        final pct = total > 0 ? (snap.counts[answer.id] ?? 0) / total * 100 : 0.0;
        return FlSpot(sEntry.key.toDouble(), pct.clamp(0.0, 100.0));
      }).toList();

      final isTouched = _touchedAnswerIndex == idx;
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.35,
        color: colors[idx].withOpacity(isTouched ? 1.0 : 0.8),
        barWidth: isTouched ? 3 : 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: isTouched,
          color: colors[idx].withOpacity(0.08),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '마감 후 의견 변화 추이',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.changelog.length}명이 마감 후 의견을 변경했습니다',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: answers.asMap().entries.map((e) {
            final isTouched = _touchedAnswerIndex == e.key;
            return GestureDetector(
              onTap: () => setState(() {
                _touchedAnswerIndex =
                    _touchedAnswerIndex == e.key ? null : e.key;
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[e.key],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    e.value.text.length > 12
                        ? '${e.value.text.substring(0, 12)}...'
                        : e.value.text,
                    style: TextStyle(
                      fontSize: 11,
                      color: isTouched
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isTouched
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: lineBarsData,
              minY: 0,
              maxY: 100,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: AppColors.border,
                  strokeWidth: 0.5,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value % 25 != 0) return const SizedBox.shrink();
                      return Text(
                        '${value.toInt()}%',
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textTertiary),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: ((snapshots.length - 1) / 3).ceilToDouble().clamp(1, 99),
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= snapshots.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat('MM/dd\nHH시').format(snapshots[idx].time),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 8, color: AppColors.textTertiary),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surfaceElev,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final ansIdx = spot.barIndex;
                      final answer = answers[ansIdx];
                      return LineTooltipItem(
                        '${answer.text.length > 8 ? '${answer.text.substring(0, 8)}...' : answer.text}: ${spot.y.toStringAsFixed(1)}%',
                        TextStyle(
                          color: colors[ansIdx],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _answerColors(int count) {
    const base = [
      AppColors.accent,
      AppColors.highlight,
      AppColors.success,
      Color(0xFFFFB347),
      Color(0xFF87CEEB),
      Color(0xFFDDA0DD),
      Color(0xFF98FB98),
      Color(0xFFFF7F7F),
    ];
    return List.generate(count, (i) => base[i % base.length]);
  }
}

class _Snapshot {
  final DateTime time;
  final Map<String, int> counts;
  _Snapshot({required this.time, required this.counts});
}
