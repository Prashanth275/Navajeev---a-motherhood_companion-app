import 'package:flutter/material.dart';
import '../models/recommendation_result.dart';
import '../theme/app_colors.dart';
import 'app_widgets/primary_card.dart';

class AiRecommendationCard extends StatefulWidget {
  final bool isPregnancy;
  final int? stageNumber; // pregnancy week or baby age in weeks
  final String? trimester;
  final bool isLoading;
  final RecommendationResult? result;
  final String? errorMessage;
  final VoidCallback? onRefresh;

  const AiRecommendationCard({
    super.key,
    required this.isPregnancy,
    this.stageNumber,
    this.trimester,
    this.isLoading = false,
    this.result,
    this.errorMessage,
    this.onRefresh,
  });

  @override
  State<AiRecommendationCard> createState() => _AiRecommendationCardState();
}

class _AiRecommendationCardState extends State<AiRecommendationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      backgroundColor: AppColors.tipCardBackground.withValues(alpha: 0.7),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          if (widget.isLoading)
            const _LoadingSection()
          else if (widget.errorMessage != null && (widget.result == null || !widget.result!.success))
            _ErrorSection(onRetry: widget.onRefresh)
          else if (widget.result == null || !widget.result!.hasContent)
            _EmptySection(isPregnancy: widget.isPregnancy, onGenerate: widget.onRefresh)
          else
            _ContentSection(
              result: widget.result!,
              isPregnancy: widget.isPregnancy,
              isExpanded: _isExpanded,
              onToggleExpand: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const title = "Weekly AI Guidance";
    final subtitle = widget.isPregnancy
        ? (widget.stageNumber != null ? "Week ${widget.stageNumber} · ${widget.trimester ?? 'Pregnancy'}" : "Pregnancy Guidance")
        : (widget.stageNumber != null ? "Baby · ${widget.stageNumber} Weeks Old" : "Postpartum Care");

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAccent.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColors.primaryAccent.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/ai_logo.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (widget.onRefresh != null)
          IconButton(
            tooltip: 'Refresh Guidance',
            onPressed: widget.isLoading ? null : widget.onRefresh,
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
      ],
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: AppColors.primaryAccent,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Personalizing your weekly guidance...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final VoidCallback? onRetry;
  const _ErrorSection({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red.shade400, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unable to load personalized guidance right now.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Please check your network connection and try again.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 15),
                label: const Text('Retry', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final bool isPregnancy;
  final VoidCallback? onGenerate;

  const _EmptySection({
    required this.isPregnancy,
    this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/ai_logo.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isPregnancy
                  ? 'Log your mood or sleep to generate customized pregnancy guidance.'
                  : 'Log your feeding, sleep, or mood to get weekly tailored recommendations.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          if (onGenerate != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onGenerate,
              icon: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 14),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  final RecommendationResult result;
  final bool isPregnancy;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const _ContentSection({
    required this.result,
    required this.isPregnancy,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final hasAdditionalContent = result.dailyRoutine.isNotEmpty ||
        (result.devActivity != null && result.devActivity!.isNotEmpty) ||
        result.nutritionTips.isNotEmpty ||
        result.selfCare.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Weekly Focus Callout (Always visible)
        if (result.weeklyFocus != null && result.weeklyFocus!.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tipIcon.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.tipIcon,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.weeklyFocus!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 2. Expandable details animated
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Routine Habits
                    if (result.dailyRoutine.isNotEmpty) ...[
                      const _SectionLabel(title: 'Daily Rhythm Habits', icon: '⏱️'),
                      ...result.dailyRoutine.map((item) => _BulletItem(text: item)),
                      const SizedBox(height: 8),
                    ],

                    // Stage Activity (Prenatal Bonding vs Baby Development)
                    if (result.devActivity != null && result.devActivity!.isNotEmpty) ...[
                      _SectionLabel(
                        title: isPregnancy ? 'Prenatal Bonding & Wellness' : 'Baby Developmental Activity',
                        icon: isPregnancy ? '🌸' : '🧸',
                      ),
                      _HighlightCard(text: result.devActivity!),
                      const SizedBox(height: 8),
                    ],

                    // Nutrition Tips
                    if (result.nutritionTips.isNotEmpty) ...[
                      _SectionLabel(
                        title: isPregnancy ? 'Pregnancy Nutrition' : 'Nourishment & Nutrition',
                        icon: '🥗',
                      ),
                      ...result.nutritionTips.map((item) => _BulletItem(text: item)),
                      const SizedBox(height: 8),
                    ],

                    // Maternal Self Care
                    if (result.selfCare.isNotEmpty) ...[
                      const _SectionLabel(title: 'Maternal Self-Care', icon: '💆'),
                      ...result.selfCare.map((item) => _BulletItem(text: item)),
                      const SizedBox(height: 8),
                    ],
                  ],
                )
              : const SizedBox.shrink(),
        ),

        // 3. View more / View less button
        if (hasAdditionalContent) ...[
          const SizedBox(height: 2),
          _ExpandToggleButton(
            isExpanded: isExpanded,
            onTap: onToggleExpand,
          ),
        ],
      ],
    );
  }
}

class _ExpandToggleButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const _ExpandToggleButton({
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExpanded ? "View less ↑" : "View more ↓",
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryAccent,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final String icon;

  const _SectionLabel({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.tipIcon,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String text;
  const _HighlightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 12.5,
          height: 1.45,
        ),
      ),
    );
  }
}
