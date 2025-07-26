import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/settings/models/blocked_user_model.dart';
import 'package:frontend_weft/features/settings/viewmodels/block_list_viewmodel.dart';

class BlockedUserCard extends ConsumerWidget {
  final BlockedUser blockedUser;

  const BlockedUserCard({
    super.key,
    required this.blockedUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.glassWhite05,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
      ),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppPallete.gradient2,
            child: Text(
              blockedUser.name.isNotEmpty ? blockedUser.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: AppPallete.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blockedUser.name,
                  style: const TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${blockedUser.branch} • ${blockedUser.year}',
                  style: const TextStyle(
                    color: AppPallete.whiteColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Unblock Button
          TextButton(
            onPressed: () => _showUnblockDialog(context, ref),
            style: TextButton.styleFrom(
              backgroundColor: AppPallete.gradient2,
              foregroundColor: AppPallete.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Unblock',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppPallete.glassWhite20,
          title: const Text(
            'Unblock User',
            style: TextStyle(color: AppPallete.textPrimaryDark),
          ),
          content: Text(
            'Are you sure you want to unblock ${blockedUser.name}? You will be able to see their posts again.',
            style: const TextStyle(color: AppPallete.textPrimaryDark),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppPallete.textPrimaryDark),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _unblockUser(context, ref);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppPallete.gradient2,
              ),
              child: const Text('Unblock'),
            ),
          ],
        );
      },
    );
  }

  void _unblockUser(BuildContext context, WidgetRef ref) {
    ref.read(blockListViewModelProvider.notifier).unblockUser(blockedUser.id, ref).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${blockedUser.name} has been unblocked'),
            backgroundColor: AppPallete.gradient2,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unblock user'),
            backgroundColor: AppPallete.red,
          ),
        );
      }
    });
  }
} 