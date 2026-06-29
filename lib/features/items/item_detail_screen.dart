import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../blocks/create_item_sheet.dart';
import '../../core/providers/providers.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final Item item;
  final Block block;

  const ItemDetailScreen({super.key, required this.item, required this.block});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  final _reflectionController = TextEditingController();
  final _evaluateController = TextEditingController();
  bool _showEvolutioPrompt = false;
  bool _showAnswerFeedback = false;
  bool _isAnswerCorrect = false;

  void _submitReflection() {
    if (_reflectionController.text.trim().isEmpty) return;
    
    // According to Philosophy: 
    // Reflection -> Insight -> "Did this change you?"
    setState(() {
      _showEvolutioPrompt = true;
    });
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
      ref.invalidate(allEvolutiosProvider);
      ref.invalidate(recentEvolutiosProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your evolution continues.', style: HermesTypography.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: HermesColors.evolutioGlow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.md)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    
    if (mounted) Navigator.pop(context);
  }

  void _evaluateAnswer() {
    final ans = _evaluateController.text.trim();
    if (ans.isEmpty) return;
    
    // In a real app, we'd check against item.metadata?['answer']
    // For now, if they enter something, we show the feedback UI.
    setState(() {
      _showAnswerFeedback = true;
      // Mock validation for the coin flip question (1.5 or 3/2)
      _isAnswerCorrect = ans == '1.5' || ans == '3/2';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HermesIconBadge(emoji: widget.block.icon, color: HermesColors.accent),
            const SizedBox(width: HermesSpacing.sm),
            Text(widget.block.name, style: HermesTypography.metadata),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: HermesColors.textSecondary, size: 20),
            onPressed: () {
              CreateItemSheet.show(context, widget.block, widget.item);
            },
          ),
          const SizedBox(width: HermesSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(HermesSpacing.screenHorizontal),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.title, style: HermesTypography.screenTitle),
                    const SizedBox(height: HermesSpacing.lg),
                    
                    // Content Area (Reader / Question Engine goes here)
                    MarkdownBody(
                      data: widget.item.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: HermesTypography.body.copyWith(height: 1.6),
                        h1: HermesTypography.itemTitle.copyWith(fontSize: 24),
                        h2: HermesTypography.itemTitle.copyWith(fontSize: 20),
                        h3: HermesTypography.itemTitle.copyWith(fontSize: 18),
                        blockquote: HermesTypography.body.copyWith(
                          color: HermesColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: HermesColors.surfaceElevated.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                          border: const Border(left: BorderSide(color: HermesColors.accent, width: 4)),
                        ),
                      ),
                    ),
                    const SizedBox(height: HermesSpacing.xxxl),
                    
                    // Evaluation / Reflection Area based on ItemType
                    if (widget.item.type == ItemType.question) ...[
                      const HermesSectionHeader(title: 'Evaluate'),
                      const SizedBox(height: HermesSpacing.sm),
                      Text(
                        'What is the final answer?',
                        style: HermesTypography.metadata,
                      ),
                      const SizedBox(height: HermesSpacing.md),
                      
                      if (!_showAnswerFeedback) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _evaluateController,
                                style: HermesTypography.itemTitle,
                                decoration: InputDecoration(
                                  hintText: 'Type answer...',
                                  hintStyle: HermesTypography.itemTitle.copyWith(color: HermesColors.textTertiary),
                                  filled: true,
                                  fillColor: HermesColors.surfaceElevated,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(HermesRadius.md),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: HermesSpacing.md),
                            ElevatedButton(
                              onPressed: _evaluateAnswer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HermesColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.md)),
                              ),
                              child: const Text('Evaluate'),
                            ),
                          ],
                        ),
                      ] else ...[
                        HermesFadeIn(
                          child: Container(
                            padding: const EdgeInsets.all(HermesSpacing.lg),
                            decoration: BoxDecoration(
                              color: _isAnswerCorrect 
                                  ? HermesColors.evolutioGlow.withValues(alpha: 0.1)
                                  : HermesColors.veritasColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(HermesRadius.lg),
                              border: Border.all(
                                color: _isAnswerCorrect 
                                    ? HermesColors.evolutioGlow.withValues(alpha: 0.3)
                                    : HermesColors.veritasColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _isAnswerCorrect ? Icons.check_circle_outline : Icons.close_rounded,
                                      color: _isAnswerCorrect ? HermesColors.evolutioGlow : HermesColors.veritasColor,
                                    ),
                                    const SizedBox(width: HermesSpacing.sm),
                                    Text(
                                      _isAnswerCorrect ? 'Correct!' : 'Incorrect.',
                                      style: HermesTypography.itemTitle.copyWith(
                                        color: _isAnswerCorrect ? HermesColors.evolutioGlow : HermesColors.veritasColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: HermesSpacing.md),
                                if (_isAnswerCorrect) ...[
                                  Text(
                                    'The truth is uncovered. A step forward in your evolution has been recorded.',
                                    style: HermesTypography.body,
                                  ),
                                  const SizedBox(height: HermesSpacing.lg),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () => _recordEvolutio(true, customText: '🧠 A mathematical insight unlocked: ${widget.item.title}'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: HermesColors.evolutioGlow,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Log Evolutio & Continue'),
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    'The path remains hidden. Reflect on your misstep, or let Veritas guide you tonight.',
                                    style: HermesTypography.body,
                                  ),
                                  const SizedBox(height: HermesSpacing.lg),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _showAnswerFeedback = false;
                                          _evaluateController.clear();
                                        });
                                      },
                                      child: const Text('Try Again', style: TextStyle(color: HermesColors.veritasColor)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ] else ...[
                      // Reflection Area (For articles, notes, etc.)
                      const HermesSectionHeader(title: 'Reflection'),
                      const SizedBox(height: HermesSpacing.sm),
                      Text(
                        'What did you learn? How does this connect?',
                        style: HermesTypography.metadata,
                      ),
                      const SizedBox(height: HermesSpacing.md),
                      
                      if (!_showEvolutioPrompt) ...[
                        TextField(
                          controller: _reflectionController,
                          maxLines: 5,
                          style: HermesTypography.reflection,
                          decoration: InputDecoration(
                            hintText: 'Type your reflection...',
                            hintStyle: HermesTypography.reflection.copyWith(color: HermesColors.textTertiary),
                            filled: true,
                            fillColor: HermesColors.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(HermesRadius.md),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: HermesSpacing.lg),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _submitReflection,
                            child: const Text('Save Reflection', style: TextStyle(color: HermesColors.accent)),
                          ),
                        ),
                      ] else ...[
                        // EVOLUTIO PROMPT (The core equation)
                        HermesFadeIn(
                          child: Container(
                            padding: const EdgeInsets.all(HermesSpacing.lg),
                            decoration: BoxDecoration(
                              color: HermesColors.evolutioGlow.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(HermesRadius.lg),
                              border: Border.all(color: HermesColors.evolutioGlow.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Did this reflection genuinely change how you think or understand something?',
                                  style: HermesTypography.itemTitle.copyWith(color: HermesColors.evolutioGlow),
                                ),
                                const SizedBox(height: HermesSpacing.lg),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _recordEvolutio(false),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: HermesColors.textSecondary,
                                          side: const BorderSide(color: HermesColors.border),
                                          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                                        ),
                                        child: const Text('No, just save note'),
                                      ),
                                    ),
                                    const SizedBox(width: HermesSpacing.md),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _recordEvolutio(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: HermesColors.evolutioGlow,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                                        ),
                                        child: const Text('Yes, Record Evolutio'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
