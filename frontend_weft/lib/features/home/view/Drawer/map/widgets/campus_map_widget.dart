// lib/widgets/campus_map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../models/building.dart';
import '../models/location.dart';
import '../services/location_service.dart';
import '../services/svg_service.dart';
import 'location_status_widget.dart';
import 'building_dropdown_widget.dart';

class CampusMapWidget extends StatefulWidget {
  const CampusMapWidget({super.key});

  @override
  _CampusMapWidgetState createState() => _CampusMapWidgetState();
}

class _CampusMapWidgetState extends State<CampusMapWidget> {
  String? _selectedBuilding;
  String? _svgString;
  
  // Location related variables
  Position? _currentPosition;
  Offset? _userLocationOnMap;
  LocationStatus _locationStatus = LocationStatus.loading;
  bool _isLoadingLocation = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadBaseSvg();
    _initializeLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoadingLocation = true);
    
    // Print campus bounds for debugging
    CampusBounds.printBounds();
    
    bool hasPermission = await LocationService.checkLocationPermission();
    if (hasPermission) {
      await _getCurrentLocation();
      _startLocationUpdates();
    }
    
    setState(() => _isLoadingLocation = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _locationStatus = LocationService.getLocationStatus(position: position);
        });
        await _updateMapWithLocation();
      } else {
        setState(() {
          _locationStatus = LocationStatus.unavailable;
        });
      }
    } catch (e) {
      print('Error getting current location: $e');
      setState(() {
        _locationStatus = LocationStatus.unavailable;
      });
    }
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _getCurrentLocation();
    });
  }

  Future<void> _updateMapWithLocation() async {
    if (_currentPosition != null && _locationStatus == LocationStatus.active) {
      // Use actual SVG dimensions from the file
      Size svgSize = Size(1408, 746); // Actual SVG dimensions
      
      _userLocationOnMap = LocationService.gpsToSvgCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        svgSize,
      );
    } else {
      _userLocationOnMap = null;
    }
    
    await _loadBaseSvg();
  }

  Future<void> _loadBaseSvg() async {
    final id = _selectedBuilding != null ? BuildingData.getSvgId(_selectedBuilding!) : null;
    final s = await SvgService.highlightSvg(
      'lib/core/assets/thapar_map.svg', 
      id,
      userLocation: _userLocationOnMap,
    );
    setState(() => _svgString = s);
  }

  Future<void> _onBuildingSelected(String? buildingName) async {
    setState(() {
      _selectedBuilding = buildingName;
    });
    
    await _loadBaseSvg();
  }

  Widget _buildLocationDebugInfo() {
    if (_locationStatus != LocationStatus.active || _userLocationOnMap == null || _currentPosition == null) {
      return SizedBox.shrink();
    }

    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GPS: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
            Text(
              'SVG: ${_userLocationOnMap!.dx.toStringAsFixed(1)}, ${_userLocationOnMap!.dy.toStringAsFixed(1)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Location Status Indicator
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LocationStatusWidget(
                  status: _isLoadingLocation ? LocationStatus.loading : _locationStatus,
                  onRefresh: _getCurrentLocation,
                ),
              ),
              
              // Building Dropdown
              BuildingDropdownWidget(
                selectedBuilding: _selectedBuilding,
                onBuildingSelected: _onBuildingSelected,
              ),
            ],
          ),
        ),
        
        // Map Container
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _svgString == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading campus map...',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          boundaryMargin: EdgeInsets.all(80),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: SvgPicture.string(
                              _svgString!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        _buildLocationDebugInfo(),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}