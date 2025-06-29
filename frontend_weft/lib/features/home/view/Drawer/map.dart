import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(ThaparApp());

class ThaparApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thapar University',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF2A2D5A),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2A2D5A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: HomeScreen(),
      routes: {
        '/map': (context) => ThaparMapScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A2D5A),
              Color(0xFF4A4E8A),
              Color(0xFF3A3E7A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 60),
                    child: Text(
                      'THAPAR',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Color(0xFF3A3E7A).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 25,
                          offset: Offset(0, 15),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Explore Campus',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Navigate through our beautiful campus with the interactive map',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6366F1).withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.pushNamed(context, '/map');
                              },
                              child: Center(
                                child: Text(
                                  'View Campus Map',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ThaparMapScreen extends StatelessWidget {
  const ThaparMapScreen({super.key});

  @override
  Widget build(BuildContext ctx) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A2D5A),
                Color(0xFF4A4E8A),
                Color(0xFF3A3E7A),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Campus Map',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: CampusMapWithDropdown()),
              ],
            ),
          ),
        ),
      );
}

const Map<String, String> nameToSvgId = {
  // Academic Blocks
  'CS Block': 'cs_block',
  'LT': 'lt',
  'Library': 'library',
  'LP101-104': 'lp101_104',
  'LP105-107': 'lp105_107',
  'LP108-111': 'lp108_111',
  'Tan': 'tan',
  'Activity Space': 'activity_space',
  'Venture Lab': 'venture_lab',
  'TSLAS': 'tslas',
  'Mechanical Workshop': 'mechanical_workshop',
  'B Block': 'b_block',
  'BC Corridor': 'bc_corridor',
  'C Block': 'c_block',
  'CD Corridor': 'cd_corridor',
  'D Block': 'd_block',
  'E Block': 'e_block',
  'F Block': 'f_block',
  'G Block': 'g_block',
  'H Block': 'h_block',
  'Hostel A': 'hostel_a',
  'Hostel B': 'hostel_b',
  'Hostel C': 'hostel_c',
  'Hostel D': 'hostel_d',
  'Hostel E': 'hostel_e',
  'Hostel G': 'hostel_g',
  'Hostel H': 'hostel_h',
  'Hostel I': 'hostel_i',
  'Hostel J': 'hostel_j',
  'Hostel K': 'hostel_k',
  'Hostel L': 'hostel_l',
  'Hostel M': 'hostel_m',
  'Hostel N': 'hostel_n',
  'Hostel O': 'hostel_o',
  'Hostel PG': 'hostel_pg',
  'Hostel Q': 'hostel_q',
  'FRA': 'fra',
  'FRB': 'frb',
  'FRC': 'frc',
  'FRD': 'frd',
  'FRE': 'fre',
  'FRF': 'frf',
  'FRG': 'frg',
  'Kravings': 'kravings',
  'Just Food': 'just_food',
  'Aahar': 'aahar',
  'Jaggi': 'jaggi',
  'TSLAS Canteen': 'tslas_canteen',
  'G Block Canteen': 'g_block_canteen',
  'Stationary Shop': 'stationary_shop',
  'Waterbody Cafe': 'waterbody_cafe',
  'Main Audi': 'main_audi',
  'SBOP Lawns': 'sbop_lawns',
  'Fete Area': 'fete_area',
  'Nirvana': 'nirvana',
  'Garden': 'garden',
  'Garden 2': 'garden_2',
  'OAT': 'oat',
  'COS': 'cos',
  'Shiv Mandir': 'shiv_mandir',
  'Gurudwara': 'gurudwara',
  'Waterbody': 'waterbody',
  'Cricket Field': 'cricket_field',
  'Running Track': 'running_track',
  'Tennis Courts': '4_tennis_courts',
  'Badminton Court': 'badminton_court',
  'Basketball Court': 'basketball_court_1',
  'Volleyball Court': 'volleyball_court',
  'Indoor Courts': 'indoor_courts',
  'Swimming Pool': 'swimming_pool',
  'Staff Quarters': 'staff_quarters',
  'Health Centre': 'health_centre',
  'Dean Office': 'dean_office',
  'Directorate': 'directorate',
  'Sports Office': 'sports_office',
  'Post Office': 'post_office',
  'Main Gate': 'main_gate',
  'Gate 2': 'gate_2',
  'Gate 3': 'gate_3',
  'Polytechnic Gate': 'polytechnic_gate',
  'Road': 'road',
};

