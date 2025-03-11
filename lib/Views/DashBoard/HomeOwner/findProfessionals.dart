// lib/Views/FindProfessionalsDashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/Professional.dart'; // Updated import
import 'package:buildbuddy/Views/DashBoard/HomeOwner/myProjects.dart';

class FindProfessionalsDashboard extends StatefulWidget {
  const FindProfessionalsDashboard({super.key});

  @override
  State<FindProfessionalsDashboard> createState() => _FindProfessionalsDashboardState();
}

class _FindProfessionalsDashboardState extends State<FindProfessionalsDashboard> {
  String userLocation = 'Faisalabad, Punjab';
  Position? _currentPosition;
  LatLng _selectedLocation = LatLng(31.4504, 73.1350);
  TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  Professional? _selectedProfessional; // Changed from Contractor? to Professional?
  String _selectedRole = 'Contractor'; // Default role

  Color _getProfessionColor(String profession) {
    switch (profession) {
      case 'Architect':
        return const Color(0xFF2ECC71); // Bright Green
      case 'Contractor':
        return const Color(0xFF3498DB); // Bright Blue
      default:
        return const Color(0xFF95A5A6); // Gray
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectController>(context, listen: false).loadProfessionals(); // Changed from loadContractors
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, cannot request permissions.')),
      );
      return;
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
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      setState(() {
        userLocation = "${place.locality ?? 'Unknown'}, ${place.administrativeArea ?? 'Unknown'}";
      });
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  Future<void> _onMapTap(TapPosition tapPosition, LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _updateUserLocation(location.latitude, location.longitude);
    });
  }

  Widget _buildMap() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation,
            initialZoom: 13.0,
            onTap: _onMapTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: _selectedLocation,
                  child: const Icon(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Professionals"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userLocation,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _getCurrentLocation,
                  child: const Text("Update Location"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildMap(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _selectedRole,
              items: ['Contractor', 'Architect'].map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                  _selectedProfessional = null; // Reset selection
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Name, Email, or Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: Consumer<ProjectController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.professionals.isEmpty) {
                  return const Center(child: Text('No professionals found.'));
                }

                final filteredProfessionals = controller.professionals
                    .where((professional) =>
                (professional.name?.isNotEmpty ?? false &&
                    (professional.name ?? '')
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase())) || // Fixed typo
                    (professional.email?.isNotEmpty ?? false &&
                        (professional.email ?? '')
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase())) ||
                    (professional.location?.isNotEmpty ?? false &&
                        (professional.location ?? '')
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase())))
                    .where((professional) => professional.role == _selectedRole)
                    .toList();
                print("Filtered professionals: $filteredProfessionals");

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProfessionals.length,
                  itemBuilder: (context, index) {
                    final professional = filteredProfessionals[index];
                    return _buildProfessionalCard(professional);
                  },
                );
              },
            ),
          ),
          if (_selectedProfessional != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => MyProjectsDashboard(
                    userType: 'homeowner',
                    selectedProfessionalId: _selectedProfessional!.uid,
                    selectedProfessionalRole: _selectedProfessional!.role,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('Proceed to My Projects'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(Professional professional) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          professional.role == 'Architect' ? Icons.architecture : Icons.engineering,
          color: _getProfessionColor(professional.role),
        ),
        title: Text(professional.name ?? 'Unnamed Professional'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (professional.email != null)
              Text('Email: ${professional.email}'),
            if (professional.location != null)
              Text('Location: ${professional.location}'),
            Text('Rating: ${professional.rating.toStringAsFixed(1)} (${professional.reviewCount} reviews)'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedProfessional = professional;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedProfessional == professional
                ? Colors.green
                : Colors.blue,
          ),
          child: Text(
              _selectedProfessional == professional ? 'Selected' : 'Select'),
        ),
      ),
    );
  }
}






