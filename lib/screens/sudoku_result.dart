import 'package:flutter/material.dart';

class SudokuResultScreen extends StatelessWidget {
  final List<List<int>> solvedGrid;

  SudokuResultScreen({required this.solvedGrid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Solved Grid')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(9, (i) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(9, (j) {
                return Container(
                  width: 36,
                  height: 36,
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.green,
                  ),
                  child: Center(
                    child: Text(
                      '${solvedGrid[i][j]}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
