import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/http_client.dart';
import 'package:frontend_weft/features/settings/model/activity_model.dart';
import 'package:frontend_weft/features/settings/repository/activity_repository.dart';
import 'package:frontend_weft/features/post/model/post_model.dart';

// Provider for ActivityRepository
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return ActivityRepository(httpClient);
});

// State class for activity data
class ActivityState {
  final bool isLoading;
  final String? error;
  final List<ActivityRecord> allActivities;
  final Map<int, Post> postsCache; // Cache for enriched post data

  ActivityState({
    required this.isLoading,
    required this.error,
    required this.allActivities,
    required this.postsCache,
  });

  // Helper getters to filter activities by type
  List<ActivityRecord> get likedPosts => allActivities
      .where((activity) => activity.isLike)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Latest first

  List<ActivityRecord> get commentedPosts => allActivities
      .where((activity) => activity.isComment)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Latest first

  ActivityState copyWith({
    bool? isLoading,
    String? error,
    List<ActivityRecord>? allActivities,
    Map<int, Post>? postsCache,
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allActivities: allActivities ?? this.allActivities,
      postsCache: postsCache ?? this.postsCache,
    );
  }
}

// ActivityViewModel (StateNotifier)
class ActivityViewModel extends StateNotifier<ActivityState> {
  final ActivityRepository _repository;

  ActivityViewModel(this._repository)
      : super(ActivityState(
          isLoading: false,
          error: null,
          allActivities: [],
          postsCache: {},
        ));

  // Fetch user activity from backend
  Future<void> fetchActivity() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final activities = await _repository.fetchUserActivity();
      
      state = state.copyWith(
        isLoading: false,
        allActivities: activities,
        error: null,
      );
      
      // Background task: enrich posts with full data
      _enrichPostsInBackground(activities);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Refresh activity data
  Future<void> refresh() async {
    await fetchActivity();
  }

  // Background enrichment of posts (non-blocking)
  Future<void> _enrichPostsInBackground(List<ActivityRecord> activities) async {
    final postsToFetch = activities
        .where((activity) => activity.postId != null)
        .map((activity) => activity.postId!)
        .toSet(); // Remove duplicates
    
    final Map<int, Post> newPostsCache = Map.from(state.postsCache);
    
    // Fetch posts in parallel (limit concurrent requests)
    final futures = postsToFetch.map((postId) async {
      if (!newPostsCache.containsKey(postId)) {
        try {
          final post = await _repository.fetchPostById(postId);
          if (post != null) {
            newPostsCache[postId] = post;
          }
        } catch (e) {
          // Silently ignore individual post fetch errors
        }
      }
    });
    
    await Future.wait(futures);
    
    // Update state with enriched posts
    if (newPostsCache.length > state.postsCache.length) {
      state = state.copyWith(postsCache: newPostsCache);
    }
  }

  // Get enriched post data for an activity
  Post? getPostForActivity(ActivityRecord activity) {
    if (activity.postId == null) return null;
    return state.postsCache[activity.postId];
  }

  // Update post like status (for unlike functionality)
  void updatePostLikeStatus(String postId, bool liked) {
    if (!liked) {
      // Remove the like activity from the list
      final updatedActivities = state.allActivities
          .where((activity) => 
              !(activity.postId?.toString() == postId && activity.isLike))
          .toList();
      
      state = state.copyWith(allActivities: updatedActivities);
    }
  }
}

// Provider for ActivityViewModel
final activityProvider = StateNotifierProvider<ActivityViewModel, ActivityState>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return ActivityViewModel(repository);
});
