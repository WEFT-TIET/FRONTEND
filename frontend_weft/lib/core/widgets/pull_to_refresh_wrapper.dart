import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

/// A reusable pull-to-refresh wrapper that provides Instagram-like
/// pull-to-refresh functionality for any scrollable content.
class PullToRefreshWrapper extends StatelessWidget {
  /// The child widget that should be wrapped with pull-to-refresh
  final Widget child;
  
  /// The function to call when user pulls to refresh
  final Future<void> Function() onRefresh;
  
  /// Optional color for the refresh indicator
  final Color? refreshIndicatorColor;
  
  /// Optional background color for the refresh indicator
  final Color? refreshIndicatorBackgroundColor;
  
  /// Displacement of the refresh indicator from the top
  final double displacement;
  
  /// Stroke width of the refresh indicator
  final double strokeWidth;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
    this.displacement = 40.0,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: refreshIndicatorColor ?? AppPallete.textPrimaryDark,
      backgroundColor: refreshIndicatorBackgroundColor ?? Colors.white,
      displacement: displacement,
      strokeWidth: strokeWidth,
      // Instagram-style smooth animation
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: child,
    );
  }
}

/// A specialized version for non-scrollable content that ensures
/// pull-to-refresh works even when content doesn't fill the screen
class PullToRefreshAlwaysScrollable extends StatelessWidget {
  /// The child widget that should be wrapped with pull-to-refresh
  final Widget child;
  
  /// The function to call when user pulls to refresh
  final Future<void> Function() onRefresh;
  
  /// Optional color for the refresh indicator
  final Color? refreshIndicatorColor;
  
  /// Optional background color for the refresh indicator
  final Color? refreshIndicatorBackgroundColor;
  
  /// Displacement of the refresh indicator from the top
  final double displacement;
  
  /// Stroke width of the refresh indicator
  final double strokeWidth;

  const PullToRefreshAlwaysScrollable({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
    this.displacement = 40.0,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: refreshIndicatorColor ?? AppPallete.textPrimaryDark,
      backgroundColor: refreshIndicatorBackgroundColor ?? Colors.white,
      displacement: displacement,
      strokeWidth: strokeWidth,
      // Instagram-style smooth animation
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: SingleChildScrollView(
        // Always scrollable physics to enable pull-to-refresh
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                       AppBar().preferredSize.height - 
                       MediaQuery.of(context).padding.top,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A specialized version for pages with CustomScrollView
class PullToRefreshCustomScrollView extends StatelessWidget {
  /// The slivers that should be wrapped with pull-to-refresh
  final List<Widget> slivers;
  
  /// The function to call when user pulls to refresh
  final Future<void> Function() onRefresh;
  
  /// Optional color for the refresh indicator
  final Color? refreshIndicatorColor;
  
  /// Optional background color for the refresh indicator
  final Color? refreshIndicatorBackgroundColor;
  
  /// Displacement of the refresh indicator from the top
  final double displacement;
  
  /// Stroke width of the refresh indicator
  final double strokeWidth;
  
  /// ScrollController for the CustomScrollView
  final ScrollController? controller;

  const PullToRefreshCustomScrollView({
    super.key,
    required this.slivers,
    required this.onRefresh,
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
    this.displacement = 40.0,
    this.strokeWidth = 2.0,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: refreshIndicatorColor ?? AppPallete.textPrimaryDark,
      backgroundColor: refreshIndicatorBackgroundColor ?? Colors.white,
      displacement: displacement,
      strokeWidth: strokeWidth,
      // Instagram-style smooth animation
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: slivers,
      ),
    );
  }
}
