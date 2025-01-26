import 'package:test/test.dart';
import 'package:flutter_work/services/find_cities_service.dart';

void main() {
  group('FindCitiesService - Integration Tests', () {
    late FindCitiesService findCitiesService;

    setUp(() {
      findCitiesService = FindCitiesService();
    });

    test('getCitiesWithin5Miles returns expected cities for San Francisco', () async {
      double lat = 37.7749;
      double lon = -122.4194;
      final cities = await findCitiesService.getCitiesWithin5Miles(lat, lon);
      expect(cities, isA<List<String>>());
      expect(cities, contains("San Francisco"));
    });

    test('getCitiesWithin5Miles returns expected cities for Costa Mesa and Irvine', () async {
      double lat = 33.672369;
      double lon = -117.868663;
      final cities = await findCitiesService.getCitiesWithin5Miles(lat, lon);
      expect(cities, isA<List<String>>());
      expect(cities, contains("Costa Mesa"));
      expect(cities, contains("Irvine"));
    });

    test('getCitiesWithin5Miles returns expected cities for New York', () async {
      double lat = 40.7128;
      double lon = -74.0060;
      final cities = await findCitiesService.getCitiesWithin5Miles(lat, lon);
      expect(cities, isA<List<String>>());
      expect(cities, contains("New York"));
    });

    test('getCitiesWithin5Miles returns empty list for invalid coordinates', () async {
      double lat = 0.0;
      double lon = 0.0;
      final cities = await findCitiesService.getCitiesWithin5Miles(lat, lon);
      expect(cities, isA<List<String>>());
      expect(cities.isEmpty, true);
    });

    test('getCitiesWithin5Miles handles API errors gracefully', () async {
      double lat = 999.999;
      double lon = 999.999;
      final cities = await findCitiesService.getCitiesWithin5Miles(lat, lon);
      expect(cities, isA<List<String>>());
      expect(cities.isEmpty, true);
    });
  });
}