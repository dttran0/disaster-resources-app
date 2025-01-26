import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NWSService {
  final String baseUrl = "https://api.weather.gov/alerts";

  Future<(List<String>, Map<String, List<LatLng>>)> getAlertsForCities(List<String> cities) async {
    Map<String, List<LatLng>> allCityCoordinates = {};
    List<String> allEvents = [];

    try {
      final response = await http.get(Uri.parse(baseUrl));
      try {if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final alerts = data['features'] as List;

        for (String city in cities) {
          print("Searching for alerts in city: $city");
          // final cityCoordinates = <List<List<double>>>[];
          // final cityEvents = <String>[];

          for (var alert in alerts) {
            final properties = alert['properties'];
            final areaDescription = properties['senderName'] + properties['areaDesc'] ?? "";
            final affectedZones = properties['affectedZones'] as List?;
            final severity = properties["severity"];
            final event = properties['event'];

            if (severity == "Severe" && areaDescription.toLowerCase().contains(city.toLowerCase()) && affectedZones != null) {
              print("Found alerts for $event : $affectedZones");
              for (var zoneUrl in affectedZones) {
                final zoneId = zoneUrl.substring(zoneUrl.lastIndexOf("/")+1);
                if (allCityCoordinates.containsKey(zoneId)){
                  continue;
                }
                final zoneResponse = await http.get(Uri.parse(zoneUrl));

                if (zoneResponse.statusCode == 200) {
                  final zoneData = json.decode(zoneResponse.body);
                  final coordinates = zoneData['geometry']['coordinates'] as List;

                  if (coordinates.isNotEmpty) {
                    // Coordinates are in a list of lists
                    final areaCoords = coordinates[0] as List;
                    double minLat = double.infinity;
                    double maxLat = double.negativeInfinity;
                    double minLon = double.infinity;
                    double maxLon = double.negativeInfinity;

                    for (var coord in areaCoords) {
                      if (coord is List && coord.length >= 2) {
                        double lat = coord[1]
                            .toDouble(); // Assuming [lon, lat] format
                        double lon = coord[0].toDouble();

                        if (lat < minLat) minLat = lat;
                        if (lat > maxLat) maxLat = lat;
                        if (lon < minLon) minLon = lon;
                        if (lon > maxLon) maxLon = lon;
                      }
                    }

                    allCityCoordinates.putIfAbsent(zoneId, () => [
                      LatLng(minLat, minLon),
                      LatLng(minLat, maxLon),
                      LatLng(maxLat, minLon),
                      LatLng(maxLat, maxLon),

                      // minLat, minLon], // Bottom-left
                      // [minLat, maxLon], // Bottom-right
                      // [maxLat, minLon], // Top-left
                      // [maxLat, maxLon] // Top-right
                    ]);
                    allEvents.add(event);

                  }
                } else {
                  print('Failed to fetch zone data from $zoneUrl');
                }
              }
            }
          }
        }

        return (allEvents, allCityCoordinates);
      }} catch (error) {
        print("Failed to load data. Status Code: ${response.statusCode}");
        return (<String>[], <String, List<LatLng>>{});
      }
    } catch (error) {
      print("Error fetching data: $error");
      return (<String>[], <String, List<LatLng>>{});
    }
    return (<String>[], <String, List<LatLng>>{});

  }
}
