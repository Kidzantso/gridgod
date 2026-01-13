// lib/screens/kakuro_input.dart
import 'package:flutter/material.dart';
import '../utils/kakuro_solver.dart';
import 'kakuro_result.dart';
import 'loading_screen.dart';

enum CellType { empty, black, rightClue, downClue, bothClues }

class KakuroInputScreen extends StatefulWidget {
  @override
  State<KakuroInputScreen> createState() => _KakuroInputScreenState();
}

class _KakuroInputScreenState extends State<KakuroInputScreen> {
  int rows = 4;
  int cols = 4;

  late List<List<CellType>> grid;
  late List<List<Map<String, int?>>> clueValues;
  CellType selectedType = CellType.empty;

  @override
  void initState() {
    super.initState();
    _resetGrid();
  }

  void _resetGrid() {
    grid = List.generate(rows, (_) => List.filled(cols, CellType.empty));
    clueValues = List.generate(
      rows,
      (_) => List.generate(cols, (_) => {"right": null, "down": null}),
    );
    setState(() {});
  }

  Future<int?> _askForNumber(String label) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AlertDialog(
          title: Text("Enter $label clue sum"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Sum"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                Navigator.pop(context, val);
              },
              child: Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, int?>?> _askForTwo() async {
    final right = await _askForNumber("right");
    final down = await _askForNumber("down");
    if (right == null && down == null) return null;
    return {"right": right, "down": down};
  }

  void setCell(int r, int c) async {
    setState(() => grid[r][c] = selectedType);

    if (selectedType == CellType.rightClue) {
      final v = await _askForNumber("right");
      if (v != null) setState(() => clueValues[r][c]["right"] = v);
    } else if (selectedType == CellType.downClue) {
      final v = await _askForNumber("down");
      if (v != null) setState(() => clueValues[r][c]["down"] = v);
    } else if (selectedType == CellType.bothClues) {
      final vals = await _askForTwo();
      if (vals != null) {
        setState(() {
          clueValues[r][c]["right"] = vals["right"];
          clueValues[r][c]["down"] = vals["down"];
        });
      }
    } else {
      setState(() {
        clueValues[r][c]["right"] = null;
        clueValues[r][c]["down"] = null;
      });
    }
  }

  bool _isPlayableCell(int r, int c) => grid[r][c] == CellType.empty;

  int _findRightRunEnd(int r, int startCol) {
    int j = startCol;
    while (j < cols && _isPlayableCell(r, j)) j++;
    return j - 1;
  }

  int _findDownRunEnd(int startRow, int c) {
    int i = startRow;
    while (i < rows && _isPlayableCell(i, c)) i++;
    return i - 1;
  }

  void submitPuzzle() async {
    final List<List<int>> rowCluesOut = [];
    final List<List<int>> colCluesOut = [];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cell = grid[r][c];
        final sums = clueValues[r][c];

        if ((cell == CellType.rightClue || cell == CellType.bothClues) &&
            sums["right"] != null) {
          final startCol = c + 1;
          final endCol = _findRightRunEnd(r, c + 1);
          if (endCol >= startCol) {
            rowCluesOut.add([r, startCol, endCol, sums["right"]!]);
          }
        }

        if ((cell == CellType.downClue || cell == CellType.bothClues) &&
            sums["down"] != null) {
          final startRow = r + 1;
          final endRow = _findDownRunEnd(r + 1, c);
          if (endRow >= startRow) {
            colCluesOut.add([c, startRow, endRow, sums["down"]!]);
          }
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingScreen(message: "Solving Kakuro..."),
      ),
    );

    await Future.delayed(Duration(milliseconds: 100));

    final puzzle = KakuroPuzzle(rowCluesOut, colCluesOut, 1);
    final ok = puzzle.solveBacktrack();

    Navigator.pop(context);

    if (ok) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KakuroResultScreen(solvedGrid: puzzle.board),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No solution found')));
    }
  }

  Widget buildGrid() {
    double cellSize = 40; // smaller to avoid overflow
    return Column(
      children: List.generate(rows, (i) {
        return Row(
          children: List.generate(cols, (j) {
            final cell = grid[i][j];
            Color color;
            String text = '';
            if (cell == CellType.black) {
              color = Colors.black;
            } else if (cell == CellType.rightClue) {
              color = Colors.blue.shade700;
              text = (clueValues[i][j]["right"]?.toString() ?? '');
            } else if (cell == CellType.downClue) {
              color = Colors.green.shade700;
              text = (clueValues[i][j]["down"]?.toString() ?? '');
            } else if (cell == CellType.bothClues) {
              color = Colors.purple.shade700;
              final right = clueValues[i][j]["right"]?.toString() ?? '';
              final down = clueValues[i][j]["down"]?.toString() ?? '';
              text = '$right\n$down';
            } else {
              color = Colors.white;
            }

            return GestureDetector(
              onTap: () => setCell(i, j),
              child: Container(
                width: cellSize,
                height: cellSize,
                margin: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: (cell == CellType.empty)
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget buildControls() {
    return Column(
      children: [
        DropdownButton<int>(
          value: rows,
          items: [3, 4, 5, 6, 7].map((size) {
            return DropdownMenuItem<int>(
              value: size,
              child: Text('${size}×$size'),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                rows = val;
                cols = val;
                _resetGrid();
              });
            }
          },
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => selectedType = CellType.empty),
              child: Text('Empty'),
            ),
            ElevatedButton(
              onPressed: () => setState(() => selectedType = CellType.black),
              child: Text('Black'),
            ),
            ElevatedButton(
              onPressed: () =>
                  setState(() => selectedType = CellType.rightClue),
              child: Text('Right clue'),
            ),
            ElevatedButton(
              onPressed: () => setState(() => selectedType = CellType.downClue),
              child: Text('Down clue'),
            ),
            ElevatedButton(
              onPressed: () =>
                  setState(() => selectedType = CellType.bothClues),
              child: Text('Both clues'),
            ),
            ElevatedButton(
              onPressed: submitPuzzle,
              child: Text('Submit Puzzle'),
            ),
            ElevatedButton(onPressed: _resetGrid, child: Text('Reset Grid')),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // fixes keyboard overlay
      appBar: AppBar(title: Text('Kakuro Input')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Tap cells to assign clue type and enter sums.\n"
              "Use the dropdown to change grid size (2×2 to 6×6).\n"
              "Reset clears the entire grid.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            buildGrid(),
            SizedBox(height: 20),
            buildControls(),
          ],
        ),
      ),
    );
  }
}
