import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class HospitalService {
  final String apiKey = 'AIzaSyA4BXNYwXIDADbWBsmVQmikBlIFCvXzHik';

  // Fetch nearby food banks from Google Maps API
  Future<List<CircleMarker>> fetchNearbyHospitals(double latitude, double longitude) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=5000&type=hospital&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List results = data['results'];

        // Debugging: Print the results
        print('Hospital API results: ${results.length}');
        if (results.isNotEmpty) {
          print('First hospital location: ${results.first['geometry']['location']}');
        }

        return results.map<CircleMarker>((hospital) {
          double lat = hospital['geometry']['location']['lat'];
          double lng = hospital['geometry']['location']['lng'];
          String name = hospital['name'];
          String address = hospital['vicinity'];

          // Returning CircleMarker instead of Marker
          return CircleMarker(
            point: LatLng(lat, lng),
            radius: 8.0, // Adjust the size of the circle
            color: Colors.red.withOpacity(0.6),
            borderColor: Colors.red,
            borderStrokeWidth: 2,

          );
        }).toList();
      } else {
        throw Exception('Failed to load hospitals');
      }
    } catch (e) {
      print('Error fetching load hospitals: $e');
      return [];
    }
  }
}