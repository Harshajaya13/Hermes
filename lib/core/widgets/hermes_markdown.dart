import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../theme/hermes_theme.dart';

class HermesMarkdown extends StatelessWidget {
  final String data;
  final double fontSizeMultiplier;
  final double lineHeightMultiplier;
  
  const HermesMarkdown({
    super.key, 
    required this.data,
    this.fontSizeMultiplier = 1.0,
    this.lineHeightMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color headingColor = const Color(0xFFECECEC);
    final Color bodyColor = const Color(0xFFC8CCD1);
    final Color secondaryColor = const Color(0xFF8E9399);
    final Color metadataColor = const Color(0xFF6F747A);

    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: HermesTypography.body.copyWith(
          height: 1.9 * lineHeightMultiplier, 
          fontSize: 19 * fontSizeMultiplier, 
          color: bodyColor,
          fontWeight: FontWeight.w400, // Slightly stronger than w300 since it's gray now
          letterSpacing: 0.3,
        ),
        pPadding: const EdgeInsets.only(bottom: 28),
        
        h1: HermesTypography.itemTitle.copyWith(color: headingColor, fontSize: 34 * fontSizeMultiplier, height: 1.3, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        h1Padding: const EdgeInsets.only(top: 48, bottom: 24),
        
        h2: HermesTypography.itemTitle.copyWith(color: headingColor, fontSize: 28 * fontSizeMultiplier, height: 1.4, fontWeight: FontWeight.w500, letterSpacing: -0.3),
        h2Padding: const EdgeInsets.only(top: 40, bottom: 20),
        
        h3: HermesTypography.itemTitle.copyWith(color: headingColor, fontSize: 24 * fontSizeMultiplier, height: 1.4, fontWeight: FontWeight.w500),
        h3Padding: const EdgeInsets.only(top: 32, bottom: 16),
        
        h4: HermesTypography.itemTitle.copyWith(color: headingColor, fontSize: 20 * fontSizeMultiplier, height: 1.4, fontWeight: FontWeight.w500),
        h4Padding: const EdgeInsets.only(top: 24, bottom: 12),
        
        h5: HermesTypography.itemTitle.copyWith(color: headingColor, fontSize: 18 * fontSizeMultiplier, height: 1.4, fontWeight: FontWeight.w500),
        h6: HermesTypography.itemTitle.copyWith(color: headingColor, fontSize: 16 * fontSizeMultiplier, height: 1.4, fontWeight: FontWeight.w500),
        
        listBullet: HermesTypography.body.copyWith(
          color: secondaryColor,
          fontSize: 19 * fontSizeMultiplier,
          height: 1.9 * lineHeightMultiplier,
          fontWeight: FontWeight.w400,
        ),
        listBulletPadding: const EdgeInsets.only(right: 12),
        
        blockquote: HermesTypography.body.copyWith(
          color: secondaryColor,
          fontStyle: FontStyle.italic,
          fontSize: 21 * fontSizeMultiplier,
          height: 1.7 * lineHeightMultiplier,
          fontWeight: FontWeight.w400,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: secondaryColor.withValues(alpha: 0.5), width: 3)),
        ),
        blockquotePadding: const EdgeInsets.only(left: 24, top: 16, bottom: 16),
        
        code: HermesTypography.metadata.copyWith(
          fontFamily: 'monospace',
          backgroundColor: const Color(0xFF161616),
          color: HermesColors.accent,
          fontSize: 15 * fontSizeMultiplier,
        ),
        codeblockPadding: EdgeInsets.zero,
        codeblockDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: HermesColors.border.withValues(alpha: 0.2), width: 1)),
        ),
        
        tableBorder: TableBorder.all(color: HermesColors.border.withValues(alpha: 0.15), width: 1),
        tableCellsPadding: const EdgeInsets.all(HermesSpacing.lg),
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
