import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../blocks/create_item_sheet.dart';

class HermesReaderScreen extends ConsumerStatefulWidget {
  final Item item;
  final Block block;

  const HermesReaderScreen({super.key, required this.item, required this.block});

  @override
  ConsumerState<HermesReaderScreen> createState() => _HermesReaderScreenState();
}

class _HermesReaderScreenState extends ConsumerState<HermesReaderScreen> {
  final _scrollController = ScrollController();
  final _reflectionController = TextEditingController();
  double _progress = 0.0;
  bool _showEvolutioPrompt = false;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    
    setState(() {
      _isScrolled = current > 20;
      if (max > 0) {
        _progress = (current / max).clamp(0.0, 1.0);
      } else {
        _progress = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _recordEvolutio(bool didChange, {String? customText}) async {
    final storage = ref.read(storageEngineProvider);
    
    final reflection = Reflection(
      itemId: widget.item.id,
      content: customText ?? _reflectionController.text.trim(),
    );
    await storage.saveReflection(reflection);

    if (didChange) {
      final evolutio = Evolutio(
        reflectionId: reflection.id,
        blockId: widget.block.id,
        content: customText ?? _reflectionController.text.trim(),
      );
      await storage.saveEvolutio(evolutio);
      if (mounted) {
        ref.invalidate(allEvolutiosProvider);
        ref.invalidate(recentEvolutiosProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evolution recorded. The journey continues.', style: HermesTypography.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: HermesColors.evolutioGlow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.md)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    
    final updatedMetadata = Map<String, dynamic>.from(widget.item.metadata ?? {});
    updatedMetadata['isSolved'] = true;
    final updatedItem = widget.item.copyWith(metadata: updatedMetadata);
    await storage.saveItems([updatedItem]);
    if (mounted) {
      ref.invalidate(itemsByBlockProvider(widget.block.id));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // OLED-first: Use pure black background for reading.
    final bgColor = Colors.black;
    final surfaceColor = const Color(0xFF111111);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Main Reading Area
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680), // Optimal reading width
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.xl,
                    vertical: 80, // Padding for header
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildArticleHeader(),
                      const SizedBox(height: HermesSpacing.xxxl),
                      _buildMarkdownContent(),
                      const SizedBox(height: HermesSpacing.xxxl * 2),
                      _buildReflectionSection(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Subtle Top Bar (Minimal Chrome)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _isScrolled ? bgColor.withValues(alpha: 0.95) : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: _isScrolled ? HermesColors.border.withValues(alpha: 0.3) : Colors.transparent,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.md, vertical: HermesSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Back',
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search_rounded, color: HermesColors.textTertiary, size: 20),
                            onPressed: () {
                              // Search in article
                            },
                            tooltip: 'Search',
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_size_rounded, color: HermesColors.textTertiary, size: 20),
                            onPressed: () {
                              // Text size controls
                            },
                            tooltip: 'Text Size',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: HermesColors.textTertiary, size: 20),
                            onPressed: () {
                              CreateItemSheet.show(context, block: widget.block, existingItem: widget.item);
                            },
                            tooltip: 'Edit Article',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Subtle Progress Indicator
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth,
                    height: 1.5,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: constraints.maxWidth * _progress,
                      height: 1.5,
                      color: HermesColors.accent.withValues(alpha: 0.5),
                    ),
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HermesIconBadge(emoji: widget.block.icon, color: HermesColors.textSecondary, size: 20),
            const SizedBox(width: HermesSpacing.sm),
            Text(
              widget.block.name.toUpperCase(), 
              style: HermesTypography.metadata.copyWith(
                color: HermesColors.textSecondary, 
                letterSpacing: 1.2
              )
            ),
          ],
        ),
        const SizedBox(height: HermesSpacing.lg),
        Text(
          widget.item.title, 
          style: HermesTypography.screenTitle.copyWith(
            fontSize: 40, 
            height: 1.1,
            fontWeight: FontWeight.w700,
          )
        ),
        const SizedBox(height: HermesSpacing.md),
        Text(
          widget.item.createdAt.toString().substring(0, 10), 
          style: HermesTypography.metadata.copyWith(color: HermesColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent() {
    return MarkdownBody(
      data: widget.item.content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: HermesTypography.body.copyWith(
          height: 1.8, 
          fontSize: 18, 
          color: HermesColors.textPrimary.withValues(alpha: 0.95),
          fontWeight: FontWeight.w400,
        ),
        h1: HermesTypography.itemTitle.copyWith(fontSize: 32, height: 1.3, fontWeight: FontWeight.w700),
        h2: HermesTypography.itemTitle.copyWith(fontSize: 26, height: 1.3, fontWeight: FontWeight.w600),
        h3: HermesTypography.itemTitle.copyWith(fontSize: 22, height: 1.3, fontWeight: FontWeight.w600),
        h4: HermesTypography.itemTitle.copyWith(fontSize: 18, height: 1.3, fontWeight: FontWeight.w600),
        h5: HermesTypography.itemTitle.copyWith(fontSize: 16, height: 1.3, fontWeight: FontWeight.w600),
        h6: HermesTypography.itemTitle.copyWith(fontSize: 14, height: 1.3, fontWeight: FontWeight.w600),
        
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
        codeblockPadding: EdgeInsets.zero, // Padding handled by custom builder
        codeblockDecoration: BoxDecoration(
          color: Colors.transparent, // Handled by custom builder
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

  Widget _buildReflectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 1,
            color: HermesColors.border.withValues(alpha: 0.3),
            margin: const EdgeInsets.symmetric(vertical: HermesSpacing.xl),
          ),
        ),
        
        Text('Reflection', style: HermesTypography.itemTitle.copyWith(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: HermesSpacing.md),
        
        Text('• What changed?', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6)),
        Text('• What challenged your thinking?', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6)),
        Text('• What surprised you?', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6)),
        Text('• What will you remember?', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6)),
        
        const SizedBox(height: HermesSpacing.xl),
        
        if (!_showEvolutioPrompt) ...[
          TextField(
            controller: _reflectionController,
            maxLines: null,
            minLines: 4,
            style: HermesTypography.body.copyWith(fontSize: 18, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Write your thoughts...',
              hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary, fontSize: 18),
              filled: true,
              fillColor: const Color(0xFF111111), // Subtle surface
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HermesRadius.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(HermesSpacing.lg),
            ),
          ),
          const SizedBox(height: HermesSpacing.lg),
          
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                if (_reflectionController.text.trim().isNotEmpty) {
                  setState(() => _showEvolutioPrompt = true);
                } else {
                  _recordEvolutio(true, customText: 'Recorded an Evolutio without a formal reflection.');
                }
              },
              borderRadius: BorderRadius.circular(HermesRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm, horizontal: HermesSpacing.md),
                child: Text('Complete Reading', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary)),
              ),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(HermesSpacing.xl),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(HermesRadius.lg),
              border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Did this genuinely change how you think or understand something?',
                  style: HermesTypography.itemTitle.copyWith(color: HermesColors.evolutioGlow, fontSize: 20),
                ),
                const SizedBox(height: HermesSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _recordEvolutio(false),
                      child: Text('No, just save', style: TextStyle(color: HermesColors.textSecondary)),
                    ),
                    const SizedBox(width: HermesSpacing.lg),
                    ElevatedButton(
                      onPressed: () => _recordEvolutio(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HermesColors.evolutioGlow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.md)),
                      ),
                      child: const Text('Record Evolutio', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(var element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final isBlock = text.contains('\n');
    
    if (!isBlock) {
       // Inline code
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
    
    // Code block with horizontal scroll and copy button
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: HermesSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF111111), // Premium dark surface
        borderRadius: BorderRadius.circular(HermesRadius.md),
        border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
             padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.md, vertical: 4),
             decoration: BoxDecoration(
               color: const Color(0xFF1A1A1A),
               borderRadius: const BorderRadius.vertical(top: Radius.circular(HermesRadius.md)),
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
                 InkWell(
                   onTap: () {
                     Clipboard.setData(ClipboardData(text: text));
                   },
                   borderRadius: BorderRadius.circular(4),
                   child: Padding(
                     padding: const EdgeInsets.all(4.0),
                     child: const Icon(Icons.copy_rounded, size: 14, color: HermesColors.textSecondary),
                   ),
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
