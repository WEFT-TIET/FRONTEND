import 'package:flutter/material.dart';

void showShareModal(BuildContext context, Color accent) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.5))),
            const SizedBox(height: 16),
            Text('Share Profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [CircleAvatar(backgroundColor: accent.withOpacity(0.1), child: Icon(Icons.qr_code, color: accent, size: 32)), const SizedBox(height: 8), const Text('QR Code')]),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile link copied!')));
                  },
                  child: Column(children: [CircleAvatar(backgroundColor: accent.withOpacity(0.1), child: Icon(Icons.link, color: accent, size: 32)), const SizedBox(height: 8), const Text('Copy Link')]),
                ),
                Column(children: [CircleAvatar(backgroundColor: accent.withOpacity(0.1), child: Icon(Icons.send, color: accent, size: 32)), const SizedBox(height: 8), const Text('Direct')]),
              ],
            ),
          ],
        ),
      );
    },
  );
}
