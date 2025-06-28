import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart';

class ThaparMapScreen extends StatefulWidget {
  @override
  _ThaparMapScreenState createState() => _ThaparMapScreenState();
}

class _ThaparMapScreenState extends State<ThaparMapScreen> {
  LocationData? _userLocation;
  final Location location = Location();

  // GPS bounds (mock values bbg, calibrate with real values)
  final double lat1 = 30.352; // NW corner
  final double lon1 = 76.362;
  final double lat2 = 30.345; // SE corner
  final double lon2 = 76.370;

  // SVG size in pixels (match SVG image viewBox or size)
  final double mapWidth = 800;
  final double mapHeight = 600;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    final loc = await location.getLocation();
    setState(() => _userLocation = loc);
  }

  Offset? _getUserOffset() {
    if (_userLocation == null) return null;

    final lat = _userLocation!.latitude!;
    final lon = _userLocation!.longitude!;

    // Linear interpolation to convert GPS to SVG pixel coords(meow meow :3)
    final xPercent = (lon - lon1) / (lon2 - lon1);
    final yPercent = 1 - (lat - lat1) / (lat2 - lat1); // invert Y

    final x = mapWidth * xPercent;
    final y = mapHeight * yPercent;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final userOffset = _getUserOffset();

    return Scaffold(
      appBar: AppBar(title: Text('Thapar Campus Map')),
      body: Center(
        child: SizedBox(
          width: mapWidth,
          height: mapHeight,
          child: Stack(
            children: [
              SvgPicture.asset(
                'lib/core/assets/thapar_map.svg',
                width: mapWidth,
                height: mapHeight,
                fit: BoxFit.contain,
              ),
              if (userOffset != null)
                Positioned(
                  left: userOffset.dx - 6, // center the circle
                  top: userOffset.dy - 6,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}