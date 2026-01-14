// lib/utils/slitherlink_solver.dart
class SlitherlinkSolver {
  final int size;
  final List<List<int>> cells; // -1 empty, else 0..3
  late List<List<List<int>>>
  edges; // [row][col][4] : right(0), up(1), left(2), down(3)

  // Directions: right, up, left, down
  final List<int> dr = [0, -1, 0, 1];
  final List<int> dc = [1, 0, -1, 0];

  // Stack for reversible operations
  late List<List<int>> stack; // entries: [row, col, edge]
  int curStackSize = 0;

  // Counters (optional for debugging)
  int counter = 0;
  int counterl = 0;

  SlitherlinkSolver(this.cells) : size = cells.length {
    edges = List.generate(
      size + 1,
      (_) => List.generate(size + 1, (_) => List.filled(4, 0)),
    );

    // Initialize borders as invalid (-1)
    for (int row = 0; row <= size; row++) {
      edges[row][0][2] = -1; // left border
      edges[row][size][0] = -1; // right border
    }
    for (int col = 0; col <= size; col++) {
      edges[0][col][1] = -1; // top border
      edges[size][col][3] = -1; // bottom border
    }

    // Initialize stack with max possible size
    stack = List.generate(2 * size * size + size + size, (_) => [-1, -1, -1]);
  }

  // Public entry
  bool solve() {
    fillZeros();
    solveCorners();
    preconditionBoard();
    return backtracking();
  }

  // ---------- Rendering helpers (optional) ----------
  // edges[r][c][e] == 1 => line, -1 => cross, 0 => undecided

