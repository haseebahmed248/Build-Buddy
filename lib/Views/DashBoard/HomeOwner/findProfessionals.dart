


import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class FindProfessionalsDashboard extends StatefulWidget {
  const FindProfessionalsDashboard({super.key});

  @override
  State<FindProfessionalsDashboard> createState() =>
      _FindProfessionalsDashboardState();
}

class _FindProfessionalsDashboardState
    extends State<FindProfessionalsDashboard> {
  String selectedProfession = '';
  String userLocation = 'Faisalabad, Punjab';
  Position? _currentPosition;
  LatLng _selectedLocation = LatLng(31.4504, 73.1350);
  bool isSearching = false;
  TextEditingController _searchController = TextEditingController();

  final Map<String, List<Professional>> professionals = {
    'Architects': [
      Professional(name: 'John Doe', role: 'Architect', rating: 4.5),
      Professional(name: 'Alice Green', role: 'Architect', rating: 4.7),
    ],
    'Contractors': [
      Professional(name: 'Jane Smith', role: 'Contractor', rating: 4.8),
      Professional(name: 'Robert Brown', role: 'Contractor', rating: 4.6),
    ],
  };

  Color _getProfessionColor(String profession) {
    switch (profession) {
      case 'Architects':
        return Color(0xFF2ECC71); // Bright Green
      case 'Contractors':
        return Color(0xFF3498DB); // Bright Blue
      default:
        return Color(0xFF95A5A6); // Gray
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _updateUserLocation(position.latitude, position.longitude);
    });
  }

  Future<void> _updateUserLocation(double latitude, double longitude) async {
    try {
      // Convert latitude and longitude to a human-readable address
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      setState(() {
        userLocation = "${place.locality}, ${place.administrativeArea}"; // Format address
      });
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  Future<void> _onMapTap(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _updateUserLocation(location.latitude, location.longitude);
    });
  }

  void _searchLocation(String query) {
    setState(() {
      userLocation = query;
    });
  }
  // ... (keep all previous methods like _getCurrentLocation, _updateUserLocation, etc.)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3799),  // Deep Blue
                Color(0xFF4834DF),  // Royal Blue
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // Main AppBar Content
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.engineering,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Find Professionals',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Nearby Experts',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.filter_list, color: Colors.white),
                              onPressed: () {
                                // Add filter functionality
                              },
                            ),
                          ],
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
      backgroundColor: Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4834DF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E3799).withOpacity(0.1),
              ),
            ),
          ),
          Column(
            children: [
              // Location Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userLocation,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1E3799),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _getCurrentLocation,
                      child: Text(
                        "Change",
                        style: TextStyle(color: Color(0xFF4834DF)),
                      ),
                    ),
                  ],
                ),
              ),

              // Profession Selection Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildProfessionCard(
                      title: 'Architects',
                      icon: Icons.architecture,
                      onTap: () {
                        setState(() {
                          selectedProfession = 'Architects';
                        });
                      },
                    ),
                    _buildProfessionCard(
                      title: 'Contractors',
                      icon: Icons.engineering,
                      onTap: () {
                        setState(() {
                          selectedProfession = 'Contractors';
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Map
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildMap(),
              ),

              // Professional List
              if (selectedProfession.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: professionals[selectedProfession]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final professional = professionals[selectedProfession]![index];
                        return _buildProfessionalCard(professional);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getProfessionColor(title).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: _getProfessionColor(title),
                size: 48,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3799),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            center: _selectedLocation,
            zoom: 13.0,
            onTap: (tapPosition, point) => _onMapTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate:
              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: _selectedLocation,
                  builder: (ctx) => const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalCard(Professional professional) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getProfessionColor(professional.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                professional.role == 'Architect' ? Icons.architecture : Icons.engineering,
                color: _getProfessionColor(professional.role),
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E3799),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    professional.role,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${professional.rating}⭐',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Professional {
  final String name;
  final String role;
  final double rating;

  Professional({required this.name, required this.role, required this.rating});
}
