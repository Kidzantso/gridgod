// lib/utils/hitori_solver.dart
enum CellState { unknown, assigned, eliminated }

class Cell {
  final int row;
  final int col;
  final int value;
  CellState state;

  Cell(this.row, this.col, this.value, {this.state = CellState.unknown});
}

class HitoriSolver {
  final int size;
  final List<List<Cell>> grid;
  int steps = 0;
  final int maxSteps = 100000;
  final Duration maxTime = Duration(seconds: 5);
  late DateTime startTime;

  HitoriSolver(this.grid) : size = grid.length;

  bool solve() {
    steps = 0;
    startTime = DateTime.now();
    return _backtrack(0, 0);
  }

  bool _backtrack(int r, int c) {
    steps++;
    if (steps > maxSteps) return false;
    if (DateTime.now().difference(startTime) > maxTime) return false;

    if (r == size) {
      return _noDuplicates() && _noAdjacentEliminated() && _isConnected();
    }

    int nextR = (c == size - 1) ? r + 1 : r;
    int nextC = (c == size - 1) ? 0 : c + 1;

    final cell = grid[r][c];
    if (cell.state != CellState.unknown) {
      return _backtrack(nextR, nextC);
    }

    // Try assigned
    cell.state = CellState.assigned;
    if (_noDuplicates() && _backtrack(nextR, nextC)) return true;

    // Try eliminated
    cell.state = CellState.eliminated;
    if (_noAdjacentEliminated() && _backtrack(nextR, nextC)) return true;

    cell.state = CellState.unknown;
    return false;
  }

  bool _noDuplicates() {
    // rows
    for (int r = 0; r < size; r++) {
      final seen = <int>{};
      for (int c = 0; c < size; c++) {
        final cell = grid[r][c];
        if (cell.state == CellState.assigned) {
          if (seen.contains(cell.value)) return false;
          seen.add(cell.value);
        }
      }
    }
    // cols
    for (int c = 0; c < size; c++) {
      final seen = <int>{};
      for (int r = 0; r < size; r++) {
        final cell = grid[r][c];
        if (cell.state == CellState.assigned) {
          if (seen.contains(cell.value)) return false;
          seen.add(cell.value);
        }
      }
    }
    return true;
  }

  bool _noAdjacentEliminated() {
    final dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    for (var row in grid) {
      for (var cell in row) {
        if (cell.state == CellState.eliminated) {
          for (var d in dirs) {
            int nr = cell.row + d[0], nc = cell.col + d[1];
            if (nr >= 0 && nc >= 0 && nr < size && nc < size) {
              if (grid[nr][nc].state == CellState.eliminated) return false;
            }
          }
        }
      }
    }
    return true;
  }

  bool _isConnected() {
    final visited = List.generate(size, (_) => List.filled(size, false));
    Cell? start;
    for (var row in grid) {
      for (var cell in row) {
        if (cell.state == CellState.assigned) {
          start = cell;
          break;
        }
      }
      if (start != null) break;
    }
    if (start == null) return true;

    final queue = <Cell>[start];
    visited[start.row][start.col] = true;
    final dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    while (queue.isNotEmpty) {
      final cur = queue.removeLast();
      for (var d in dirs) {
        int nr = cur.row + d[0], nc = cur.col + d[1];
        if (nr >= 0 && nc >= 0 && nr < size && nc < size) {
          final neigh = grid[nr][nc];
          if (neigh.state == CellState.assigned && !visited[nr][nc]) {
            visited[nr][nc] = true;
            queue.add(neigh);
          }
        }
      }
    }

    for (var row in grid) {
      for (var cell in row) {
        if (cell.state == CellState.assigned && !visited[cell.row][cell.col]) {
          return false;
        }
      }
    }
    return true;
  }
}
