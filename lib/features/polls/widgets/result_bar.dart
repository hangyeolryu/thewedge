import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ResultBar extends StatelessWidget {
  final String label;
  final double realtimePct;
  final double deadlinePct;
  final bool isSelected;

  const ResultBar({
    super.key,
    required this.label,
    required this.realtimePct,
    required this.deadlinePct,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSelected)
                const Icon(Icons.check_circle,
                    size: 14, color: AppColors.accent),
              if (isSelected) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Real-time bar
          _BarRow(
            label: '실시간',
            pct: realtimePct,
            color: AppColors.resultBar,
          ),
          const SizedBox(height: 4),
          // Deadline bar
          _BarRow(
            label: '마감시',
            pct: deadlinePct,
            color: AppColors.resultBarDeadline,
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double pct;
  final Color color;

  const _BarRow({
    required this.label,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '${pct.toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
