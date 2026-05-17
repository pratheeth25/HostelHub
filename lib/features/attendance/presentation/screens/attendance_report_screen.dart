import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../../data/attendance_models.dart';

class AttendanceReportScreen extends StatefulWidget {
  final EventModel event;

  const AttendanceReportScreen({super.key, required this.event});

  @override
  State<AttendanceReportScreen> createState() =>
      _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _loadTotal();
  }

  Future<void> _loadTotal() async {
    final count =
        await context.read<AttendanceProvider>().getTotalStudentCount();
    if (mounted) setState(() => _totalStudents = count);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AttendanceProvider>();
    final isGathering = widget.event.isGathering;
    final accentColor = isGathering
        ? Theme.of(context).colorScheme.primary
        : Colors.deepOrange;

    return Scaffold(
      appBar: AppBar(
        title: Text(isGathering
            ? 'Evening Gathering Report'
            : 'Report: ${widget.event.title}'),
      ),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: provider.getAttendanceForEvent(widget.event.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data ?? [];

          final yearGroups = <String, int>{};
          for (final r in records) {
            yearGroups[r.userYear] = (yearGroups[r.userYear] ?? 0) + 1;
          }

          final absentCount =
              (_totalStudents - records.length).clamp(0, _totalStudents);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Present',
                        count: records.length,
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Absent',
                        count: absentCount,
                        icon: Icons.cancel_outlined,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Total',
                        count: _totalStudents,
                        icon: Icons.people_outline,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Event meta
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                                isGathering
                                    ? Icons.nights_stay
                                    : Icons.event,
                                color: accentColor,
                                size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.event.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMM dd yyyy')
                              .format(widget.event.date),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                        if (widget.event.startTime != null ||
                            widget.event.endTime != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              [
                                widget.event.startTime,
                                widget.event.endTime
                              ]
                                  .where((t) => t != null)
                                  .join(' – '),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // By Year breakdown
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance by Year',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (yearGroups.isEmpty)
                          const Text('No records yet',
                              style: TextStyle(color: Colors.grey))
                        else
                          ...yearGroups.entries.map(
                            (entry) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Text('${entry.key} Year',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.green
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${entry.value} present',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Individual records
                Text(
                  'Attendance List (${records.length})',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: Text('No attendance records',
                            style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...records.map(
                    (r) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0x1A4CAF50),
                        child: Icon(Icons.check,
                            color: Colors.green, size: 18),
                      ),
                      title: Text(r.userId),
                      subtitle: Text('${r.userYear} Year'),
                      trailing: Text(
                        DateFormat('HH:mm').format(r.timestamp),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

