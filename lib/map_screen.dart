import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'user_location.dart'; // Import your location service
import 'food_bank.dart'; // Import the FoodBankService
//import 'package:flutter_map_circle_marker/flutter_map_circle_marker.dart'; // Import the circle marker plugin
import 'services/nws_service.dart';
import 'services/find_cities_service.dart'; // Ensure this service is
import 'hospital.dart';
import 'named_marker.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  LatLng _center = LatLng(34.0549, 118.2426); // Initial center (LA, CA)
  double _currentZoom = 13.0; // Initial zoom level
  //List<CircleMarker> _foodBankMarkers = []; // List of CircleMarkers
  //List<CircleMarker> disasterMarkers = [];
  //List<Polygon> disasterPolygons = [];  // List to store polygons
  List<CircleMarker> disasterCircles = [];
  List<Marker> _foodBankMarkers = []; // List of Markers for food banks
  List<Marker> _hospitalMarkers = []; // List of Markers for hospitals

  // Info window variables
  LatLng? _selectedMarkerLocation;
  String? _selectedMarkerName;
  double? _selectedMarkerDistance;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
        backgroundColor: Color(0xFF2F8D46),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _center,
              zoom: _currentZoom,
                onTap: (_, __) {
                  setState(() {
                    _selectedMarkerLocation = null;
                  });
                },
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture && position.center != null) {
                    setState(() {
                      _center = position.center ?? _center;
                    });
                  }
                }
            ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            // Use CircleMarkerLayerPlugin to display CircleMarkers
            MarkerLayer(
              markers: [..._foodBankMarkers, ..._hospitalMarkers]
            ),
            CircleLayer(
                circles: disasterCircles,
            ),
          ],
        ),
          if (_selectedMarkerLocation != null)
            Positioned(
              bottom: 100,
              left: MediaQuery.of(context).size.width * 0.2,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedMarkerName ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_selectedMarkerDistance?.toStringAsFixed(2)} km away',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
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
      var foodBanks = await FoodBankService().fetchNearbyFoodBanks(
        location.latitude,
        location.longitude,
      );
      var hospitals = await HospitalService().fetchNearbyHospitals(
        location.latitude,
        location.longitude,
      );

      final findCitiesService = FindCitiesService();
      final nwsService = NWSService();

      // Get cities within a 5-mile radius of the given lat/lon
      List<String> nearbyCities = await findCitiesService.getCitiesWithin5Miles(
          location.latitude, location.longitude);

      // Now, fetch alerts for the list of cities
      List<String> events = [];
      Map<String, List<LatLng>> coords = {};
      (events, coords) = await nwsService.getAlertsForCities(nearbyCities);

      var index = 0;
      var event = "";
      for (var areaCoords in coords.values){
        event = events[index];
        print('$event Affected Area Coordinates: $areaCoords');

        LatLng center = _calculateCenter(areaCoords);
        print('Center Coordinates: $center');
        // Calculate the radius (distance from center to one of the corners)
        double radius = _calculateRadius(center, areaCoords[0]); // Distance to the first corner
        print('Radius $radius');
        disasterCircles.add(CircleMarker(
          point: center,
          color: Colors.red.withOpacity(0.5),
          borderColor: Colors.red,
          borderStrokeWidth: 2.0,
          radius: radius,
        ));

        index += 1;
      }


      // Update food banks markers
      setState(() {
        _foodBankMarkers = foodBanks.map((marker) => _createMarker(marker)).toList();
        _hospitalMarkers = hospitals.map((marker) => _createMarker(marker)).toList(); // Update the CircleMarkers list

        // Add disaster markers
        // disasterPolygons = disasterPolygonsMap.entries.map((entry) {
        //   return Polygon(
        //     points: entry.value, // Use the list of LatLng points
        //     color: Colors.red.withOpacity(0.5),
        //     borderColor: Colors.red,
        //     borderStrokeWidth: 3.0,
        //   );
        // }).toList();
      });
    }
  }

  Marker _createMarker(NamedMarker namedMarker) {
    return Marker(
      point: namedMarker.point,
      width: 40,
      height: 40,
      builder: (ctx) =>
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMarkerLocation = namedMarker.point;
                _selectedMarkerName =
                    namedMarker.name; // Display the actual name
                _selectedMarkerDistance = Distance().as(
                  LengthUnit.Kilometer,
                  _center,
                  namedMarker.point,
                );
              });
            },
            child: Icon(
              Icons.location_on,
              color: namedMarker.name.contains('Hospital') ? Colors.red : Colors
                  .blue,
              size: 30,
            ),
          ),
    );
  }

  LatLng _calculateCenter(List<LatLng> coords) {
    double latSum = 0.0;
    double lonSum = 0.0;

    for (var coord in coords) {
      latSum += coord.latitude;
      lonSum += coord.longitude;
    }

    return LatLng(latSum / coords.length, lonSum / coords.length);
  }

  // Calculate the radius (distance from the center to one of the corners)
  double _calculateRadius(LatLng center, LatLng corner) {
    final Distance distance = Distance();
    return distance.as(LengthUnit.Mile, center, corner);
  }
}
