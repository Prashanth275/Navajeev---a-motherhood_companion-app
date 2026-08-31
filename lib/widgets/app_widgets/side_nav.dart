import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SideNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  final List<SideNavItem> items;

  const SideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final double width = isCollapsed ? 70 : 260;

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        curve: Curves.easeInOut,
        color: AppColors.background,
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                isCollapsed ? 15 : 24,
                32,
                isCollapsed ? 15 : 24,
                24,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisAlignment: isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'NavaJeev',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                          Text(
                            'Motherhood Companion',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 4 : 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildNavItem(
                    index,
                    items[index].title,
                    items[index].icon,
                  );
                },
              ),
            ),

            // Collapse Button
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 24,
                horizontal: isCollapsed ? 0 : 16,
              ),
              child: InkWell(
                onTap: onToggleCollapse,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: isCollapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Icon(
                          isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                          color: AppColors.primaryAccent,
                        ),
                        if (!isCollapsed) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Collapse',
                            style: TextStyle(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, dynamic icon) {
    final bool isSelected = currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(12),
          child: Tooltip(
            message: isCollapsed ? title : '',
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 8 : 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryAccent.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisAlignment: isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    icon is IconData
                        ? Icon(
                            icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.primaryAccent
                                : AppColors.textSecondary,
                          )
                        : ImageIcon(
                            AssetImage(icon as String),
                            size: 22,
                            color: isSelected
                                ? AppColors.primaryAccent
                                : AppColors.textSecondary,
                          ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.textSecondary,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SideNavItem {
  final String title;
  final dynamic icon;

  const SideNavItem({required this.title, required this.icon});
}
