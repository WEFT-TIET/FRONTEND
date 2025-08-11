import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/settings/viewmodels/block_list_viewmodel.dart';
import 'package:frontend_weft/features/settings/widgets/blocked_user_card.dart';

class BlockListPage extends ConsumerWidget {
  const BlockListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsersAsync = ref.watch(blockedUsersProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.gradient1,
            AppPallete.gradient2,
            AppPallete.gradient3,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppPallete.glassWhite10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(
            'Block List',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPallete.glassWhite10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: AppPallete.textPrimaryDark, size: 20),
                onPressed: () {
                  ref.read(blockListViewModelProvider.notifier).refreshBlockedUsers(ref);
                },
              ),
            ),
          ],
        ),
        body: blockedUsersAsync.when(
          data: (blockedUsers) {
            if (blockedUsers.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(blockListViewModelProvider.notifier).refreshBlockedUsers(ref);
              },
              color: AppPallete.profileAccent,
              backgroundColor: AppPallete.glassWhite20,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: blockedUsers.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: BlockedUserCard(blockedUser: blockedUsers[index]),
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppPallete.textPrimaryDark),
            ),
          ),
          error: (error, stack) => _buildErrorState(error.toString(), ref),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppPallete.glassWhite10,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppPallete.glassWhite20, width: 0.5),
              ),
              child: Icon(
                Icons.block_outlined,
                size: 48,
                color: AppPallete.textPrimaryDark.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No blocked users',
              style: TextStyle(
                color: AppPallete.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Users you block will appear here.\nYou can unblock them anytime.',
              style: TextStyle(
                color: AppPallete.whiteColor,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppPallete.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPallete.red.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppPallete.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load block list',
              style: TextStyle(
                color: AppPallete.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: AppPallete.whiteColor,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppPallete.gradient2, AppPallete.profileAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(blockListViewModelProvider.notifier).refreshBlockedUsers(ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}