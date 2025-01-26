import 'package:flutter/material.dart';
import 'user_location.dart';
import 'package:flutter/material.dart';
import 'services/nws_service.dart';
import 'services/find_cities_service.dart'; // Ensure this service is imported as well
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'map_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final nameController = TextEditingController();
  final pointController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resources Map',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MapScreen(),
    );
  }
}



