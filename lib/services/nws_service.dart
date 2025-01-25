import 'dart:convert';
import 'package:http/http.dart' as http;

class NWSService {
  final String baseUrl = "https://api.weather.gov/alerts";

  Future<List<List<List<double>>>> getAlertsForCities(List<String> cities) async {
    List<List<List<double>>> allCityCoordinates = [];

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final alerts = data['features'] as List;

        for (String city in cities) {
          print("Searching for alerts in city: $city");
          final cityCoordinates = <List<double>>[];

          for (var alert in alerts) {
            final properties = alert['properties'];
            final areaDescription = properties['senderName'] + properties['areaDesc'] ?? "";
            final affectedZones = properties['affectedZones'] as List?;
            final severity = properties["severity"];

            if (severity == "Severe" && areaDescription.toLowerCase().contains(city.toLowerCase()) && affectedZones != null) {
              print("Searching for alerts in city: $affectedZones");
              for (var zoneUrl in affectedZones) {
                final zoneResponse = await http.get(Uri.parse(zoneUrl));

                if (zoneResponse.statusCode == 200) {
                  final zoneData = json.decode(zoneResponse.body);
                  final coordinates = zoneData['geometry']['coordinates'] as List;

                  if (coordinates.isNotEmpty) {
                    // Coordinates are in a list of lists
                    final areaCoords = coordinates[0] as List;
                    double totalLat = 0.0;
                    double totalLon = 0.0;
                    int count = 0;

                    for (var coord in areaCoords) {
                      if (coord is List) {
                        // Assuming the coordinates are stored as [lat, lon]
                        for (var innerCoord in coord) {
                          // Now check if innerCoord is a number
                          if (innerCoord is num) {
                            if (count % 2 == 0) {
                              totalLat += innerCoord.toDouble();
                            } else {
                              totalLon += innerCoord.toDouble();
                            }
                            count++;
                          }
                        }
                      }
                    }

                    double centerLat = totalLat / (count/2);
                    double centerLon = totalLon / (count/2);

                    cityCoordinates.add([centerLat, centerLon]);

                  }
                } else {
                  print('Failed to fetch zone data from $zoneUrl');
                }
              }
            }
          }

          allCityCoordinates.add(cityCoordinates);
        }

        return allCityCoordinates;
      } else {
        print("Failed to load data. Status Code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching data: $error");
      return [];
    }
  }
}