Future<String> highlightSvg(String assetPath, String? highlightId) async {
  final rawSvg = await rootBundle.loadString(assetPath);
  final doc = XmlDocument.parse(rawSvg);

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

  return doc.toXmlString(pretty: false);
}

class CampusMapWithDropdown extends StatefulWidget {
  const CampusMapWithDropdown({super.key});

  @override
  _CampusMapWithDropdownState createState() => _CampusMapWithDropdownState();
}

class _CampusMapWithDropdownState extends State<CampusMapWithDropdown>
    with TickerProviderStateMixin {
  String? _selectedName;
  String? _svgString;
  final List<String> _buildingNames = nameToSvgId.keys.toList();
  List<String> _filteredBuildings = [];
  bool _isDropdownOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _filteredBuildings = _buildingNames;
    _loadBaseSvg();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadBaseSvg() async {
    final s = await highlightSvg('lib/core/assets/thapar_map.svg', null);
    setState(() => _svgString = s);
  }

  Future<void> _onSelect(String? name) async {
    if (name == null) return;
    
    setState(() {
      _selectedName = name;
      _isDropdownOpen = false;
      _searchController.clear();
      _filteredBuildings = _buildingNames;
    });
    _animationController.reverse();
    
    final id = nameToSvgId[name];
    final s = await highlightSvg('lib/core/assets/thapar_map.svg', id);
    setState(() => _svgString = s);
  }

  void _filterBuildings(String query) {
    setState(() {
      _filteredBuildings = _buildingNames
          .where((building) => building.toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      if (_isDropdownOpen) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _filteredBuildings = _buildingNames;
      }
    });
    if (_isDropdownOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Dropdown Button
              GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFF3A3E7A).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedName ?? 'Select Building',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedName != null 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isDropdownOpen ? 0.5 : 0,
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Dropdown List with Search
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return ClipRect(
                    child: Container(
                      height: _animation.value * 400,
                      child: _animation.value > 0
                          ? Container(
                              margin: EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Color(0xFF3A3E7A).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Search Bar
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextField(
                                        controller: _searchController,
                                        focusNode: _searchFocusNode,
                                        onChanged: _filterBuildings,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Search buildings...',
                                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Building List
                                  Expanded(
                                    child: _filteredBuildings.isEmpty
                                        ? Center(
                                            child: Text(
                                              'No buildings found',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.6),
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            padding: EdgeInsets.only(bottom: 8),
                                            itemCount: _filteredBuildings.length,
                                            itemBuilder: (context, index) {
                                              final building = _filteredBuildings[index];
                                              final isSelected = building == _selectedName;
                                              
                                              return GestureDetector(
                                                onTap: () => _onSelect(building),
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color: isSelected 
                                                        ? Color(0xFF6366F1).withOpacity(0.2)
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: isSelected
                                                        ? Border.all(color: Color(0xFF6366F1).withOpacity(0.5))
                                                        : null,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration: BoxDecoration(
                                                          color: isSelected 
                                                              ? Color(0xFF6366F1)
                                                              : Colors.white.withOpacity(0.4),
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          building,
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: isSelected 
                                                                ? Colors.white
                                                                : Colors.white.withOpacity(0.8),
                                                            fontWeight: isSelected 
                                                                ? FontWeight.w600
                                                                : FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                      if (isSelected)
                                                        Icon(
                                                          Icons.check,
                                                          color: Color(0xFF6366F1),
                                                          size: 18,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                  );
                },
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
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _svgString == null
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    )
                  : RotatedBox(
                      quarterTurns: 1,
                      child: SvgPicture.string(
                        _svgString!,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}