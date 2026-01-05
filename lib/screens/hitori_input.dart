import 'package:flutter/material.dart';
import '../utils/hitori_solver.dart';
import 'hitori_result.dart';

class HitoriInputScreen extends StatefulWidget {
  @override
  _HitoriInputScreenState createState() => _HitoriInputScreenState();
}

class _HitoriInputScreenState extends State<HitoriInputScreen> {
  List<List<int>> grid = List.generate(5, (_) => List.filled(5, 0));
  int? selectedNumber;

  void setCell(int row, int col) {
    setState(() {
      grid[row][col] = selectedNumber ?? 0;
    });
  }

  void eraseCell(int row, int col) {
    setState(() {
      grid[row][col] = 0;
    });
  }

  void resetGrid() {
    setState(() {
      grid = List.generate(5, (_) => List.filled(5, 0));
      selectedNumber = null;
    });
  }

  void submitGrid() {
    // Build Cell objects for solver
    final hitoriGrid = List.generate(
      5,
      (r) => List.generate(5, (c) => Cell(r, c, grid[r][c])),
    );
    final solver = HitoriSolver(hitoriGrid);
    final solved = solver.solve();
    if (solved) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HitoriResultScreen(grid: hitoriGrid)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No solution found")));
    }
  }

  Widget buildGrid() {
    return Column(
      children: List.generate(5, (i) {
        return Row(
          children: List.generate(5, (j) {
            return GestureDetector(
              onTap: () => setCell(i, j),
              onLongPress: () => eraseCell(i, j),
              child: Container(
                width: 48,
                height: 48,
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: grid[i][j] == 0 ? Colors.black : Colors.blueGrey,
                ),
                child: Center(
                  child: Text(
                    grid[i][j] == 0 ? '' : '${grid[i][j]}',
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
        for (int num = 1; num <= 5; num++)
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
      appBar: AppBar(title: Text('Hitori Input (5×5)')),
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
