// lib/services/svg_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

class SvgService {
  static Future<String> highlightSvg(
    String assetPath, 
    String? highlightId, {
    Offset? userLocation,
  }) async {
    final rawSvg = await rootBundle.loadString(assetPath);
    final doc = XmlDocument.parse(rawSvg);

    // Highlight selected building
    if (highlightId != null) {
      final allElements = doc.descendants.whereType<XmlElement>();
      final matches = allElements.where((node) => node.getAttribute('id') == highlightId);

      if (matches.isNotEmpty) {
        final node = matches.first;
        node.setAttribute('fill', '#FFD700');
        node.setAttribute('stroke', '#FF8C00');
        node.setAttribute('stroke-width', '4');
      }
    }

    // Add user location marker if provided
    if (userLocation != null) {
      _addUserLocationMarker(doc, userLocation);
    }

    return doc.toXmlString(pretty: false);
  }

  static void _addUserLocationMarker(XmlDocument doc, Offset userLocation) {
    final svgElement = doc.rootElement;
    
    // Create a group for the user location marker
    final markerGroup = XmlElement(XmlName('g'));
    markerGroup.setAttribute('id', 'user_location_marker');
    
    // Outer circle (pulsing effect)
    final outerCircle = XmlElement(XmlName('circle'));
    outerCircle.setAttribute('cx', userLocation.dx.toString());
    outerCircle.setAttribute('cy', userLocation.dy.toString());
    outerCircle.setAttribute('r', '25');
    outerCircle.setAttribute('fill', '#FF0000');
    outerCircle.setAttribute('fill-opacity', '0.2');
    outerCircle.setAttribute('stroke', '#FF0000');
    outerCircle.setAttribute('stroke-width', '3');
    
    // Middle circle
    final middleCircle = XmlElement(XmlName('circle'));
    middleCircle.setAttribute('cx', userLocation.dx.toString());
    middleCircle.setAttribute('cy', userLocation.dy.toString());
    middleCircle.setAttribute('r', '15');
    middleCircle.setAttribute('fill', '#FF0000');
    middleCircle.setAttribute('fill-opacity', '0.4');
    middleCircle.setAttribute('stroke', '#FF0000');
    middleCircle.setAttribute('stroke-width', '2');
    
    // Inner circle (solid)
    final innerCircle = XmlElement(XmlName('circle'));
    innerCircle.setAttribute('cx', userLocation.dx.toString());
    innerCircle.setAttribute('cy', userLocation.dy.toString());
    innerCircle.setAttribute('r', '8');
    innerCircle.setAttribute('fill', '#FF0000');
    innerCircle.setAttribute('stroke', '#FFFFFF');
    innerCircle.setAttribute('stroke-width', '2');
    
    // Center dot
    final centerDot = XmlElement(XmlName('circle'));
    centerDot.setAttribute('cx', userLocation.dx.toString());
    centerDot.setAttribute('cy', userLocation.dy.toString());
    centerDot.setAttribute('r', '3');
    centerDot.setAttribute('fill', '#FFFFFF');
    
    markerGroup.children.add(outerCircle);
    markerGroup.children.add(middleCircle);
    markerGroup.children.add(innerCircle);
    markerGroup.children.add(centerDot);
    
    svgElement.children.add(markerGroup);
  }
}