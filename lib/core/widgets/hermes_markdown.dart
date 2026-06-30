import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../theme/hermes_theme.dart';

class HermesMarkdown extends StatelessWidget {
  final String data;
  
  const HermesMarkdown({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: HermesTypography.body.copyWith(
          height: 1.8, 
          fontSize: 18, 
          color: HermesColors.textPrimary.withValues(alpha: 0.95),
          fontWeight: FontWeight.w400,
        ),
        h1: HermesTypography.itemTitle.copyWith(fontSize: 32, height: 1.4, fontWeight: FontWeight.w700),
        h2: HermesTypography.itemTitle.copyWith(fontSize: 26, height: 1.4, fontWeight: FontWeight.w600),
        h3: HermesTypography.itemTitle.copyWith(fontSize: 22, height: 1.4, fontWeight: FontWeight.w600),
        h4: HermesTypography.itemTitle.copyWith(fontSize: 18, height: 1.4, fontWeight: FontWeight.w600),
        h5: HermesTypography.itemTitle.copyWith(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600),
        h6: HermesTypography.itemTitle.copyWith(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
        
        listBullet: HermesTypography.body.copyWith(
          color: HermesColors.textSecondary,
          fontSize: 18,
          height: 1.8,
        ),
        
        blockquote: HermesTypography.body.copyWith(
          color: HermesColors.textSecondary,
          fontStyle: FontStyle.italic,
          fontSize: 20,
          height: 1.6,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: HermesColors.accent.withValues(alpha: 0.5), width: 3)),
        ),
        blockquotePadding: const EdgeInsets.only(left: HermesSpacing.xl, top: HermesSpacing.sm, bottom: HermesSpacing.sm),
        
        code: HermesTypography.metadata.copyWith(
          fontFamily: 'monospace',
          backgroundColor: const Color(0xFF1A1A1A),
          color: HermesColors.accent,
          fontSize: 14,
        ),
        codeblockPadding: EdgeInsets.zero,
        codeblockDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: HermesColors.border.withValues(alpha: 0.3), width: 1)),
        ),
        
        tableBorder: TableBorder.all(color: HermesColors.border.withValues(alpha: 0.2)),
        tableCellsPadding: const EdgeInsets.all(HermesSpacing.md),
      ),
      builders: {
        'code': _CodeElementBuilder(),
        'math': _MathBuilder(),
        'latex': _MathBuilder(),
      },
      imageBuilder: (uri, title, alt) {
        Widget image;
        if (uri.scheme == 'http' || uri.scheme == 'https') {
          image = Image.network(uri.toString());
        } else {
          image = Image.network(uri.toString());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.xl),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      InteractiveViewer(
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Center(child: image),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HermesRadius.lg),
              child: image,
            ),
          ),
        );
      },
    );
  }
}

class _CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(var element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final isBlock = text.contains('\n');
    
    if (!isBlock) {
       return Container(
         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
         margin: const EdgeInsets.symmetric(horizontal: 2),
         decoration: BoxDecoration(
           color: const Color(0xFF1A1A1A), 
           borderRadius: BorderRadius.circular(4)
         ),
         child: Text(text, style: preferredStyle?.copyWith(fontFamily: 'monospace', color: HermesColors.accent, fontSize: 15)),
       );
    }
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: HermesSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(HermesRadius.md),
        border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
             padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.md, vertical: 4),
             decoration: const BoxDecoration(
               color: Color(0xFF1A1A1A),
               borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.md)),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Row(
                   children: [
                     const Icon(Icons.code_rounded, size: 14, color: HermesColors.textTertiary),
                     const SizedBox(width: 6),
                     Text('code', style: HermesTypography.metadata.copyWith(fontSize: 12, color: HermesColors.textTertiary)),
                   ]
                 ),
                 Builder(
                   builder: (context) => InkWell(
                     onTap: () {
                       Clipboard.setData(ClipboardData(text: text));
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('Code copied to clipboard', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textPrimary)),
                           backgroundColor: HermesColors.surfaceElevated,
                           duration: const Duration(seconds: 1),
                         ),
                       );
                     },
                     borderRadius: BorderRadius.circular(4),
                     child: const Padding(
                       padding: EdgeInsets.all(4.0),
                       child: Icon(Icons.copy_rounded, size: 14, color: HermesColors.textSecondary),
                     ),
                   )
                 )
               ],
             ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(HermesSpacing.lg),
            child: Text(
              text, 
              style: preferredStyle?.copyWith(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFFE0E0E0),
              )
            ),
          ),
        ],
      ),
    );
  }
}

class _MathBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(var element, TextStyle? preferredStyle) {
    return Math.tex(
      element.textContent,
      textStyle: preferredStyle?.copyWith(fontSize: 18),
    );
  }
}
