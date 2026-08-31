import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:navajeev_m/theme/app_colors.dart';
import 'package:navajeev_m/providers/feeding/feeding_provider.dart';
import 'package:navajeev_m/models/feeding/feeding_model.dart';
import 'log_feeding_screen.dart';

class FeedingTrackerScreen extends StatefulWidget {
  const FeedingTrackerScreen({super.key});

  @override
  State<FeedingTrackerScreen> createState() =>
      _FeedingTrackerScreenState();
}

class _FeedingTrackerScreenState
    extends State<FeedingTrackerScreen> {
  final ScrollController _scrollController =
  ScrollController();

  bool _showLogButton = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FeedingProvider>();
      if (provider.error != null || provider.feedings.isEmpty) {
        provider.initialize();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showLogButton) {
          setState(() => _showLogButton = false);
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showLogButton) {
          setState(() => _showLogButton = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<FeedingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Text(provider.error!),
              );
            }

            final isToday =
            _isToday(provider.selectedDate);

            return Column(
              children: [
                const SizedBox(height: 16),

                _FeedingHeaderCard(
                  provider: provider,
                  showLogButton:
                  isToday && _showLogButton,
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recent Feedings",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await provider.initialize();
                    },
                    child: provider.filteredFeedings.isEmpty
                        ? ListView(
                      controller: _scrollController,
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child:
                          Text("No feedings logged yet"),
                        ),
                      ],
                    )
                        : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      itemCount:
                      provider.filteredFeedings.length,
                      itemBuilder: (context, index) {
                        final feeding =
                        provider.filteredFeedings[index];
                        return _FeedingListItem(
                            feeding: feeding);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeedingHeaderCard extends StatelessWidget {
  final FeedingProvider provider;
  final bool showLogButton;

  const _FeedingHeaderCard({
    required this.provider,
    required this.showLogButton,
  });

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final isToday =
    _isToday(provider.selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shadowColor:
        Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 420;

              final dateSelector = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 18),
                    onPressed: () {
                      provider.setSelectedDate(
                        provider.selectedDate
                            .subtract(const Duration(days: 1)),
                      );
                    },
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(
                            provider.selectedDate),
                        style: const TextStyle(
                            fontWeight:
                            FontWeight.w600),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18),
                    onPressed: provider.selectedDate
                        .isBefore(DateTime.now())
                        ? () {
                      final nextDay =
                      provider.selectedDate
                          .add(const Duration(days: 1));
                      if (!nextDay.isAfter(
                          DateTime.now())) {
                        provider
                            .setSelectedDate(nextDay);
                      }
                    }
                        : null,
                  ),
                ],
              );

              final logBtn = AnimatedOpacity(
                opacity:
                showLogButton ? 1 : 0,
                duration: const Duration(
                    milliseconds: 250),
                child: isToday
                    ? ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) =>
                        const LogFeedingScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add,
                      size: 18),
                  label: const Text("Log Feeding"),
                  style:
                  ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              );

              final summaryCardsList = [
                _SummaryCard(
                  icon: Icons.pregnant_woman,
                  title: "Breast",
                  value:
                  "${provider.breastCount} feeds",
                  color: AppColors.weight,
                ),
                _SummaryCard(
                  icon: Icons.local_drink,
                  title: "Bottle",
                  value:
                  "${provider.bottleCount} feeds • ${provider.totalBottleMl.toStringAsFixed(0)} ml",
                  color: AppColors.feed,
                ),
                _SummaryCard(
                  icon: Icons.restaurant,
                  title: "Solid",
                  value:
                  "${provider.solidCount} meals",
                  color: AppColors.mood,
                ),
              ];

              return Column(
                children: [
                  /// DATE + LOG BUTTON ROW / COLUMN
                  isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(child: dateSelector),
                            const SizedBox(height: 12),
                            Center(child: logBtn),
                          ],
                        )
                      : Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            dateSelector,
                            logBtn,
                          ],
                        ),

                  const SizedBox(height: 20),

                  /// SUMMARY CARDS
                  isNarrow
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: summaryCardsList.map((card) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 140,
                                child: card,
                              ),
                            )).toList(),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(child: summaryCardsList[0]),
                            const SizedBox(width: 10),
                            Expanded(child: summaryCardsList[1]),
                            const SizedBox(width: 10),
                            Expanded(child: summaryCardsList[2]),
                          ],
                        ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color:
                        AppColors.primaryAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        provider.lastFedText != null
                            ? "Last fed: ${provider.lastFedText}"
                            : "No feedings logged yet",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                            fontWeight:
                            FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final yesterday =
    today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return "Today";
    }

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return "Yesterday";
    }

    return "${date.day}/${date.month}/${date.year}";
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: Colors.grey.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(
              fontWeight:
              FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(
              color: AppColors
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedingListItem extends StatelessWidget {
  final Feeding feeding;

  const _FeedingListItem({required this.feeding});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(feeding.id),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.55,
      },
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20),
              ),
              title:
              const Text("Delete Feeding"),
              content: const Text(
                "Are you sure you want to delete this feeding record?",
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                          context, false),
                  child:
                  const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    Colors.red,
                  ),
                  onPressed: () =>
                      Navigator.pop(
                          context, true),
                  child:
                  const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (_) async {
        await context
            .read<FeedingProvider>()
            .deleteFeeding(
            feeding.id);

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
            Text("Feeding deleted"),
          ),
        );
      },
      background: Container(
        margin:
        const EdgeInsets.only(bottom: 12),
        padding:
        const EdgeInsets.symmetric(
            horizontal: 20),
        alignment:
        Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red
              .withValues(alpha: 0.85),
          borderRadius:
          BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 26,
        ),
      ),
      child: Card(
        margin:
        const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: Padding(
          padding:
          const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                _getIcon(feeding),
                color:
                _getTypeColor(feeding),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      _buildTitle(
                          feeding),
                      style: Theme.of(
                          context)
                          .textTheme
                          .bodyMedium,
                    ),
                    const SizedBox(
                        height: 4),
                    Text(
                      _formatTime(
                          feeding
                              .timestamp),
                      style: Theme.of(
                          context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(
      Feeding feeding) {
    switch (feeding.type.name) {
      case 'breast':
        return AppColors.weight;
      case 'bottle':
        return AppColors.feed;
      case 'solid':
        return AppColors.mood;
      default:
        return AppColors.primaryAccent;
    }
  }

  IconData _getIcon(
      Feeding feeding) {
    switch (feeding.type.name) {
      case 'breast':
        return Icons.pregnant_woman;
      case 'bottle':
        return Icons.local_drink;
      case 'solid':
        return Icons.restaurant;
      default:
        return Icons.local_drink;
    }
  }

  String _buildTitle(
      Feeding feeding) {
    switch (feeding.type.name) {
      case 'breast':
        return "${feeding.breastSide?.name ?? ''} • ${feeding.duration ?? 0} min";
      case 'bottle':
        return "${feeding.bottleType?.name ?? ''} • ${feeding.quantity ?? 0} ml";
      case 'solid':
        return "${feeding.foodName ?? ''} • ${feeding.quantity ?? 0}";
      default:
        return "";
    }
  }

  String _formatTime(
      DateTime time) {
    final hour =
    time.hour > 12
        ? time.hour - 12
        : time.hour;
    final minute = time.minute
        .toString()
        .padLeft(2, '0');
    final period =
    time.hour >= 12
        ? "PM"
        : "AM";

    return "$hour:$minute $period";
  }
}