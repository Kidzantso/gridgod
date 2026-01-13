// lib/screens/futoshiki_result.dart
import 'package:flutter/material.dart';

class FutoshikiResultScreen extends StatelessWidget {
  final List<List<int>> grid;
  final Map<String, int> hConstraints;
  final Map<String, int> vConstraints;

  const FutoshikiResultScreen({
    required this.grid,
    required this.hConstraints,
    required this.vConstraints,
  });

  @override
  Widget build(BuildContext context) {
    int size = grid.length;
    return Scaffold(
      appBar: AppBar(title: const Text("Futoshiki Solution")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(size * 2 - 1, (i) {
            if (i.isEven) {
              int row = i ~/ 2;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(size * 2 - 1, (j) {
                  if (j.isEven) {
                    int col = j ~/ 2;
                    return Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: const Color.fromARGB(138, 119, 105, 105),
                      ),
                      child: Center(
                        child: Text(
                          grid[row][col].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                    return Container(
                      width: 24,
                      height: 48,
                      margin: const EdgeInsets.all(2),
                      child: Center(
                        child: Text(
                          symbol,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  }
                }),
              );
            } else {
              int row = (i - 1) ~/ 2;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(size * 2 - 1, (j) {
                  if (j.isEven) {
                    int col = j ~/ 2;
                    String key = "$row,$col";
                    String symbol = '';
                    if (vConstraints[key] == 1)
                      symbol = '^';
                    else if (vConstraints[key] == 0)
                      symbol = 'v';
                    return Container(
                      width: 48,
                      height: 24,
                      margin: const EdgeInsets.all(2),
                      child: Center(
                        child: Text(
                          symbol,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox(width: 24, height: 24);
                  }
                }),
              );
            }
          }),
        ),
      ),
    );
  }
}
