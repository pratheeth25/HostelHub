import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../../data/attendance_models.dart';
import 'add_event_screen.dart';
import 'attendance_report_screen.dart';
import 'admin_mark_attendance_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final count =
        await context.read<AttendanceProvider>().getTotalStudentCount();
    if (mounted) setState(() => _totalStudents = count);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthProvider>().isAdmin;
    final provider = context.read<AttendanceProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEventScreen()),
                );
                _loadCount();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          : null,
      body: Column(
        children: [
          // Total students banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            child: Row(
              children: [
                Icon(Icons.people_alt_outlined,
                    color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total Students: $_totalStudents',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: provider.eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_reg_outlined,
                            size: 64,
                            color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('No attendance records yet',
                            style: TextStyle(color: colorScheme.outline)),
                        if (isAdmin) ...[
                          const SizedBox(height: 8),
                          Text('Tap + to add an Evening Gathering or Event',
                              style: TextStyle(
                                  color: colorScheme.outline, fontSize: 12)),
                        ],
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) => _EventCard(
                    event: snapshot.data![i],
                    isAdmin: isAdmin,
                    totalStudents: _totalStudents,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Event Card ────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final EventModel event;
  final bool isAdmin;
  final int totalStudents;

  const _EventCard(
      {required this.event,
      required this.isAdmin,
      required this.totalStudents});

  @override
  Widget build(BuildContext context) {
    final isGathering = event.isGathering;
    final accentColor = isGathering
        ? Theme.of(context).colorScheme.primary
        : Colors.deepOrange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: type badge + title + report button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          isGathering ? Icons.nights_stay : Icons.event,
                          size: 13,
                          color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        isGathering ? 'Evening Gathering' : 'Event',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accentColor),
                      ),
                      if (isGathering) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Mandatory',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor)),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.bar_chart, size: 20),
                    tooltip: 'View Report',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AttendanceReportScreen(event: event),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Title (only for events, gatherings have fixed title)
            if (!isGathering)
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            if (!isGathering && event.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(event.description,
                  style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 6),
            // Date & time
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('EEE, MMM dd yyyy').format(event.date),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                if (event.startTime != null || event.endTime != null) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time_outlined,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    [event.startTime, event.endTime]
                        .where((t) => t != null)
                        .join(' – '),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            if (isAdmin)
              _AdminEventAction(event: event, totalStudents: totalStudents)
            else
              _UserEventSection(event: event),
          ],
        ),
      ),
    );
  }
}

// ── Admin action row ──────────────────────────────────────────────────────────

class _AdminEventAction extends StatefulWidget {
  final EventModel event;
  final int totalStudents;

  const _AdminEventAction(
      {required this.event, required this.totalStudents});

  @override
  State<_AdminEventAction> createState() => _AdminEventActionState();
}

class _AdminEventActionState extends State<_AdminEventAction> {
  int _markedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final records = await context
        .read<AttendanceProvider>()
        .getMarkedRecordsForEvent(widget.event.id);
    if (mounted) setState(() => _markedCount = records.length);
  }

  @override
  Widget build(BuildContext context) {
    final isGathering = widget.event.isGathering;
    final accentColor = isGathering
        ? Theme.of(context).colorScheme.primary
        : Colors.deepOrange;

    return Row(
      children: [
        // Attendance count chips
        _MiniChip(
            label: '$_markedCount present',
            color: Colors.green),
        const SizedBox(width: 6),
        _MiniChip(
            label: '${widget.totalStudents} total',
            color: Colors.blueGrey),
        const Spacer(),
        FilledButton.tonalIcon(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    AdminMarkAttendanceScreen(event: widget.event),
              ),
            );
            _loadCount();
          },
          icon: Icon(Icons.how_to_reg_outlined,
              size: 17, color: accentColor),
          label: Text('Mark', style: TextStyle(color: accentColor)),
          style: FilledButton.styleFrom(
            backgroundColor: accentColor.withValues(alpha: 0.12),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ── User section ──────────────────────────────────────────────────────────────

class _UserEventSection extends StatefulWidget {
  final EventModel event;
  const _UserEventSection({required this.event});

  @override
  State<_UserEventSection> createState() => _UserEventSectionState();
}

class _UserEventSectionState extends State<_UserEventSection> {
  bool? _isPresent;
  bool? _onLeave;
  bool _leaveLoading = false;

  String get _userId =>
      context.read<AuthProvider>().currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final provider = context.read<AttendanceProvider>();
    final uid = _userId;
    final present =
        await provider.hasMarkedAttendance(uid, widget.event.id);
    final onLeave =
        await provider.hasMarkedLeave(uid, widget.event.id);
    if (mounted) {
      setState(() {
        _isPresent = present;
        _onLeave = onLeave;
      });
    }
  }

  Future<void> _toggleLeave() async {
    setState(() => _leaveLoading = true);
    final provider = context.read<AttendanceProvider>();
    final uid = _userId;
    String? error;
    if (_onLeave == true) {
      error = await provider.cancelLeave(userId: uid, eventId: widget.event.id);
      if (error == null) setState(() => _onLeave = false);
    } else {
      error = await provider.markLeave(userId: uid, eventId: widget.event.id);
      if (error == null) setState(() => _onLeave = true);
    }
    setState(() => _leaveLoading = false);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGathering = widget.event.isGathering;
    final accentColor = isGathering
        ? Theme.of(context).colorScheme.primary
        : Colors.deepOrange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attendance status row
        Row(
          children: [
            Icon(isGathering ? Icons.nights_stay_outlined : Icons.event_outlined,
                color: accentColor, size: 18),
            const SizedBox(width: 6),
            Text(
              isGathering ? 'Evening Gathering' : 'Attendance',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: accentColor),
            ),
            if (isGathering)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Mandatory',
                    style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            const Spacer(),
            if (_isPresent == null)
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else if (_isPresent!)
              const Chip(
                label: Text('Present',
                    style: TextStyle(color: Colors.green, fontSize: 12)),
                avatar: Icon(Icons.check_circle,
                    color: Colors.green, size: 15),
                backgroundColor: Color(0x1A4CAF50),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            else
              Chip(
                label: const Text('Not marked',
                    style: TextStyle(fontSize: 12)),
                avatar: const Icon(Icons.radio_button_unchecked, size: 15),
                backgroundColor:
                    Colors.grey.withValues(alpha: 0.1),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Leave button
        if (_onLeave != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _leaveLoading ? null : _toggleLeave,
              icon: _leaveLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_onLeave!
                      ? Icons.event_available
                      : Icons.event_busy_outlined),
              label: Text(
                  _onLeave! ? 'Cancel Leave' : 'Mark as On Leave'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _onLeave! ? Colors.grey : Colors.amber[800],
                side: BorderSide(
                    color: _onLeave!
                        ? Colors.grey
                        : Colors.amber.shade700),
              ),
            ),
          ),
      ],
    );
  }
}

