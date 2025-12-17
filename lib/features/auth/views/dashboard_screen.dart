import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

// --- Local Colors ---
class DashboardDesignColors {
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color darkBlueNav = Color(0xFF1A237E);
  static const Color navTextGrey = Color(0xFF757575);
  static const Color timeBlue = Color(0xFF448AFF);
  static const Color backgroundGrey = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF9E9E9E);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep watching auth state if needed for UI updates
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: DashboardDesignColors.backgroundGrey,

      // --- Custom App Bar ---
      appBar: AppBar(
        backgroundColor: DashboardDesignColors.backgroundGrey,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'FIXO',
          style: TextStyle(
            color: DashboardDesignColors.textDark,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined, size: 28, color: DashboardDesignColors.textDark),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notifications coming soon!")),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '6',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // --- Main Body ---
      body: SingleChildScrollView(
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
                          hintText: "",
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
              // Calendar
              const CalendarMockupCard(),
              const SizedBox(height: 24),
              // Jobs Title
              const Text(
                "On Going Jobs",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DashboardDesignColors.textDark
                ),
              ),
              const SizedBox(height: 16),
              // Jobs List
              const JobCard(
                title: "House Visual Optimization",
                workerName: "James The Mason",
                timeRange: "9:30 - 12:30 PM",
                status: "IN PROGRESS",
              ),
              const JobCard(
                title: "Sink Repair",
                workerName: "Aaron The Plumber",
                timeRange: "9:30 - 10:30 AM",
                status: "IN PROGRESS",
              ),
              const JobCard(
                title: "Termite Treatment",
                workerName: "Ivan The Pest Control",
                timeRange: "7:30 - 10:00 AM",
                status: "IN PROGRESS",
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // --- FAB ---
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- Bottom Navigation ---
      bottomNavigationBar: CustomBottomAppBar(
        onLogoutSelected: () async {
          print("Logout selected..."); // Debug print
          try {
            // Read the notifier directly inside the callback for safety
            await ref.read(authViewModelProvider.notifier).logout();
            print("Logout successful. Navigating...");

            if (context.mounted) {
              context.go('/login');
            }
          } catch (e) {
            print("Logout failed: $e");
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Logout failed: $e")),
              );
            }
          }
        },
      ),
    );
  }
}

// =========================================
// CUSTOM WIDGETS
// =========================================

// --- 1. Job Card Widget ---
class JobCard extends StatelessWidget {
  final String title;
  final String workerName;
  final String timeRange;
  final String status;

  const JobCard({
    super.key,
    required this.title,
    required this.workerName,
    required this.timeRange,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: DashboardDesignColors.primaryOrange, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DashboardDesignColors.textDark)),
                      const SizedBox(height: 4),
                      Text(workerName, style: const TextStyle(fontSize: 14, color: DashboardDesignColors.textGrey)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: DashboardDesignColors.primaryOrange,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: DashboardDesignColors.timeBlue),
                const SizedBox(width: 6),
                Text(timeRange, style: const TextStyle(color: DashboardDesignColors.timeBlue, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMockAvatar(Colors.brown.shade300),
                _buildMockAvatar(Colors.orange.shade300),
                _buildMockAvatar(Colors.blueGrey.shade300),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                  child: Text("+3", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMockAvatar(Color color) {
    return Align(
      widthFactor: 0.6,
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: const Icon(Icons.person, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}

// --- 2. Calendar Mockup Widget ---
class CalendarMockupCard extends StatelessWidget {
  const CalendarMockupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left, color: DashboardDesignColors.textGrey)),
              Column(
                children: [
                  const Text("April 2025", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Job to do 12 TASKS 8 UNFINISH", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right, color: DashboardDesignColors.textGrey)),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Sun", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Mon", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Tue", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Wed", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Thu", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Fri", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Sat", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("30", style: TextStyle(color: DashboardDesignColors.textGrey)),
              CircleAvatar(
                radius: 16,
                backgroundColor: DashboardDesignColors.textDark,
                child: Text("1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Text("2", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("3", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("4", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("5", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("6", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("7", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("8", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("9", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("10", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("11", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("12", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("13", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 3. Custom Bottom Navigation Bar (FIXED) ---
class CustomBottomAppBar extends StatelessWidget {
  final VoidCallback onLogoutSelected;

  const CustomBottomAppBar({super.key, required this.onLogoutSelected});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 10,
      // Wrap in SafeArea to ensure it's not hidden by system gestures
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_filled, "Home", isSelected: true),
              _buildNavItem(context, Icons.work_outline, "Jobs"),
              const SizedBox(width: 48), // Spacer for the center FAB
              _buildNavItem(context, Icons.chat_bubble_outline_rounded, "Messages"),

              // Profile Button with Popup Menu for Logout
              PopupMenuButton<String>(
                offset: const Offset(0, -50), // Show menu above the tab
                color: Colors.white, // Ensure background is white
                onSelected: (value) {
                  print("Menu selected: $value"); // Debug print
                  if (value == 'logout') {
                    onLogoutSelected();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
                // We use child to ensure the click area is correct
                child: _buildNavItem(context, Icons.person_outline_rounded, "Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, {bool isSelected = false}) {
    final Color color = isSelected ? DashboardDesignColors.darkBlueNav : DashboardDesignColors.navTextGrey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 26),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }
}