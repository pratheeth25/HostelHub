import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String venue;
  final int participantLimit;
  final int registeredCount;
  final String organizerId;
  final String organizerName;
  final String? bannerUrl;
  final bool isActive;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.venue,
    required this.participantLimit,
    required this.registeredCount,
    required this.organizerId,
    required this.organizerName,
    this.bannerUrl,
    required this.isActive,
    required this.createdAt,
  });

  bool get isFull => registeredCount >= participantLimit;
  bool get isUpcoming => dateTime.isAfter(DateTime.now());

  factory EventModel.fromMap(Map<String, dynamic> map, String docId) {
    return EventModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      venue: map['venue'] ?? '',
      participantLimit: map['participantLimit'] ?? 0,
      registeredCount: map['registeredCount'] ?? 0,
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'] ?? '',
      bannerUrl: map['bannerUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'venue': venue,
      'participantLimit': participantLimit,
      'registeredCount': registeredCount,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'bannerUrl': bannerUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  EventModel copyWith({
    String? title,
    String? description,
    DateTime? dateTime,
    String? venue,
    int? participantLimit,
    int? registeredCount,
    String? bannerUrl,
    bool? isActive,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      participantLimit: participantLimit ?? this.participantLimit,
      registeredCount: registeredCount ?? this.registeredCount,
      organizerId: organizerId,
      organizerName: organizerName,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
