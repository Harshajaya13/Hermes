import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/engines/article_fetcher.dart';

void main() {
  test('Test ArticleFetcher with Paul Graham essay', () async {
    final url = 'http://www.paulgraham.com/ds.html';
    print('Fetching: \$url\\n');
    final result = await ArticleFetcher.fetchAndConvertToMarkdown(url);
    
    // Print first 500 characters
    if (result.length > 500) {
      print(result.substring(0, 500) + '...\\n\\n[Truncated for brevity. Total length: \${result.length} characters]');
    } else {
      print(result);
    }
  });

  test('Test ArticleFetcher with a Medium article', () async {
    final url = 'https://medium.com/@harshalabs/hello-world'; // Using a dummy or real medium URL
    print('Fetching: \$url\\n');
    final result = await ArticleFetcher.fetchAndConvertToMarkdown(url);
    print('Length: \${result.length}\\nSnippet: \${result.substring(0, result.length > 200 ? 200 : result.length)}...');
  });
}
