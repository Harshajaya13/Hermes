import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/constants/knowledge_guide.dart';
import '../reader/hermes_reader_screen.dart';
import 'create_manual_source_screen.dart';
import 'create_web_source_screen.dart';

class ManualPipelineScreen extends ConsumerWidget {
  const ManualPipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(sourcesProvider);
    final manualSources = sources
        .where((s) => s.type == SourceType.manualQuestion || s.type == SourceType.manualArticle)
        .toList();

    final questionSources = manualSources.where((s) => s.type == SourceType.manualQuestion).toList();
    final articleSources = manualSources.where((s) => s.type == SourceType.manualArticle).toList();

    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Manual Collection', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.screenHorizontal, vertical: HermesSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Knowledge Sources', style: HermesTypography.sectionTitle),
                  const SizedBox(height: HermesSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          final guideItem = Item(
                            id: 'hermes_guide_001',
                            blockId: 'system_guide',
                            sourceId: 'system',
                            type: ItemType.article,
                            title: 'The Knowledge Pipeline',
                            content: knowledgeGuideMarkdown,
                            createdAt: DateTime.now(),
                          );
                          final guideBlock = Block(
                            id: 'system_guide',
                            domainId: 'system',
                            name: 'Hermes Codex',
                            icon: '📚',
                            createdAt: DateTime.now(),
                          );
                          Navigator.push(context, MaterialPageRoute(builder: (_) => HermesReaderScreen(item: guideItem, block: guideBlock)));
                        },
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: const Text('Guide'),
                        style: TextButton.styleFrom(
                          foregroundColor: HermesColors.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: HermesColors.surfaceElevated,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateManualSourceScreen()));
                        },
                        icon: const Icon(Icons.upload_file_rounded, size: 18),
                        label: const Text('JSON File'),
                        style: TextButton.styleFrom(
                          foregroundColor: HermesColors.evolutioGlow,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: HermesColors.evolutioGlow.withValues(alpha: 0.1),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateWebSourceScreen()));
                        },
                        icon: const Icon(Icons.link_rounded, size: 18),
                        label: const Text('URL'),
                        style: TextButton.styleFrom(
                          foregroundColor: HermesColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: HermesColors.accent.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: HermesSpacing.md),
              
              if (questionSources.isNotEmpty) ...[
                Text('QUESTION SOURCES', style: HermesTypography.metadata),
                const SizedBox(height: HermesSpacing.sm),
                ...questionSources.map((s) => _buildSourceCard(context, ref, s)),
                const SizedBox(height: HermesSpacing.lg),
              ],
              
              if (articleSources.isNotEmpty) ...[
                Text('ARTICLE SOURCES', style: HermesTypography.metadata),
                const SizedBox(height: HermesSpacing.sm),
                ...articleSources.map((s) => _buildSourceCard(context, ref, s)),
              ],
              
              if (manualSources.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: HermesSpacing.xl),
                  child: Center(
                    child: Text('No manual sources created yet.\nTap "Add Source" to begin.', textAlign: TextAlign.center, style: HermesTypography.metadata),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceCard(BuildContext context, WidgetRef ref, KnowledgeSource source) {
    final blocks = ref.watch(allBlocksProvider);
    final domains = ref.watch(domainsProvider);
    final block = blocks.where((b) => b.id == source.targetBlockId).firstOrNull;
    final domain = domains.where((d) => d.id == source.targetDomainId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: HermesSpacing.md),
      child: HermesCard(
        onTap: () => _showEditRulesDialog(context, ref, source),
        child: Padding(
          padding: const EdgeInsets.all(HermesSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(source.name, style: HermesTypography.body.copyWith(fontWeight: FontWeight.bold)),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: HermesColors.textSecondary),
                    color: HermesColors.surfaceElevated,
                    onSelected: (val) async {
                      if (val == 'edit') {
                        _showEditRulesDialog(context, ref, source);
                      } else if (val == 'delete') {
                        await ref.read(storageEngineProvider).deleteSource(source.id);
                        ref.invalidate(sourcesProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Source deleted.'), backgroundColor: HermesColors.surfaceElevated),
                          );
                        }
                      } else if (val == 'replace') {
                        _handleReplaceJson(context, ref, source);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit Rules')),
                      const PopupMenuItem(value: 'replace', child: Text('Replace JSON')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete Source', style: TextStyle(color: HermesColors.error))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: HermesSpacing.sm),
              Text('${domain?.name ?? 'Unknown Domain'} > ${block?.name ?? 'Unknown Block'}', style: HermesTypography.metadata),
              const SizedBox(height: HermesSpacing.xs),
              Row(
                children: [
                  Icon(Icons.today_rounded, size: 14, color: source.includeInToday ? HermesColors.evolutioGlow : HermesColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(source.includeInToday ? 'Today\'s Pursuit (Max: ${source.dailyLimit})' : 'Excluded from Today\'s Pursuit', style: HermesTypography.metadata),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleReplaceJson(BuildContext context, WidgetRef ref, KnowledgeSource source) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final contents = await file.readAsString();
        final dynamic decoded = jsonDecode(contents);
        if (decoded is! List) throw Exception('Root element must be a JSON array.');
        if (decoded.length > 500) throw Exception('Maximum 500 items allowed per source.');
        
        final parsedData = <Map<String, dynamic>>[];
        for (final item in decoded) {
          if (item['title'] == null || item['content'] == null) throw Exception('Missing required fields.');
          parsedData.add({
            'title': item['title'].toString().trim(),
            'content': item['content'].toString().trim(),
            'sourceUrl': item['sourceUrl']?.toString().trim(),
          });
        }
        
        final storage = ref.read(storageEngineProvider);
        
        // 1. Delete all existing items for this source
        final oldItems = storage.getItems(source.targetBlockId).where((i) => i.sourceId == source.id).toList();
        for (final oldItem in oldItems) {
           await storage.deleteItem(oldItem.id); 
        }
        
        // 2. Insert new items
        final itemsToSave = parsedData.map((data) => Item(
          blockId: source.targetBlockId,
          sourceId: source.id,
          type: source.type == SourceType.manualQuestion ? ItemType.question : ItemType.article,
          title: data['title'],
          content: data['content'],
          sourceUrl: data['sourceUrl'],
          metadata: {
            'isDailyGoal': source.includeInToday,
          },
        )).toList();
        
        await storage.saveItems(itemsToSave);
        ref.invalidate(itemsByBlockProvider(source.targetBlockId));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Replaced with ${itemsToSave.length} new items!', style: const TextStyle(color: HermesColors.textSecondary)),
              backgroundColor: HermesColors.surfaceElevated,
            )
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error replacing JSON: $e'),
            backgroundColor: HermesColors.error,
          )
        );
      }
    }
  }

  void _showEditRulesDialog(BuildContext context, WidgetRef ref, KnowledgeSource source) {
    showDialog(
      context: context,
      builder: (context) => _EditRulesDialog(source: source),
    );
  }
}

class _EditRulesDialog extends ConsumerStatefulWidget {
  final KnowledgeSource source;
  const _EditRulesDialog({required this.source});

  @override
  ConsumerState<_EditRulesDialog> createState() => _EditRulesDialogState();
}

class _EditRulesDialogState extends ConsumerState<_EditRulesDialog> {
  late String _sourceName;
  late bool _includeInToday;
  late int _dailyLimit;
  Domain? _selectedDomain;
  Block? _selectedBlock;

  @override
  void initState() {
    super.initState();
    _sourceName = widget.source.name;
    _includeInToday = widget.source.includeInToday;
    _dailyLimit = widget.source.dailyLimit;
    
    // We will initialize domain and block in build since we need ref
  }

  @override
  Widget build(BuildContext context) {
    final domains = ref.watch(domainsProvider);
    
    // Initialize selected domain on first build
    _selectedDomain ??= domains.where((d) => d.id == widget.source.targetDomainId).firstOrNull;
    
    final blocks = _selectedDomain != null 
        ? ref.watch(blocksByDomainProvider(_selectedDomain!.id)) 
        : <Block>[];
        
    // Initialize selected block on first build if possible
    if (_selectedBlock == null && _selectedDomain != null) {
      _selectedBlock = blocks.where((b) => b.id == widget.source.targetBlockId).firstOrNull;
    }

    return AlertDialog(
      backgroundColor: HermesColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.lg)),
      title: Text('Edit Rules', style: HermesTypography.sectionTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source Name:', style: HermesTypography.metadata),
            const SizedBox(height: HermesSpacing.sm),
            TextFormField(
              initialValue: _sourceName,
              onChanged: (val) => _sourceName = val,
              decoration: InputDecoration(
                filled: true,
                fillColor: HermesColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: HermesSpacing.md),
            
            Text('Target Domain:', style: HermesTypography.metadata),
            const SizedBox(height: HermesSpacing.sm),
            DropdownButtonFormField<Domain>(
              value: _selectedDomain,
              dropdownColor: HermesColors.surfaceElevated,
              items: domains.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedDomain = val;
                  _selectedBlock = null; // reset block when domain changes
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: HermesColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: HermesSpacing.md),
            
            Text('Target Block:', style: HermesTypography.metadata),
            const SizedBox(height: HermesSpacing.sm),
            DropdownButtonFormField<Block>(
              value: _selectedBlock,
              dropdownColor: HermesColors.surfaceElevated,
              items: blocks.map((b) => DropdownMenuItem(value: b, child: Text('${b.icon} ${b.name}'))).toList(),
              onChanged: _selectedDomain == null ? null : (val) => setState(() => _selectedBlock = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: HermesColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: HermesSpacing.lg),
            
            SwitchListTile(
              title: const Text('Include in Today\'s Pursuit?', style: TextStyle(fontSize: 14)),
              value: _includeInToday,
              activeColor: HermesColors.evolutioGlow,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _includeInToday = val),
            ),
            if (_includeInToday) ...[
              const SizedBox(height: HermesSpacing.md),
              Text('Daily Maximum Limit:', style: HermesTypography.metadata),
              const SizedBox(height: HermesSpacing.sm),
              Wrap(
                spacing: HermesSpacing.sm,
                children: [1, 3, 5, 10].map((limit) {
                  return ChoiceChip(
                    label: Text('$limit'),
                    selected: _dailyLimit == limit,
                    onSelected: (val) {
                      if (val) setState(() => _dailyLimit = limit);
                    },
                    selectedColor: HermesColors.evolutioGlow.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: HermesColors.textSecondary)),
        ),
        TextButton(
          onPressed: () async {
            if (_sourceName.trim().isEmpty || _selectedDomain == null || _selectedBlock == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
              return;
            }
            
            final updatedSource = widget.source.copyWith(
              name: _sourceName.trim(),
              targetDomainId: _selectedDomain!.id,
              targetBlockId: _selectedBlock!.id,
              includeInToday: _includeInToday,
              dailyLimit: _dailyLimit,
            );
            
            final storage = ref.read(storageEngineProvider);
            
            // 1. Save updated source
            await storage.saveSource(updatedSource);
            
            // 2. If the block changed, we need to update all underlying items to the new block!
            if (widget.source.targetBlockId != updatedSource.targetBlockId) {
              final oldBlockId = widget.source.targetBlockId;
              final items = storage.getItems(oldBlockId).where((i) => i.sourceId == updatedSource.id).toList();
              
              final updatedItems = items.map((i) => i.copyWith(blockId: updatedSource.targetBlockId)).toList();
              await storage.saveItems(updatedItems);
              
              // Invalidate both blocks so UI updates perfectly
              ref.invalidate(itemsByBlockProvider(oldBlockId));
              ref.invalidate(itemsByBlockProvider(updatedSource.targetBlockId));
            }
            
            ref.invalidate(sourcesProvider);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save Rules', style: TextStyle(color: HermesColors.evolutioGlow)),
        ),
      ],
    );
  }
}
