import 'package:flutter/material.dart';
import 'package:navajeev_m/widgets/app_header.dart';
import 'package:navajeev_m/widgets/side_nav.dart';
import '../../widgets/home_dashboard.dart';
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

  // Mapping pages to side nav items
  // 0: Dashboard
  // 1: Growth (Tracker)
  // 2: Vaccines (New/Placeholder)
  // 3: Sleep (Tracker)
  // 4: Feeding (Tracker)
  // 5: Mental Health (Wellbeing)
  // 6: Trimester (Placeholder)
  // 7: Appointments (Placeholder)
  // 8: AI Assistant (Chat)
  // 9: Tips (Placeholder)
  // 10: Profile
  final List<Widget> _pages =  [
    HomeDashboard(), // 0
    TrackersPage(singleTracker: 'Growth Tracker'), // 1
    VaccinationTrackerPage(), // 2
    TrackersPage(singleTracker: 'Sleep Tracker'), // 3
    TrackersPage(singleTracker: 'Feed Tracker'), // 4
    WellbeingPage(), // 5
    Center(child: Text('Trimester Tracker')), // 6
    Center(child: Text('Appointments')), // 7
    ChatPage(), // 8
    Center(child: Text('Tips & Myths')), // 9
    ProfilePage(), // 10
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Growth Tracker',
    'Vaccines',
    'Sleep Tracker',
    'Feeding Tracker',
    'Mental Health',
    'Trimester',
    'Appointments',
    'Chat Assistant',
    'Tips & Myths',
    'Profile',
  ];

    String _getGreeting(UserModel user) {
      final hour = DateTime.now().hour;
      String timeGreeting;

      if (hour < 12) {
        timeGreeting = 'Good Morning';
      } else if (hour < 17) {
        timeGreeting = 'Good Afternoon';
      } else {
        timeGreeting = 'Good Evening';
      }

      return '$timeGreeting, ${user.name}';
    }

    String? _getSubtitle(UserModel user) {
      if (user.isPregnancy && user.pregnancyDetails != null) {
        final dueDate = user.pregnancyDetails!.expectedDueDate;
        final weeksLeft = dueDate.difference(DateTime.now()).inDays ~/ 7;

        if (weeksLeft > 0) {
          return '$weeksLeft weeks to go';
        } else {
          return 'Due date reached';
        }
      }

      if (user.isPostpartum && user.babyDetails != null) {
        final baby = user.babyDetails!;
        final days = DateTime.now().difference(baby.dateOfBirth).inDays;
        final months = (days / 30).floor();

        final ageText =
        months < 1 ? '$days days old' : '$months months old';

        return '${baby.name} • $ageText';
      }

      return null;
    }


    @override
  Widget build(BuildContext context) {
    final UserModel? user = authService.currentUser;

    return Scaffold(
      body: Row(
        children: [
          SideNav(
            currentIndex: _currentIndex,
            isCollapsed: _isSideNavCollapsed,
            onToggleCollapse: () {
              setState(() {
                _isSideNavCollapsed = !_isSideNavCollapsed;
              });
            },
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Expanded(
            child: Scaffold(
              appBar: AppHeader(
                title: _currentIndex == 0 && user != null
                    ? _getGreeting(user)
                    : _titles[_currentIndex],
                subtitle: _currentIndex == 0 && user != null
                    ? _getSubtitle(user)
                    : null,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                ],
              ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    ),
      ),
      ],
      ),
      );
  }
}
