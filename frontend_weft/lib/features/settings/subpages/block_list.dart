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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Block List'),
        backgroundColor: AppPallete.transperantColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppPallete.textPrimaryDark),
            onPressed: () {
              ref.read(blockListViewModelProvider.notifier).refreshBlockedUsers(ref);
            },
          ),
        ],
      ),
      backgroundColor: AppPallete.transperantColor,
      body: blockedUsersAsync.when(
        data: (blockedUsers) {
          if (blockedUsers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block_outlined,
                    size: 64,
                    color: AppPallete.textPrimaryDark,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No blocked users',
                    style: TextStyle(
                      color: AppPallete.textPrimaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Users you block will appear here',
                    style: TextStyle(
                      color: AppPallete.whiteColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(blockListViewModelProvider.notifier).refreshBlockedUsers(ref);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                return BlockedUserCard(blockedUser: blockedUsers[index]);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppPallete.textPrimaryDark),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppPallete.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading block list',
                style: const TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  color: AppPallete.whiteColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(blockListViewModelProvider.notifier).refreshBlockedUsers(ref);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}