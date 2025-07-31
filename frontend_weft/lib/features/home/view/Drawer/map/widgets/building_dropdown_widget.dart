// lib/widgets/building_dropdown_widget.dart
import 'package:flutter/material.dart';
import '../models/building.dart';

class BuildingDropdownWidget extends StatefulWidget {
  final String? selectedBuilding;
  final Function(String?) onBuildingSelected;

  const BuildingDropdownWidget({
    Key? key,
    this.selectedBuilding,
    required this.onBuildingSelected,
  }) : super(key: key);

  @override
  _BuildingDropdownWidgetState createState() => _BuildingDropdownWidgetState();
}

class _BuildingDropdownWidgetState extends State<BuildingDropdownWidget>
    with TickerProviderStateMixin {
  final List<String> _buildingNames = BuildingData.getAllBuildingNames();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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

  void _onSelect(String? name) {
    if (name == null) return;
    
    setState(() {
      _isDropdownOpen = false;
      _searchController.clear();
      _filteredBuildings = _buildingNames;
    });
    _animationController.reverse();
    
    widget.onBuildingSelected(name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    widget.selectedBuilding ?? 'Select Building',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.selectedBuilding != null 
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
                                        final isSelected = building == widget.selectedBuilding;
                                        
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
    );
  }
}