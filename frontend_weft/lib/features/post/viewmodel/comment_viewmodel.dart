import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/post/data/comment_service.dart';
import 'package:frontend_weft/features/post/model/comment_model.dart';

// State class for managing comment operations
class CommentState {
  final List<Comment> comments;
  final bool isLoading;
  final bool isCreatingComment;
  final String? error;
  final String postId;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.isCreatingComment = false,
    this.error,
    required this.postId,
  });

  CommentState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isCreatingComment,
    String? error,
    String? postId,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isCreatingComment: isCreatingComment ?? this.isCreatingComment,
      error: error,
      postId: postId ?? this.postId,
    );
  }
}

// CommentViewModel that manages comment state
class CommentViewModel extends StateNotifier<CommentState> {
  final CommentService _commentService;

  CommentViewModel(this._commentService, String postId) 
      : super(CommentState(postId: postId));

  // Fetch comments for a specific post
  Future<void> fetchComments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final comments = await _commentService.getComments(state.postId);
      
      // Sort comments by creation date (newest first)
      comments.sort((a, b) {
        try {
          final aDate = DateTime.parse(a.createdAt);
          final bDate = DateTime.parse(b.createdAt);
          return bDate.compareTo(aDate); // Newest first
        } catch (e) {
          return 0; // If parsing fails, maintain original order
        }
      });
      
      state = state.copyWith(
        comments: comments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Create a new comment
  Future<bool> createComment(String content) async {
    if (content.trim().isEmpty) return false;

    state = state.copyWith(isCreatingComment: true, error: null);

    try {
      final newComment = await _commentService.createComment(
        postId: state.postId,
        content: content.trim(),
      );

      if (newComment != null) {
        // Add the new comment to the beginning of the list
        final updatedComments = [newComment, ...state.comments];
        state = state.copyWith(
          comments: updatedComments,
          isCreatingComment: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isCreatingComment: false,
          error: 'Failed to create comment',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isCreatingComment: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Refresh comments
  Future<void> refreshComments() async {
    await fetchComments();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider factory for comment viewmodel
final commentViewModelProvider = StateNotifierProvider.family<CommentViewModel, CommentState, String>(
  (ref, postId) {
    final commentService = ref.watch(commentServiceProvider);
    final viewModel = CommentViewModel(commentService, postId);
    // Initialize comments automatically when the provider is created
    Future.microtask(() => viewModel.fetchComments());
    return viewModel;
  },
); 