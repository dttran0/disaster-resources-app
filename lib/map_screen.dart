import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'user_location.dart';
import 'food_bank.dart';
import 'hospital.dart';
import 'named_marker.dart';
import 'resourcelist.dart';
import 'affectedareawidget.dart';
import 'services/nws_service.dart';
import 'services/find_cities_service.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  LatLng _center = LatLng(34.0549, -118.2426);
  LatLng _initialCenter = LatLng(34.0549, -118.2426);
  double _currentZoom = 13.0;
  List<CircleMarker> disasterCircles = [];
  List<Marker> _foodBankMarkers = [];
  List<Marker> _hospitalMarkers = [];

  LatLng? _selectedMarkerLocation;
  String? _selectedMarkerName;
  double? _selectedMarkerDistance;
  List<String>? _selectedMarkerResources;
  List<LatLng> nearbyDisasters = [];

  Map<String, List<String>> disasterResources = {
    'Cold-Weather': [
      'Blankets',
      'Warm clothing',
      'Heaters',
      'Emergency shelters',
      'Food (non-perishable)',
      'Water (non-perishable)',
      'First aid kits',
    ],
    'Hot-Weather': [
      'Water (for drinking and cooling)',
      'Fire extinguishers',
      'Emergency shelters (cooling centers)',
      'First aid kits (for burns, dehydration)',
      'Non-perishable food',
      'Fire safety equipment',
    ],
    'Flooding': [
      'Sandbags',
      'Life vests',
      'Emergency shelters (safe from flooding)',
      'Water (non-contaminated)',
      'First aid kits',
      'Non-perishable food',
      'Flashlights',
    ],
    'Hurricane': [
      'Emergency shelters (hurricane-resistant)',
      'First aid kits',
      'Non-perishable food',
      'Water (non-contaminated)',
      'Flashlights',
      'Sandbags',
      'Battery-powered radios',
      'Extra clothing',
      'Emergency kits for evacuation',
    ],
  };

  String getDisasterGroup(String disasterType) {
    if (['Winter Storm Watch', 'Blizzard Warning', 'Winter Storm Warning', 'Ice Storm Warning'].contains(disasterType)) {
      return 'Cold-Weather';
    } else if (['Fire Weather Watch', 'Red Flag Warning'].contains(disasterType)) {
      return 'Hot-Weather';
    } else if ([
      'Coastal Flood Watch', 'Coastal Flood Warning', 'Coastal Flood Advisory',
      'Flood Watch', 'Flash Flood Warning', 'Flood Warning',
      'River Flood Watch', 'River Flood Warning'
    ].contains(disasterType)) {
      return 'Flooding';
    } else if (['Hurricane Watch', 'Hurricane Warning'].contains(disasterType)) {
      return 'Hurricane';
    } else {
      return 'Unknown';  // for unexpected disaster types
    }
  }



  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BeaconAid',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF333333),
      ),
      body: Column(
        children: [
          AffectedAreaWidget(
            isSafe: nearbyDisasters.isEmpty,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResourceListScreen(
                    latitude: _initialCenter.latitude,
                    longitude: _initialCenter.longitude,
                  ),
                ),
              );
            },
          ),
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  child: Stack(
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
                          CircleLayer(
                            circles: disasterCircles,
                          ),
                          MarkerLayer(
                              markers: [..._foodBankMarkers, ..._hospitalMarkers]
                          ),
                        ],
                      ),
                      if (_selectedMarkerLocation != null)
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(horizontal: 20),
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
                                  // Display disaster name
                                  Text(
                                    _selectedMarkerName ?? '',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  // Display distance
                                  Text(
                                    '${_selectedMarkerDistance?.toStringAsFixed(2)} km away',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  // Conditionally display resources if not empty
                                  if (_selectedMarkerResources != null && (_selectedMarkerResources ?? []).isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Column(
                                        children: [
                                          // "Needed Items:" label with underline
                                          Text(
                                            'Needed Items:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                          // List of resources
                                          ...(_selectedMarkerResources ?? []).map((resource) => Text(
                                            resource,
                                            style: TextStyle(color: Colors.grey[800]),
                                          )).toList(),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
            backgroundColor: Color(0xFF333333),
            heroTag: 'zoomIn',
            child: Icon(Icons.zoom_in, color: Colors.white),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
            backgroundColor: Color(0xFF333333),
            heroTag: 'zoomOut',
            child: Icon(Icons.zoom_out, color: Colors.white),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            tooltip: 'Get Location',
            backgroundColor: Color(0xFF333333),
            heroTag: 'getLocation',
            child: Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
      _mapController.move(_center, _currentZoom);
    });
  }


  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
      _mapController.move(_center, _currentZoom);
    });
  }


  Future<void> _getCurrentLocation() async {
    var location = await LocationService().getLocation();
    if (location != null) {
      setState(() {
        _center = location;
        _initialCenter = location;
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

      setState(() {
        _foodBankMarkers = foodBanks.map((marker) => _createMarker(marker)).toList();
        _hospitalMarkers = hospitals.map((marker) => _createMarker(marker)).toList(); // Update the CircleMarkers list
      });

      final findCitiesService = FindCitiesService();
      final nwsService = NWSService();

      // Get cities within a 5-mile radius of the given lat/lon
      List<String> nearbyCities = await findCitiesService.getCitiesWithin5Miles(
          location.latitude, location.longitude);

      // Now, fetch alerts for the list of cities
      List<String> events = [];
      Map<String, List<LatLng>> coords = {};
      (events, coords) = await nwsService.getAlertsForCities(nearbyCities);

      nearbyDisasters.clear();
      disasterCircles.clear();

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
        double distance = Distance().as(LengthUnit.Kilometer, _initialCenter, center);
        if (distance <= 10.0) {
          nearbyDisasters.add(center);  // Add to nearby disaster list
        }


        // Add an invisible Marker at the same location to detect taps
        // _foodBankMarkers.add(Marker(
        //   point: center,
        //   width: 40, // Use a small size for the invisible marker
        //   height: 40,
        //   builder: (ctx) => GestureDetector(
        //     onTap: () {
        //       setState(() {
        //         _selectedMarkerLocation = center;
        //         _selectedMarkerName = event; // Show the disaster event name
        //         _selectedMarkerDistance = Distance().as(LengthUnit.Kilometer, _center, center);
        //       });
        //     },
        //     child: Container(
        //       width: 0, // Make the marker invisible
        //       height: 0, // Make the marker invisible
        //     ),
        //   ),
        // ));
        NamedMarker disasterMarker = NamedMarker(
          name: "Disaster: $event",  // Set the disaster event name
          point: center, // Set the center of the disaster area
          address: "",
        );

        // Add the invisible marker to the _foodBankMarkers list
        _foodBankMarkers.add(_createMarker(disasterMarker));
        index += 1;
      }


      // Update food banks markers
      // setState(() {
      //   _foodBankMarkers = foodBanks.map((marker) => _createMarker(marker)).toList();
      //   _hospitalMarkers = hospitals.map((marker) => _createMarker(marker)).toList(); // Update the CircleMarkers list
      //});
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
                  _initialCenter,
                  namedMarker.point,
                );
                if (namedMarker.name.contains("Disaster")){
                  String disasterGroup = getDisasterGroup(namedMarker.name.substring(10));
                  _selectedMarkerResources = disasterResources[disasterGroup] ?? [];
                }
                else{
                  _selectedMarkerResources = [];
                }
              });
              print('Tapped on ${namedMarker.name} at ${namedMarker.point}');
            },
            child: Icon(
              Icons.location_on,
              color: namedMarker.name.contains('Hospital') ? Colors.red : namedMarker.name.contains('Disaster') ? Colors.orange :
              Colors
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
    try {
      return distance.as(LengthUnit.Mile, center, corner).abs();
    } catch (e) {
      print('Error in radius calculation: $e');
      return 0.0; // Default to zero if there's an error
    }
  }
}