import 'package:flutter/material.dart';

class RecentSearchItem extends StatelessWidget {
  final String searchText;
  final VoidCallback onTap;

  const RecentSearchItem({
    Key? key,
    required this.searchText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey[400],
              size: 20,
            ),
            SizedBox(width: 16),
            Text(
              searchText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}