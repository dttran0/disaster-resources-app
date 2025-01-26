import 'package:flutter/material.dart';
import 'user_location.dart';
//

import 'package:flutter/material.dart';
import 'services/nws_service.dart';
import 'services/find_cities_service.dart'; // Ensure this service is imported as well

// void main() async {
//   runApp(MyApp());
//
//   final lat = 32.7157;  // Latitude of San Diego
//   final lon = -117.1611; // Longitude of San Diego
//
//   final findCitiesService = FindCitiesService();
//   final nwsService = NWSService();
//
//   // Get cities within a 5-mile radius of the given lat/lon
//   List<String> nearbyCities = await findCitiesService.getCitiesWithin5Miles(lat, lon);
//
//   // Now, fetch alerts for the list of cities
//   List<List<String>> events = [];
//   List<List<List<double>>> coords = [];
//   (events, coords) = await nwsService.getAlertsForCities(nearbyCities);
//
//   // Print out the alerts and their coordinates
//   for (var (index, alert) in coords.indexed) {
//     for (var areaCoords in alert) {
//       var event = events[index];
//       print('$event Affected Area Coordinates: $areaCoords');
//     }
//   }
// }
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'NWS Alerts Test',
//       home: Scaffold(
//         appBar: AppBar(title: Text('NWS Alerts Test')),
//         body: Center(
//           child: Text('Check console for results!'),
//         ),
//       ),
//     );
//   }
// }

//
import 'package:flutter/material.dart';
import 'map_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resources Map',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MapScreen(),
    );
  }
}