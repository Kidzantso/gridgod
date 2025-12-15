import 'package:flutter/material.dart';
import 'screens/sudoku_input.dart';

void main() => runApp(GridGodApp());

class GridGodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GridGod',
      theme: ThemeData.dark(),
      home: SudokuInputScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
