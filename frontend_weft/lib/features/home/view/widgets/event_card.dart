import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class EventCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String date;
  final String location;
  final Color backgroundColor;

  const EventCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.location,
    required this.backgroundColor,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isInterested = false;

  void _toggleInterest() {
    setState(() {
      _isInterested = !_isInterested;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPallete.glassWhite05,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: theme.textTheme.bodyMedium
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: AppPallete.whiteColor),
              const SizedBox(width: 4),
              Text(widget.date, style: const TextStyle(color: AppPallete.whiteColor)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_pin, size: 16, color: AppPallete.red),
              const SizedBox(width: 4),
              Text(widget.location,
                  style: const TextStyle(color: AppPallete.whiteColor)),
            ],
          ),
        ],
      ),
    );
  }
}
