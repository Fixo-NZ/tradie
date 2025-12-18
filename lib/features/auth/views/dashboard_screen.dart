import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';

// ==========================================
// 1. DASHBOARD COLORS (Locally Defined)
// ==========================================
class DashboardDesignColors {
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color darkBlueNav = Color(0xFF1A237E);
  static const Color navTextGrey = Color(0xFF757575);
  static const Color timeBlue = Color(0xFF448AFF);
  static const Color backgroundGrey = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF9E9E9E);
}

// ==========================================
// 2. MAIN DASHBOARD SCREEN
// ==========================================
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeView(),
      const PlaceholderView(title: "Jobs", icon: Icons.work_outline),
      const PlaceholderView(title: "Messages", icon: Icons.chat_bubble_outline),
      const ProfileView(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 1:
        return 'My Jobs';
      case 2:
        return 'Messages';
      case 3:
        return 'My Profile';
      default:
        return 'FIXO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardDesignColors.backgroundGrey,

      // --- Custom App Bar ---
      appBar: AppBar(
        backgroundColor: DashboardDesignColors.backgroundGrey,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _selectedIndex == 0 ? 'FIXO' : _getPageTitle(_selectedIndex),
          style: const TextStyle(
            color: DashboardDesignColors.textDark,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 24,
          ),
        ),
        actions: [
          // Notification Bell (Only show on Home)
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined,
                        size: 28, color: DashboardDesignColors.textDark),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: const Text('6',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      // --- Body (Switches views) ---
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // --- FAB (Visible Everywhere) ---
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: DashboardDesignColors.darkBlueNav,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),

      // Ensures the button sits halfway on the bottom bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- Bottom Nav Bar ---
      bottomNavigationBar: CustomBottomAppBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
      ),
    );
  }
}

// ==========================================
// 3. HOME VIEW
// ==========================================
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.grey.shade600),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Functional Calendar
            const DashboardCalendar(),
            const SizedBox(height: 24),
            // Jobs List
            const Text("On Going Jobs",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DashboardDesignColors.textDark)),
            const SizedBox(height: 16),
            const JobCard(
                title: "House Visual Optimization",
                workerName: "James The Mason",
                timeRange: "09:00 - 12:30 PM",
                status: "IN PROGRESS",
                icon: Icons.brush_outlined,
                iconColor: Colors.orangeAccent),
            const JobCard(
                title: "Sink Repair",
                workerName: "Aaron The Plumber",
                timeRange: "02:30 - 04:30 PM",
                status: "IN PROGRESS",
                icon: Icons.plumbing_outlined,
                iconColor: Colors.blueAccent),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. PROFILE VIEW
// ==========================================
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: DashboardDesignColors.darkBlueNav,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text("My Profile",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            onPressed: () async {
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. HELPER WIDGETS
// ==========================================

class CustomBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomAppBar(
      {super.key, required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 10,
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_filled, "Home", 0),
              _buildNavItem(context, Icons.work_outline, "Jobs", 1),
              const SizedBox(width: 20),
              _buildNavItem(
                  context, Icons.chat_bubble_outline_rounded, "Messages", 2),
              _buildNavItem(
                  context, Icons.person_outline_rounded, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    final Color color = isSelected
        ? DashboardDesignColors.darkBlueNav
        : DashboardDesignColors.navTextGrey;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class PlaceholderView extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderView({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
        ],
      ),
    );
  }
}

// ------------------------------------------
// REFACTORED: FUNCTIONAL CALENDAR WIDGET
// ------------------------------------------
class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({super.key});

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends State<DashboardCalendar> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _weekStartDate;

  @override
  void initState() {
    super.initState();
    // Start week from current Monday
    final now = DateTime.now();
    _weekStartDate = now.subtract(Duration(days: now.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.add(const Duration(days: 7));
    });
  }

  void _onDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // Helper to check if two dates are same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getWeekDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Generate the 7 days for the current week view
    List<DateTime> weekDays = List.generate(
        7, (index) => _weekStartDate.add(Duration(days: index)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          // --- Header: Month Year + Navigation Arrows ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_getMonthName(_weekStartDate.month)} ${_weekStartDate.year}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DashboardDesignColors.textDark),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.grey.shade600),
                    onPressed: _previousWeek,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: Colors.grey.shade600),
                    onPressed: _nextWeek,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Week Row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((date) {
              final isSelected = _isSameDay(date, _selectedDate);
              return GestureDetector(
                onTap: () => _onDateTap(date),
                behavior: HitTestBehavior.opaque,
                child: _DayItem(
                  day: _getWeekDayName(date.weekday),
                  date: date.day.toString(),
                  isSelected: isSelected,
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;
  const _DayItem(
      {required this.day, required this.date, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day,
            style: TextStyle(
                color: isSelected
                    ? DashboardDesignColors.primaryOrange
                    : Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 13)),
        const SizedBox(height: 10),
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: isSelected
                ? DashboardDesignColors.primaryOrange
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
              child: Text(date,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 15))),
        ),
      ],
    );
  }
}

// ------------------------------------------
// REFACTORED: JOB CARD
// ------------------------------------------
class JobCard extends StatelessWidget {
  final String title, workerName, timeRange, status;
  final IconData icon;
  final Color iconColor;

  const JobCard({
    super.key,
    required this.title,
    required this.workerName,
    required this.timeRange,
    required this.status,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DashboardDesignColors.textDark)),
                const SizedBox(height: 4),
                Text(workerName,
                    style: const TextStyle(
                        fontSize: 13, color: DashboardDesignColors.textGrey)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 16, color: DashboardDesignColors.timeBlue),
                    const SizedBox(width: 4),
                    Text(timeRange,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DashboardDesignColors.timeBlue)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}