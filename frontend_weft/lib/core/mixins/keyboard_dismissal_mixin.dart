import 'package:flutter/material.dart';

/// A mixin that provides keyboard dismissal functionality to widgets.
/// 
/// Mix this into any StatefulWidget's State class that contains text fields
/// to automatically add tap-to-dismiss keyboard behavior.
/// 
/// Usage:
/// ```dart
/// class MyPageState extends State<MyPage> with KeyboardDismissalMixin {
///   @override
///   Widget build(BuildContext context) {
///     return addKeyboardDismissal(
///       child: Scaffold(
///         // ... your page content
///       ),
///     );
///   }
/// }
/// ```
mixin KeyboardDismissalMixin<T extends StatefulWidget> on State<T> {
  
  /// Wraps the given child widget with keyboard dismissal functionality.
  /// 
  /// When the user taps outside of text fields, the keyboard will be dismissed.
  Widget addKeyboardDismissal({required Widget child}) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      // Make sure the gesture detector doesn't interfere with scrolling or other gestures
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
  
  /// Alternative method - can be called directly to dismiss keyboard programmatically
  void dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }
}
