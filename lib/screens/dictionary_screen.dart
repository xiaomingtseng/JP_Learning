import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
// import 'word_detail_screen.dart'; // 稍後建立單字詳細頁面

// 模擬的字典資料 (之後會從 API 或本地資料庫獲取)
final List<DictionaryEntry> _allDictionaryEntries = [
  DictionaryEntry(
    id: 'dict_001',
    term: '日本語',
    reading: 'にほんご',
    meanings: [
      MeaningEntry(partOfSpeech: '名詞', definitions: ['日語，日本話']),
    ],
    jlptLevel: 'N5',
    examples: [
      ExampleSentence(
        japanese: '日本語を勉強しています。',
        reading: 'にほんごをべんきょうしています。',
        translation: '我正在學習日語。',
      ),
    ],
    tags: ['常用'],
  ),
  DictionaryEntry(
    id: 'dict_002',
    term: '食べる',
    reading: 'たべる',
    meanings: [
      MeaningEntry(partOfSpeech: '動詞（一段）', definitions: ['吃']),
    ],
    jlptLevel: 'N5',
    examples: [
      ExampleSentence(
        japanese: 'リンゴを食べます。',
        reading: 'リンゴをたべます。',
        translation: '吃蘋果。',
      ),
    ],
  ),
  DictionaryEntry(
    id: 'dict_003',
    term: '綺麗',
    reading: 'きれい',
    meanings: [
      MeaningEntry(partOfSpeech: '形容動詞', definitions: ['漂亮，乾淨']),
    ],
    jlptLevel: 'N5',
    examples: [
      ExampleSentence(
        japanese: 'この花は綺麗ですね。',
        reading: 'このはなはきれいですね。',
        translation: '這朵花真漂亮啊。',
      ),
    ],
  ),
  DictionaryEntry(
    id: 'dict_004',
    term: '行く',
    reading: 'いく',
    meanings: [
      MeaningEntry(partOfSpeech: '動詞（五段）', definitions: ['去']),
    ],
    jlptLevel: 'N5',
    examples: [
      ExampleSentence(
        japanese: '学校へ行きます。',
        reading: 'がっこうへいきます。',
        translation: '去學校。',
      ),
    ],
  ),
  DictionaryEntry(
    id: 'dict_005',
    term: '検索',
    reading: 'けんさく',
    meanings: [
      MeaningEntry(partOfSpeech: '名詞・サ変動詞', definitions: ['檢索，搜索']),
    ],
    jlptLevel: 'N3',
    examples: [
      ExampleSentence(
        japanese: 'インターネットで情報を検索する。',
        reading: 'インターネットでじょうほうをけんさくする。',
        translation: '在網路上搜尋資訊。',
      ),
    ],
    tags: ['IT用語'],
  ),
  DictionaryEntry(
    id: 'dict_006',
    term: '愛',
    reading: 'あい',
    meanings: [
      MeaningEntry(partOfSpeech: '名詞', definitions: ['愛，愛情']),
    ],
    jlptLevel: 'N1',
    examples: [
      ExampleSentence(
        japanese: '愛は全てを乗り越える。',
        reading: 'あいはすべてをのりこえる。',
        translation: '愛能克服一切。',
      ),
    ],
  ),
];

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  List<DictionaryEntry> _filteredEntries = [];
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = "";

  @override
  void initState() {
    super.initState();
    // Initially, show no results or a prompt, not all entries.
    // _filteredEntries = _allDictionaryEntries;
    _searchController.addListener(_performSearch);
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase().trim();
    if (_currentQuery == query) return; // Avoid redundant searches

    _currentQuery = query;

    if (query.isEmpty) {
      setState(() {
        _filteredEntries = [];
      });
    } else {
      setState(() {
        _filteredEntries =
            _allDictionaryEntries.where((entry) {
              final termMatches = entry.term.toLowerCase().contains(query);
              final readingMatches = entry.reading.toLowerCase().contains(
                query,
              );
              final meaningMatches = entry.meanings.any(
                (meaning) => meaning.definitions.any(
                  (def) => def.toLowerCase().contains(query),
                ),
              );
              return termMatches || readingMatches || meaningMatches;
            }).toList();
      });
    }
  }

  void _navigateToWordDetail(DictionaryEntry entry) {
    // TODO: 導航到單字詳細頁面 (WordDetailScreen)
    print('Navigating to detail for: ${entry.term}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('點擊了: ${entry.term} - ${entry.reading}')),
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => WordDetailScreen(entry: entry)),
    // );
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildRichTextWithFurigana(String term, String reading) {
    // 簡易的振假名實現，可以根據需要做得更複雜
    // 這裡假設讀音是針對整個詞彙的
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(fontSize: 18), // 主詞彙字體大小
        children: <TextSpan>[
          TextSpan(text: term),
          TextSpan(
            text: ' [$reading]',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ), // 讀音字體大小和顏色
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("字典")), // 通常在 BottomNav 頁面不需要獨立 AppBar
      body: Column(
        children: <Widget>[
          // 搜尋列
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜尋日文、假名或中文意思...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            // _performSearch(); // clear() 會觸發 listener
                          },
                        )
                        : null,
              ),
              onSubmitted: (_) => _performSearch(), // 鍵盤確認也觸發搜尋
            ),
          ),

          // 結果列表
          Expanded(
            child:
                _searchController.text.trim().isEmpty &&
                        _filteredEntries.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '開始搜尋您的單字吧！',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : _filteredEntries.isEmpty &&
                        _searchController.text.trim().isNotEmpty
                    ? Center(
                      child: Text(
                        '找不到符合 "${_searchController.text}" 的結果',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: _filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _filteredEntries[index];
                        return Card(
                          elevation: 1.5,
                          margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8.0,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            title: _buildRichTextWithFurigana(
                              entry.term,
                              entry.reading,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                entry.meanings
                                    .map(
                                      (m) =>
                                          '${m.partOfSpeech}: ${m.definitions.join("； ")}',
                                    )
                                    .join('\n'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            trailing:
                                entry.jlptLevel != null
                                    ? Chip(
                                      label: Text(
                                        entry.jlptLevel!,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 0,
                                      ),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColorLight.withOpacity(0.5),
                                      labelPadding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    )
                                    : null,
                            onTap: () => _navigateToWordDetail(entry),
                          ),
                        );
                      },
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(height: 0), // Card 之間已有間距
                    ),
          ),
        ],
      ),
    );
  }
}
