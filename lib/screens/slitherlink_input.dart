// lib/screens/slitherlink_input.dart
import 'package:flutter/material.dart';
import '../utils/slitherlink_solver.dart';
import 'slitherlink_result.dart';

class SlitherlinkInputScreen extends StatefulWidget {
  @override
  _SlitherlinkInputScreenState createState() => _SlitherlinkInputScreenState();
}

class _SlitherlinkInputScreenState extends State<SlitherlinkInputScreen> {
  final int size = 5;
  late List<List<int>> cells;
  int? selectedNumber;

  @override
  void initState() {
    super.initState();
    cells = List.generate(size, (_) => List.filled(size, -1));
  }

  void setCell(int row, int col) {
    setState(() {
      cells[row][col] = selectedNumber ?? -1;
    });
  }

  void resetGrid() {
    setState(() {
      cells = List.generate(size, (_) => List.filled(size, -1));
      selectedNumber = null;
    });
  }

  void submitGrid() {
    final solver = SlitherlinkSolver(cells);
    final solved = solver.solve();
    if (solved) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SlitherlinkResultScreen(cells: cells, edges: solver.edges),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No solution found")));
    }
  }

  Widget buildGrid() {
    return Column(
      children: List.generate(size, (i) {
        return Row(
          children: List.generate(size, (j) {
            return GestureDetector(
              onTap: () => setCell(i, j),
              child: Container(
                width: 48,
                height: 48,
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: cells[i][j] == -1 ? Colors.black : Colors.blueGrey,
                ),
                child: Center(
                  child: Text(
                    cells[i][j] == -1 ? '' : '${cells[i][j]}',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget buildNumberPad() {
    return Wrap(
      spacing: 8,
      children: [
        for (int num = 0; num <= 3; num++)
          ElevatedButton(
            onPressed: () => setState(() => selectedNumber = num),
            child: Text('$num'),
          ),
        ElevatedButton(
          onPressed: () => setState(() => selectedNumber = null),
          child: Text('Erase'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Slitherlink Input (5×5)')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildGrid(),
            SizedBox(height: 20),
            buildNumberPad(),
            SizedBox(height: 20),
            ElevatedButton(onPressed: submitGrid, child: Text('Submit')),
            ElevatedButton(onPressed: resetGrid, child: Text('Reset')),
          ],
        ),
      ),
    );
  }
}
