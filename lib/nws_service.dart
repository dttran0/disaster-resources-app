import 'dart:convert';
import 'package:http/http.dart' as http;

class NWSService {
  final String baseUrl = "https://api.weather.gov/alerts";

  Future<void> getSevereAlertsForCity(String cityName) async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final alerts = data['features'] as List;

        // Use a set to track seen alerts for deduplication
        final seenAlerts = <String>{};

        // Filter alerts by senderName and severity (Severe only)
        final severeAlerts = alerts.where((alert) {
          final properties = alert['properties'];
          final senderName = properties['senderName'] ?? "";
          final severity = properties['severity'] ?? "";

          return senderName.toLowerCase().contains(cityName.toLowerCase()) &&
              severity == "Severe";
        }).toList();

        // Display filtered alerts with deduplication
        for (var alert in severeAlerts) {
          final properties = alert['properties'];
          final event = properties['event'] ?? "";
          final description = properties['description'] ?? "";
          final areaDescription = properties['areaDesc'] ?? "No area description available";

          // Create a unique key for each alert
          final uniqueKey = "$event-$description";
          if (seenAlerts.contains(uniqueKey)) {
            continue; // Skip duplicate alerts
          }
          seenAlerts.add(uniqueKey);

          print("Disaster Type: $event");
          print("Description: $description");
          print("Area Description: $areaDescription");
          print("Sender: ${properties['senderName'] ?? 'No sender information'}");

          print("------------------------");
        }

        if (severeAlerts.isEmpty) {
          print("No severe alerts found for $cityName.");
        }
      } else {
        print("Failed to load data. Status Code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }
}
