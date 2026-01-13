// lib/utils/sudoku_solver.dart

bool solveSudoku(List<List<int>> grid) {
  return _solve(grid, 0, 0);
}

bool _solve(List<List<int>> grid, int row, int col) {
  if (row == 9) return true;

  int nextRow = (col == 8) ? row + 1 : row;
  int nextCol = (col == 8) ? 0 : col + 1;

  if (grid[row][col] != 0) {
    return _solve(grid, nextRow, nextCol);
  }

  for (int num = 1; num <= 9; num++) {
    if (_isValid(grid, row, col, num)) {
      grid[row][col] = num;
      if (_solve(grid, nextRow, nextCol)) return true;
      grid[row][col] = 0;
    }
  }
  return false;
}

bool _isValid(List<List<int>> grid, int row, int col, int num) {
  for (int i = 0; i < 9; i++) {
    if (grid[row][i] == num || grid[i][col] == num) return false;
  }
  int startRow = row - row % 3;
  int startCol = col - col % 3;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (grid[startRow + i][startCol + j] == num) return false;
    }
  }
  return true;
}

/// Quick validation before solving: checks for duplicates in rows, cols, blocks
bool isValidSudokuGrid(List<List<int>> grid) {
  // rows
  for (int r = 0; r < 9; r++) {
    final seen = <int>{};
    for (int c = 0; c < 9; c++) {
      int val = grid[r][c];
      if (val != 0) {
        if (seen.contains(val)) return false;
        seen.add(val);
      }
    }
  }
  // cols
  for (int c = 0; c < 9; c++) {
    final seen = <int>{};
    for (int r = 0; r < 9; r++) {
      int val = grid[r][c];
      if (val != 0) {
        if (seen.contains(val)) return false;
        seen.add(val);
      }
    }
  }
  // blocks
  for (int br = 0; br < 9; br += 3) {
    for (int bc = 0; bc < 9; bc += 3) {
      final seen = <int>{};
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          int val = grid[br + r][bc + c];
          if (val != 0) {
            if (seen.contains(val)) return false;
            seen.add(val);
          }
        }
      }
    }
  }
  return true;
}
