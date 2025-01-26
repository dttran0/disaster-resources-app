import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'named_marker.dart';

class FoodBankService {
  final String apiKey = 'AIzaSyA4BXNYwXIDADbWBsmVQmikBlIFCvXzHik';

  Future<List<NamedMarker>> fetchNearbyFoodBanks(double latitude, double longitude) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=5000&type=church&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List results = data['results'];

        return results.map<NamedMarker>((foodBank) {
          double lat = foodBank['geometry']['location']['lat'];
          double lng = foodBank['geometry']['location']['lng'];
          String name = foodBank['name'];
          String address = foodBank['vicinity'];
          return NamedMarker(point: LatLng(lat, lng), name: name, address: address);
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