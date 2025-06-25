import 'package:flutter/material.dart';

void showBadgeModal(BuildContext context, Map<String, dynamic> badge) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          CircleAvatar(backgroundColor: badge['color'], child: Icon(badge['icon'], color: Colors.white)),
          const SizedBox(width: 12),
          Text(badge['label']),
        ],
      ),
      content: Text(badge['description']),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ),
  );
}
