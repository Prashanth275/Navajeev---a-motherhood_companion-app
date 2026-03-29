import 'package:flutter/material.dart';
import 'package:navajeev_m/screens/appointments/appointment_page.dart';
import 'package:navajeev_m/screens/tracker/baby_growth_tracker/growth_home_page.dart';
import 'package:navajeev_m/screens/tracker/feeding%20tracker/feeding_tracker_screen.dart';
import 'package:navajeev_m/screens/tracker/sleep_tracker/sleep_dashboard.dart';
import 'package:navajeev_m/screens/tracker/trimester_tracker/trimester_tracker_screen.dart';
import 'package:navajeev_m/widgets/app_widgets/app_header.dart';
import 'package:navajeev_m/widgets/app_widgets/side_nav.dart';
import 'package:provider/provider.dart';
import '../../providers/feeding/feeding_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/reponsive.dart';
import '../../widgets/app_widgets/bottom_nav.dart';
import '../../widgets/home_page_widgets/home_dashboard.dart';
import '../chatbot/chat_page.dart';
import '../tracker/trackers_page.dart';
import '../tracker/vaccination_tracker_page.dart';
import '../wellbeing/wellbeing_page.dart';
import '../profile/profile_page.dart';
import 'package:navajeev_m/models/user_model.dart';
import 'package:navajeev_m/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isSideNavCollapsed = false;

  @override
  void initState() {
    super.initState();

      final feedingProvider =
      context.read<FeedingProvider>();

      feedingProvider.setSelectedDate(DateTime.now());
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<_NavConfig> _getNavConfig(UserModel? user) {
    final stage = user?.stage ?? UserStage.pregnancy;

    if (stage == UserStage.pregnancy) {
      return [
        _NavConfig(title: 'Dashboard', icon: Icons.home_outlined, page: const HomeDashboard()), // 0
        _NavConfig(title: 'Trimester', icon: Icons.calculate_outlined, page: const TrimesterTrackerScreen()), // 1
        _NavConfig(title: 'AI Assistant', icon: Icons.chat_bubble_outline, page: const ChatPage()), // 2
        _NavConfig(title: 'Sleep Tracker', icon: Icons.bedtime_outlined, page: const SleepDashboard()), // 3
        _NavConfig(title: 'Appointments', icon: Icons.calendar_today_outlined, page: const AppointmentsPage()),
        _NavConfig(title: 'Wellbeing', icon: Icons.favorite_border, page: const WellbeingScreen()),
        _NavConfig(title: 'Profile', icon: Icons.person_outline, page:  ProfilePage()), // 6 (Consistent index)
        _NavConfig(title: 'Settings', icon: Icons.settings_outlined, page: const Center(child: Text('Settings Page'))),
      ];
    } else {
      return [
        _NavConfig(title: 'Dashboard', icon: Icons.home_outlined, page: const HomeDashboard()), // 0
        _NavConfig(title: 'Growth Tracker', icon: Icons.show_chart, page: const GrowthHomePage()), // 1
        _NavConfig(title: 'AI Assistant', icon: Icons.chat_bubble_outline, page: const ChatPage()), // 2
        _NavConfig(title: 'Feeding', icon: Icons.soup_kitchen_outlined, page: const FeedingTrackerScreen()), // 3
        _NavConfig(title: 'Vaccines', icon: Icons.vaccines_outlined, page: const VaccinationTrackerPage()),
        _NavConfig(title: 'Sleep Tracker', icon: Icons.bedtime_outlined, page: const SleepDashboard()),
        _NavConfig(title: 'Appointments', icon: Icons.calendar_today_outlined, page: const AppointmentsPage()),
        _NavConfig(title: 'Wellbeing', icon: Icons.favorite_border, page: const WellbeingScreen()),
        _NavConfig(title: 'Profile', icon: Icons.person_outline, page: ProfilePage()), // 8 (Consistent index)
        _NavConfig(title: 'Settings', icon: Icons.settings_outlined, page: const Center(child: Text('Settings Page'))),
      ];
    }
  }

  List<int> _getBottomNavIndices(UserModel? user) {
    final navConfig = _getNavConfig(user);
    int profileIndex = navConfig.indexWhere((c) => c.title == 'Profile');
    if (profileIndex == -1) profileIndex = 6; // Default fallback

    return [0, 1, 2, 3, profileIndex];
  }

  List<int> _getDrawerIndices(UserModel? user) {
    final all = List.generate(_getNavConfig(user).length, (i) => i);
    final bottom = _getBottomNavIndices(user);
    return all.where((i) => !bottom.contains(i)).toList();
  }

  String _getGreeting(UserModel user) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good Morning';
    } else if (hour < 17) {
      timeGreeting = 'Good Afternoon';
    }
    else timeGreeting = 'Good Evening';
    return '$timeGreeting, ${user.name}';
  }

  String? _getSubtitle(UserModel user) {
    if (user.isPregnancy && user.pregnancyDetails != null) {
      final weeksLeft = user.pregnancyDetails!.expectedDueDate.difference(DateTime.now()).inDays ~/ 7;
      return weeksLeft > 0 ? '$weeksLeft weeks to go' : 'Due date reached';
    }
    if (user.isPostpartum && user.babyDetails != null) {
      final baby = user.babyDetails!;
      final days = DateTime.now().difference(baby.dateOfBirth).inDays;
      final months = (days / 30).floor();
      return '${baby.name} • ${months < 1 ? '$days days old' : '$months months old'}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final UserModel? user = auth.currentUser;
    final navConfig = _getNavConfig(user);
    final greeting = user != null ? _getGreeting(user) : '';
    final subtitle = user != null ? _getSubtitle(user) : null;

    return Responsive(
      mobile: _MobileLayout(
        user: user,
        currentIndex: _currentIndex,
        allPages: navConfig,
        bottomNavIndices: _getBottomNavIndices(user),
        drawerIndices: _getDrawerIndices(user),
        greeting: greeting,
        subtitle: subtitle,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      desktop: _DesktopLayout(
        user: user,
        currentIndex: _currentIndex,
        allPages: navConfig,
        isCollapsed: _isSideNavCollapsed,
        greeting: greeting,
        subtitle: subtitle,
        onToggleCollapse: () => setState(() => _isSideNavCollapsed = !_isSideNavCollapsed),
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final UserModel? user;
  final int currentIndex;
  final List<_NavConfig> allPages;
  final List<int> bottomNavIndices;
  final List<int> drawerIndices;
  final Function(int) onTap;
  final String greeting;
  final String? subtitle;

  const _MobileLayout({
    required this.user,
    required this.currentIndex,
    required this.allPages,
    required this.bottomNavIndices,
    required this.drawerIndices,
    required this.onTap,
    required this.greeting,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final pages = allPages.map((c) => c.page).toList();
    int bottomNavSelection = bottomNavIndices.indexOf(currentIndex);
    if (bottomNavSelection == -1) bottomNavSelection = 0;

    final bool isTrimester =
        allPages[currentIndex].title == 'Trimester';

    return Scaffold(
      extendBody: true,
      appBar: isTrimester
          ? null
      : AppHeader(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: currentIndex == 0 ? greeting : allPages[currentIndex].title,
        subtitle: currentIndex == 0 ? subtitle : null,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'User'),
              accountEmail: const Text('Navajeev Companion'),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              decoration: const BoxDecoration(gradient: AppColors.brandGradient), // Pink accent
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...drawerIndices.map((index) => ListTile(
                    leading: Icon(allPages[index].icon),
                    title: Text(allPages[index].title),
                    selected: currentIndex == index,
                    onTap: () {
                      onTap(index);
                      Navigator.pop(context);
                    },
                  )),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                      onTap: () => context.read<AuthService>().signOut(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: bottomNavSelection,
        onTap: (navIndex) => onTap(bottomNavIndices[navIndex]),
        items: bottomNavIndices.map((index) => BottomNavigationBarItem(
          icon: Icon(allPages[index].icon),
          label: allPages[index].title,
        )).toList(),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final UserModel? user;
  final int currentIndex;
  final List<_NavConfig> allPages;
  final bool isCollapsed;
  final String greeting;
  final String? subtitle;
  final VoidCallback onToggleCollapse;
  final Function(int) onTap;

  const _DesktopLayout({
    required this.user,
    required this.currentIndex,
    required this.allPages,
    required this.isCollapsed,
    required this.greeting,
    required this.subtitle,
    required this.onToggleCollapse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = allPages.map((c) => SideNavItem(title: c.title, icon: c.icon)).toList();
    final pages = allPages.map((c) => c.page).toList();

    final bool isTrimester =
        allPages[currentIndex].title == 'Trimester';

    return Row(
      children: [
        SideNav(
          currentIndex: currentIndex,
          isCollapsed: isCollapsed,
          onToggleCollapse: onToggleCollapse,
          onTap: onTap,
          items: navItems,
        ),
        Expanded(
          child: Scaffold(
            appBar: isTrimester
                ? null
                : AppHeader(
              title: currentIndex == 0 ? greeting : allPages[currentIndex].title,
              subtitle: currentIndex == 0 ? subtitle : null,
            ),
            body: IndexedStack(index: currentIndex, children: pages),
          ),
        ),
      ],
    );
  }
}

class _NavConfig {
  final String title;
  final IconData icon;
  final Widget page;
  _NavConfig({required this.title, required this.icon, required this.page});
}