import 'package:flutter/material.dart';

class WefCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final Color cardColor;

  const WefCard({super.key, required this.title, required this.subtitle, required this.accent, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: accent.withAlpha((0.15 * 255).toInt()), blurRadius: 12, offset: const Offset(0, 6))],
        border: Border.all(color: accent.withAlpha((0.2 * 255).toInt()), width: 1.5),
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
              style: TextButton.styleFrom(foregroundColor: accent, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}
