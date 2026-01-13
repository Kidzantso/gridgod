import 'package:flutter/material.dart';
import 'sudoku_input.dart';
import 'kakuro_input.dart';
import 'hitori_input.dart';
import 'futoshiki_input.dart';

class HomeScreen extends StatelessWidget {
  final List<_GameCard> games = [
    _GameCard(
      title: 'Sudoku',
      image: 'assets/images/sudoku_logo.png',
      builder: (_) => SudokuInputScreen(),
    ),
    _GameCard(
      title: 'Kakuro',
      image: 'assets/images/kakuro-logo.png',
      builder: (_) => KakuroInputScreen(),
    ),
    _GameCard(
      title: 'Hitori',
      image: 'assets/images/hitori_logo.png',
      builder: (_) => HitoriInputScreen(),
    ),
    _GameCard(
      title: 'Futoshiki',
      image: 'assets/images/futoshiki-logo.png',
      builder: (_) => FutoshikiInputScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GridGod')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: games.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1, // square cards
          ),
          itemBuilder: (context, index) {
            final game = games[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: game.builder),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(game.image, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GameCard {
  final String title;
  final String image;
  final WidgetBuilder builder;

  _GameCard({required this.title, required this.image, required this.builder});
}
