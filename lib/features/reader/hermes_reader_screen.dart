import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/widgets/hermes_markdown.dart';
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
  
  double _fontSizeMultiplier = 1.0;
  double _lineHeightMultiplier = 1.0;
  double _readingWidth = 680.0;
  double _focusLevel = 0; // 0: Off, 1: Low, 2: Medium, 3: High

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

  void _showReadingSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(HermesSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reading Settings', style: HermesTypography.sectionTitle),
                  const SizedBox(height: HermesSpacing.lg),
                  
                  // Font Size
                  Text('Font Size', style: HermesTypography.metadata),
                  Slider(
                    value: _fontSizeMultiplier,
                    min: 0.8,
                    max: 1.5,
                    activeColor: HermesColors.evolutioGlow,
                    inactiveColor: HermesColors.border.withValues(alpha: 0.3),
                    onChanged: (val) {
                      setModalState(() => _fontSizeMultiplier = val);
                      setState(() => _fontSizeMultiplier = val);
                    },
                  ),
                  
                  // Line Height
                  Text('Line Height', style: HermesTypography.metadata),
                  Slider(
                    value: _lineHeightMultiplier,
                    min: 0.9,
                    max: 1.6,
                    activeColor: HermesColors.evolutioGlow,
                    inactiveColor: HermesColors.border.withValues(alpha: 0.3),
                    onChanged: (val) {
                      setModalState(() => _lineHeightMultiplier = val);
                      setState(() => _lineHeightMultiplier = val);
                    },
                  ),
                  
                  // Reading Width
                  Text('Reading Width', style: HermesTypography.metadata),
                  Slider(
                    value: _readingWidth,
                    min: 500,
                    max: 1000,
                    activeColor: HermesColors.evolutioGlow,
                    inactiveColor: HermesColors.border.withValues(alpha: 0.3),
                    onChanged: (val) {
                      setModalState(() => _readingWidth = val);
                      setState(() => _readingWidth = val);
                    },
                  ),
                  
                  // Focus Intensity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Focus Intensity', style: HermesTypography.metadata),
                      Text(
                        _focusLevel == 0 ? 'Off' : _focusLevel == 1 ? 'Low' : _focusLevel == 2 ? 'Medium' : 'High', 
                        style: HermesTypography.metadata.copyWith(color: HermesColors.evolutioGlow)
                      ),
                    ],
                  ),
                  Slider(
                    value: _focusLevel,
                    min: 0,
                    max: 3,
                    divisions: 3,
                    activeColor: HermesColors.evolutioGlow,
                    inactiveColor: HermesColors.border.withValues(alpha: 0.3),
                    onChanged: (val) {
                      setModalState(() => _focusLevel = val);
                      setState(() => _focusLevel = val);
                    },
                  ),
                ],
              ),
            ),
          );
        }
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
    
    final isGuide = widget.item.id.startsWith('hermes_guide');
    final isEditable = [ItemType.note, ItemType.idea, ItemType.observation].contains(widget.item.type) && !isGuide;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Main Reading Area
          SafeArea(
            bottom: false,
            child: Center(
              child: Builder(
                builder: (context) {
                  final Widget scrollContent = ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _readingWidth), // Optimal reading width
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
                          _buildPostReadingWorkflow(isGuide),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  );
                  
                  if (_focusLevel == 0) return scrollContent;
                  
                  double edgeOpacity = 1.0;
                  double midOpacity = 1.0;
                  if (_focusLevel == 1) { edgeOpacity = 0.7; midOpacity = 0.85; }
                  else if (_focusLevel == 2) { edgeOpacity = 0.4; midOpacity = 0.7; }
                  else if (_focusLevel == 3) { edgeOpacity = 0.15; midOpacity = 0.6; }

                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(edgeOpacity),
                          Colors.white.withOpacity(midOpacity),
                          Colors.white, // Center focus
                          Colors.white.withOpacity(midOpacity),
                          Colors.white.withOpacity(edgeOpacity),
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: scrollContent,
                  );
                }
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
                            icon: const Icon(Icons.copy_outlined, color: HermesColors.textTertiary, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: widget.item.content));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied entire text to clipboard.', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textPrimary)),
                                  backgroundColor: HermesColors.surfaceElevated,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            tooltip: 'Copy All Text',
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: HermesColors.textTertiary, size: 20),
                            onPressed: _showShareOptions,
                            tooltip: 'Share',
                          ),


                          IconButton(
                            icon: const Icon(Icons.font_download_outlined, color: HermesColors.textTertiary, size: 20),
                            onPressed: _showReadingSettings,
                            tooltip: 'Reading Settings',
                          ),
                          if (isEditable)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: HermesColors.textTertiary, size: 20),
                              onPressed: () {
                                CreateItemSheet.show(context, block: widget.block, existingItem: widget.item);
                              },
                              tooltip: 'Edit Document',
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
    String mdData = widget.item.content;
    final titlePattern = '# ${widget.item.title}';
    if (mdData.trimLeft().startsWith(titlePattern)) {
      mdData = mdData.trimLeft().substring(titlePattern.length).trimLeft();
    }
    return HermesMarkdown(
      data: mdData,
      fontSizeMultiplier: _fontSizeMultiplier,
      lineHeightMultiplier: _lineHeightMultiplier,
    );
  }

  Widget _buildPostReadingWorkflow(bool isGuide) {
    if (isGuide) return const SizedBox.shrink();

    switch (widget.item.type) {
      case ItemType.article:
        return _buildArticleWorkflow();
      case ItemType.note:
        return _buildNoteWorkflow();
      case ItemType.idea:
        return _buildIdeaWorkflow();
      case ItemType.observation:
        return _buildObservationWorkflow();
      case ItemType.reflection:
        return _buildReflectionWorkflow();
      case ItemType.question:
        return _buildQuestionWorkflow();
    }
  }

  Widget _buildWorkflowHeader(String title) {
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
        Text(title, style: HermesTypography.itemTitle.copyWith(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: HermesSpacing.md),
      ],
    );
  }

  Widget _buildWorkflowAction(String label, IconData icon, {Color? color, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HermesSpacing.sm),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(HermesRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md, horizontal: HermesSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(HermesRadius.md),
            border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color ?? HermesColors.textSecondary),
              const SizedBox(width: HermesSpacing.md),
              Expanded(
                child: Text(label, style: HermesTypography.body.copyWith(color: color ?? HermesColors.textSecondary)),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: HermesColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Reflection'),
        Text('• What challenged your thinking?', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6)),
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
              fillColor: const Color(0xFF111111),
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

  Widget _buildNoteWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Connections'),
        _buildWorkflowAction('Related Notes', Icons.account_tree_outlined),
        _buildWorkflowAction('Keywords', Icons.tag_rounded),
        _buildWorkflowAction('Backlinks', Icons.link_rounded),
        _buildWorkflowAction('Last Edited', Icons.history_rounded),
        _buildWorkflowAction('History', Icons.manage_history_rounded),
      ],
    );
  }

  Widget _buildIdeaWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Evolution'),
        _buildWorkflowAction('Expand this idea', Icons.open_in_full_rounded, color: HermesColors.accent),
        _buildWorkflowAction('Potential applications', Icons.api_rounded),
        _buildWorkflowAction('Connect to another Block', Icons.link_rounded),
        _buildWorkflowAction('Promote to Project', Icons.rocket_launch_outlined, color: HermesColors.evolutioGlow),
        _buildWorkflowAction('Archive', Icons.archive_outlined),
      ],
    );
  }

  Widget _buildObservationWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Synthesis'),
        _buildWorkflowAction('Why was this worth recording?', Icons.help_outline_rounded),
        _buildWorkflowAction('Did this observation lead to a pattern?', Icons.pattern_rounded),
        _buildWorkflowAction('Convert to Reflection', Icons.edit_note_rounded, color: HermesColors.reflectionColor),
        _buildWorkflowAction('Convert to Idea', Icons.lightbulb_outline_rounded, color: HermesColors.accent),
      ],
    );
  }

  Widget _buildReflectionWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Evolutio'),
        Text('Does this represent a fundamental shift in your thinking?', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6)),
        const SizedBox(height: HermesSpacing.lg),
        _buildWorkflowAction('Create Evolutio', Icons.auto_awesome_rounded, color: HermesColors.evolutioGlow),
        _buildWorkflowAction('Save Reflection', Icons.save_rounded),
      ],
    );
  }

  Widget _buildQuestionWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Resolution'),
        _buildWorkflowAction('Reveal Answer', Icons.visibility_outlined, color: HermesColors.accent),
        _buildWorkflowAction('Compare', Icons.compare_arrows_rounded),
        _buildWorkflowAction('Self Score', Icons.score_rounded),
        _buildWorkflowAction('Reflection', Icons.edit_note_rounded),
        _buildWorkflowAction('Complete', Icons.check_circle_outline_rounded, color: HermesColors.veritasColor),
      ],
    );
  }
}
