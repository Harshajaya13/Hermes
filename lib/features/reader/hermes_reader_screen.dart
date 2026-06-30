import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/widgets/hermes_markdown.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../blocks/create_item_sheet.dart';
import 'connection_detail_screen.dart';

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
  String? _reflectionId;

  late int _articleStep;
  late int _questionStep;

  @override
  void initState() {
    super.initState();
    _articleStep = (widget.item.metadata?['isRead'] == true) ? 1 : 0;
    _questionStep = (widget.item.metadata?['isSolved'] == true) ? 3 : 0;
    if (widget.item.metadata?['userAnswer'] != null) {
      _answerController.text = widget.item.metadata!['userAnswer'];
    }
    if (widget.item.metadata?['questionReflection'] != null) {
      _questionReflectionController.text = widget.item.metadata!['questionReflection'];
    }
    
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = ref.read(storageEngineProvider);
      final existing = storage.getAllReflections().where((r) => r.itemId == widget.item.id).firstOrNull;
      if (existing != null) {
        _reflectionId = existing.id;
        _reflectionController.text = existing.content;
      }
      _reflectionController.addListener(_autoSaveReflection);
    });
    
    _answerController.addListener(_autoSaveQuestionData);
    _questionReflectionController.addListener(_autoSaveQuestionData);
  }

  void _autoSaveQuestionData() {
    final storage = ref.read(storageEngineProvider);
    final updatedMeta = Map<String, dynamic>.from(widget.item.metadata ?? {});
    updatedMeta['userAnswer'] = _answerController.text.trim();
    updatedMeta['questionReflection'] = _questionReflectionController.text.trim();
    final updatedItem = widget.item.copyWith(metadata: updatedMeta);
    storage.saveItems([updatedItem]);
  }

  void _autoSaveReflection() {
    final storage = ref.read(storageEngineProvider);
    final reflection = Reflection(
      id: _reflectionId,
      itemId: widget.item.id,
      content: _reflectionController.text.trim(),
    );
    _reflectionId = reflection.id;
    storage.saveReflection(reflection);
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
    _answerController.dispose();
    _questionReflectionController.dispose();
    super.dispose();
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
    
    final content = customText ?? _reflectionController.text.trim();
    final reflection = Reflection(
      id: _reflectionId,
      itemId: widget.item.id,
      content: content,
    );
    _reflectionId = reflection.id;
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
        HermesToast.show(context, 'Reading completed.');
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
                          Colors.white.withValues(alpha: edgeOpacity),
                          Colors.white.withValues(alpha: midOpacity),
                          Colors.white, // Center focus
                          Colors.white.withValues(alpha: midOpacity),
                          Colors.white.withValues(alpha: edgeOpacity),
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
                              final content = _getShareContent();
                              Clipboard.setData(ClipboardData(text: content));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied text to clipboard.', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textPrimary)),
                                  backgroundColor: HermesColors.surfaceElevated,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            tooltip: 'Copy Text',
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: HermesColors.textTertiary, size: 20),
                            onPressed: () {
                              final content = _getShareContent();
                              Share.share(content, subject: widget.item.title);
                            },
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
    final storage = ref.watch(storageEngineProvider);
    final currentItem = storage.getItemById(widget.item.id) ?? widget.item;
    
    String mdData = currentItem.content;
    final titlePattern = '# ${currentItem.title}';
    if (mdData.trimLeft().startsWith(titlePattern)) {
      mdData = mdData.trimLeft().substring(titlePattern.length).trimLeft();
    }
    
    if (currentItem.type == ItemType.idea) {
      final expansion = currentItem.metadata?['expansion'] as String?;
      if (expansion != null && expansion.isNotEmpty) {
        mdData += '\n\n---\n\n**Expansion:**\n\n$expansion';
      }
      final appsData = currentItem.metadata?['applications'];
      String appsText = '';
      if (appsData is List) {
        appsText = appsData.map((e) => e.toString()).join('\n\n');
      } else if (appsData is String) {
        appsText = appsData;
      }
      if (appsText.trim().isNotEmpty) {
        mdData += '\n\n---\n\n**Potential Applications:**\n\n$appsText';
      }
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

  // ── Article Workflow State ──────────────────────────────────────

  Widget _buildArticleWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Article Completion'),
        
        if (_articleStep == 0) ...[
          Text('Have you finished reading?', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6)),
          const SizedBox(height: HermesSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () async {
                setState(() => _articleStep = 1);
                final updatedMeta = Map<String, dynamic>.from(widget.item.metadata ?? {});
                updatedMeta['isRead'] = true;
                await ref.read(storageEngineProvider).saveItems([widget.item.copyWith(metadata: updatedMeta)]);
                ref.invalidate(itemsByBlockProvider(widget.block.id));
              },
              borderRadius: BorderRadius.circular(HermesRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm, horizontal: HermesSpacing.lg),
                decoration: BoxDecoration(
                  color: HermesColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(HermesRadius.md),
                  border: Border.all(color: HermesColors.border.withValues(alpha: 0.2)),
                ),
                child: Text('Mark Read', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary)),
              ),
            ),
          ),
        ] else ...[
          Text('Reflection (optional)', style: HermesTypography.itemTitle.copyWith(fontSize: 18)),
          const SizedBox(height: HermesSpacing.sm),
          Text('What challenged your thinking? What will you remember?', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6)),
          const SizedBox(height: HermesSpacing.xl),
          
          TextField(
            controller: _reflectionController,
            maxLines: null,
            minLines: 4,
            style: HermesTypography.body.copyWith(fontSize: 16, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Write your thoughts...',
              hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary, fontSize: 16),
              filled: true,
              fillColor: const Color(0xFF111111),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HermesRadius.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(HermesSpacing.lg),
            ),
          ),
          const SizedBox(height: HermesSpacing.xl),

          // Auto Evolutio — always created, always editable
          Container(
            padding: const EdgeInsets.all(HermesSpacing.xl),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(HermesRadius.lg),
              border: Border.all(color: HermesColors.evolutioGlow.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto Evolutio',
                  style: HermesTypography.itemTitle.copyWith(color: HermesColors.evolutioGlow, fontSize: 18),
                ),
                const SizedBox(height: HermesSpacing.sm),
                Text(
                  'An Evolutio will be generated for this reading.',
                  style: HermesTypography.metadata.copyWith(color: HermesColors.textTertiary, height: 1.5),
                ),
                const SizedBox(height: HermesSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        final text = _reflectionController.text.trim();
                        _recordEvolutio(true, customText: text.isNotEmpty ? text : 'Read: ${widget.item.title}');
                      },
                      borderRadius: BorderRadius.circular(HermesRadius.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm, horizontal: HermesSpacing.lg),
                        decoration: BoxDecoration(
                          color: HermesColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(HermesRadius.md),
                          border: Border.all(color: HermesColors.border.withValues(alpha: 0.2)),
                        ),
                        child: Text('Edit Evolutio', style: HermesTypography.body.copyWith(color: HermesColors.evolutioGlow)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: HermesSpacing.lg),
          _buildWorkflowAction('Archive', Icons.archive_outlined, onTap: () => _handleWorkflowAction('Archive')),
          const SizedBox(height: HermesSpacing.lg),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () async {
                setState(() => _articleStep = 0);
                final updatedMeta = Map<String, dynamic>.from(widget.item.metadata ?? {});
                updatedMeta['isRead'] = false;
                await ref.read(storageEngineProvider).saveItems([widget.item.copyWith(metadata: updatedMeta)]);
                ref.invalidate(itemsByBlockProvider(widget.block.id));
              },
              child: Text('Mark as Unread', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textTertiary)),
            ),
          ),
        ],
      ],
    );
  }

  void _handleWorkflowAction(String action) async {
    final terminalActions = ['Save Reflection', 'Complete', 'Convert to Idea', 'Convert to Reflection', 'Promote to Project'];
    
    if (action == 'Archive') {
      await ref.read(storageEngineProvider).deleteItem(widget.item.id);
      if (mounted) {
        ref.invalidate(itemsByBlockProvider(widget.block.id));
        Navigator.pop(context);
        HermesToast.show(context, 'Item archived.');
      }
      return;
    }

    if (terminalActions.contains(action)) {
      _recordEvolutio(false, customText: 'Completed via: $action');
    } else if (action == 'Create Evolutio') {
      _recordEvolutio(true, customText: 'Fundamental cognitive shift recorded.');
    } else {
      HermesToast.show(context, '$action workflow opens in next update.');
    }
  }

  Widget _buildConnectionsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final connections = ref.watch(itemConnectionsProvider(widget.item.id));
        final storage = ref.watch(storageEngineProvider);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (connections.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.md, vertical: HermesSpacing.xs),
                child: Text('Connected Items', style: HermesTypography.metadata),
              ),
              ...connections.map((c) {
                final targetId = c.itemAId == widget.item.id ? c.itemBId : c.itemAId;
                final targetItem = storage.getItemById(targetId);
                if (targetItem == null) return const SizedBox.shrink();
                
                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ConnectionDetailScreen(
                        connection: c,
                        itemA: widget.item,
                        itemB: targetItem,
                      ),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.md, vertical: HermesSpacing.xs),
                    child: Row(
                      children: [
                        const Text('•', style: TextStyle(color: HermesColors.textTertiary, fontSize: 16)),
                        const SizedBox(width: HermesSpacing.sm),
                        Expanded(
                          child: Text(
                            targetItem.title,
                            style: HermesTypography.bodySmall.copyWith(color: HermesColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: HermesSpacing.sm),
            ],
            _buildWorkflowAction(
              connections.isEmpty ? 'Connect Items' : 'Add New Connection',
              Icons.link_rounded,
              color: HermesColors.accent,
              onTap: () => _showConnectionSheet(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoteWorkflow() {
    final storage = ref.watch(storageEngineProvider);
    final currentItem = storage.getItemById(widget.item.id) ?? widget.item;
    final keywords = (currentItem.metadata?['keywords'] as List?)?.cast<String>() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Connections'),
        
        _buildConnectionsSection(),
        
        // Keywords
        _buildWorkflowAction(
          keywords.isEmpty ? 'Add Keywords' : 'Keywords: ${keywords.join(", ")}',
          Icons.label_outline_rounded,
          onTap: () {
            _showKeywordsSheet();
          },
        ),
        
        // Last Edited
        Padding(
          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm, horizontal: HermesSpacing.md),
          child: Text(
            'Last edited: ${currentItem.modifiedAt.toString().substring(0, 16)}',
            style: HermesTypography.metadata.copyWith(color: HermesColors.textTertiary),
          ),
        ),
      ],
    );
  }
  
  void _showKeywordsSheet() {
    final currentItem = ref.read(storageEngineProvider).getItemById(widget.item.id) ?? widget.item;
    final kwController = TextEditingController();
    final existingKw = List<String>.from(currentItem.metadata?['keywords'] ?? []);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: HermesSpacing.lg, right: HermesSpacing.lg,
            top: HermesSpacing.lg, bottom: MediaQuery.of(ctx).viewInsets.bottom + HermesSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Keywords', style: HermesTypography.sectionTitle),
              const SizedBox(height: HermesSpacing.md),
              if (existingKw.isNotEmpty) ...[
                Wrap(
                  spacing: HermesSpacing.xs,
                  runSpacing: HermesSpacing.xs,
                  children: existingKw.map((kw) => Chip(
                    label: Text(kw, style: HermesTypography.bodySmall),
                    backgroundColor: HermesColors.surface,
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () async {
                      existingKw.remove(kw);
                      final latestItem = ref.read(storageEngineProvider).getItemById(widget.item.id) ?? widget.item;
                      final updatedMeta = Map<String, dynamic>.from(latestItem.metadata ?? {});
                      updatedMeta['keywords'] = existingKw;
                      await ref.read(storageEngineProvider).saveItems([latestItem.copyWith(metadata: updatedMeta)]);
                      ref.invalidate(itemsByBlockProvider(widget.block.id));
                      setSheetState(() {});
                      if (mounted) setState(() {});
                    },
                  )).toList(),
                ),
                const SizedBox(height: HermesSpacing.sm),
              ],
              TextField(
                controller: kwController,
                autofocus: true,
                style: HermesTypography.body.copyWith(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Add a keyword and press Enter...',
                  hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                  filled: true, fillColor: HermesColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
                ),
                onSubmitted: (val) async {
                  if (val.trim().isEmpty) return;
                  existingKw.add(val.trim().toLowerCase());
                  final latestItem = ref.read(storageEngineProvider).getItemById(widget.item.id) ?? widget.item;
                  final updatedMeta = Map<String, dynamic>.from(latestItem.metadata ?? {});
                  updatedMeta['keywords'] = existingKw;
                  await ref.read(storageEngineProvider).saveItems([latestItem.copyWith(metadata: updatedMeta)]);
                  ref.invalidate(itemsByBlockProvider(widget.block.id));
                  kwController.clear();
                  setSheetState(() {});
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: HermesSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdeaWorkflow() {
    final storage = ref.watch(storageEngineProvider);
    final currentItem = storage.getItemById(widget.item.id) ?? widget.item;
    final isProject = currentItem.metadata?['isProject'] == true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Evolution'),
        
        // Expand Idea — original stays visible, write beneath
        _buildWorkflowAction('Expand Idea', Icons.expand_more_rounded, onTap: () {
          _showExpandIdeaSheet();
        }),
        
        // Potential Applications — stored separately
        _buildWorkflowAction('Potential Applications', Icons.apps_rounded, onTap: () {
          _showApplicationsSheet();
        }),
        
        // Connections
        _buildConnectionsSection(),
        
        // Promote To Project
        _buildWorkflowAction(
          isProject ? 'Remove Project ✦' : 'Promote to Project',
          Icons.rocket_launch_outlined,
          color: isProject ? HermesColors.veritasColor : HermesColors.evolutioGlow,
          onTap: () async {
            final latestItem = ref.read(storageEngineProvider).getItemById(widget.item.id) ?? widget.item;
            final updatedMeta = Map<String, dynamic>.from(latestItem.metadata ?? {});
            updatedMeta['isProject'] = !isProject;
            final updatedItem = latestItem.copyWith(metadata: updatedMeta);
            await ref.read(storageEngineProvider).saveItems([updatedItem]);
            ref.invalidate(itemsByBlockProvider(widget.block.id));
            if (mounted) {
              setState(() {});
              HermesToast.show(context, isProject ? 'Removed from Projects.' : 'Promoted to Project.');
            }
          },
        ),
        
        // Archive
        _buildWorkflowAction('Archive', Icons.archive_outlined, onTap: () => _handleWorkflowAction('Archive')),
      ],
    );
  }
  
  void _showExpandIdeaSheet() async {
    final expansionController = TextEditingController(
      text: widget.item.metadata?['expansion'] as String? ?? '',
    );
    await showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: HermesSpacing.lg, right: HermesSpacing.lg,
          top: HermesSpacing.lg, bottom: MediaQuery.of(ctx).viewInsets.bottom + HermesSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expand Idea', style: HermesTypography.sectionTitle),
            const SizedBox(height: HermesSpacing.md),
            Container(
              padding: const EdgeInsets.all(HermesSpacing.md),
              decoration: BoxDecoration(
                color: HermesColors.surface,
                borderRadius: BorderRadius.circular(HermesRadius.sm),
                border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
              ),
              child: Text(widget.item.content, style: HermesTypography.bodySmall.copyWith(color: HermesColors.textTertiary), maxLines: 5, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: HermesSpacing.md),
            TextField(
              controller: expansionController,
              maxLines: null,
              minLines: 4,
              autofocus: true,
              style: HermesTypography.body.copyWith(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Continue developing this idea...',
                hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                filled: true, fillColor: HermesColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: HermesSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: Text('Save', style: TextStyle(color: HermesColors.evolutioGlow)),
              ),
            ),
          ],
        ),
      ),
    );
    
    final updatedMeta = Map<String, dynamic>.from(widget.item.metadata ?? {});
    final newExpansion = expansionController.text.trim();
    if (updatedMeta['expansion'] != newExpansion) {
      updatedMeta['expansion'] = newExpansion;
      final updatedItem = widget.item.copyWith(metadata: updatedMeta);
      await ref.read(storageEngineProvider).saveItems([updatedItem]);
      ref.invalidate(itemsByBlockProvider(widget.block.id));
      if (mounted) {
        setState(() {});
        HermesToast.show(context, 'Idea expanded.');
      }
    }
  }
  
  void _showApplicationsSheet() async {
    final storage = ref.read(storageEngineProvider);
    final currentItem = storage.getItemById(widget.item.id) ?? widget.item;
    
    final appsData = currentItem.metadata?['applications'];
    String initialText = '';
    if (appsData is List) {
      initialText = appsData.map((e) => e.toString()).join('\n\n');
    } else if (appsData is String) {
      initialText = appsData;
    }
    
    final appController = TextEditingController(text: initialText);
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: HermesSpacing.lg, right: HermesSpacing.lg,
          top: HermesSpacing.lg, bottom: MediaQuery.of(ctx).viewInsets.bottom + HermesSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Potential Applications', style: HermesTypography.sectionTitle),
            const SizedBox(height: HermesSpacing.md),
            TextField(
              controller: appController,
              maxLines: null,
              minLines: 4,
              autofocus: true,
              style: HermesTypography.body.copyWith(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Write potential applications here...',
                hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                filled: true, fillColor: HermesColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: HermesSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: Text('Save', style: TextStyle(color: HermesColors.evolutioGlow)),
              ),
            ),
          ],
        ),
      ),
    );
    
    final updatedMeta = Map<String, dynamic>.from(currentItem.metadata ?? {});
    final newText = appController.text.trim();
    if (updatedMeta['applications'] != newText) {
      updatedMeta['applications'] = newText;
      final updatedItem = currentItem.copyWith(metadata: updatedMeta);
      await ref.read(storageEngineProvider).saveItems([updatedItem]);
      if (mounted) {
        ref.invalidate(itemsByBlockProvider(widget.block.id));
        setState(() {});
        HermesToast.show(context, 'Applications saved.');
      }
    }
  }
  
  void _showConnectionSheet() {
    final storage = ref.read(storageEngineProvider);
    final workspace = ref.read(currentWorkspaceProvider);
    if (workspace == null) return;
    
    final domains = storage.getDomains(workspace.id);
    String? selectedDomainId;
    String? selectedBlockId;
    String? selectedItemId;
    final noteController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final blocks = selectedDomainId != null ? storage.getBlocks(selectedDomainId!) : <Block>[];
          final items = selectedBlockId != null
              ? storage.getItems(selectedBlockId!).where((i) => i.id != widget.item.id).toList()
              : <Item>[];
          
          return Padding(
            padding: EdgeInsets.only(
              left: HermesSpacing.lg, right: HermesSpacing.lg,
              top: HermesSpacing.lg, bottom: MediaQuery.of(ctx).viewInsets.bottom + HermesSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connect', style: HermesTypography.sectionTitle),
                const SizedBox(height: HermesSpacing.lg),
                
                // Step 1: Choose Domain
                Text('Choose Domain', style: HermesTypography.metadata),
                const SizedBox(height: HermesSpacing.xs),
                Wrap(
                  spacing: HermesSpacing.xs,
                  children: domains.map((d) => ChoiceChip(
                    label: Text(d.name, style: HermesTypography.bodySmall),
                    selected: selectedDomainId == d.id,
                    selectedColor: HermesColors.accent.withValues(alpha: 0.2),
                    backgroundColor: HermesColors.surface,
                    onSelected: (_) => setSheetState(() {
                      selectedDomainId = d.id;
                      selectedBlockId = null;
                      selectedItemId = null;
                    }),
                  )).toList(),
                ),
                
                // Step 2: Choose Block
                if (selectedDomainId != null && blocks.isNotEmpty) ...[
                  const SizedBox(height: HermesSpacing.md),
                  Text('Choose Block', style: HermesTypography.metadata),
                  const SizedBox(height: HermesSpacing.xs),
                  Wrap(
                    spacing: HermesSpacing.xs,
                    children: blocks.map((b) => ChoiceChip(
                      label: Text(b.name, style: HermesTypography.bodySmall),
                      selected: selectedBlockId == b.id,
                      selectedColor: HermesColors.accent.withValues(alpha: 0.2),
                      backgroundColor: HermesColors.surface,
                      onSelected: (_) => setSheetState(() {
                        selectedBlockId = b.id;
                        selectedItemId = null;
                      }),
                    )).toList(),
                  ),
                ],
                
                // Step 3: Choose Item
                if (selectedBlockId != null && items.isNotEmpty) ...[
                  const SizedBox(height: HermesSpacing.md),
                  Text('Choose Item', style: HermesTypography.metadata),
                  const SizedBox(height: HermesSpacing.xs),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView(
                      shrinkWrap: true,
                      children: items.map((i) => ListTile(
                        dense: true,
                        title: Text(i.title, style: HermesTypography.bodySmall.copyWith(
                          color: selectedItemId == i.id ? HermesColors.accent : HermesColors.textSecondary,
                        )),
                        trailing: selectedItemId == i.id ? const Icon(Icons.check, size: 16, color: HermesColors.accent) : null,
                        onTap: () => setSheetState(() => selectedItemId = i.id),
                      )).toList(),
                    ),
                  ),
                ],
                
                if (selectedItemId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: HermesSpacing.md, bottom: HermesSpacing.lg),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          final storage = ref.read(storageEngineProvider);
                          final targetItem = storage.getItemById(selectedItemId!);
                          if (targetItem == null) return;
                          
                          final existingConnections = storage.getConnectionsForItem(widget.item.id);
                          final existing = existingConnections.where((c) => c.itemAId == selectedItemId || c.itemBId == selectedItemId).firstOrNull;
                          
                          Connection connection;
                          if (existing != null) {
                            connection = existing;
                          } else {
                            connection = Connection(
                              itemAId: widget.item.id,
                              itemBId: selectedItemId!,
                              title: '${widget.item.title} ↔ ${targetItem.title}',
                            );
                            await storage.saveConnection(connection);
                          }
                          
                          ref.invalidate(itemConnectionsProvider(widget.item.id));
                          ref.invalidate(itemConnectionsProvider(targetItem.id));
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            setState(() {});
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ConnectionDetailScreen(
                                connection: connection,
                                itemA: widget.item,
                                itemB: targetItem,
                              ),
                            ));
                          }
                        },
                        child: Text('Create Connection', style: TextStyle(color: HermesColors.evolutioGlow)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildObservationWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Synthesis'),
        
        // Why worth recording
        _buildWorkflowAction('Why worth recording', Icons.help_outline_rounded, onTap: () {
          _showObservationReasoningSheet();
        }),

        _buildConnectionsSection(),

        _buildWorkflowAction('Convert to Reflection', Icons.auto_awesome_rounded, color: HermesColors.evolutioGlow, onTap: () async {
          final updatedItem = widget.item.copyWith(type: ItemType.reflection);
          await ref.read(storageEngineProvider).saveItems([updatedItem]);
          ref.invalidate(itemsByBlockProvider(widget.block.id));
          if (mounted) {
            HermesToast.show(context, 'Converted to Reflection.');
            Navigator.pop(context);
          }
        }),
        _buildWorkflowAction('Convert to Idea', Icons.lightbulb_outline_rounded, color: HermesColors.accent, onTap: () async {
          final updatedItem = widget.item.copyWith(type: ItemType.idea);
          await ref.read(storageEngineProvider).saveItems([updatedItem]);
          ref.invalidate(itemsByBlockProvider(widget.block.id));
          if (mounted) {
            HermesToast.show(context, 'Converted to Idea.');
            Navigator.pop(context);
          }
        }),
      ],
    );
  }
  
  void _showObservationReasoningSheet() {
    final reasonController = TextEditingController(
      text: widget.item.metadata?['reasoning'] as String? ?? '',
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: HermesSpacing.lg, right: HermesSpacing.lg,
          top: HermesSpacing.lg, bottom: MediaQuery.of(ctx).viewInsets.bottom + HermesSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Why worth recording', style: HermesTypography.sectionTitle),
            const SizedBox(height: HermesSpacing.md),
            // Original observation visible as context
            Container(
              padding: const EdgeInsets.all(HermesSpacing.md),
              decoration: BoxDecoration(
                color: HermesColors.surface,
                borderRadius: BorderRadius.circular(HermesRadius.sm),
                border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
              ),
              child: Text(widget.item.content, style: HermesTypography.bodySmall.copyWith(color: HermesColors.textTertiary), maxLines: 5, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: HermesSpacing.md),
            TextField(
              controller: reasonController,
              maxLines: null,
              minLines: 4,
              autofocus: true,
              style: HermesTypography.body.copyWith(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Continue writing below the observation...',
                hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                filled: true, fillColor: HermesColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: HermesSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final updatedMeta = Map<String, dynamic>.from(widget.item.metadata ?? {});
                  updatedMeta['reasoning'] = reasonController.text.trim();
                  final updatedItem = widget.item.copyWith(metadata: updatedMeta);
                  await ref.read(storageEngineProvider).saveItems([updatedItem]);
                  ref.invalidate(itemsByBlockProvider(widget.block.id));
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) HermesToast.show(context, 'Reasoning added.');
                },
                child: Text('Save', style: TextStyle(color: HermesColors.evolutioGlow)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showObservationPatternSheet() {
    final patternController = TextEditingController();
    final existingPatterns = List<String>.from(widget.item.metadata?['patterns'] ?? []);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: HermesSpacing.lg, right: HermesSpacing.lg,
            top: HermesSpacing.lg, bottom: MediaQuery.of(ctx).viewInsets.bottom + HermesSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pattern', style: HermesTypography.sectionTitle),
              const SizedBox(height: HermesSpacing.md),
              ...existingPatterns.map((app) => Padding(
                padding: const EdgeInsets.only(bottom: HermesSpacing.xs),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: HermesColors.textTertiary),
                    const SizedBox(width: HermesSpacing.sm),
                    Expanded(child: Text(app, style: HermesTypography.bodySmall)),
                  ],
                ),
              )),
              const SizedBox(height: HermesSpacing.sm),
              TextField(
                controller: patternController,
                autofocus: true,
                style: HermesTypography.body.copyWith(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Record recurring patterns...',
                  hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                  filled: true, fillColor: HermesColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
                ),
                onSubmitted: (val) async {
                  if (val.trim().isEmpty) return;
                  existingPatterns.add(val.trim());
                  final updatedMeta = Map<String, dynamic>.from(widget.item.metadata ?? {});
                  updatedMeta['patterns'] = existingPatterns;
                  final updatedItem = widget.item.copyWith(metadata: updatedMeta);
                  await ref.read(storageEngineProvider).saveItems([updatedItem]);
                  ref.invalidate(itemsByBlockProvider(widget.block.id));
                  patternController.clear();
                  setSheetState(() {});
                },
              ),
              const SizedBox(height: HermesSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Evolutio'),
        Text('Does this represent a fundamental shift in your thinking?', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6)),
        const SizedBox(height: HermesSpacing.lg),
        TextField(
          controller: _reflectionController,
          maxLines: null,
          minLines: 4,
          style: HermesTypography.body.copyWith(fontSize: 16, height: 1.6),
          decoration: InputDecoration(
            hintText: 'Write your reflection...',
            hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary, fontSize: 16),
            filled: true,
            fillColor: const Color(0xFF111111),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(HermesRadius.md),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(HermesSpacing.lg),
          ),
        ),
        const SizedBox(height: HermesSpacing.xl),
        _buildWorkflowAction('Create Evolutio', Icons.auto_awesome_rounded, color: HermesColors.evolutioGlow, onTap: () => _handleWorkflowAction('Create Evolutio')),
        _buildWorkflowAction('Save Reflection', Icons.save_rounded, onTap: () => _handleWorkflowAction('Save Reflection')),
      ],
    );
  }

  // ── Question Workflow State ──────────────────────────────────────
  final _answerController = TextEditingController();
  final _questionReflectionController = TextEditingController();
  bool _solutionRevealed = false;

  Widget _buildQuestionWorkflow() {
    final officialSolution = widget.item.metadata?['officialSolution'] as String? ?? widget.item.metadata?['officialAnswer'] as String? ?? '';
    final explanation = widget.item.metadata?['explanation'] as String? ?? '';
    final hasOfficialAnswer = officialSolution.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkflowHeader('Resolution'),
        
        // Step 0: Write your answer
        if (_questionStep == 0) ...[
          Text(
            'Write your answer before seeing the solution.',
            style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: HermesSpacing.lg),
          TextField(
            controller: _answerController,
            maxLines: null,
            minLines: 5,
            style: HermesTypography.body.copyWith(fontSize: 16, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Think through it. Write your reasoning...',
              hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary, fontSize: 16),
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
                if (_answerController.text.trim().isNotEmpty) {
                  setState(() => _questionStep = hasOfficialAnswer ? 1 : 3);
                }
              },
              borderRadius: BorderRadius.circular(HermesRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm, horizontal: HermesSpacing.lg),
                decoration: BoxDecoration(
                  color: HermesColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(HermesRadius.md),
                  border: Border.all(color: HermesColors.border.withValues(alpha: 0.2)),
                ),
                child: Text(hasOfficialAnswer ? 'Validate Answer' : 'Continue to Reflection', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary)),
              ),
            ),
          ),
        ],
        
        // Step 1: Validate — confirm you're ready to see the solution
        if (hasOfficialAnswer && _questionStep == 1) ...[
          Container(
            padding: const EdgeInsets.all(HermesSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(HermesRadius.md),
              border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Answer', style: HermesTypography.metadata.copyWith(color: HermesColors.textTertiary)),
                const SizedBox(height: HermesSpacing.sm),
                Text(_answerController.text.trim(), style: HermesTypography.body.copyWith(height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: HermesSpacing.xl),
          Text(
            'Are you satisfied with your reasoning?',
            style: HermesTypography.body.copyWith(color: HermesColors.textSecondary),
          ),
          const SizedBox(height: HermesSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _questionStep = 0),
                child: Text('Revise', style: TextStyle(color: HermesColors.textTertiary)),
              ),
              const SizedBox(width: HermesSpacing.md),
              InkWell(
                onTap: () => setState(() => _questionStep = 2),
                borderRadius: BorderRadius.circular(HermesRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm, horizontal: HermesSpacing.lg),
                  decoration: BoxDecoration(
                    color: HermesColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(HermesRadius.md),
                    border: Border.all(color: HermesColors.border.withValues(alpha: 0.2)),
                  ),
                  child: Text('Reveal Solution', style: HermesTypography.body.copyWith(color: HermesColors.accent)),
                ),
              ),
            ],
          ),
        ],
        
        // Step 2: Reveal Official Solution
        if (hasOfficialAnswer && _questionStep == 2) ...[
          Container(
            padding: const EdgeInsets.all(HermesSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(HermesRadius.md),
              border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Answer', style: HermesTypography.metadata.copyWith(color: HermesColors.textTertiary)),
                const SizedBox(height: HermesSpacing.sm),
                Text(_answerController.text.trim(), style: HermesTypography.body.copyWith(height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: HermesSpacing.xl),
          Container(
            padding: const EdgeInsets.all(HermesSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(HermesRadius.md),
              border: Border.all(color: HermesColors.accent.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Official Solution', style: HermesTypography.metadata.copyWith(color: HermesColors.accent)),
                const SizedBox(height: HermesSpacing.sm),
                Text(officialSolution, style: HermesTypography.body.copyWith(height: 1.6)),
                if (explanation.isNotEmpty) ...[
                  const SizedBox(height: HermesSpacing.lg),
                  Text('Explanation', style: HermesTypography.metadata.copyWith(color: HermesColors.textSecondary)),
                  const SizedBox(height: HermesSpacing.xs),
                  Text(explanation, style: HermesTypography.body.copyWith(color: HermesColors.textTertiary, height: 1.5)),
                ],
              ],
            ),
          ),
          const SizedBox(height: HermesSpacing.xl),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => setState(() => _questionStep = 3),
              borderRadius: BorderRadius.circular(HermesRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm, horizontal: HermesSpacing.lg),
                decoration: BoxDecoration(
                  color: HermesColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(HermesRadius.md),
                  border: Border.all(color: HermesColors.border.withValues(alpha: 0.2)),
                ),
                child: Text('Continue', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary)),
              ),
            ),
          ),
        ],
        
        // Step 3: Reflection (optional) → Complete
        if (_questionStep == 3) ...[
          Text(
            'Reflection (optional)',
            style: HermesTypography.itemTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: HermesSpacing.sm),
          Text(
            'What did you learn? Where was your reasoning wrong?',
            style: HermesTypography.body.copyWith(color: HermesColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: HermesSpacing.lg),
          TextField(
            controller: _questionReflectionController,
            maxLines: null,
            minLines: 3,
            style: HermesTypography.body.copyWith(fontSize: 16, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Optional: capture what changed in your understanding...',
              hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary, fontSize: 16),
              filled: true,
              fillColor: const Color(0xFF111111),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HermesRadius.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(HermesSpacing.lg),
            ),
          ),
          const SizedBox(height: HermesSpacing.xl),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                final reflectionText = _questionReflectionController.text.trim();
                final hasReflection = reflectionText.isNotEmpty;
                
                // Save the user's answer into the item metadata
                final updatedMeta = Map<String, dynamic>.from(widget.item.metadata ?? {});
                updatedMeta['userAnswer'] = _answerController.text.trim();
                updatedMeta['isSolved'] = true;
                if (hasReflection) updatedMeta['questionReflection'] = reflectionText;
                
                _recordEvolutio(hasReflection, customText: hasReflection ? reflectionText : 'Solved: ${widget.item.title}');
              },
              borderRadius: BorderRadius.circular(HermesRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm, horizontal: HermesSpacing.lg),
                decoration: BoxDecoration(
                  color: HermesColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(HermesRadius.md),
                  border: Border.all(color: HermesColors.border.withValues(alpha: 0.2)),
                ),
                child: Text('Complete', style: HermesTypography.body.copyWith(color: HermesColors.evolutioGlow)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getShareContent() {
    final item = widget.item;
    final engine = ref.read(storageEngineProvider);
    final reflection = engine.getReflectionForItem(item.id);
    
    switch (item.type) {
      case ItemType.article:
        return '${item.title}\n\n${item.content}';
        
      case ItemType.question:
        final answer = item.metadata?['answer'] as String?;
        final parts = <String>[];
        parts.add('Question: ${item.title}');
        if (item.content.isNotEmpty) {
          parts.add(item.content);
        }
        if (answer != null && answer.isNotEmpty) {
          parts.add('\nMy Answer:\n$answer');
        }
        if (reflection != null && reflection.content.isNotEmpty) {
          parts.add('\nReflection:\n${reflection.content}');
        }
        return parts.join('\n');
        
      case ItemType.note:
        return item.content;
        
      case ItemType.idea:
        return '${item.title}\n\n${item.content}';
        
      case ItemType.observation:
        final patterns = List<String>.from(item.metadata?['patterns'] ?? []);
        final parts = <String>[];
        parts.add(item.content);
        if (patterns.isNotEmpty) {
          parts.add('\nPatterns Observed:');
          for (final p in patterns) {
            parts.add('- $p');
          }
        }
        return parts.join('\n');
        
      case ItemType.reflection:
        return item.content;
        
      default:
        return '${item.title}\n\n${item.content}';
    }
  }
}
