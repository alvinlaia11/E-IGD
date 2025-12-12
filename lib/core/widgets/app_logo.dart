import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final bool showSubtitle;
  final Color? textColor;
  final bool isCompact;

  const AppLogo({
    super.key,
    this.size,
    this.showSubtitle = true,
    this.textColor,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? (isCompact ? 32.0 : 48.0);
    final textColorValue = textColor ?? Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // E Icon with background
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'E',
              style: TextStyle(
                fontSize: logoSize * 0.6,
                fontWeight: FontWeight.bold,
                color: AppColors.triageMerah,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // IGD Text
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IGD',
              style: TextStyle(
                fontSize: isCompact ? 20 : 28,
                fontWeight: FontWeight.bold,
                color: textColorValue,
                letterSpacing: 1.2,
              ),
            ),
            if (showSubtitle && !isCompact)
              Text(
                'Digital',
                style: TextStyle(
                  fontSize: 12,
                  color: textColorValue.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// Logo untuk AppBar
class AppBarLogo extends StatelessWidget {
  const AppBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(
      isCompact: true,
      showSubtitle: false,
    );
  }
}

// Logo untuk Splash Screen
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Large E-IGD Logo
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // E Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.triageMerah,
                      AppColors.triageMerah.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'E',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // IGD Text
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IGD',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.triageMerah,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Digital',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.triageMerah,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Icon Medical
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_hospital,
            size: 48,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

