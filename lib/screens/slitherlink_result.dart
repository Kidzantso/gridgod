// lib/screens/slitherlink_result.dart
import 'package:flutter/material.dart';

class SlitherlinkResultScreen extends StatelessWidget {
  final List<List<int>> cells;
  final List<List<List<int>>> edges;

  const SlitherlinkResultScreen({required this.cells, required this.edges});

  @override
  Widget build(BuildContext context) {
    int size = cells.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Slitherlink Solution")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(size * 2 + 1, (i) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(size * 2 + 1, (j) {
                if (i.isEven && j.isEven) {
                  // Dot
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  );
                } else if (i.isEven && j.isOdd) {
                  // Horizontal edge
                  int r = i ~/ 2;
                  int c = j ~/ 2;
                  String symbol = '';
                  if (edges[r][c][0] == 1)
                    symbol = '─';
                  else if (edges[r][c][0] == -1)
                    symbol = 'x';
                  return SizedBox(
                    width: 24,
                    height: 12,
                    child: Center(
                      child: Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else if (i.isOdd && j.isEven) {
                  // Vertical edge
                  int r = i ~/ 2;
                  int c = j ~/ 2;
                  String symbol = '';
                  if (edges[r][c][3] == 1)
                    symbol = '│';
                  else if (edges[r][c][3] == -1)
                    symbol = 'x';
                  return SizedBox(
                    width: 12,
                    height: 24,
                    child: Center(
                      child: Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Cell with number
                  int r = i ~/ 2;
                  int c = j ~/ 2;
                  return Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: Text(
                      cells[r][c] == -1 ? '' : '${cells[r][c]}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
              }),
            );
          }),
        ),
      ),
    );
  }
}
