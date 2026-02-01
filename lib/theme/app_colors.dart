import 'package:flutter/material.dart';

class AppColors {
  // ─────────────────────────────────────────
  // 🌸 BASE / BRAND COLORS (from your UI)
  // ─────────────────────────────────────────

  /// Main scaffold background (used everywhere)
  /// Main scaffold background (used everywhere)
  /// Main scaffold background (used everywhere)
  static const Color background = Color(0xFFFFF5F8); // Much softer blush white

  /// Light surface for cards, chat bubbles, inputs
  static const Color surface = Colors.white;

  /// Primary accent (greetings, highlights)
  static const Color primaryAccent = Color(
    0xFFE91E63,
  ); // Keep for brand identity but use sparingly
  static const Color medicalBlush = Color(0xFFFFF0F5); // For Next Due card
  static const Color medicalMint = Color(0xFFF5FCF7); // For Completed cards
  static const Color textMuted = Color(0xFF757575); // For secondary text
  static const Color success = Color(0xFF4CAF50); // Green for completed states

  /// Main brand gradient (AppBar, Splash, headers)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFFBA4DD), Color(0xFFFFE1F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────
  // 📝 TEXT COLORS
  // ─────────────────────────────────────────

  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textInverse = Colors.white;

  // ─────────────────────────────────────────
  // 💡 TIP / NEUTRAL CARD
  // ─────────────────────────────────────────

  static const Color tipCardBackground = Color(0xFFFFF5FA);
  static const Color tipIcon = Colors.orange;

  // ─────────────────────────────────────────
  // 📅 APPOINTMENT / INFORMATION CARD
  // ─────────────────────────────────────────

  static const LinearGradient appointmentGradient = LinearGradient(
    colors: [Color(0xFFE6F7FF), Color(0xFF59A2EC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color appointmentPrimary = Color(0xFF1976D2);
  static const Color appointmentDivider = Color(0xFF48A4F1);

  // ─────────────────────────────────────────
  // 👥 PARTNER / EMOTIONAL CARD
  // ─────────────────────────────────────────

  static const LinearGradient partnerGradient = LinearGradient(
    colors: [Color(0xFFF67F7F), Color(0xFFF1429A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color partnerPrimaryText = Color(0xFF4A0E3C);
  static const Color partnerButton = Color(0xFFD2191F);

  // ─────────────────────────────────────────
  // ⚡ QUICK ACTION COLORS (SEMANTIC)
  // ─────────────────────────────────────────
  // These should NEVER be unified

  static const Color feed = Color(0xFF00BCD4);
  static const Color sleep = Color(0xFF673AB7);
  static const Color height = Color(0xFF4CAF50);
  static const Color weight = Color(0xFFE91E63);
  static const Color mood = Color(0xFFFF9900);

  // ─────────────────────────────────────────
  // 🌫 SHADOW COLORS
  // ─────────────────────────────────────────

  static Color softPinkShadow = Colors.pink.withValues(alpha: 0.3);

  static Color softBlueShadow = Colors.blue.withValues(alpha: 0.3);

  static Color softRedShadow = Colors.red.withValues(alpha: 0.3);
}
