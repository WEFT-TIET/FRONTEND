import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class PartyPage extends StatelessWidget {
  const PartyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.gradient1,
            AppPallete.gradient2,
            AppPallete.gradient3,
          ],
        ),
      ),
      child: Scaffold(
         appBar: AppBar(
          backgroundColor: AppPallete.transperantColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: AppPallete.textPrimaryDark),
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
            ),
          ],
          centerTitle: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end, // Push content to right
            children: [Text('Book Tickets')],
          ),
        ),
      ),
    );
  }
}