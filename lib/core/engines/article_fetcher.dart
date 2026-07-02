import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:html2md/html2md.dart' as html2md;

class ArticleFetcher {
  static Future<String> fetchAndConvertToMarkdown(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to load article (Status: ${response.statusCode})');
      }

      final document = html_parser.parse(response.body);
      
      // Try to find the main article container using common structural elements and class names
      Element? contentElement = document.querySelector('article') ?? 
                                document.querySelector('.post-content') ??
                                document.querySelector('.entry-content') ??
                                document.querySelector('.article-content') ??
                                document.querySelector('.story-body') ??
                                document.querySelector('.story-content') ??
                                document.querySelector('[itemprop="articleBody"]') ??
                                document.querySelector('.post-body') ??
                                document.querySelector('.page-content') ??
                                document.querySelector('main') ?? 
                                document.querySelector('#content') ??
                                document.body;

      if (contentElement == null) {
        return 'Could not extract content from the page.';
      }

      // Remove garbage elements that pollute the reading experience
      final selectorsToRemove = [
        'nav', 'header', 'footer', 'script', 'style', 'aside', 'noscript', 'iframe',
        '.ad', '.sidebar', '#comments', '.comments', '.newsletter-form', '.share-buttons',
        '.social-share', '.related-posts', '.author-bio', '[role="navigation"]',
        '.cookie-banner', '#cookie-notice'
      ];
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
