import 'package:flutter/material.dart';
import 'user_location.dart';
//

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
