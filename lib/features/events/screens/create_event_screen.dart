import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../../../models/event_model.dart';
import '../../auth/providers/auth_provider.dart';

final _storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class CreateEventScreen extends ConsumerStatefulWidget {
  final String? eventId;
  const CreateEventScreen({super.key, this.eventId});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  DateTime _dateTime = DateTime.now().add(const Duration(days: 1));
  File? _bannerFile;
  String? _existingBannerUrl;
  bool _loading = false;
  EventModel? _existingEvent;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) _loadEvent();
  }

  Future<void> _loadEvent() async {
    final events = await ref.read(firestoreServiceProvider).getAllEvents().first;
    final event = events.where((e) => e.id == widget.eventId).firstOrNull;
    if (event != null) {
      setState(() {
        _existingEvent = event;
        _titleCtrl.text = event.title;
        _descCtrl.text = event.description;
        _venueCtrl.text = event.venue;
        _limitCtrl.text = event.participantLimit.toString();
        _dateTime = event.dateTime;
        _existingBannerUrl = event.bannerUrl;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _bannerFile = File(picked.path));
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      String? bannerUrl = _existingBannerUrl;
      if (_bannerFile != null) {
        bannerUrl = await ref.read(_storageServiceProvider).uploadEventBanner(_bannerFile!);
      }
      final firestore = ref.read(firestoreServiceProvider);
      if (_existingEvent != null) {
        await firestore.updateEvent(_existingEvent!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          dateTime: _dateTime,
          venue: _venueCtrl.text.trim(),
          participantLimit: int.parse(_limitCtrl.text),
          bannerUrl: bannerUrl,
        ));
      } else {
        final event = EventModel(
          id: '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          dateTime: _dateTime,
          venue: _venueCtrl.text.trim(),
          participantLimit: int.parse(_limitCtrl.text),
          registeredCount: 0,
          organizerId: user?.uid ?? '',
          organizerName: user?.name ?? '',
          bannerUrl: bannerUrl,
          isActive: true,
          createdAt: DateTime.now(),
        );
        await firestore.createEvent(event);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Event' : 'Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    image: _bannerFile != null
                        ? DecorationImage(
                            image: FileImage(_bannerFile!), fit: BoxFit.cover)
                        : _existingBannerUrl != null
                            ? DecorationImage(
                                image:
                                    NetworkImage(_existingBannerUrl!),
                                fit: BoxFit.cover)
                            : null,
                  ),
                  child: _bannerFile == null && _existingBannerUrl == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: cs.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text('Add Banner Image',
                                style: TextStyle(color: cs.onSurfaceVariant)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Event Title',
                    prefixIcon: Icon(Icons.title)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outline)),
                leading: const Icon(Icons.calendar_month),
                title: Text(DateFormat('EEE, MMM d, y • h:mm a').format(_dateTime)),
                subtitle: const Text('Date & Time'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _venueCtrl,
                decoration: const InputDecoration(
                    labelText: 'Venue',
                    prefixIcon: Icon(Icons.location_on_outlined)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Participant Limit',
                    prefixIcon: Icon(Icons.people_outline)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null || int.parse(v) < 1) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loading ? null : _save,
                icon: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isEdit ? 'Update Event' : 'Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
