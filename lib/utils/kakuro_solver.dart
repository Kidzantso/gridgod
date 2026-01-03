// lib/utils/kakuro_solver.dart
import 'dart:async';

class KakuroPuzzle {
  int count = 0;
  final int caseNumber;
  final List<List<int>> rowClues;
  final List<List<int>> colClues;
  late final int rows;
  late final int cols;

  late final List<List<int>> board;
  final List<List<int>> clueGrids = [];
  final List<List<int>> emptyGrids = [];
  late final List<List<int>> question;

  // Limits
  final int maxSteps = 100000; // step cap
  final Duration maxTime = Duration(seconds: 5); // time cap
  late DateTime startTime;

  KakuroPuzzle(this.rowClues, this.colClues, this.caseNumber)
    : rows =
          (rowClues.isEmpty
              ? 0
              : rowClues.map((r) => r[0]).reduce((a, b) => a > b ? a : b)) +
          1,
      cols =
          (colClues.isEmpty
              ? 0
              : colClues.map((c) => c[0]).reduce((a, b) => a > b ? a : b)) +
          1 {
    board = List.generate(rows, (_) => List.filled(cols, 0));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        emptyGrids.add([i, j]);
      }
    }

    for (final row in rowClues) {
      final r = row[0], startCol1 = row[1], endCol1 = row[2], sum = row[3];
      final clueCol = startCol1 - 1;
      board[r][clueCol] = sum;
      clueGrids.add([r, clueCol]);
      for (int j = clueCol; j <= endCol1; j++) {
        _removeFromEmpty([r, j]);
      }
    }

    for (final col in colClues) {
      final c = col[0], startRow1 = col[1], endRow1 = col[2], sum = col[3];
      final clueRow = startRow1 - 1;
      board[clueRow][c] = sum;
      clueGrids.add([clueRow, c]);
      for (int i = clueRow; i <= endRow1; i++) {
        _removeFromEmpty([i, c]);
      }
    }

    question = List.generate(rows, (i) => List.from(board[i]));
  }

  void _removeFromEmpty(List<int> cell) {
    emptyGrids.removeWhere((e) => e[0] == cell[0] && e[1] == cell[1]);
  }

  bool solveBacktrack() {
    count = 0;
    startTime = DateTime.now();
    print("Starting backtracking solver...");
    return _solveBacktrackHelper(0, 0);
  }

  bool _solveBacktrackHelper(int row, int col) {
    count++;
    if (count > maxSteps) {
      print("Stopped: step limit exceeded");
      return false;
    }
    if (DateTime.now().difference(startTime) > maxTime) {
      print("Stopped: time limit exceeded");
      return false;
    }

    if (row > rows - 1) return isSolution();

    final nextRow = (col == cols - 1) ? row + 1 : row;
    final nextCol = (col == cols - 1) ? 0 : col + 1;

    if (board[row][col] != 0) {
      return _solveBacktrackHelper(nextRow, nextCol);
    }

    final bool isEmptyCell = emptyGrids.any((e) => e[0] == row && e[1] == col);
    if (!isEmptyCell) {
      for (int num = 9; num >= 1; num--) {
        print("Trying ($row,$col) = $num");
        if (isValid(row, col, num)) {
          board[row][col] = num;
          if (_solveBacktrackHelper(nextRow, nextCol)) return true;
          board[row][col] = 0;
        }
      }
    }

    if (isEmptyCell && _solveBacktrackHelper(nextRow, nextCol)) return true;

    return false;
  }

  bool isSolution() {
    for (final row in rowClues) {
      final r = row[0], startCol1 = row[1], endCol1 = row[2], sum = row[3];
      int total = 0;
      for (int j = startCol1; j <= endCol1; j++) total += board[r][j];
      if (total != sum) return false;
    }
    for (final col in colClues) {
      final c = col[0], startRow1 = col[1], endRow1 = col[2], sum = col[3];
      int total = 0;
      for (int i = startRow1; i <= endRow1; i++) total += board[i][c];
      if (total != sum) return false;
    }
    return true;
  }

  bool isValid(int row, int col, int num) {
    // Row uniqueness and pruning
    for (final clue in rowClues) {
      if (clue[0] == row && col >= clue[1] && col <= clue[2]) {
        // uniqueness
        for (int j = clue[1]; j <= clue[2]; j++) {
          if (board[row][j] == num) return false;
        }
        // partial sum pruning
        int total = 0, filled = 0;
        for (int j = clue[1]; j <= clue[2]; j++) {
          total += board[row][j];
          if (board[row][j] != 0) filled++;
        }
        int cells = clue[2] - clue[1] + 1;
        int remaining = cells - filled - 1; // minus current cell
        int minPossible = total + num + remaining; // worst case (all 1s)
        int maxPossible = total + num + 9 * remaining;
        if (minPossible > clue[3] || maxPossible < clue[3]) return false;
      }
    }

    // Column uniqueness and pruning
    for (final clue in colClues) {
      if (clue[0] == col && row >= clue[1] && row <= clue[2]) {
        for (int i = clue[1]; i <= clue[2]; i++) {
          if (board[i][col] == num) return false;
        }
        int total = 0, filled = 0;
        for (int i = clue[1]; i <= clue[2]; i++) {
          total += board[i][col];
          if (board[i][col] != 0) filled++;
        }
        int cells = clue[2] - clue[1] + 1;
        int remaining = cells - filled - 1;
        int minPossible = total + num + remaining;
        int maxPossible = total + num + 9 * remaining;
        if (minPossible > clue[3] || maxPossible < clue[3]) return false;
      }
    }

    return true;
  }
}
