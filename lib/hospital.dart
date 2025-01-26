import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'named_marker.dart';

class HospitalService {
  final String apiKey = 'AIzaSyA4BXNYwXIDADbWBsmVQmikBlIFCvXzHik';

  Future<List<NamedMarker>> fetchNearbyHospitals(double latitude, double longitude) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=5000&type=hospital&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List results = data['results'];

        return results.map<NamedMarker>((hospital) {
          double lat = hospital['geometry']['location']['lat'];
          double lng = hospital['geometry']['location']['lng'];
          String name = hospital['name'];
          String address = hospital['vicinity'];
          return NamedMarker(point: LatLng(lat, lng), name: name, address: address);
        }).toList();
      } else {
        throw Exception('Failed to load hospitals');
      }
    } catch (e) {
      print('Error fetching hospitals: $e');
      return [];
    }
  }

}