import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.player1, required this.player2});

  final String player1;
  final String player2;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  final Constants _constants = Constants();
  int timerSeconds = 30;
  Timer? _timer;
  bool gameOver = false;
  int? winStartIndex, winEndIndex;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.greenAccent,
    ).animate(_controller);
  }

  void _startTimer() {
    _timer?.cancel();
    timerSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!gameOver && timerSeconds > 0) {
        setState(() {
          timerSeconds--;
        });
      } else if (timerSeconds == 0 && !gameOver) {
        _timer?.cancel();
        _showResultDialog("Time's Up!");
      }
    });
  }

  void _switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });
  }

  void _onTap(int index) {
    if (board[index] != '' || gameOver) return;

    setState(() {
      board[index] = currentPlayer;
    });

    if (_checkWin(currentPlayer)) {
      gameOver = true;
      _timer?.cancel();
      _showResultDialog("$currentPlayer Wins!");
    } else if (!board.contains('')) {
      gameOver = true;
      _timer?.cancel();
      _showResultDialog("It's a Draw!");
    } else {
      _switchPlayer();
    }
  }

  bool _checkWin(String player) {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var pattern in winPatterns) {
      if (board[pattern[0]] == player &&
          board[pattern[1]] == player &&
          board[pattern[2]] == player) {
        winStartIndex = pattern[0];
        winEndIndex = pattern[2];
        return true;
      }
    }
    return false;
  }

  void _showResultDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: Text(msg, style: const TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetGame();
                },
                child: const Text(
                  "Play Again",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      timerSeconds = 30;
      gameOver = false;
      winStartIndex = null;
      winEndIndex = null;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool _isWinningCell(int index) {
    if (winStartIndex == null || winEndIndex == null) return false;
    List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var combo in winningCombinations) {
      if (combo[0] == winStartIndex &&
          combo[2] == winEndIndex &&
          combo.contains(index)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPlayerContainer(
                      widget.player1,
                      currentPlayer == 'X',
                      Colors.cyanAccent,
                    ),
                    Text(
                      "Turn: $currentPlayer",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    _buildPlayerContainer(
                      widget.player2,
                      currentPlayer == 'O',
                      Colors.orangeAccent,
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    bool isWinCell = _isWinningCell(index);
                    return GestureDetector(
                      onTap: () => _onTap(index),
                      child: Card(
                        color:
                            isWinCell
                                ? _colorAnimation.value ?? Colors.greenAccent
                                : const Color(0xFF0F3460),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        child: Center(
                          child: Text(
                            board[index],
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color:
                                  board[index] == 'X'
                                      ? Colors.cyanAccent
                                      : Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Timer: 00:${timerSeconds.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.restart_alt, color: Colors.black),
                    label: const Text(
                      "Restart",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildPlayerContainer(
    String name,
    bool isActive,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isActive
                ? borderColor.withOpacity(0.3)
                : borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: borderColor,
        ),
      ),
    );
  }
}
