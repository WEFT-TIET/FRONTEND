import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 80.0,
          left: 20.0,
          right: 20.0,
          bottom: 20.0
          ),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
             TextFormField(
              decoration: InputDecoration(
                labelText: "Branch",
                border: OutlineInputBorder(),
              ),
            ),
             SizedBox(height: 15),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Batch",
                border: OutlineInputBorder(),
              ),
            ),
             SizedBox(height: 15),
             TextFormField(
              decoration: InputDecoration(
                labelText: "Class",
                border: OutlineInputBorder(),
              ),
            ),
             SizedBox(height: 15), 
          ]
        ),
      ),
    );
  }
}