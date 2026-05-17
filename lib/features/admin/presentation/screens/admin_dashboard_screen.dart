import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../food/presentation/providers/food_provider.dart';
import '../../../complaints/presentation/providers/complaints_provider.dart';
import '../../../announcements/presentation/providers/announcements_provider.dart';
import '../../../home/presentation/screens/profile_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
        padding: const EdgeInsets.all(16),
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
                  const Text(
                    'Welcome, Admin!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.currentUser?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM dd yyyy').format(today),
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Today's Food Counts",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _FoodStatsCard(date: today),
            const SizedBox(height: 24),
            Text(
              'Complaints Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _ComplaintsStatCard(),
            const SizedBox(height: 24),
            Text(
              'Recent Announcements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _RecentAnnouncementsCard(),
          ],
        ),
      ),
    );
  }
}

class _FoodStatsCard extends StatelessWidget {
  final DateTime date;

  const _FoodStatsCard({required this.date});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FoodProvider>();
    return StreamBuilder<Map<String, int>>(
      stream: provider.getDailyTotalsStream(date),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'breakfast': 0, 'lunch': 0, 'dinner': 0};
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FoodStat(label: 'Breakfast', count: data['breakfast']!, color: Colors.orange, icon: Icons.free_breakfast),
                _FoodStat(label: 'Lunch', count: data['lunch']!, color: Colors.green, icon: Icons.lunch_dining),
                _FoodStat(label: 'Dinner', count: data['dinner']!, color: Colors.indigo, icon: Icons.dinner_dining),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FoodStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _FoodStat({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _ComplaintsStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<ComplaintsProvider>();
    return StreamBuilder(
      stream: provider.getAllComplaintsStream(),
      builder: (context, snapshot) {
        final complaints = snapshot.data ?? [];
        final pending = complaints.where((c) => c.status == 'Pending').length;
        final inProgress = complaints.where((c) => c.status == 'In Progress').length;
        final resolved = complaints.where((c) => c.status == 'Resolved').length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatPill(label: 'Pending', count: pending, color: Colors.red),
                _StatPill(label: 'In Progress', count: inProgress, color: Colors.orange),
                _StatPill(label: 'Resolved', count: resolved, color: Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _RecentAnnouncementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<AnnouncementsProvider>();
    return StreamBuilder(
      stream: provider.announcementsStream,
      builder: (context, snapshot) {
        final items = snapshot.data?.take(3).toList() ?? [];
        if (items.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No announcements yet', style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        return Card(
          child: Column(
            children: items
                .map(
                  (a) => ListTile(
                    leading: const Icon(Icons.campaign_outlined),
                    title: Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      DateFormat('MMM dd').format(a.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
