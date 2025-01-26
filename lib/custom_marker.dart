import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'foodbank_model.dart';

class CustomMarkerLayer extends StatelessWidget {
  final List<FoodBank> foodBanks;

  CustomMarkerLayer({required this.foodBanks});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(),
      children: [
        CircleLayer(
          circles: foodBanks.map((foodBank) {
            return CircleMarker(
              point: foodBank.location,
              radius: 8.0, // Circle radius
              color: Colors.red.withOpacity(0.6),
              borderColor: Colors.red,
              borderStrokeWidth: 2.0,
            );
          }).toList(),
        ),
      ],
    );
  }
}