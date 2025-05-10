import 'package:ruby_text/ruby_text.dart';

List<RubyTextData> parseRubyTextToData(String htmlText) {
  if (htmlText.isEmpty) return [];

  List<RubyTextData> dataList = [];
  // Regex to find <ruby>BASE<rt>RUBY</rt></ruby> tags
  final rubyRegex = RegExp(r"<ruby>(.*?)<rt>(.*?)</rt></ruby>");

  int lastEnd = 0;
  for (final match in rubyRegex.allMatches(htmlText)) {
    // Add plain text before this ruby match
    if (match.start > lastEnd) {
      String plainText = htmlText.substring(lastEnd, match.start);
      if (plainText.isNotEmpty) {
        // Optionally, strip any other HTML tags from plainText if necessary
        // plainText = plainText.replaceAll(RegExp(r'<[^>]*>'), '');
        if (plainText.isNotEmpty) {
          dataList.add(RubyTextData(plainText, ruby: ''));
        }
      }
    }

    // Add ruby text
    String base = match.group(1) ?? '';
    String ruby = match.group(2) ?? '';

    // Add RubyTextData even if base or ruby is empty, as long as the tag structure was matched.
    // The RubyText widget should handle empty strings gracefully.
    dataList.add(RubyTextData(base, ruby: ruby));

    lastEnd = match.end;
  }

  // Add any remaining plain text after the last ruby match
  if (lastEnd < htmlText.length) {
    String plainText = htmlText.substring(lastEnd);
    if (plainText.isNotEmpty) {
      // Optionally, strip any other HTML tags from plainText
      // plainText = plainText.replaceAll(RegExp(r'<[^>]*>'), '');
      if (plainText.isNotEmpty) {
        dataList.add(RubyTextData(plainText, ruby: ''));
      }
    }
  }

  return dataList;
}
