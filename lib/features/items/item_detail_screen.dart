import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/widgets/hermes_markdown.dart';
import '../blocks/create_item_sheet.dart';
import '../../core/providers/providers.dart';
import '../reader/hermes_reader_screen.dart';

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

  @override
  void dispose() {
    _reflectionController.dispose();
    _evaluateController.dispose();
    super.dispose();
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined, color: HermesColors.textSecondary),
                title: const Text('Share Text Content'),
                subtitle: const Text('Best for sharing with non-Hermes users', style: TextStyle(color: HermesColors.textTertiary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(widget.item.content, subject: widget.item.title);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined, color: HermesColors.textSecondary),
                title: const Text('Export as .hitem'),
                subtitle: const Text('Best for sending to another Hermes workspace', style: TextStyle(color: HermesColors.textTertiary, fontSize: 12)),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final engine = ref.read(exchangeEngineProvider);
                    final path = await engine.exportItems([widget.item]);
                    await Share.shareXFiles([XFile(path)], subject: '${widget.item.title} (Hermes)');
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e'), backgroundColor: HermesColors.veritasColor),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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
    
    // Mark item as solved so it drops out of Today's Pursuit
    final updatedMetadata = Map<String, dynamic>.from(widget.item.metadata ?? {});
    updatedMetadata['isSolved'] = true;
    final updatedItem = widget.item.copyWith(metadata: updatedMetadata);
    await storage.saveItems([updatedItem]);
    ref.invalidate(itemsByBlockProvider(widget.block.id));
    if (mounted) Navigator.pop(context);
  }

  void _evaluateAnswer() {
    final ans = _evaluateController.text.trim();
    if (ans.isEmpty) return;
    
    setState(() {
      _showAnswerFeedback = true;
      final expected = widget.item.metadata?['answer']?.toString().toLowerCase();
      if (expected != null && expected.isNotEmpty) {
        _isAnswerCorrect = ans.toLowerCase() == expected;
      } else {
        _isAnswerCorrect = true; // If no explicit answer, self-evaluated as correct
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.type == ItemType.article) {
      return HermesReaderScreen(item: widget.item, block: widget.block);
    }

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
            icon: const Icon(Icons.share_outlined, color: HermesColors.textSecondary, size: 20),
            onPressed: _showShareOptions,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: HermesColors.textSecondary, size: 20),
            onPressed: () {
              CreateItemSheet.show(context, block: widget.block, existingItem: widget.item);
            },
            tooltip: 'Edit Item',
          ),
          const SizedBox(width: HermesSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HermesSpacing.screenHorizontal,
                      vertical: HermesSpacing.xl,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: _buildLayout(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayout() {
    switch (widget.item.type) {
      case ItemType.question:
        return _buildQuestionLayout();
      case ItemType.article:
        return _buildArticleLayout();
      case ItemType.idea:
        return _buildIdeaLayout();
      case ItemType.observation:
        return _buildObservationLayout();
      default:
        return _buildDefaultLayout();
    }
  }

  Widget _buildMarkdownContent() {
    String mdData = widget.item.content;
    final titlePattern = '# ${widget.item.title}';
    if (mdData.trimLeft().startsWith(titlePattern)) {
      mdData = mdData.trimLeft().substring(titlePattern.length).trimLeft();
    }
    return HermesMarkdown(data: mdData);
  }

  Widget _buildReflectionSection(String title, String subtitle, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HermesSectionHeader(title: title),
        const SizedBox(height: HermesSpacing.sm),
        Text(
          subtitle,
          style: HermesTypography.metadata,
        ),
        const SizedBox(height: HermesSpacing.md),
        
        if (!_showEvolutioPrompt) ...[
          TextField(
            controller: _reflectionController,
            maxLines: 5,
            style: HermesTypography.reflection,
            decoration: InputDecoration(
              hintText: hint,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _recordEvolutio(true, customText: 'Recorded an Evolutio without a formal reflection.'),
                child: const Text('Record Evolutio', style: TextStyle(color: HermesColors.evolutioGlow)),
              ),
              const SizedBox(width: HermesSpacing.md),
              ElevatedButton(
                onPressed: _submitReflection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HermesColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Reflection'),
              ),
            ],
          ),
        ] else ...[
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
    );
  }

  Widget _buildQuestionLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Topic: ${widget.block.name}', style: HermesTypography.metadata),
        const SizedBox(height: HermesSpacing.sm),
        Text(
          widget.item.title, 
          style: HermesTypography.screenTitle.copyWith(
            fontSize: 40, 
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: HermesSpacing.xl),
        _buildMarkdownContent(),
        const SizedBox(height: HermesSpacing.xxxl),
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
      ],
    );
  }

  Widget _buildArticleLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Article', style: HermesTypography.metadata),
        const SizedBox(height: HermesSpacing.sm),
        Text(
          widget.item.title, 
          style: HermesTypography.screenTitle.copyWith(
            fontSize: 40, 
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: HermesSpacing.xl),
        _buildMarkdownContent(),
        const SizedBox(height: HermesSpacing.xxxl),
        _buildReflectionSection(
          'Think', 
          'What did you learn? How does this reading change your perspective?', 
          'Type your reflection...'
        ),
      ],
    );
  }

  Widget _buildIdeaLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Idea', style: HermesTypography.metadata),
        const SizedBox(height: HermesSpacing.sm),
        Text(
          widget.item.title, 
          style: HermesTypography.screenTitle.copyWith(
            fontSize: 40, 
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: HermesSpacing.md),
        Wrap(
          spacing: 8.0,
          children: ['#create', '#${widget.block.name.toLowerCase().replaceAll(' ', '')}'].map((t) => Chip(
            label: Text(t, style: const TextStyle(fontSize: 12)),
            backgroundColor: HermesColors.surfaceElevated,
          )).toList(),
        ),
        const SizedBox(height: HermesSpacing.lg),
        _buildMarkdownContent(),
        const SizedBox(height: HermesSpacing.xxxl),
        _buildReflectionSection(
          'Expand & Think', 
          'How does this idea connect to what you already know? Where does it lead?', 
          'Elaborate on this idea...'
        ),
      ],
    );
  }

  Widget _buildObservationLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.item.createdAt.toString().substring(0, 10), style: HermesTypography.metadata),
        const SizedBox(height: HermesSpacing.sm),
        Text(
          widget.item.title, 
          style: HermesTypography.screenTitle.copyWith(
            fontSize: 40, 
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: HermesSpacing.xl),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(HermesSpacing.md),
          decoration: BoxDecoration(
            color: HermesColors.surfaceElevated,
            borderRadius: BorderRadius.circular(HermesRadius.md),
            border: Border.all(color: HermesColors.border),
          ),
          child: _buildMarkdownContent(),
        ),
        const SizedBox(height: HermesSpacing.xxxl),
        _buildReflectionSection(
          'Think', 
          'What does this observation reveal? Should it change how you act?', 
          'Reflect on this observation...'
        ),
      ],
    );
  }

  Widget _buildDefaultLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item.title, 
          style: HermesTypography.screenTitle.copyWith(
            fontSize: 40, 
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: HermesSpacing.sm),
        Text('In ${widget.block.name}', style: HermesTypography.metadata),
        const SizedBox(height: HermesSpacing.xl),
        _buildMarkdownContent(),
        const SizedBox(height: HermesSpacing.xxxl),
        _buildReflectionSection(
          'Think', 
          'What did you learn? How does this connect?', 
          'Type your reflection...'
        ),
      ],
    );
  }
}
