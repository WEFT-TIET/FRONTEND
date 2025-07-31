// lib/models/location.dart
import 'package:flutter/material.dart';

class CampusBounds {
  // Updated coordinates for Thapar University campus
  static const double minLat = 30.3513122;  // Bottom
  static const double maxLat = 30.3585832;  // Top
  static const double minLng = 76.3585424;  // Left
  static const double maxLng = 76.3740141;  // Right
  
  // For debugging - print actual campus bounds
  static void printBounds() {
    print('Campus Bounds:');
    print('Latitude: ${minLat} to ${maxLat}');
    print('Longitude: ${minLng} to ${maxLng}');
  }
}

enum LocationStatus {
  loading,
  unavailable,
  outsideCampus,
  active
}

class LocationData {
  final double latitude;
  final double longitude;
  final LocationStatus status;
  final Offset? svgCoordinates;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.status,
    this.svgCoordinates,
  });

  LocationData copyWith({
    double? latitude,
    double? longitude,
    LocationStatus? status,
    Offset? svgCoordinates,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      svgCoordinates: svgCoordinates ?? this.svgCoordinates,
    );
  }
}