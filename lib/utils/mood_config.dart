import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MoodConfig {
  static IconData getIcon(int mood) {
    switch (mood) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  static Color getBackgroundColor(int mood) {
    switch (mood) {
      case 1:
        return Colors.red.withValues(alpha: 0.15);
      case 2:
        return Colors.orange.withValues(alpha: 0.15);
      case 3:
        return Colors.grey.withValues(alpha: 0.15);
      case 4:
        return Colors.green.withValues(alpha: 0.15);
      case 5:
        return AppColors.success.withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.15);
    }
  }

  static Color getIconColor(int mood) {
    switch (mood) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.grey;
      case 4:
        return Colors.green;
      case 5:
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  static String getLabel(int mood) {
    switch (mood) {
      case 1:
        return "Very Sad";
      case 2:
        return "Sad";
      case 3:
        return "Neutral";
      case 4:
        return "Happy";
      case 5:
        return "Very Happy";
      default:
        return "Neutral";
    }
  }
}