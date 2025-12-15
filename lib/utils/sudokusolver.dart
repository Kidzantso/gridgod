// lib/utils/sudokusolver.dart

bool isSafe(
  List<List<int>> mat,
  int i,
  int j,
  int num,
  List<int> row,
  List<int> col,
  List<int> box,
) {
  int boxIndex = (i ~/ 3) * 3 + (j ~/ 3);
  if ((row[i] & (1 << num)) != 0 ||
      (col[j] & (1 << num)) != 0 ||
      (box[boxIndex] & (1 << num)) != 0) {
    return false;
  }
  return true;
}

bool sudokuSolverRec(
  List<List<int>> mat,
  int i,
  int j,
  List<int> row,
  List<int> col,
  List<int> box,
) {
  int n = mat.length;

  if (i == n - 1 && j == n) return true;
  if (j == n) {
    i++;
    j = 0;
  }

  if (mat[i][j] != 0) return sudokuSolverRec(mat, i, j + 1, row, col, box);

  for (int num = 1; num <= n; num++) {
    if (isSafe(mat, i, j, num, row, col, box)) {
      mat[i][j] = num;
      int boxIndex = (i ~/ 3) * 3 + (j ~/ 3);
      row[i] |= (1 << num);
      col[j] |= (1 << num);
      box[boxIndex] |= (1 << num);

      if (sudokuSolverRec(mat, i, j + 1, row, col, box)) return true;

      mat[i][j] = 0;
      row[i] &= ~(1 << num);
      col[j] &= ~(1 << num);
      box[boxIndex] &= ~(1 << num);
    }
  }

  return false;
}

void solveSudoku(List<List<int>> mat) {
  int n = mat.length;
  List<int> row = List.filled(n, 0);
  List<int> col = List.filled(n, 0);
  List<int> box = List.filled(n, 0);

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (mat[i][j] != 0) {
        int boxIndex = (i ~/ 3) * 3 + (j ~/ 3);
        row[i] |= (1 << mat[i][j]);
        col[j] |= (1 << mat[i][j]);
        box[boxIndex] |= (1 << mat[i][j]);
      }
    }
  }

  sudokuSolverRec(mat, 0, 0, row, col, box);
}
