import 'package:flutter/material.dart';

class AffectedAreaWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSafe;

  AffectedAreaWidget({required this.onTap, required this.isSafe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isSafe ? Colors.blue : Color(0xFFFF4500),
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Text(
          isSafe ? "Your area is safe. Click here for resources." : "Your area is affected. Click here for resources.",
          style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}