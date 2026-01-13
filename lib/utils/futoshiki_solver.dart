// lib/utils/futoshiki_solver.dart
class FutoshikiSolver {
  final int size = 4;
  final List<List<int>> grid;
  final Map<String, int> hConstraints; // 1 = left > right, 0 = left < right
  final Map<String, int> vConstraints; // 1 = top > bottom, 0 = top < bottom

  FutoshikiSolver(this.grid, this.hConstraints, this.vConstraints);

  bool solve() {
    return _backtrack(0, 0);
  }

  bool _backtrack(int r, int c) {
    if (r == size) return _isCompleteAndValid();

    int nextR = (c == size - 1) ? r + 1 : r;
    int nextC = (c == size - 1) ? 0 : c + 1;

    if (grid[r][c] != 0) {
      return _backtrack(nextR, nextC);
    }

    for (int num = 1; num <= size; num++) {
      if (_isValid(r, c, num)) {
        grid[r][c] = num;
        if (_backtrack(nextR, nextC)) return true;
        grid[r][c] = 0;
      }
    }
    return false;
  }

  bool _isValid(int r, int c, int num) {
    // row uniqueness
    for (int j = 0; j < size; j++) {
      if (grid[r][j] == num) return false;
    }
    // col uniqueness
    for (int i = 0; i < size; i++) {
      if (grid[i][c] == num) return false;
    }

    // horizontal constraints
    String key = "$r,$c";
    if (hConstraints.containsKey(key)) {
      int ineq = hConstraints[key]!;
      if (c + 1 < size && grid[r][c + 1] != 0) {
        if (ineq == 1 && !(num > grid[r][c + 1])) return false;
        if (ineq == 0 && !(num < grid[r][c + 1])) return false;
      }
    }
    if (c - 1 >= 0) {
      String leftKey = "$r,${c - 1}";
      if (hConstraints.containsKey(leftKey)) {
        int ineq = hConstraints[leftKey]!;
        if (grid[r][c - 1] != 0) {
          if (ineq == 1 && !(grid[r][c - 1] > num)) return false;
          if (ineq == 0 && !(grid[r][c - 1] < num)) return false;
        }
      }
    }

    // vertical constraints
    if (vConstraints.containsKey(key)) {
      int ineq = vConstraints[key]!;
      if (r + 1 < size && grid[r + 1][c] != 0) {
        if (ineq == 1 && !(num > grid[r + 1][c])) return false;
        if (ineq == 0 && !(num < grid[r + 1][c])) return false;
      }
    }
    if (r - 1 >= 0) {
      String upKey = "${r - 1},$c";
      if (vConstraints.containsKey(upKey)) {
        int ineq = vConstraints[upKey]!;
        if (grid[r - 1][c] != 0) {
          if (ineq == 1 && !(grid[r - 1][c] > num)) return false;
          if (ineq == 0 && !(grid[r - 1][c] < num)) return false;
        }
      }
    }

    return true;
  }

  bool _isCompleteAndValid() {
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) return false;
      }
    }
    return true;
  }
}
