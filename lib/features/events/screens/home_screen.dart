import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/providers/event_provider.dart';
import '../../../widgets/event_card.dart';
import '../../../widgets/shimmer_list.dart';
import '../../../services/auth_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusSphere'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          _MyEventsTab(),
        ],
      ),
      floatingActionButton: userAsync.when(
        data: (user) => user?.isAdmin == true
            ? FloatingActionButton.extended(
                onPressed: () => context.push('/create-event'),
                icon: const Icon(Icons.add),
                label: const Text('Create Event'),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'My Events',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(upcomingEventsProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userAsync.when(
              data: (user) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primaryContainer, cs.secondaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: cs.primary,
                      child: Text(
                        (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(
                            user?.name ?? 'Student',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${user?.course} • ${user?.hostelBlock}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (user?.isAdmin == true)
                      Chip(
                        label: const Text('Admin'),
                        backgroundColor: cs.primary,
                        labelStyle: TextStyle(color: cs.onPrimary),
                      ),
                  ],
                ),
              ),
              loading: () => const ShimmerList(count: 1, height: 90),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 24),
            Text('Upcoming Events',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.event_busy, size: 48, color: cs.outline),
                          const SizedBox(height: 12),
                          Text('No upcoming events',
                              style: TextStyle(color: cs.outline)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => EventCard(event: events[i]),
                );
              },
              loading: () => const ShimmerList(count: 3),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyEventsTab extends ConsumerWidget {
  const _MyEventsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(userRegisteredEventsProvider);
    final cs = Theme.of(context).colorScheme;

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 64, color: cs.outline),
                const SizedBox(height: 16),
                Text('No registered events yet',
                    style: TextStyle(color: cs.outline)),
                const SizedBox(height: 8),
                Text('Browse events and register to see them here',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.outline)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => EventCard(event: events[i]),
        );
      },
      loading: () => const ShimmerList(count: 3),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
