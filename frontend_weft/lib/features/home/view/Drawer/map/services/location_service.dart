// lib/services/location_service.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location.dart';

class LocationService {
  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static bool isWithinCampus(double lat, double lng) {
    const double margin = 0.001; // ~110 meters margin
    final bool within = lat >= (CampusBounds.minLat - margin) &&
                        lat <= (CampusBounds.maxLat + margin) &&
                        lng >= (CampusBounds.minLng - margin) &&
                        lng <= (CampusBounds.maxLng + margin);

    print('Checking campus bounds:');
    print('User location: lat=$lat, lng=$lng');
    print('Bounds: lat [${CampusBounds.minLat - margin}, ${CampusBounds.maxLat + margin}], '
          'lng [${CampusBounds.minLng - margin}, ${CampusBounds.maxLng + margin}]');
    print('Is within campus: $within');

    return within;
  }

  // Convert GPS coordinates to SVG coordinates
  static Offset? gpsToSvgCoordinates(double lat, double lng, Size svgSize) {
    if (!isWithinCampus(lat, lng)) return null;

    // Calculate relative position within campus bounds
    double latRange = CampusBounds.maxLat - CampusBounds.minLat;
    double lngRange = CampusBounds.maxLng - CampusBounds.minLng;

    // Normalize coordinates (0-1 range)
    double relativeLat = (lat - CampusBounds.minLat) / latRange;
    double relativeLng = (lng - CampusBounds.minLng) / lngRange;

    // Since the SVG is rotated 90 degrees, we need to swap coordinates
    // and adjust for the rotation
    double svgX = relativeLng * svgSize.width;
    double svgY = (1.0 - relativeLat) * svgSize.height;

    print('GPS to SVG conversion:');
    print('GPS: lat=$lat, lng=$lng');
    print('Relative: lat=${relativeLat.toStringAsFixed(4)}, lng=${relativeLng.toStringAsFixed(4)}');
    print('SVG: x=${svgX.toStringAsFixed(2)}, y=${svgY.toStringAsFixed(2)}');

    return Offset(svgX, svgY);
  }

  static LocationStatus getLocationStatus({
    bool isLoading = false,
    Position? position,
  }) {
    if (isLoading) return LocationStatus.loading;
    if (position == null) return LocationStatus.unavailable;
    
    bool withinCampus = isWithinCampus(position.latitude, position.longitude);
    return withinCampus ? LocationStatus.active : LocationStatus.outsideCampus;
  }
}