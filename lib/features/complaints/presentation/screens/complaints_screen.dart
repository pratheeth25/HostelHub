import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../providers/complaints_provider.dart';
import '../../data/complaint_model.dart';
import 'add_complaint_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  late final bool _isAdmin;
  late final Stream<List<ComplaintModel>> _stream;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _isAdmin = authProvider.isAdmin;
    final provider = context.read<ComplaintsProvider>();
    final uid = authProvider.currentUser?.uid;

    if (_isAdmin) {
      _stream = provider.getAllComplaintsStream();
    } else if (uid != null) {
      _stream = provider.getUserComplaintsStream(uid);
    } else {
      _stream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaints')),
      floatingActionButton: !_isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddComplaintScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Submit'),
            )
          : null,
      body: StreamBuilder<List<ComplaintModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error loading complaints: ${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No complaints yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) => _ComplaintCard(
              complaint: snapshot.data![i],
              isAdmin: _isAdmin,
            ),
          );
        },
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final bool isAdmin;

  const _ComplaintCard({required this.complaint, required this.isAdmin});

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ComplaintsProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(complaint.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    complaint.status,
                    style: TextStyle(
                      color: _statusColor(complaint.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(label: Text(complaint.category), padding: EdgeInsets.zero),
                const SizedBox(width: 8),
                if (complaint.anonymous)
                  const Chip(label: Text('Anonymous'), padding: EdgeInsets.zero),
              ],
            ),
            const SizedBox(height: 4),
            Text(complaint.description),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy').format(complaint.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: complaint.status,
                decoration: const InputDecoration(
                  labelText: 'Update Status',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ComplaintsProvider.statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) provider.updateStatus(complaint.id, val);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
