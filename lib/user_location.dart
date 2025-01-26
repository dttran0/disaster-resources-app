
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
//
// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   late final MapController _mapController;
//   LatLng _center = LatLng(34.0549, 118.2426); // Initial center (LA, CA)
//   double _currentZoom = 13.0; // Initial zoom level
//
//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('UserLocation Maps'),
//         backgroundColor: Color(0xFF2F8D46),
//       ),
//       body: FlutterMap(
//         mapController: _mapController,
//         options: MapOptions(
//           initialCenter: _center,
//           initialZoom: _currentZoom,
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: ['a', 'b', 'c'],
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           FloatingActionButton(
//             onPressed: _zoomIn,
//             tooltip: 'Zoom In',
//             backgroundColor: Color(0xFF2F8D46),
//             child: Icon(Icons.zoom_in, color: Colors.white),
//           ),
//           SizedBox(height: 10),
//           FloatingActionButton(
//             onPressed: _zoomOut,
//             tooltip: 'Zoom Out',
//             backgroundColor: Color(0xFF2F8D46),
//             child: Icon(Icons.zoom_out, color: Colors.white),
//           ),
//           SizedBox(height: 10),
//           FloatingActionButton(
//             onPressed: _getCurrentLocation,
//             tooltip: 'Get Location',
//             backgroundColor: Color(0xFF2F8D46),
//             child: Icon(Icons.my_location, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
//
//   //set the zoom in and zoom features
//   void _zoomIn() {
//     setState(() {
//       _currentZoom = (_currentZoom + 1).clamp(0.0, 18.0); // Max zoom level is 18
//       _mapController.move(_center, _currentZoom);
//     });
//   }
//
//   void _zoomOut() {
//     setState(() {
//       _currentZoom = (_currentZoom - 1).clamp(0.0, 18.0); // Min zoom level is 0
//       _mapController.move(_center, _currentZoom);
//     });
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Test if location services are enabled.
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Location services are disabled.')),
//       );
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Location permissions are denied')),
//         );
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'Location permissions are permanently denied, we cannot request permissions.'),
//         ),
//       );
//       return;
//     }
//
//     // When permissions are granted, get the position of the device.
//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       _center = LatLng(position.latitude, position.longitude);
//       _mapController.move(_center, _currentZoom);
//     });
//   }
// }
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  // Get the current location of the user
  Future<LatLng?> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }
}
