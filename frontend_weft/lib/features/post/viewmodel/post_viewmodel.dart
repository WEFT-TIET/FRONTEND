import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/post/data/post_service.dart';
import 'package:frontend_weft/features/post/model/post_model.dart';

// State class for managing post operations
class PostState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMorePosts;

  const PostState({
    this.posts = const [], 
    this.isLoading = false, 
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePosts = true,
  });

  PostState copyWith({
    List<Post>? posts, 
    bool? isLoading, 
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMorePosts,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
    );
  }
}

// PostViewModel that manages post state
class PostViewModel extends StateNotifier<PostState> {
  final PostService _postService;

  PostViewModel(this._postService) : super(const PostState());

  // Fetch all posts (first page)
  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, error: null, currentPage: 1);

    try {
      final posts = await _postService.getPostsByPage(1);
      state = state.copyWith(
        posts: posts, 
        isLoading: false, 
        hasMorePosts: posts.length == 10, // Assuming 10 posts per page
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Load more posts (pagination)
  Future<void> loadMorePosts() async {
    if (state.isLoadingMore || !state.hasMorePosts) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final newPosts = await _postService.getPostsByPage(nextPage);
      
      if (newPosts.isNotEmpty) {
        final updatedPosts = [...state.posts, ...newPosts];
        state = state.copyWith(
          posts: updatedPosts,
          currentPage: nextPage,
          isLoadingMore: false,
          hasMorePosts: newPosts.length == 10, // Assuming 10 posts per page
        );
      } else {
        state = state.copyWith(
          isLoadingMore: false,
          hasMorePosts: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  // Create a new post
  Future<bool> createPost({
    required String title,
    required String content,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _postService.createPost(
        title: title,
        content: content,
      );

      if (success) {
        // Refresh posts after creation
        await fetchPosts();
      }

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Like a post
  Future<bool> likePost(String postId) async {
    try {
      final response = await _postService.likePost(postId);

      if (response != null) {
        final status = response['status'] as String?;
        final isLiked = status == 'Liked';
        
        // Update the local state based on the backend response
        final updatedPosts = state.posts.map((post) {
          if (post.id == postId) {
            return post.copyWith(liked: isLiked);
          }
          return post;
        }).toList();

        state = state.copyWith(posts: updatedPosts);
        
        // Refresh posts to get accurate counts from server
        // This ensures we have the correct like counts
        Future.microtask(() => fetchPosts());
        
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Delete a post
  Future<bool> deletePost(String postId) async {
    try {
      final success = await _postService.deletePost(postId);

      if (success) {
        // Remove the post from local state
        final updatedPosts = state.posts
            .where((post) => post.id != postId)
            .toList();
        state = state.copyWith(posts: updatedPosts);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    await fetchPosts();
  }

  // Block a user
  Future<bool> blockUser(String userId) async {
    try {
      final success = await _postService.blockUser(userId);
      
      if (success) {
        // Remove posts from blocked user from the feed
        final updatedPosts = state.posts
            .where((post) => post.userId != userId)
            .toList();
        state = state.copyWith(posts: updatedPosts);
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Unblock a user
  Future<bool> unblockUser(String userId) async {
    try {
      final success = await _postService.unblockUser(userId);
      
      if (success) {
        // Refresh posts to show posts from unblocked user
        await fetchPosts();
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

// Providers
final postViewModelProvider = StateNotifierProvider<PostViewModel, PostState>((
  ref,
) {
  final postService = ref.watch(postServiceProvider);
  final viewModel = PostViewModel(postService);
  // Initialize posts automatically when the provider is created
  Future.microtask(() => viewModel.fetchPosts());
  return viewModel;
});

// Provider for posts list - directly uses the state from postViewModelProvider
final postsProvider = Provider<AsyncValue<List<Post>>>((ref) {
  final postState = ref.watch(postViewModelProvider);

  if (postState.isLoading && postState.posts.isEmpty) {
    return const AsyncValue.loading();
  } else if (postState.error != null) {
    return AsyncValue.error(postState.error!, StackTrace.current);
  } else {
    return AsyncValue.data(postState.posts);
  }
});

// Provider for getting a specific post by ID
final postByIdProvider = FutureProvider.family<Post?, String>((
  ref,
  postId,
) async {
  final postService = ref.watch(postServiceProvider);
  return await postService.getPostById(postId);
});
