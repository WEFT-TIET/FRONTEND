// map.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(ThaparMapScreen());

class ThaparMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => MaterialApp(
        title: 'Thapar Campus Map',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: CampusMapWithSidebar(),
      );
}

/// Map of buildings to <svg> element IDs
const Map<String, String> nameToSvgId = {
  'FRF': 'frf',
  'FRD': 'frd',
  'FRE': 'fre',
  'FRG': 'frg',
  'FRC': 'frc',
  'FRB': 'frb',
  'FRA': 'fra',
  'Hostel K': 'hostel_k',
  'Hostel L': 'hostel_l',
  'Staff Quarters': 'staff_quarters',
  'Health Centre': 'health_centre',
  'Sports Office': 'sports_office',
  '4 Tennis Courts': '4_tennis_courts',
  'Badminton Court': 'badminton_court',
  'Basketball Court 1': 'basketball_court_1',
  'Basketball Court 2': 'basketball_court_2',
  'Basketball Court 3': 'basketball_court_3',
  // …add more as needed
};

/// Loads the SVG file, finds the element with [highlightId], and
/// applies a gold fill + orange stroke(meeeeeeeee :3) to highlight it.
Future<String> highlightSvg(String assetPath, String? highlightId) async {
  final rawSvg = await rootBundle.loadString(assetPath);
  final doc = XmlDocument.parse(rawSvg);

  if (highlightId != null) {
    // Collect all element nodes…
    final allElements = doc.descendants.whereType<XmlElement>();
    // Find those whose id matches
    final matches =
        allElements.where((node) => node.getAttribute('id') == highlightId);

    if (matches.isNotEmpty) {
      final node = matches.first;
      node.setAttribute('fill', '#FFD700');       // gold
      node.setAttribute('stroke', '#FF8C00');     // dark orange
      node.setAttribute('stroke-width', '4');
    }
  }

  return doc.toXmlString(pretty: false);
}

/// Sidebar
class CampusMapWithSidebar extends StatefulWidget {
  @override
  _CampusMapWithSidebarState createState() => _CampusMapWithSidebarState();
}

class _CampusMapWithSidebarState extends State<CampusMapWithSidebar> {
  String? _selectedName;
  String? _svgString;

  @override
  void initState() {
    super.initState();
    _loadBaseSvg();
  }

  /// Load SVG initially with no highlights
  Future<void> _loadBaseSvg() async {
    final s = await highlightSvg('lib/core/assets/thapar_map.svg', null);
    setState(() => _svgString = s);
  }

  /// Called when user taps an entry
  Future<void> _onSelect(String name) async {
    setState(() => _selectedName = name);
    final id = nameToSvgId[name];
    final s = await highlightSvg('lib/core/assets/thapar_map.svg', id);
    setState(() => _svgString = s);
  }

  @override
  Widget build(BuildContext ctx) {
    final names = nameToSvgId.keys.toList();
    return Scaffold(
      appBar: AppBar(title: Text('Thapar Campus Map')),
      body: Row(
        children: [
          // ── Sidebar ───────────────────────────────────────
          Container(
            width: 200,
            color: Colors.grey.shade200,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 24),
              itemCount: names.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (_, i) {
                final name = names[i];
                final sel = name == _selectedName;
                return ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      color: sel ? Colors.blue : Colors.black87,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () => _onSelect(name),
                );
              },
            ),
          ),

          // ── SVG Map ───────────────────────────────────────
          Expanded(
            child: Center(
              child: _svgString == null
                  ? CircularProgressIndicator()
                  : SvgPicture.string(
                      _svgString!,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
