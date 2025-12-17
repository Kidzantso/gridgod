import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(GridGodApp());

class GridGodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GridGod',
      theme: ThemeData.dark(),
      home: HomeScreen(), // now starts at the selector screen
    );
  }
}
