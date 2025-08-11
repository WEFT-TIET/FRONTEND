import 'package:flutter/material.dart';

/// A widget that dismisses the keyboard when the user taps outside of text fields.
/// 
/// Wrap your pages/widgets with this to enable tap-to-dismiss keyboard functionality.
/// This improves user experience by automatically hiding the keyboard when users
/// tap on empty areas of the screen.
class KeyboardDismisser extends StatelessWidget {
  final Widget child;

  const KeyboardDismisser({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      // Make sure the gesture detector doesn't interfere with scrolling
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

/// Extension method to easily wrap any widget with keyboard dismissal
extension KeyboardDismissible on Widget {
  Widget dismissKeyboard() {
    return KeyboardDismisser(child: this);
  }
}
