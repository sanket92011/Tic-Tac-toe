import 'package:flutter/material.dart';
import 'package:tic_tac_toe/constants.dart';
import 'package:tic_tac_toe/screens/game_screen.dart';
import 'package:tic_tac_toe/widgets/input_box.dart';
import 'package:tic_tac_toe/widgets/start_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();
  final Constants _constants = Constants();

  @override
  void dispose() {
    player1Controller.dispose();
    player2Controller.dispose();
    super.dispose();
  }

  void startGame() {
    final player1 = player1Controller.text.trim();
    final player2 = player2Controller.text.trim();

    if (player1.isEmpty || player2.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter both player names!')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => GameScreen(
              player1: player1Controller.text,
              player2: player2Controller.text,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tic Tac Toe',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.white,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                InputBox(label: 'Player 1 Name', controller: player1Controller),
                const SizedBox(height: 25),
                InputBox(label: 'Player 2 Name', controller: player2Controller),
                const SizedBox(height: 50),
                StartButton(onTap: startGame),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
