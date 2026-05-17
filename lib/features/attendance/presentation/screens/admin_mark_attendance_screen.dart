import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/user_model.dart';
import '../../data/attendance_models.dart';
import '../providers/attendance_provider.dart';

class AdminMarkAttendanceScreen extends StatefulWidget {
  final EventModel event;

  const AdminMarkAttendanceScreen({super.key, required this.event});

  @override
  State<AdminMarkAttendanceScreen> createState() =>
      _AdminMarkAttendanceScreenState();
}

class _AdminMarkAttendanceScreenState
    extends State<AdminMarkAttendanceScreen> {
  static const List<String> _years = [
    '1st',
    '2nd',
    '3rd',
    '4th',
    'Super Senior',
  ];

  String _selectedYear = '1st';
  List<UserModel> _students = [];
  Set<String> _markedUserIds = {};
  bool _loading = false;
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _loadTotalCount();
    _loadData();
  }

  Future<void> _loadTotalCount() async {
    final count =
        await context.read<AttendanceProvider>().getTotalStudentCount();
    if (mounted) setState(() => _totalStudents = count);
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final provider = context.read<AttendanceProvider>();
    final results = await Future.wait([
      provider.getStudentsByYear(_selectedYear),
      provider.getMarkedRecordsForEvent(widget.event.id),
    ]);
    final students = results[0] as List<UserModel>;
    final records = results[1] as List<AttendanceRecord>;
    if (mounted) {
      setState(() {
        _students = students;
        _markedUserIds = records.map((r) => r.userId).toSet();
        _loading = false;
      });
    }
  }

  Future<void> _toggle(UserModel student) async {
    final provider = context.read<AttendanceProvider>();
    if (_markedUserIds.contains(student.uid)) {
      await provider.unmarkAttendanceAsAdmin(student.uid, widget.event.id);
      setState(() => _markedUserIds.remove(student.uid));
    } else {
      await provider.markAttendanceAsAdmin(
        userId: student.uid,
        eventId: widget.event.id,
        userYear: student.year,
      );
      setState(() => _markedUserIds.add(student.uid));
    }
  }

  Future<void> _markAllPresent() async {
    final provider = context.read<AttendanceProvider>();
    setState(() => _loading = true);
    for (final student in _students) {
      if (!_markedUserIds.contains(student.uid)) {
        await provider.markAttendanceAsAdmin(
          userId: student.uid,
          eventId: widget.event.id,
          userYear: student.year,
        );
        _markedUserIds.add(student.uid);
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isGathering = widget.event.isGathering;
    final accentColor = isGathering ? colorScheme.primary : Colors.deepOrange;

    return Scaffold(
      appBar: AppBar(
        title: Text(isGathering ? 'Mark Gathering Attendance' : 'Mark Event Attendance'),
        actions: [
          if (_students.isNotEmpty && !_loading)
            TextButton.icon(
              onPressed: _markAllPresent,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark All'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Summary banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: accentColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Icon(
                  isGathering ? Icons.nights_stay : Icons.event,
                  color: accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.event.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: accentColor),
                  ),
                ),
                _CountBadge(
                  label: 'Present',
                  count: _markedUserIds.length,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _CountBadge(
                  label: 'Total',
                  count: _totalStudents,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          // Year selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Select Year',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: _years
                  .map((y) =>
                      DropdownMenuItem(value: y, child: Text('$y Year')))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedYear = val);
                  _loadData();
                }
              },
            ),
          ),
          // Student list
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_students.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_outline,
                        size: 56, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('No students in $_selectedYear year',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _students.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1),
                itemBuilder: (context, i) {
                  final student = _students[i];
                  final isPresent = _markedUserIds.contains(student.uid);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: isPresent
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.1),
                      child: Icon(
                        isPresent ? Icons.check : Icons.person_outline,
                        color: isPresent ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      student.email.split('@').first,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${student.email}  •  ${student.year} Year  •  ${student.branch}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: isPresent,
                      activeThumbColor: Colors.green,
                      onChanged: (_) => _toggle(student),
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

class _CountBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountBadge(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

