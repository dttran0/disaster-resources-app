import 'package:latlong2/latlong.dart';

class NamedMarker {
  final LatLng point;
  final String name;
  final String address;

  NamedMarker({required this.point, required this.name, required this.address});
}