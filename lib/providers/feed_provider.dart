import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../services/supabase_service.dart';

class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;
  final bool hasReachedEnd;
  final int page;

  const FeedState({
    required this.posts,
    required this.isLoading,
    required this.isFetchingMore,
    this.error,
    required this.hasReachedEnd,
    required this.page,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    bool clearError = false,
    bool? hasReachedEnd,
    int? page,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: clearError ? null : (error ?? this.error),
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      page: page ?? this.page,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  static const int _pageSize = 10;
  // Temporary unique user id for tracking liked states
  final String _currentUserId = '11111111-1111-1111-1111-111111111111';

  final Map<String, Timer> _debounceTimers = {};
  final Set<String> _pendingToggles = {};

  FeedNotifier()
      : super(const FeedState(
          posts: [],
          isLoading: false,
          isFetchingMore: false,
          hasReachedEnd: false,
          page: 0,
        )) {
    loadInitial();
  }

  @override
  void dispose() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    super.dispose();
  }

  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final postsData = await SupabaseService.fetchPosts(0, _pageSize);
      final likedPostIds = await SupabaseService.fetchLikedPosts(_currentUserId);
      final likedSet = likedPostIds.toSet();

      final posts = postsData.map((json) {
        final isLiked = likedSet.contains(json['id']);
        return Post.fromJson(json, isLiked: isLiked);
      }).toList();

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasReachedEnd: posts.length < _pageSize,
        page: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isFetchingMore || state.hasReachedEnd) return;

    state = state.copyWith(isFetchingMore: true, clearError: true);

    try {
      final postsData = await SupabaseService.fetchPosts(state.page, _pageSize);
      final likedPostIds = await SupabaseService.fetchLikedPosts(_currentUserId);
      final likedSet = likedPostIds.toSet();

      final newPosts = postsData.map((json) {
        final isLiked = likedSet.contains(json['id']);
        return Post.fromJson(json, isLiked: isLiked);
      }).toList();

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isFetchingMore: false,
        hasReachedEnd: newPosts.length < _pageSize,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isFetchingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final postsData = await SupabaseService.fetchPosts(0, _pageSize);
      final likedPostIds = await SupabaseService.fetchLikedPosts(_currentUserId);
      final likedSet = likedPostIds.toSet();

      final posts = postsData.map((json) {
        final isLiked = likedSet.contains(json['id']);
        return Post.fromJson(json, isLiked: isLiked);
      }).toList();

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasReachedEnd: posts.length < _pageSize,
        page: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleLike(String postId) async {
    // 1. Optimistic UI update (Instant feedback)
    final postIndex = state.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final oldPost = state.posts[postIndex];
    final isLiked = oldPost.isLiked;
    final newLikeCount = isLiked ? oldPost.likeCount - 1 : oldPost.likeCount + 1;

    final newPost = oldPost.copyWith(
      isLiked: !isLiked,
      likeCount: newLikeCount,
    );

    final newPosts = List<Post>.from(state.posts);
    newPosts[postIndex] = newPost;

    state = state.copyWith(posts: newPosts, clearError: true);

    // 2. Debounce and Spam Protection
    // Toggle the net pending state
    if (_pendingToggles.contains(postId)) {
      _pendingToggles.remove(postId); // Net zero change (even number of clicks)
    } else {
      _pendingToggles.add(postId); // Net change (odd number of clicks)
    }

    // Cancel existing debounce timer for this specific post
    _debounceTimers[postId]?.cancel();

    // Start a new 500ms debounce timer
    _debounceTimers[postId] = Timer(const Duration(milliseconds: 500), () async {
      _debounceTimers.remove(postId);
      
      // Only execute RPC if there was a net change after the user stopped tapping
      if (_pendingToggles.contains(postId)) {
        _pendingToggles.remove(postId);
        
        try {
          await SupabaseService.toggleLike(postId, _currentUserId);
        } catch (e) {
          if (!mounted) return;
          // Revert on failure
          final revertPosts = List<Post>.from(state.posts);
          final currentIndex = revertPosts.indexWhere((p) => p.id == postId);
          if (currentIndex != -1) {
            final revertPost = revertPosts[currentIndex];
            final revertedIsLiked = !revertPost.isLiked;
            final revertedLikeCount = revertedIsLiked ? revertPost.likeCount + 1 : revertPost.likeCount - 1;
            
            revertPosts[currentIndex] = revertPost.copyWith(
              isLiked: revertedIsLiked,
              likeCount: revertedLikeCount,
            );
            state = state.copyWith(posts: revertPosts, error: 'Offline: Failed to sync like, changes reverted.');
          }
        }
      }
    });
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier();
});
