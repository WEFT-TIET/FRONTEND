// lib/models/building.dart
class Building {
  final String name;
  final String svgId;

  const Building({
    required this.name,
    required this.svgId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Building && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class BuildingData {
  static const Map<String, String> _nameToSvgId = {
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

  static List<Building> getAllBuildings() {
    return _nameToSvgId.entries
        .map((entry) => Building(name: entry.key, svgId: entry.value))
        .toList();
  }

  static List<String> getAllBuildingNames() {
    return _nameToSvgId.keys.toList();
  }

  static String? getSvgId(String buildingName) {
    return _nameToSvgId[buildingName];
  }
}