import 'package:flutter/material.dart';
import '../../../../core/constants/triage_levels.dart';
import '../../../../core/constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  final StatusPenanganan status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case StatusPenanganan.menunggu:
        backgroundColor = AppColors.statusMenunggu;
        break;
      case StatusPenanganan.ditangani:
        backgroundColor = AppColors.statusDitangani;
        break;
      case StatusPenanganan.selesai:
        backgroundColor = AppColors.statusSelesai;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

