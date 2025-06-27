import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPallete.gradient1, AppPallete.gradient2, AppPallete.gradient3],
        ),
      ),
      child: Scaffold(body: Center(child: Text('Message Page'))),
    );
  }
}
