import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class FoodBankService {
  final String apiKey = 'AIzaSyA4BXNYwXIDADbWBsmVQmikBlIFCvXzHik';

  // Fetch nearby food banks from Google Maps API
  Future<List<CircleMarker>> fetchNearbyFoodBanks(double latitude, double longitude) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=5000&type=food_bank&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List results = data['results'];

        return results.map<CircleMarker>((foodBank) {
          double lat = foodBank['geometry']['location']['lat'];
          double lng = foodBank['geometry']['location']['lng'];
          String name = foodBank['name'];
          String address = foodBank['vicinity'];

          // Returning CircleMarker instead of Marker
          return CircleMarker(
            point: LatLng(lat, lng),
            radius: 8.0, // Adjust the size of the circle
            color: Colors.blue.withOpacity(0.6),
            borderColor: Colors.blue,
            borderStrokeWidth: 2,
          );
        }).toList();
      } else {
        throw Exception('Failed to load food banks');
      }
    } catch (e) {
      print('Error fetching food banks: $e');
      return [];
    }
  }
}
