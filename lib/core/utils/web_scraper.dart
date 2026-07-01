import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart';

class WebScraper {
  static Future<Map<String, String>> fetchArticle(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to load page. HTTP Status: ${response.statusCode}');
      }

      final document = html.parse(response.body);

      // 1. Extract Title
      String title = '';
      final titleElement = document.querySelector('title');
      if (titleElement != null) {
        title = titleElement.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      } else {
        final h1 = document.querySelector('h1');
        if (h1 != null) {
          title = h1.text.trim().replaceAll(RegExp(r'\s+'), ' ');
        } else {
          title = 'Web Article';
        }
      }

      // 2. Locate Main Content Node
      Element? contentNode = document.querySelector('article') ?? document.querySelector('main');
      if (contentNode == null) {
        // Fallback: Find the div with the most <p> tags
        final divs = document.querySelectorAll('div');
        int maxParagraphs = 0;
        for (var div in divs) {
          final pCount = div.querySelectorAll('p').length;
          if (pCount > maxParagraphs) {
            maxParagraphs = pCount;
            contentNode = div;
          }
        }
      }
      
      contentNode ??= document.body;
      if (contentNode == null) {
        throw Exception('Could not find meaningful HTML body on this page.');
      }

      // 3. Extract Text via Heuristics
      final buffer = StringBuffer();
      
      // We will look for headers and paragraphs within the chosen content node.
      // This is a naive but effective approach for basic blogs, Wikipedia, Hacker News, etc.
      final validTags = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'li', 'img'];
      
      void extract(Node node) {
        if (node is Element) {
          final tag = node.localName?.toLowerCase();
          
          if (['script', 'style', 'nav', 'header', 'footer', 'aside', 'svg'].contains(tag)) {
            return;
          }

          if (validTags.contains(tag)) {
            if (tag == 'img') {
              final src = node.attributes['src'] ?? node.attributes['data-src'] ?? node.attributes['data-lazy-src'];
              final alt = node.attributes['alt'] ?? 'Image';
              if (src != null && src.isNotEmpty && !src.startsWith('data:image')) {
                String finalSrc = src;
                if (src.startsWith('//')) {
                  finalSrc = 'https:$src';
                } else if (src.startsWith('/')) {
                  final baseUri = Uri.parse(url);
                  finalSrc = '${baseUri.scheme}://${baseUri.host}$src';
                } else if (!src.startsWith('http')) {
                  final baseUri = Uri.parse(url);
                  finalSrc = '${baseUri.scheme}://${baseUri.host}/$src';
                }
                buffer.writeln('\n![$alt]($finalSrc)\n');
              }
              return;
            }

            final text = node.text.trim().replaceAll(RegExp(r'\s+'), ' ');
            if (text.isEmpty) return;

            if (tag!.startsWith('h')) {
              int level = int.tryParse(tag.substring(1)) ?? 2;
              String hashes = List.filled(level, '#').join('');
              buffer.writeln('\n$hashes $text\n');
            } else if (tag == 'li') {
              buffer.writeln('- $text');
            } else {
              buffer.writeln('$text\n');
            }
          } else {
            for (var child in node.nodes) {
              extract(child);
            }
          }
        }
      }

      extract(contentNode);

      final content = buffer.toString().trim();
      if (content.isEmpty) {
        throw Exception('Found the page, but could not extract readable text paragraphs.');
      }

      return {
        'title': title,
        'content': content,
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
