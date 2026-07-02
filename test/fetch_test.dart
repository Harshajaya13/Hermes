import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/engines/article_fetcher.dart';

void main() {
  test('Test ArticleFetcher with Medium Article', () async {
    final url = 'https://medium.com/geekculture/web-scraping-101-tools-techniques-and-best-practices-417e377fbeaf';
    print('Fetching: \$url\\n');
    final result = await ArticleFetcher.fetchAndConvertToMarkdown(url);
    print('Length: \${result.length}\\nSnippet: \${result.substring(0, result.length > 200 ? 200 : result.length)}...');
  });

  test('Test ArticleFetcher with React SPA (Hermes Website)', () async {
    final url = 'https://hermes.harshalabs.me';
    print('Fetching: \$url\\n');
    final result = await ArticleFetcher.fetchAndConvertToMarkdown(url);
    print('Length: \${result.length}\\nSnippet: \${result.substring(0, result.length > 200 ? 200 : result.length)}...');
  });
}
