// lib/screens/futoshiki_input.dart
import 'package:flutter/material.dart';
import '../utils/futoshiki_solver.dart';
import 'futoshiki_result.dart';

class FutoshikiInputScreen extends StatefulWidget {
  @override
  _FutoshikiInputScreenState createState() => _FutoshikiInputScreenState();
}

class _FutoshikiInputScreenState extends State<FutoshikiInputScreen> {
  final int size = 4;
  late List<List<int>> grid;
  int? selectedNumber;

  Map<String, int> hConstraints = {};
  Map<String, int> vConstraints = {};

  @override
  void initState() {
    super.initState();
    grid = List.generate(size, (_) => List.filled(size, 0));
  }

  bool initialConstraintsValid() {
    for (var entry in hConstraints.entries) {
      final parts = entry.key.split(',');
      int r = int.parse(parts[0]);
      int c = int.parse(parts[1]);
      int ineq = entry.value;
      if (grid[r][c] != 0 && grid[r][c + 1] != 0) {
        if (ineq == 1 && !(grid[r][c] > grid[r][c + 1])) return false;
        if (ineq == 0 && !(grid[r][c] < grid[r][c + 1])) return false;
      }
    }
    for (var entry in vConstraints.entries) {
      final parts = entry.key.split(',');
      int r = int.parse(parts[0]);
      int c = int.parse(parts[1]);
      int ineq = entry.value;
      if (grid[r][c] != 0 && grid[r + 1][c] != 0) {
        if (ineq == 1 && !(grid[r][c] > grid[r + 1][c])) return false;
        if (ineq == 0 && !(grid[r][c] < grid[r + 1][c])) return false;
      }
    }
    return true;
  }

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

  void toggleHorizontal(int r, int c) {
    String key = "$r,$c";
    setState(() {
      if (!hConstraints.containsKey(key)) {
        hConstraints[key] = 1; // >
      } else if (hConstraints[key] == 1) {
        hConstraints[key] = 0; // <
      } else {
        hConstraints.remove(key);
      }
    });
  }

  void toggleVertical(int r, int c) {
    String key = "$r,$c";
    setState(() {
      if (!vConstraints.containsKey(key)) {
        vConstraints[key] = 1; // top > bottom
      } else if (vConstraints[key] == 1) {
        vConstraints[key] = 0; // top < bottom
      } else {
        vConstraints.remove(key);
      }
    });
  }

  void resetGrid() {
    setState(() {
      grid = List.generate(size, (_) => List.filled(size, 0));
      selectedNumber = null;
      hConstraints.clear();
      vConstraints.clear();
    });
  }

  void submitGrid() {
    if (!initialConstraintsValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid constraints: contradiction detected")),
      );
      return;
    }
    final solverGrid = List.generate(size, (r) => List<int>.from(grid[r]));
    final solver = FutoshikiSolver(solverGrid, hConstraints, vConstraints);
    final solved = solver.solve();
    if (solved) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FutoshikiResultScreen(
            grid: solverGrid,
            hConstraints: Map.from(hConstraints),
            vConstraints: Map.from(vConstraints),
          ),
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
      children: List.generate(size * 2 - 1, (i) {
        if (i.isEven) {
          // Row of cells with horizontal slots
          int row = i ~/ 2;
          return Row(
            children: List.generate(size * 2 - 1, (j) {
              if (j.isEven) {
                int col = j ~/ 2;
                // Cell
                return GestureDetector(
                  onTap: () => setCell(row, col),
                  onLongPress: () => eraseCell(row, col),
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      color: grid[row][col] == 0
                          ? Colors.black
                          : Colors.blueGrey,
                    ),
                    child: Center(
                      child: Text(
                        grid[row][col] == 0 ? '' : '${grid[row][col]}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                int col = (j - 1) ~/ 2;
                String key = "$row,$col";
                String symbol = '';
                if (hConstraints[key] == 1)
                  symbol = '>';
                else if (hConstraints[key] == 0)
                  symbol = '<';
                return GestureDetector(
                  onTap: () => toggleHorizontal(row, col),
                  child: Container(
                    width: 24,
                    height: 48,
                    margin: const EdgeInsets.all(2),
                    color: Colors.grey.shade800,
                    child: Center(
                      child: Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }
            }),
          );
        } else {
          // Row of vertical slots
          int row = (i - 1) ~/ 2;
          return Row(
            children: List.generate(size * 2 - 1, (j) {
              if (j.isEven) {
                int col = j ~/ 2;
                String key = "$row,$col";
                String symbol = '';
                if (vConstraints[key] == 1)
                  symbol = 'v';
                else if (vConstraints[key] == 0)
                  symbol = '^';
                return GestureDetector(
                  onTap: () => toggleVertical(row, col),
                  child: Container(
                    width: 48,
                    height: 24,
                    margin: const EdgeInsets.all(2),
                    color: Colors.grey.shade800,
                    child: Center(
                      child: Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox(width: 24, height: 24);
              }
            }),
          );
        }
      }),
    );
  }

  Widget buildNumberPad() {
    return Wrap(
      spacing: 8,
      children: [
        for (int num = 1; num <= size; num++)
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
      appBar: AppBar(title: Text('Futoshiki Input (4×4)')),
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
