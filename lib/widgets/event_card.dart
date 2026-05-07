import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/event/${event.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.bannerUrl != null)
              CachedNetworkImage(
                imageUrl: event.bannerUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(height: 140, color: cs.surfaceVariant),
                errorWidget: (_, __, ___) =>
                    Container(height: 140, color: cs.surfaceVariant,
                        child: Icon(Icons.broken_image, color: cs.outline)),
              )
            else
              Container(
                height: 80,
                color: cs.primaryContainer,
                width: double.infinity,
                child: Icon(Icons.event, size: 36, color: cs.primary),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (event.isFull)
                        Chip(
                          label: const Text('Full'),
                          backgroundColor: cs.errorContainer,
                          labelStyle: TextStyle(
                              color: cs.onErrorContainer, fontSize: 12),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, y • h:mm a').format(event.dateTime),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: cs.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.people, size: 14, color: cs.outline),
                      const SizedBox(width: 4),
                      Text(
                        '${event.registeredCount}/${event.participantLimit}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
