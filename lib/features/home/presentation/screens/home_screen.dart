import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../announcements/presentation/screens/announcements_screen.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../complaints/presentation/screens/complaints_screen.dart';
import '../../../food/presentation/screens/food_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void jumpToPage(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _studentPages = [
    const _HomeDashboard(),
    const AnnouncementsScreen(),
    const AttendanceScreen(),
    const ComplaintsScreen(),
    const FoodScreen(),
  ];

  final List<Widget> _adminPages = [
    const AdminDashboardScreen(),
    const AnnouncementsScreen(),
    const AttendanceScreen(),
    const ComplaintsScreen(),
    const FoodScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final pages = isAdmin ? _adminPages : _studentPages;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: Icon(isAdmin ? Icons.dashboard_outlined : Icons.home_outlined),
            selectedIcon: Icon(isAdmin ? Icons.dashboard : Icons.home),
            label: isAdmin ? 'Dashboard' : 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Notice',
          ),
          const NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg),
            label: 'Attendance',
          ),
          const NavigationDestination(
            icon: Icon(Icons.report_outlined),
            selectedIcon: Icon(Icons.report),
            label: 'Complaints',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Food',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: themeProvider.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user?.email.split('@').first ?? 'Student'}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user != null)
                    Text(
                      '${user.course} • ${user.year} Year • ${user.branch}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: const [
                _QuickAccessCard(
                  title: 'Announcements',
                  icon: Icons.campaign,
                  color: Colors.blue,
                  pageIndex: 1,
                ),
                _QuickAccessCard(
                  title: 'Attendance',
                  icon: Icons.how_to_reg,
                  color: Colors.green,
                  pageIndex: 2,
                ),
                _QuickAccessCard(
                  title: 'Complaints',
                  icon: Icons.report,
                  color: Colors.red,
                  pageIndex: 3,
                ),
                _QuickAccessCard(
                  title: 'Food Count',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                  pageIndex: 4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int pageIndex;

  const _QuickAccessCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final homeState = context.findAncestorStateOfType<_HomeScreenState>();
          homeState?.jumpToPage(pageIndex);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
