import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: AppPallete.transperantColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppPallete.transperantColor,
      body: const Center(
        child: Text(
          'Delete Account Page',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
      ),
    );
  }
}