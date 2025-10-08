import 'package:flutter/material.dart';
import 'screens/player_list_screen.dart';

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
      home: PlayerListScreen(),
    );
  }
}
