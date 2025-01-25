import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'user_location.dart'; // Import your location service
import 'food_bank.dart'; // Import the FoodBankService
import 'hospital.dart';
//import 'package:flutter_map_circle_marker/flutter_map_circle_marker.dart'; // Import the circle marker plugin

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  LatLng _center = LatLng(34.0549, 118.2426); // Initial center (LA, CA)
  double _currentZoom = 13.0; // Initial zoom level
  List<CircleMarker> _foodBankMarkers = []; // List of CircleMarkers for food bank
  List<CircleMarker> _hospitalMarkers = []; // List of CircleMarkers for hospital

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Banks Map'),
        backgroundColor: Color(0xFF2F8D46),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: _currentZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          // Use CircleMarkerLayerPlugin to display CircleMarkers
          CircleLayer(
            circles: _foodBankMarkers,
          ),

          CircleLayer(
            circles: _hospitalMarkers,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
            backgroundColor: Color(0xFF2F8D46),
            child: Icon(Icons.zoom_in, color: Colors.white),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
            backgroundColor: Color(0xFF2F8D46),
            child: Icon(Icons.zoom_out, color: Colors.white),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            tooltip: 'Get Location',
            backgroundColor: Color(0xFF2F8D46),
            child: Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Zoom In and Out features
  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(0.0, 18.0);
      _mapController.move(_center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(0.0, 18.0);
      _mapController.move(_center, _currentZoom);
    });
  }

  // Get current location and update map
  Future<void> _getCurrentLocation() async {
    var location = await LocationService().getLocation();
    if (location != null) {
      setState(() {
        _center = location;
        _mapController.move(_center, _currentZoom);
      });

      // Fetch food banks nearby and get CircleMarkers
      var foodBanks = await FoodBankService().fetchNearbyFoodBanks(location.latitude, location.longitude);
      var hospitals = await HospitalService().fetchNearbyHospitals(location.latitude, location.longitude);

      // Update food banks markers
      setState(() {
        _foodBankMarkers = foodBanks; // Update the CircleMarkers list
        _hospitalMarkers = hospitals;
      });
    }
  }
}
