import 'package:flutter/material.dart';
import 'sudoku_input.dart';
import 'kakuro_input.dart';
import 'hitori_input.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GridGod')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SudokuInputScreen()),
                );
              },
              child: Text('Play Sudoku'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KakuroInputScreen()),
                );
              },
              child: Text('Play Kakuro'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HitoriInputScreen()),
                );
              },
              child: Text('Play Hitori'),
            ),
          ],
        ),
      ),
    );
  }
}