  // ---------- Core checks ----------
  bool cellsSatisfied() {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (cells[row][col] == -1) continue;
        int numLine = 0;
        // cell edges: (row,col,0),(row,col,3),(row+1,col+1,1),(row+1,col+1,2)
        if (edges[row][col][0] == 1) numLine++;
        if (edges[row][col][3] == 1) numLine++;
        if (edges[row + 1][col + 1][1] == 1) numLine++;
        if (edges[row + 1][col + 1][2] == 1) numLine++;
        if (numLine != cells[row][col]) return false;
      }
    }
    return true;
  }

  bool countFillings(int row, int col) {
    if (row < 0 || col < 0 || row >= size || col >= size) return true;
    if (cells[row][col] == -1) return true;

    int numLine = 0;
    int numCross = 0;
    // left/right edges at (row,col)
    for (final i in [0, 3]) {
      if (edges[row][col][i] == 1)
        numLine++;
      else if (edges[row][col][i] == -1)
        numCross++;
    }
    // up/left edges at (row+1,col+1)
    for (final i in [1, 2]) {
      if (edges[row + 1][col + 1][i] == 1)
        numLine++;
      else if (edges[row + 1][col + 1][i] == -1)
        numCross++;
    }
    return !(numLine > cells[row][col] || numCross > (4 - cells[row][col]));
  }

  bool checkBoard(int row, int col, int edge) {
    // Vertex-wise contradictions at (row,col)
    int numLine = 0, numCross = 0;
    for (int e_ = 0; e_ < 4; e_++) {
      if (edges[row][col][e_] == 1)
        numLine++;
      else if (edges[row][col][e_] == -1)
        numCross++;
    }
    if (numLine > 2) return false;
    if (numLine == 1 && numCross == 3) return false;

    // Vertex-wise contradictions at neighbor
    int nr = row + dr[edge], nc = col + dc[edge];
    numLine = 0;
    numCross = 0;
    for (int e_ = 0; e_ < 4; e_++) {
      if (edges[nr][nc][e_] == 1)
        numLine++;
      else if (edges[nr][nc][e_] == -1)
        numCross++;
    }
    if (numLine > 2) return false;
    if (numLine == 1 && numCross == 3) return false;

    // Cell-wise contradictions
    if (edge == 0 || edge == 1) {
      if (!countFillings(row - 1, col)) return false;
    }
    if (edge == 1 || edge == 2) {
      if (!countFillings(row - 1, col - 1)) return false;
    }
    if (edge == 2 || edge == 3) {
      if (!countFillings(row, col - 1)) return false;
    }
    if (edge == 3 || edge == 0) {
      if (!countFillings(row, col)) return false;
    }

    // Board-wise contradictions: loop closure check
    if (edges[row][col][edge] == -1) return true;

    // Walk the loop from current segment
    int d = -1;
    for (int i = 0; i < 5; i++) {
      if (i == 4) return true;
      if (i == edge) continue;
      if (edges[row][col][i] == 1) {
        d = i;
        break;
      }
    }
    int prevD = (d + 2) % 4;
    int curRow = row + dr[d], curCol = col + dc[d];
    int loopLen = 2;

    while (true) {
      int nextD = -1;
      for (int i = 0; i < 5; i++) {
        if (i == 4) return true;
        if (i == prevD) continue;
        if (edges[curRow][curCol][i] == 1) {
          nextD = i;
          break;
        }
      }
      prevD = (nextD + 2) % 4;
      curRow += dr[nextD];
      curCol += dc[nextD];
      if (curRow == row && curCol == col) break;
      loopLen++;
    }

    int totalLines = 0;
    for (int r = 0; r <= size; r++) {
      for (int c = 0; c <= size; c++) {
        for (final e in [0, 3]) {
          if (edges[r][c][e] == 1) totalLines++;
        }
      }
    }
    if (loopLen < totalLines) return false;
    return cellsSatisfied();
  }

  bool fillEdge(int row, int col, int edge, int state) {
    // conflict
    if (edges[row][col][edge] == -state) return false;
    // already same
    if (edges[row][col][edge] == state) return true;

    // set both vertices
    edges[row][col][edge] = state;
    int nr = row + dr[edge], nc = col + dc[edge], opp = (edge + 2) % 4;
    edges[nr][nc][opp] = state;

    // push to stack
    stack[curStackSize] = [row, col, edge];
    curStackSize++;

    return checkBoard(row, col, edge);
  }

  void revert(int k) {
    for (int entry = k; entry < curStackSize; entry++) {
      final r = stack[entry][0], c = stack[entry][1], e = stack[entry][2];
      edges[r][c][e] = 0;
      int nr = r + dr[e], nc = c + dc[e], opp = (e + 2) % 4;
      edges[nr][nc][opp] = 0;
      stack[entry] = [-1, -1, -1];
    }
    curStackSize = k;
  }

  // ---------- Preconditioning ----------
  void solveCorners() {
    // Python logic uses r=[-1,-1,0,0], c=[0,-1,-1,0] indexing trick
    final r = [-1, -1, 0, 0];
    final c = [0, -1, -1, 0];
    for (int i = 0; i < 4; i++) {
      final cellVal = _cellAt(r[i], c[i]);
      if (cellVal == 1) {
        solveLogically(r[i], c[i], i, -1);
        solveLogically(r[i] + dr[i], c[i] + dc[i], (i + 2) % 4, -1);
        solveLogically(r[i], c[i], (i + 1) % 4, -1);
        solveLogically(
          r[i] + dr[(i + 1) % 4],
          c[i] + dc[(i + 1) % 4],
          (i + 3) % 4,
          -1,
        );
      } else if (cellVal == 2) {
        solveLogically(r[i] + dr[i], c[i] + dc[i], i, 1);
        solveLogically(r[i] + 2 * dr[i], c[i] + 2 * dc[i], (i + 2) % 4, 1);
        solveLogically(
          r[i] + dr[(i + 1) % 4],
          c[i] + dc[(i + 1) % 4],
          (i + 1) % 4,
          1,
        );
        solveLogically(
          r[i] + 2 * dr[(i + 1) % 4],
          c[i] + 2 * dc[(i + 1) % 4],
          (i + 3) % 4,
          1,
        );
      } else if (cellVal == 3) {
        solveLogically(r[i], c[i], i, 1);
        solveLogically(r[i] + dr[i], c[i] + dc[i], (i + 2) % 4, 1);
        solveLogically(r[i], c[i], (i + 1) % 4, 1);
        solveLogically(
          r[i] + dr[(i + 1) % 4],
          c[i] + dc[(i + 1) % 4],
          (i + 3) % 4,
          1,
        );
      }
    }
  }

  void fillZeros() {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (cells[row][col] != 0) continue;
        solveLogically(row, col, 0, -1);
        solveLogically(row, col, 3, -1);
        solveLogically(row + 1, col, 0, -1);
        solveLogically(row + 1, col, 1, -1);
        solveLogically(row, col + 1, 2, -1);
        solveLogically(row, col + 1, 3, -1);
        solveLogically(row + 1, col + 1, 1, -1);
        edges[row + 1][col + 1][2] = -1;
      }
    }
  }

  void preconditionBoard() {
    // Port of Python pattern preconditioning for adjacent 3s
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (cells[row][col] != 3) continue;

        // Adjacent 3s in cardinal directions
        for (int d = 0; d < 4; d++) {
          int r = row + dr[d], c = col + dc[d];
          if (!_inBoundsCell(r, c)) continue;
          if (cells[r][c] == 3) {
            int dir1 = 3 * ((d + 1) % 2);
            int dir2 = d % 2;
            int r_, c_;
            if (d == 0) {
              r_ = row;
              c_ = col + 1;
            } else if (d == 1) {
              r_ = row;
              c_ = col;
            } else if (d == 2) {
              r_ = row;
              c_ = col;
            } else {
              r_ = row + 1;
              c_ = col;
            }
            solveLogically(r_, c_, dir1, 1);
            solveLogically(r_ - dr[dir2], c_ - dc[dir2], dir1, 1);
            solveLogically(r_ + dr[dir2], c_ + dc[dir2], dir1, 1);
            if (edges[r_ - dr[dir1]][c_ - dc[dir1]][dir1] == 0) {
              solveLogically(r_ - dr[dir1], c_ - dc[dir1], dir1, -1);
            }
            if (edges[r_ + dr[dir1]][c_ + dc[dir1]][dir1] == 0) {
              solveLogically(r_ + dr[dir1], c_ + dc[dir1], dir1, -1);
            }
            break;
          }
        }

        // Diagonal 3s patterns
        final diag = [
          [0, 1, 1],
          [1, -1, 1],
          [2, -1, -1],
          [3, 1, -1],
        ];
        for (final d in diag) {
          int k = d[0], r_ = d[1], c_ = d[2];
          int r = row + r_, c = col + c_;
          if (!_inBoundsCell(r, c)) continue;
          if (cells[r][c] == 3) {
            int r1 = row, c1 = col;
            int r2 = r, c2 = c;
            if (c_ > 0)
              c2 += 1;
            else
              c1 += 1;
            if (r_ > 0)
              r2 += 1;
            else
              r1 += 1;

            solveLogically(r1, c1, (k - 1) % 4, 1);
            solveLogically(r1, c1, k, 1);
            solveLogically(r2, c2, (k + 1) % 4, 1);
            solveLogically(r2, c2, (k + 2) % 4, 1);

            if (edges[r1][c1][(k + 1) % 4] == 0) {
              solveLogically(r1, c1, (k + 1) % 4, -1);
            }
            if (edges[r1][c1][(k + 2) % 4] == 0) {
              solveLogically(r1, c1, (k + 2) % 4, -1);
            }
            if (edges[r2][c2][(k - 1) % 4] == 0) {
              solveLogically(r2, c2, (k - 1) % 4, -1);
            }
            if (edges[r2][c2][k] == 0) {
              solveLogically(r2, c2, k, -1);
            }
            break;
          }
        }
      }
    }

    // Clear stack entries (Python clears values but keeps size)
    for (int k = 0; k < curStackSize; k++) {
      stack[k] = [-1, -1, -1];
    }
  }

  // ---------- Logical rules ----------
  bool cellLogic(int row, int col, int state) {
    if (!_inBoundsCell(row, col)) return true;
    if (cells[row][col] == -1) return true;

    int numMatch = 0;
    final edgesList = [
      [row, col, 0],
      [row, col, 3],
      [row + 1, col + 1, 1],
      [row + 1, col + 1, 2],
    ];
    for (final e in edgesList) {
      if (edges[e[0]][e[1]][e[2]] == state) numMatch++;
    }

    if (state == 1) {
      if (numMatch == cells[row][col]) {
        for (final e in edgesList) {
          if (edges[e[0]][e[1]][e[2]] == 0) {
            if (!solveLogically(e[0], e[1], e[2], -1)) return false;
          }
        }
      }
    } else {
      if (numMatch == 4 - cells[row][col]) {
        for (final e in edgesList) {
          if (edges[e[0]][e[1]][e[2]] == 0) {
            if (!solveLogically(e[0], e[1], e[2], 1)) return false;
          }
        }
      }
    }
    return true;
  }

  bool threeLogic(int r, int c, int e) {
    // Port of Python three_logic with bounds checks
    if (e == 0 || e == 1) {
      if (_inBoundsCell(r, c - 1) && cells[r][c - 1] == 3) {
        if (edges[r + 1][c - 1][0] != 1) {
          if (!solveLogically(r + 1, c - 1, 0, 1)) return false;
        }
        if (edges[r + 1][c - 1][1] != 1) {
          if (!solveLogically(r + 1, c - 1, 1, 1)) return false;
        }
        if (e == 0 && edges[r][c][1] != -1) {
          if (!solveLogically(r, c, 1, -1)) return false;
        } else if (e == 1 && edges[r][c][0] != -1) {
          if (!solveLogically(r, c, 0, -1)) return false;
        }
      }
    }
    if (e == 1 || e == 2) {
      if (_inBoundsCell(r, c) && cells[r][c] == 3) {
        if (edges[r + 1][c + 1][1] != 1) {
          if (!solveLogically(r + 1, c + 1, 1, 1)) return false;
        }
        if (edges[r + 1][c + 1][2] != 1) {
          if (!solveLogically(r + 1, c + 1, 2, 1)) return false;
        }
        if (e == 1 && edges[r][c][2] != -1) {
          if (!solveLogically(r, c, 2, -1)) return false;
        } else if (e == 2 && edges[r][c][1] != -1) {
          if (!solveLogically(r, c, 1, -1)) return false;
        }
      }
    }
    if (e == 2 || e == 3) {
      if (_inBoundsCell(r - 1, c) && cells[r - 1][c] == 3) {
        if (edges[r - 1][c + 1][2] != 1) {
          if (!solveLogically(r - 1, c + 1, 2, 1)) return false;
        }
        if (edges[r - 1][c + 1][3] != 1) {
          if (!solveLogically(r - 1, c + 1, 3, 1)) return false;
        }
        if (e == 2 && edges[r][c][3] != -1) {
          if (!solveLogically(r, c, 3, -1)) return false;
        } else if (e == 3 && edges[r][c][2] != -1) {
          if (!solveLogically(r, c, 2, -1)) return false;
        }
      }
    }
    if (e == 3 || e == 0) {
      if (_inBoundsCell(r - 1, c - 1) && cells[r - 1][c - 1] == 3) {
        if (edges[r - 1][c - 1][0] != 1) {
          if (!solveLogically(r - 1, c - 1, 0, 1)) return false;
        }
        if (edges[r - 1][c - 1][3] != 1) {
          if (!solveLogically(r - 1, c - 1, 3, 1)) return false;
        }
        if (e == 0 && edges[r][c][3] != -1) {
          if (!solveLogically(r, c, 3, -1)) return false;
        } else if (e == 3 && edges[r][c][0] != -1) {
          if (!solveLogically(r, c, 0, -1)) return false;
        }
      }
    }
    return true;
  }

  bool twoLogic(int r, int c, int e) {
    // Port of Python two_logic with bounds checks
    bool b;
    if (e == 0 || e == 1) {
      if (_inBoundsCell(r, c - 1) && cells[r][c - 1] == 2) {
        b = false;
        if (edges[r + 1][c - 1][1] == -1 && edges[r + 1][c - 1][0] != 1) {
          if (!solveLogically(r + 1, c - 1, 0, 1)) return false;
          b = true;
        }
        if (edges[r + 1][c - 1][0] == -1 && edges[r + 1][c - 1][1] != 1) {
          if (!solveLogically(r + 1, c - 1, 1, 1)) return false;
          b = true;
        }
        if (b) {
          if (e == 0 && edges[r][c][1] != -1) {
            if (!solveLogically(r, c, 1, -1)) return false;
          } else if (e == 1 && edges[r][c][0] != -1) {
            if (!solveLogically(r, c, 0, -1)) return false;
          }
        }
      }
    }
    if (e == 1 || e == 2) {
      if (_inBoundsCell(r, c) && cells[r][c] == 2) {
        b = false;
        if (edges[r + 1][c + 1][2] == -1 && edges[r + 1][c + 1][1] != 1) {
          if (!solveLogically(r + 1, c + 1, 1, 1)) return false;
          b = true;
        }
        if (edges[r + 1][c + 1][1] == -1 && edges[r + 1][c + 1][2] != 1) {
          if (!solveLogically(r + 1, c + 1, 2, 1)) return false;
          b = true;
        }
        if (b) {
          if (e == 1 && edges[r][c][2] != -1) {
            if (!solveLogically(r, c, 2, -1)) return false;
          } else if (e == 2 && edges[r][c][1] != -1) {
            if (!solveLogically(r, c, 1, -1)) return false;
          }
        }
      }
    }
    if (e == 2 || e == 3) {
      if (_inBoundsCell(r - 1, c) && cells[r - 1][c] == 2) {
        b = false;
        if (edges[r - 1][c + 1][3] == -1 && edges[r - 1][c + 1][2] != 1) {
          if (!solveLogically(r - 1, c + 1, 2, 1)) return false;
          b = true;
        }
        if (edges[r - 1][c + 1][2] == -1 && edges[r - 1][c + 1][3] != 1) {
          if (!solveLogically(r - 1, c + 1, 3, 1)) return false;
          b = true;
        }
        if (b) {
          if (e == 2 && edges[r][c][3] != -1) {
            if (!solveLogically(r, c, 3, -1)) return false;
          } else if (e == 3 && edges[r][c][2] != -1) {
            if (!solveLogically(r, c, 2, -1)) return false;
          }
        }
      }
    }
    if (e == 3 || e == 0) {
      if (_inBoundsCell(r - 1, c - 1) && cells[r - 1][c - 1] == 2) {
        b = false;
        if (edges[r - 1][c - 1][3] == -1 && edges[r - 1][c - 1][0] != 1) {
          if (!solveLogically(r - 1, c - 1, 0, 1)) return false;
          b = true;
        }
        if (edges[r - 1][c - 1][0] == -1 && edges[r - 1][c - 1][3] != 1) {
          if (!solveLogically(r - 1, c - 1, 3, 1)) return false;
          b = true;
        }
        if (b) {
          if (e == 0 && edges[r][c][3] != -1) {
            if (!solveLogically(r, c, 3, -1)) return false;
          } else if (e == 3 && edges[r][c][0] != -1) {
            if (!solveLogically(r, c, 0, -1)) return false;
          }
        }
      }
    }
    return true;
  }

  bool oneLogic(int r, int c, int edge1, int edge2) {
    int e1 = edge1, e2 = edge2;
    if (e1 > e2) {
      final t = e1;
      e1 = e2;
      e2 = t;
    }
    if (e1 == 0 && e2 == 1) {
      if (_inBoundsCell(r, c - 1) && cells[r][c - 1] == 1) {
        if (edges[r + 1][c - 1][e1] != -1) {
          if (!solveLogically(r + 1, c - 1, e1, -1)) return false;
        }
        if (edges[r + 1][c - 1][e2] != -1) {
          if (!solveLogically(r + 1, c - 1, e2, -1)) return false;
        }
      }
    } else if (e1 == 1 && e2 == 2) {
      if (_inBoundsCell(r, c) && cells[r][c] == 1) {
        if (edges[r + 1][c + 1][e1] != -1) {
          if (!solveLogically(r + 1, c + 1, e1, -1)) return false;
        }
        if (edges[r + 1][c + 1][e2] != -1) {
          if (!solveLogically(r + 1, c + 1, e2, -1)) return false;
        }
      }
    } else if (e1 == 2 && e2 == 3) {
      if (_inBoundsCell(r - 1, c) && cells[r - 1][c] == 1) {
        if (edges[r - 1][c + 1][e1] != -1) {
          if (!solveLogically(r - 1, c + 1, e1, -1)) return false;
        }
        if (edges[r - 1][c + 1][e2] != -1) {
          if (!solveLogically(r - 1, c + 1, e2, -1)) return false;
        }
      }
    } else {
      if (_inBoundsCell(r - 1, c - 1) && cells[r - 1][c - 1] == 1) {
        if (edges[r - 1][c - 1][e1] != -1) {
          if (!solveLogically(r - 1, c - 1, e1, -1)) return false;
        }
        if (edges[r - 1][c - 1][e2] != -1) {
          if (!solveLogically(r - 1, c - 1, e2, -1)) return false;
        }
      }
    }
    return true;
  }

  bool solveLogically(int row, int col, int edge, int state) {
    counterl++;
    if (!fillEdge(row, col, edge, state)) return false;

    // Vertex-wise logic
    if (state == 1) {
      // at (row,col)
      int numLine = 0, numCross = 0;
      for (int e_ = 0; e_ < 4; e_++) {
        if (edges[row][col][e_] == 1) {
          numLine++;
          if (numLine == 2) {
            for (int e = 0; e < 4; e++) {
              if (edges[row][col][e] == 0) {
                if (!solveLogically(row, col, e, -1)) return false;
              }
            }
            break;
          }
        } else if (edges[row][col][e_] == -1) {
          numCross++;
          if (numCross == 2) {
            for (int e = 0; e < 4; e++) {
              if (edges[row][col][e] == 0) {
                if (!solveLogically(row, col, e, 1)) return false;
              }
            }
            break;
          }
        }
      }
      // at neighbor
      int nr = row + dr[edge], nc = col + dc[edge];
      numLine = 0;
      numCross = 0;
      for (int e_ = 0; e_ < 4; e_++) {
        if (edges[nr][nc][e_] == 1) {
          numLine++;
          if (numLine == 2) {
            for (int e = 0; e < 4; e++) {
              if (edges[nr][nc][e] == 0) {
                if (!solveLogically(nr, nc, e, -1)) return false;
              }
            }
            break;
          }
        } else if (edges[nr][nc][e_] == -1) {
          numCross++;
          if (numCross == 2) {
            for (int e = 0; e < 4; e++) {
              if (edges[nr][nc][e] == 0) {
                if (!solveLogically(nr, nc, e, 1)) return false;
              }
            }
            break;
          }
        }
      }
    } else {
      // state == -1
      int numLine = 0, numCross = 0;
      for (int e_ = 0; e_ < 4; e_++) {
        if (edges[row][col][e_] == -1) {
          numCross++;
          if (numCross == 3) {
            for (int e = 0; e < 4; e++) {
              if (edges[row][col][e] != -1) {
                if (!solveLogically(row, col, e, -1)) return false;
              }
            }
          }
        }
        if (edges[row][col][e_] == 1) numLine++;
        if (numCross == 2 && numLine == 1) {
          for (int e = 0; e < 4; e++) {
            if (edges[row][col][e] == 0) {
              if (!solveLogically(row, col, e, 1)) return false;
            }
          }
        }
      }
      int nr = row + dr[edge], nc = col + dc[edge];
      numLine = 0;
      numCross = 0;
      for (int e_ = 0; e_ < 4; e_++) {
        if (edges[nr][nc][e_] == -1) {
          numCross++;
          if (numCross == 3) {
            for (int e = 0; e < 4; e++) {
              if (edges[nr][nc][e] != -1) {
                if (!solveLogically(nr, nc, e, -1)) return false;
              }
            }
          }
        }
        if (edges[nr][nc][e_] == 1) numLine++;
        if (numCross == 2 && numLine == 1) {
          for (int e = 0; e < 4; e++) {
            if (edges[nr][nc][e] == 0) {
              if (!solveLogically(nr, nc, e, 1)) return false;
            }
          }
        }
      }
    }

    // Cell-wise logic
    if (edge == 0 || edge == 1) {
      if (!cellLogic(row - 1, col, state)) return false;
    }
    if (edge == 1 || edge == 2) {
      if (!cellLogic(row - 1, col - 1, state)) return false;
    }
    if (edge == 2 || edge == 3) {
      if (!cellLogic(row, col - 1, state)) return false;
    }
    if (edge == 3 || edge == 0) {
      if (!cellLogic(row, col, state)) return false;
    }

    // Pattern-wise logic: adjacent crosses around a cell
    if (state == -1 && edges[row][col][(edge + 1) % 4] == -1) {
      int r = row - edge ~/ 2, c = col - ((edge - 1) % 4) ~/ 2;
      if (_inBoundsCell(r, c)) {
        if (cells[r][c] == 1 && edges[row][col][(edge + 2) % 4] != -1) {
          if (!solveLogically(row, col, (edge + 2) % 4, -1)) return false;
        } else if (cells[r][c] == 3 && edges[row][col][(edge + 2) % 4] != 1) {
          if (!solveLogically(row, col, (edge + 2) % 4, 1)) return false;
        }
      }
    }
    if (state == -1 && edges[row][col][(edge - 1) % 4] == -1) {
      int r = row - ((edge - 1) % 4) ~/ 2, c = col - ((edge - 2) % 4) ~/ 2;
      if (_inBoundsCell(r, c)) {
        if (cells[r][c] == 1 && edges[row][col][(edge + 2) % 4] != -1) {
          if (!solveLogically(row, col, (edge + 2) % 4, -1)) return false;
        } else if (cells[r][c] == 3 && edges[row][col][(edge + 2) % 4] != 1) {
          if (!solveLogically(row, col, (edge + 2) % 4, 1)) return false;
        }
      }
    }

    // Rules for cells with 3 if there is a line pointing in
    if (state == 1) {
      if (!threeLogic(row, col, edge)) return false;
      if (!threeLogic(row + dr[edge], col + dc[edge], (edge + 2) % 4))
        return false;
    }

    // Rules for cells with 1 if there are a line and a cross pointing in
    if (state == 1) {
      if (edges[row][col][(edge + 1) % 4] == -1) {
        if (!oneLogic(row, col, edge, (edge + 1) % 4)) return false;
      }
      if (edges[row][col][(edge - 1) % 4] == -1) {
        if (!oneLogic(row, col, edge, (edge - 1) % 4)) return false;
      }
      int nr = row + dr[edge], nc = col + dc[edge];
      if (edges[nr][nc][(edge + 3) % 4] == -1) {
        if (!oneLogic(nr, nc, (edge + 2) % 4, (edge + 3) % 4)) return false;
      }
      if (edges[nr][nc][(edge + 1) % 4] == -1) {
        if (!oneLogic(row, col, (edge + 2) % 4, (edge + 1) % 4)) return false;
      }
    } else {
      // For crosses, mirror one_logic if a line is present
      if (edges[row][col][(edge + 1) % 4] == 1) {
        if (!oneLogic(row, col, edge, (edge + 1) % 4)) return false;
      }
      if (edges[row][col][(edge - 1) % 4] == 1) {
        if (!oneLogic(row, col, edge, (edge - 1) % 4)) return false;
      }
    }

    // Rules for cells with 2 with a line pointing in opposite to a cross
    if (state == 1) {
      if (!twoLogic(row, col, edge)) return false;
      if (!twoLogic(row + dr[edge], col + dc[edge], (edge + 2) % 4))
        return false;
    }

    return true;
  }

  // ---------- Backtracking ----------
  List<int>? findNextOpen() {
    for (int r = 0; r <= size; r++) {
      for (int c = 0; c <= size; c++) {
        for (final e in [0, 3]) {
          if (edges[r][c][e] == 0) return [r, c, e];
        }
      }
    }
    return null;
  }

  bool backtracking() {
    counter++;
    final stackLen = curStackSize;

    final next = findNextOpen();
    if (next == null) {
      // all edges decided—final check
      return cellsSatisfied();
    }

    final row = next[0], col = next[1], edge = next[2];

    if (!solveLogically(row, col, edge, 1)) {
      revert(stackLen);
      if (!solveLogically(row, col, edge, -1)) return false;
      return backtracking();
    } else {
      if (!backtracking()) {
        revert(stackLen);
        if (!solveLogically(row, col, edge, -1)) return false;
        return backtracking();
      }
    }
    return true;
  }

  // ---------- Utilities ----------
  bool _inBoundsCell(int r, int c) => r >= 0 && c >= 0 && r < size && c < size;

  int _cellAt(int r, int c) {
    if (!_inBoundsCell(r, c)) return -1;
    return cells[r][c];
  }
}
