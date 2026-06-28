import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:html2md/html2md.dart' as html2md;

class ArticleFetcher {
  static Future<String> fetchAndConvertToMarkdown(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load article');
      }

      final document = html_parser.parse(response.body);
      
      // Try to find the main article container
      Element? contentElement = document.querySelector('article') ?? 
                                document.querySelector('main') ?? 
                                document.body;

      if (contentElement == null) {
        return 'Could not extract content from the page.';
      }

      // Remove garbage elements
      final selectorsToRemove = ['nav', 'header', 'footer', 'script', 'style', 'aside', '.ad', '.sidebar', '#comments'];
      for (final selector in selectorsToRemove) {
        contentElement.querySelectorAll(selector).forEach((e) => e.remove());
      }

      final buffer = StringBuffer();
      
      // Attempt to extract title
      final title = document.querySelector('h1')?.text ?? document.querySelector('title')?.text ?? 'Untitled Article';
      
      // Clean up the inner HTML of the content element
      final rawHtml = contentElement.innerHtml;
      
      // Convert HTML to Markdown
      String markdown = html2md.convert(rawHtml, styleOptions: {'headingStyle': 'atx'});
      
      // Ensure the title is at the top
      if (!markdown.startsWith('# ')) {
        markdown = '# $title\n\n$markdown';
      }

      return markdown.trim();
    } catch (e) {
      return 'Error fetching article: $e';
    }
  }
}
