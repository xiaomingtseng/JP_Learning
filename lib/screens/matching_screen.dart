import 'package:flutter/material.dart';
import '../models/kotoba.dart';
import 'dart:async';

class MatchingScreen extends StatefulWidget {
  final List<Kotoba> kotobaList;

  const MatchingScreen({super.key, required this.kotobaList});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  late List<Kotoba> gameKotoba; // Holds the Kotoba objects for the current round
  late List<String> wordsForCurrentRound; // All words for this round
  late List<String> meaningsForCurrentRound; // All meanings for this round (shuffled once)

  String? selectedWord;
  String? selectedMean;
  Map<String, String> userMatches = {}; // Stores word -> mean for matched pairs
  late Stopwatch stopwatch;
  bool isLoading = true; // To handle initial loading or if not enough data

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    _startNewRound();
  }

  void _startNewRound() {
    setState(() {
      isLoading = true;
      userMatches.clear();
      selectedWord = null;
      selectedMean = null;

      final fullList = List<Kotoba>.from(widget.kotobaList)..shuffle();
      
      // Ensure there's a minimum number of words to start a game, e.g., at least 1.
      // Game can proceed with fewer than 6 if less are available.
      if (fullList.isEmpty) {
        gameKotoba = [];
        wordsForCurrentRound = [];
        meaningsForCurrentRound = [];
        isLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showNotEnoughWordsDialog();
          }
        });
        return;
      }
      
      gameKotoba = fullList.take(6).toList(); 

      wordsForCurrentRound = gameKotoba.map((k) => k.word).toList();
      meaningsForCurrentRound = gameKotoba.map((k) => k.mean).toList()..shuffle();

      stopwatch.reset();
      stopwatch.start();
      isLoading = false;
    });
  }

  void _showNotEnoughWordsDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('資料不足'),
        content: const Text('沒有足夠的單字來開始配對遊戲。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Go back from MatchingScreen
              }
            },
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  void _checkMatch() {
    if (selectedWord != null && selectedMean != null) {
      Kotoba? targetKotoba;
      try {
        targetKotoba = gameKotoba.firstWhere((k) => k.word == selectedWord);
      } catch (e) {
        // This block is executed if no element is found.
        // targetKotoba will remain null.
        // It's good practice to log this, as it might indicate an unexpected state,
        // though selectedWord should ideally always be in gameKotoba.
        print('Developer warning: selectedWord "$selectedWord" was not found in gameKotoba. This might indicate a logic error.');
      }

      if (targetKotoba != null && targetKotoba.mean == selectedMean) {
        setState(() {
          userMatches[selectedWord!] = selectedMean!;
          selectedWord = null;
          selectedMean = null;
        });

        if (userMatches.length == gameKotoba.length && gameKotoba.isNotEmpty) {
          stopwatch.stop();
          _showCompletionDialog();
        }
      } else {
        setState(() {
          selectedWord = null;
          selectedMean = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('配對錯誤！請再試一次。'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _showCompletionDialog() {
    if (!mounted) return;
    final elapsedTime = stopwatch.elapsed;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('恭喜完成！'),
        content: Text(
            '您花了 ${elapsedTime.inMinutes} 分 ${elapsedTime.inSeconds % 60} 秒完成配對！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              _startNewRound();       
            },
            child: const Text('再玩一次'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              if (Navigator.canPop(context)) {
                 Navigator.pop(context);
              }
            },
            child: const Text('結束'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('配對練習')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (gameKotoba.isEmpty && !isLoading) {
       // This case is handled by _showNotEnoughWordsDialog, 
       // but as a fallback or if dialog is dismissed without navigating back.
      return Scaffold(
        appBar: AppBar(title: const Text('配對練習')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('沒有單字可供遊戲。', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('返回'),
              )
            ],
          ),
        ),
      );
    }

    final displayableWords = wordsForCurrentRound
        .where((word) => !userMatches.containsKey(word))
        .toList();
    final displayableMeanings = meaningsForCurrentRound
        .where((mean) => !userMatches.containsValue(mean))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('配對練習'),
        actions: [
          if (gameKotoba.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Center(
                child: Text(
                  '${userMatches.length} / ${gameKotoba.length}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3, // Responsive columns
                childAspectRatio: 2.5, 
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: displayableWords.length + displayableMeanings.length,
              itemBuilder: (context, index) {
                final bool isWordSide = index < displayableWords.length;
                final String content;

                if (isWordSide) {
                  content = displayableWords[index];
                } else {
                  content = displayableMeanings[index - displayableWords.length];
                }

                bool isSelected = (isWordSide && content == selectedWord) ||
                                  (!isWordSide && content == selectedMean);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isWordSide) {
                        selectedWord = content;
                      } else {
                        selectedMean = content;
                      }
                      _checkMatch();
                    });
                  },
                  child: Card(
                    elevation: 3.0,
                    color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: isSelected 
                          ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                          : BorderSide.none,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          content,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
