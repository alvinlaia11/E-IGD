import 'package:flutter/material.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/constants/app_colors.dart';

class TriageBadge extends StatelessWidget {
  final TriageLevel triage;

  const TriageBadge({
    super.key,
    required this.triage,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (triage) {
      case TriageLevel.merah:
        backgroundColor = AppColors.triageMerah;
        break;
      case TriageLevel.kuning:
        backgroundColor = AppColors.triageKuning;
        textColor = Colors.black87;
        break;
      case TriageLevel.hijau:
        backgroundColor = AppColors.triageHijau;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        triage.displayName,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

