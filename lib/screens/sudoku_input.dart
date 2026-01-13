// lib/screens/sudoku_input.dart
import 'package:flutter/material.dart';
import '../utils/sudoku_solver.dart';
import 'sudoku_result.dart';

class SudokuInputScreen extends StatefulWidget {
  @override
  _SudokuInputScreenState createState() => _SudokuInputScreenState();
}

class _SudokuInputScreenState extends State<SudokuInputScreen> {
  List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
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
      grid = List.generate(9, (_) => List.filled(9, 0));
      selectedNumber = null;
    });
  }

  void submitGrid() {
    // Validate before solving
    if (!isValidSudokuGrid(grid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No solution detected (invalid input)")),
      );
      return;
    }

    List<List<int>> solved = List.generate(9, (i) => List.from(grid[i]));
    bool ok = solveSudoku(solved);

    if (ok) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SudokuResultScreen(solvedGrid: solved),
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
      children: List.generate(9, (i) {
        return Row(
          children: List.generate(9, (j) {
            return GestureDetector(
              onTap: () => setCell(i, j),
              onLongPress: () => eraseCell(i, j),
              child: Container(
                width: 36,
                height: 36,
                margin: EdgeInsets.only(
                  left: j % 3 == 0 ? 4 : 1,
                  right: 1,
                  top: i % 3 == 0 ? 4 : 1,
                  bottom: 1,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: grid[i][j] == 0 ? Colors.black : Colors.blueGrey,
                ),
                child: Center(
                  child: Text(
                    grid[i][j] == 0 ? '' : '${grid[i][j]}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
        for (int num = 1; num <= 9; num++)
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
      appBar: AppBar(title: Text('Sudoku Input')),
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
