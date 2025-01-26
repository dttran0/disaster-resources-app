// lib/models/food_bank_model.dart
import 'package:latlong2/latlong.dart';

// define the foodbank models
class FoodBank {
  final String name;
  final String address;
  final LatLng location;

  FoodBank({required this.name, required this.address, required this.location});
}
