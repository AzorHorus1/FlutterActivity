import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(BadmintonApp());
}

class BadmintonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Badminton Queue',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
    );
  }
}
