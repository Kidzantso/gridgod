// lib/screens/kakuro_result.dart
import 'package:flutter/material.dart';

class KakuroResultScreen extends StatelessWidget {
  final List<List<int>> solvedGrid;

  const KakuroResultScreen({required this.solvedGrid, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rows = solvedGrid.length;
    final cols = rows == 0 ? 0 : solvedGrid[0].length;

    return Scaffold(
      appBar: AppBar(title: Text('Solved Kakuro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(rows, (i) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cols, (j) {
                final value = solvedGrid[i][j];
                final isNumber =
                    value >= 1 && value <= 45; // numbers or clue sums
                final isEmpty = value == 0;

                return Container(
                  width: 36,
                  height: 36,
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: isEmpty
                        ? Colors.black
                        : (isNumber ? Colors.orange : Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      isEmpty ? '' : '$value',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
