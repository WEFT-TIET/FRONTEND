import 'package:flutter/material.dart';

class WefCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final Color cardColor;

  const WefCard({required this.title, required this.subtitle, required this.accent, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))],
        border: Border.all(color: accent.withOpacity(0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.star, color: accent, size: 32),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('View'),
              style: TextButton.styleFrom(foregroundColor: accent, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
