// import 'package:flutter/material.dart';
// import 'user_location.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'User Location Map',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         useMaterial3: true,
//       ),
//       home: MapScreen(), // Set MapScreen as the home widget
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'map_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

