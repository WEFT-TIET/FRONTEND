import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/settings/services/block_list_service.dart';
import 'package:frontend_weft/features/settings/models/blocked_user_model.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';

// State class for managing block list operations
class BlockListState {
  final List<BlockedUser> blockedUsers;
  final bool isLoading;
  final String? error;

  const BlockListState({
    this.blockedUsers = const [],
    this.isLoading = false,
    this.error,
  });

  BlockListState copyWith({
    List<BlockedUser>? blockedUsers,
    bool? isLoading,
    String? error,
  }) {
    return BlockListState(
      blockedUsers: blockedUsers ?? this.blockedUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// BlockListViewModel that manages block list state
class BlockListViewModel extends StateNotifier<BlockListState> {
  final BlockListService _blockListService;

  BlockListViewModel(this._blockListService) : super(const BlockListState());

  // Fetch blocked users
  Future<void> fetchBlockedUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final blockedUsers = await _blockListService.getBlockedUsers();
      state = state.copyWith(blockedUsers: blockedUsers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Unblock a user
  Future<bool> unblockUser(String userId, WidgetRef? ref) async {
    try {
      final success = await _blockListService.unblockUser(userId);
      
      if (success) {
        // Remove the user from the blocked list
        final updatedBlockedUsers = state.blockedUsers
            .where((user) => user.id != userId)
            .toList();
        state = state.copyWith(blockedUsers: updatedBlockedUsers);
        
        // Refresh posts to show posts from unblocked user
        if (ref != null) {
          ref.read(postViewModelProvider.notifier).refreshPosts();
        }
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Refresh blocked users
  Future<void> refreshBlockedUsers(WidgetRef? ref) async {
    await fetchBlockedUsers();
    
    // Also refresh posts to ensure they are filtered correctly
    if (ref != null) {
      ref.read(postViewModelProvider.notifier).refreshPosts();
    }
  }
}

// Providers
final blockListViewModelProvider = StateNotifierProvider<BlockListViewModel, BlockListState>((
  ref,
) {
  final blockListService = ref.watch(blockListServiceProvider);
  final viewModel = BlockListViewModel(blockListService);
  // Initialize blocked users automatically when the provider is created
  Future.microtask(() => viewModel.fetchBlockedUsers());
  return viewModel;
});

// Provider for blocked users list
final blockedUsersProvider = Provider<AsyncValue<List<BlockedUser>>>((ref) {
  final blockListState = ref.watch(blockListViewModelProvider);

  if (blockListState.isLoading && blockListState.blockedUsers.isEmpty) {
    return const AsyncValue.loading();
  } else if (blockListState.error != null) {
    return AsyncValue.error(blockListState.error!, StackTrace.current);
  } else {
    return AsyncValue.data(blockListState.blockedUsers);
  }
}); 