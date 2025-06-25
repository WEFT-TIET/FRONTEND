import 'package:flutter/material.dart';

class PartyPage extends StatelessWidget {
  const PartyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Push content to right
          children: [Text('Book Tickets')],
        ),
      ),
    );
  }
}