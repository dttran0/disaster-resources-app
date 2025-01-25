import 'package:flutter/material.dart';
import 'nws_service.dart';

void main() {
  runApp(MyApp());
  final nwsService = NWSService();

  // Test for severe alerts in a specific city using senderName
  nwsService.getSevereAlertsForCity("San Diego"); // Replace with other city names to test
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NWS Alerts Test',
      home: Scaffold(
        appBar: AppBar(title: Text('NWS Alerts Test')),
        body: Center(
          child: Text('Check console for results!'),
        ),
      ),
    );
  }
}
