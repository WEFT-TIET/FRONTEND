// lib/widgets/location_status_widget.dart
import 'package:flutter/material.dart';
import '../models/location.dart';

class LocationStatusWidget extends StatelessWidget {
  final LocationStatus status;
  final VoidCallback? onRefresh;

  const LocationStatusWidget({
    Key? key,
    required this.status,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusIndicator(),
        if (onRefresh != null)
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF6366F1).withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                Icons.refresh,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    switch (status) {
      case LocationStatus.loading:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Getting location...',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ),
        );

      case LocationStatus.unavailable:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Text(
                'Location unavailable',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
        );

      case LocationStatus.outsideCampus:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_searching, color: Colors.amber, size: 16),
              SizedBox(width: 8),
              Text(
                'Outside campus',
                style: TextStyle(color: Colors.amber, fontSize: 12),
              ),
            ],
          ),
        );

      case LocationStatus.active:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.my_location, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                'Location active',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        );
    }
  }
}