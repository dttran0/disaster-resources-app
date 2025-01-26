import 'package:flutter/material.dart';

class AffectedAreaWidget extends StatelessWidget {
  final VoidCallback onTap;

  AffectedAreaWidget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Color(0xFFFF4500),
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Text(
          "You are in an affected area. Click here to find safety now.",
          style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
