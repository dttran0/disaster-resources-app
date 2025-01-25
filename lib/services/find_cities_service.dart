import 'dart:convert';
import 'package:http/http.dart' as http;

class FindCitiesService {
  Future<List<String>> getCitiesWithin5Miles(double lat, double lon) async {
    int radiusMeters = 16093;
    String url =
        "https://overpass-api.de/api/interpreter?data=[out:json];node[place=city](around:$radiusMeters,$lat,$lon);out;";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> cities = data["elements"]
            .where((element) => element.containsKey("tags") && element["tags"].containsKey("name"))
            .map<String>((element) => element["tags"]["name"] as String) // Explicitly cast to String
            .toList();

        return cities;
      } else {
        throw Exception("Failed to load cities. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching cities: $e");
      return [];
    }
  }
}