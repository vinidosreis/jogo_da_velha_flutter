import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jogo_da_velha/components/colors.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isPlayerOTurn = true;
  bool matchOver = false;
  int playerOScore = 0;
  int playerXScore = 0;
  int filledBoxes = 0;
  int attempts = 0;
  String gameResult = '';
  List<String> cellValues = ['', '', '', '', '', '', '', '', ''];
  List<int> matchedIndexes = [];

  Timer? timer;
  static const maxSeconds = 20;
  int seconds = maxSeconds;

  TextStyle customFontWhite = GoogleFonts.coiny(
    textStyle: const TextStyle(
      color: Colors.white,
      letterSpacing: 3,
      fontSize: 28,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColor.primaryColor,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(flex: 1, child: _buildScoreView()),
              Expanded(flex: 3, child: _buildGameGrid()),
              Expanded(flex: 2, child: _buildResultView()),
            ],
          ),
        ));
  }

  Row _buildScoreView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Player O',
              style: customFontWhite,
            ),
            Text(
              playerOScore.toString(),
              style: customFontWhite,
            ),
          ],
        ),
        const SizedBox(width: 30),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Player X',
              style: customFontWhite,
            ),
            Text(
              playerXScore.toString(),
              style: customFontWhite,
            ),
          ],
        )
      ],
    );
  }

  GridTile _buildGameGrid() {
    return GridTile(
        child: GridView.builder(
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: ((context, index) {
              return GestureDetector(
                onTap: () {
                  _tapped(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border:
                        Border.all(width: 5, color: CustomColor.primaryColor),
                    color: matchedIndexes.contains(index)
                        ? CustomColor.accentColor
                        : CustomColor.secondaryColor,
                  ),
                  child: Center(
                    child: Text(
                      cellValues[index],
                      style: customFontWhite,
                    ),
                  ),
                ),
              );
            })));
  }

  Center _buildResultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            gameResult,
            style: customFontWhite,
          ),
          const SizedBox(
            height: 10,
          ),
          _buildTimer()
        ],
      ),
    );
  }

  Widget _buildTimer() {
    final isRunning = timer == null ? false : timer?.isActive ?? true;

    return isRunning
        ? SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1 - seconds / maxSeconds,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 8,
                  backgroundColor: CustomColor.accentColor,
                ),
                Center(
                  child: Text(
                    '$seconds',
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                )
              ],
            ),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            onPressed: () {
              _clearBoard();
              _startTimer();
              attempts++;
            },
            child: Text(
              attempts == 0 ? 'Start' : 'Play Again',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ));
  }

  void _tapped(int index) {
    final isRunning = timer == null ? false : timer?.isActive ?? true;

    if (isRunning) {
      setState(() {
        if (cellValues[index] == '') {
          cellValues[index] = isPlayerOTurn ? 'O' : 'X';
          isPlayerOTurn = !isPlayerOTurn;
          filledBoxes++;
          _checkWinner();
        }
      });
    }
  }

  void _checkWinner() {
    List<List<int>> winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var condition in winConditions) {
      var firstCellValue = cellValues[condition[0]];

      if (firstCellValue.isNotEmpty &&
          condition.every((index) => cellValues[index] == firstCellValue)) {
        setState(() {
          gameResult = 'Player $firstCellValue Wins!';
          matchedIndexes.addAll(condition);
          _stopTimer();
          _updateScore(firstCellValue);
        });
        continue;
      }
    }

    if (!matchOver && filledBoxes == 9) {
      setState(() {
        gameResult = 'Nobody Wins!';
      });
    }
  }

  void _updateScore(String winner) {
    if (winner == 'O') {
      playerOScore++;
    } else if (winner == 'X') {
      playerXScore++;
    }
    matchOver = true;
  }

  void _clearBoard() {
    setState(() {
      cellValues.fillRange(0, 9, '');
      gameResult = '';
      matchedIndexes = [];
    });
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          _stopTimer();
        }
      });
    });
  }

  void _stopTimer() {
    timer?.cancel();
    _resetTimer();
  }

  void _resetTimer() => seconds = maxSeconds;
}
