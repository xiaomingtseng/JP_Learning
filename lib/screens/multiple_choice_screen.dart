import 'package:flutter/material.dart';
import '../models/kotoba.dart';

class MultipleChoiceScreen extends StatefulWidget {
  final List<Kotoba> kotobaList;

  const MultipleChoiceScreen({super.key, required this.kotobaList});

  @override
  State<MultipleChoiceScreen> createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  late List<Kotoba> selectedKotoba;
  late Kotoba currentKotoba;
  late List<String> options;
  int score = 0;
  int questionIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedKotoba = List.from(widget.kotobaList)..shuffle();
    selectedKotoba = selectedKotoba.take(10).toList();
    _loadNextQuestion();
  }

  void _loadNextQuestion() {
    if (questionIndex < selectedKotoba.length) {
      currentKotoba = selectedKotoba[questionIndex];
      options = [];
      options.add(currentKotoba.mean); // Add the correct answer

      // Get a list of all other meanings, excluding the correct one
      List<String> otherMeanings = widget.kotobaList
          .map((kotoba) => kotoba.mean)
          .where((mean) => mean != currentKotoba.mean)
          .toList();
      otherMeanings.shuffle();

      // Add 3 unique random meanings
      for (var mean in otherMeanings) {
        if (options.length < 4) {
          if (!options.contains(mean)) {
            options.add(mean);
          }
        }
        if (options.length == 4) break;
      }
      // If not enough unique options, fill with placeholders or repeat (less ideal)
      while (options.length < 4) {
        // This case should be rare if kotobaList is large enough
        options.add("替補選項"); // Placeholder, ideally handle this more gracefully
      }

      options.shuffle(); // Shuffle all options including the correct one
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('完成！'),
        content: Text('您的分數是：$score/10'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  void _checkAnswer(String selectedOption) {
    if (selectedOption == currentKotoba.mean) {
      setState(() {
        score++;
      });
    }
    setState(() {
      questionIndex++;
      _loadNextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('選擇題練習 (${questionIndex + 1}/${selectedKotoba.length})'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                '得分: $score',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: questionIndex < selectedKotoba.length
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
                children: [
                  Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        '單字：${currentKotoba.word}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...options.take(4).map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () => _checkAnswer(option),
                        child: Text(option),
                      ),
                    );
                  }).toList(),
                ],
              ),
            )
          : Center(
              // This part is shown when all questions are answered,
              // before the dialog pops up.
              // You might want to show a summary or a different message here,
              // or ensure the dialog appears immediately.
              // For now, keeping CircularProgressIndicator if _loadNextQuestion leads here.
              child: _buildCompletionView(),
            ),
    );
  }

  Widget _buildCompletionView() {
    // This view is briefly shown after the last question is answered,
    // just before the score dialog.
    // You can customize this, e.g., show "Calculating score..."
    // or directly trigger the dialog if preferred (though dialog is modal).
    // For now, let's keep it simple.
    // If _showFinalScore is called immediately, this might not be visible for long.
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text("正在計算結果...", style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
