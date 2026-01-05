// lib/screens/hitori_result.dart
import 'package:flutter/material.dart';
import '../utils/hitori_solver.dart';

class HitoriResultScreen extends StatelessWidget {
  final List<List<Cell>> grid;
  const HitoriResultScreen({required this.grid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hitori Solution")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: grid.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((cell) {
                Color color;
                String text = '';
                if (cell.state == CellState.assigned) {
                  color = Colors.white;
                  text = cell.value.toString();
                } else if (cell.state == CellState.eliminated) {
                  color = Colors.black;
                } else {
                  color = Colors.grey.shade300;
                  text = '?';
                }
                return Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.all(2),
                  color: color,
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: (cell.state == CellState.assigned)
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
