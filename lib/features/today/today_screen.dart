import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../reader/hermes_reader_screen.dart';
import '../archive/archive_screen.dart';
import '../evolution/veritas_sheet.dart';
import '../blocks/block_detail_screen.dart';
import '../blocks/domain_detail_screen.dart';
import '../blocks/create_item_sheet.dart';
import 'workspace_security_dialogs.dart';
import 'visibility_screen.dart';

class StarterWelcomeBanner extends StatefulWidget {
  const StarterWelcomeBanner({super.key});

  @override
  State<StarterWelcomeBanner> createState() => _StarterWelcomeBannerState();
}

class _StarterWelcomeBannerState extends State<StarterWelcomeBanner> {
  bool _isVisible = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
  }

  Future<void> _checkVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isVisible = prefs.getBool('welcome_dismissed') != true;
        _isLoading = false;
      });
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcome_dismissed', true);
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_isVisible) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        children: [
          HermesFadeIn(
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.screenHorizontal),
              child: Container(
                padding: const EdgeInsets.all(HermesSpacing.lg),
                decoration: BoxDecoration(
                  color: HermesColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(HermesRadius.md),
                  border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Welcome to Hermes.', style: HermesTypography.body.copyWith(color: HermesColors.textPrimary)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: HermesColors.textTertiary),
                          onPressed: _dismiss,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: HermesSpacing.sm),
                    Text(
                      'This workspace exists to demonstrate what Hermes can do.\n\nExplore it.\nModify it.\nDelete it.\nOr archive it when you\'re ready to begin your own journey.\n\nYour journey starts when you create your own workspace.',
                      style: HermesTypography.metadata.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: HermesSpacing.sm),
                    Text(
                      '> Tip: Long press section titles to discover additional actions.',
                      style: HermesTypography.metadata.copyWith(color: HermesColors.textTertiary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: HermesSpacing.sectionGap),
        ],
      ),
    );
  }
}

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  String _getItemTypeBadge(ItemType type) {
    switch (type) {
      case ItemType.article: return '📖 Article';
      case ItemType.question: return '❓ Question';
      case ItemType.idea: return '💡 Idea';
      case ItemType.note: return '📝 Note';
      case ItemType.observation: return '👀 Observation';
      case ItemType.reflection: return '💭 Reflection';
    }
  }

  String _getPreviewText(String content) {
    // Remove markdown headers, code blocks, bold, italic
    String preview = content
      .replaceAll(RegExp(r'```.*?```', dotAll: true), '[Code Block]')
      .replaceAll(RegExp(r'#+\s'), '')
      .replaceAll(RegExp(r'[*_`~]'), '')
      .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '[Image]')
      .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '[Link]')
      .trim();
    return preview;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    
    // Read dynamic data from offline storage
    final recentEvolutios = ref.watch(recentEvolutiosProvider);
    final workspace = ref.watch(currentWorkspaceProvider);
    final archivedSections = ref.watch(archivedSectionsProvider);
    
    final storage = ref.watch(storageEngineProvider);
    final veritasList = workspace != null ? storage.getVeritas(workspace.id) : <Veritas>[];
    
    final allDomains = ref.watch(domainsProvider);
    final pinnedDomains = allDomains.where((d) => d.pinned && !d.deleted && !d.archived).toList();
    
    final allBlocks = ref.watch(allBlocksProvider);
    var pinnedBlocks = allBlocks.where((b) => b.pinned && !b.deleted && !b.archived).toList();

    // Dynamic daily item calculation based on selected format
    final List<MapEntry<Block, Item>> dailyItems = [];
    final sources = ref.watch(sourcesProvider);
    final Map<String, KnowledgeSource> sourceMap = { for (var s in sources) s.id: s };
    
    if (allBlocks.isNotEmpty) {
      // Temporary map to track how many items we've taken per source today
      final sourceCounts = <String, int>{};
      
      for (final block in allBlocks) {
        final items = ref.watch(itemsByBlockProvider(block.id));
        
        // Find all unsolved items meant for Today's Pursuit
        final unsolvedItems = items.where((i) {
          if (i.metadata?['isDailyGoal'] != true) return false;
          if (i.metadata?['isSolved'] == true) return false;
          return true;
        }).toList();
        
        // Stably sort them so the same items appear until solved
        unsolvedItems.sort((a, b) => a.id.compareTo(b.id));
        
        // Enforce the Daily Limit from the KnowledgeSource!
        for (final item in unsolvedItems) {
          if (item.sourceId != null) {
            final source = sourceMap[item.sourceId];
            if (source != null && source.includeInToday) {
              final limit = source.dailyLimit;
              final currentCount = sourceCounts[item.sourceId!] ?? 0;
              if (currentCount < limit) {
                sourceCounts[item.sourceId!] = currentCount + 1;
                dailyItems.add(MapEntry(block, item));
              }
            }
          } else if (item.metadata?['isManualDailyGoal'] == true) {
             // If a user manually added a goal, explicitly include it.
             dailyItems.add(MapEntry(block, item));
          } else {
             // For legacy items without a sourceId but with isDailyGoal=true,
             // these are old imports before the Data Pipeline v2.0 was built.
             // We drop them.
          }
        }
      }
      // Sort by newest first
      dailyItems.sort((a, b) => b.value.createdAt.compareTo(a.value.createdAt));
      
      // Deduplicate by title to hide past duplicate attempts
      final uniqueTitles = <String>{};
      final dedupedItems = <MapEntry<Block, Item>>[];
      for (final entry in dailyItems) {
        final title = entry.value.title.trim().toLowerCase();
        if (!uniqueTitles.contains(title)) {
          uniqueTitles.add(title);
          dedupedItems.add(entry);
        }
      }
      dailyItems.clear();
      dailyItems.addAll(dedupedItems);
    }

    void showSectionOptions(String sectionId, String sectionName) {
      final isDailySection = sectionId == 'question';
      
      showModalBottomSheet(
        context: context,
        backgroundColor: HermesColors.surfaceElevated,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(HermesSpacing.lg),
            child: Consumer(
              builder: (consumerCtx, ref, child) {
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$sectionName Options', style: HermesTypography.sectionTitle),
                    const SizedBox(height: HermesSpacing.md),
                    
                    if (isDailySection) ...[
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline, color: HermesColors.textPrimary),
                        title: Text('Add New Goal', style: HermesTypography.body),
                        onTap: () {
                          Navigator.pop(ctx);
                          final blockToUse = allBlocks.isNotEmpty ? allBlocks.first : null;
                          if (blockToUse != null) {
                            CreateItemSheet.show(
                              context,
                              block: blockToUse,
                              initialType: ItemType.question,
                              isDailyGoal: true,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please create a block first.')));
                          }
                        },
                      ),
                    ],
                      
                    if (!isDailySection)
                      ListTile(
                        leading: const Icon(Icons.visibility_off_outlined, color: HermesColors.textPrimary),
                        title: Text((sectionId == 'pinned' || sectionId == 'pinned_domains') ? 'Unpin From Home' : 'Hide From Home', style: HermesTypography.body),
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(archivedSectionsProvider.notifier).archiveSection(sectionId);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$sectionName hidden.')));
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: HermesColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.xl),
            ),

            // ── Greeting & Date & Settings ──────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: HermesTypography.screenTitle,
                          ),
                          const SizedBox(height: HermesSpacing.xxs),
                          Text(
                            _formatDate(now),
                            style: HermesTypography.metadata,
                          ),
                        ],
                      ),
                      // Workspace & Settings Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Open Workspace/Settings Sheet
                            _showWorkspaceSettings(context, ref, workspace);
                          },
                          borderRadius: BorderRadius.circular(HermesRadius.pill),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: HermesSpacing.sm,
                              vertical: HermesSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: HermesColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(HermesRadius.pill),
                              border: Border.all(
                                color: HermesColors.border,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: workspace?.isEncrypted == true 
                                        ? HermesColors.veritasColor 
                                        : HermesColors.evolutioGlow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: HermesSpacing.xs),
                                Text(
                                  workspace?.name ?? 'Personal',
                                  style: HermesTypography.metadata.copyWith(
                                    color: HermesColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: HermesSpacing.xs),
                                const Icon(
                                  Icons.settings_rounded,
                                  size: 14,
                                  color: HermesColors.textTertiary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.sectionGap),
            ),

            if (workspace?.name == 'Starter') 
              const StarterWelcomeBanner(),

            // ── Morning Question ────────────────────────────────────
            if (!archivedSections.contains('question')) ...[
              SliverToBoxAdapter(
                child: HermesFadeIn(
                  delay: Duration.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HermesSpacing.screenHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HermesSectionHeader(
                          title: "Today's Pursuit",
                          onLongPress: () {
                            showSectionOptions('question', "Today's Pursuit");
                          },
                        ),
                        const SizedBox(height: HermesSpacing.xs),
                        
                        if (dailyItems.isEmpty)
                          HermesCard(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: HermesSpacing.lg),
                              child: Center(child: Text('No goals for today.\nLong press section title to add one.', textAlign: TextAlign.center, style: HermesTypography.metadata)),
                            ),
                          )
                        else
                          ...dailyItems.take(20).map((entry) {
                            final item = entry.value;
                            final block = entry.key;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: HermesSpacing.sm),
                              child: HermesCard(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => HermesReaderScreen(item: item, block: block),
                                  ));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: item.type.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: HermesSpacing.xs),
                                        Expanded(
                                          child: Text(
                                            '${_getItemTypeBadge(item.type)}  •  ${item.title}',
                                            style: HermesTypography.metadata.copyWith(
                                              color: item.type.color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_horiz, size: 20, color: HermesColors.textSecondary),
                                          padding: EdgeInsets.zero,
                                          color: HermesColors.surfaceElevated,
                                          onSelected: (value) async {
                                            if (value == 'remove') {
                                              final updatedMeta = Map<String, dynamic>.from(item.metadata ?? {});
                                              updatedMeta['isDailyGoal'] = false;
                                              final updatedItem = item.copyWith(metadata: updatedMeta);
                                              await ref.read(storageEngineProvider).saveItem(updatedItem);
                                              ref.invalidate(itemsByBlockProvider(item.blockId));
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Removed from Today\'s Pursuit')),
                                                );
                                              }
                                            } else if (value == 'open') {
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => BlockDetailScreen(block: block),
                                              ));
                                            } else if (value == 'share_text') {
                                              Share.share(item.content, subject: item.title);
                                            } else if (value == 'export_hitem') {
                                              try {
                                                final engine = ref.read(exchangeEngineProvider);
                                                final path = await engine.exportItems([item]);
                                                await Share.shareXFiles([XFile(path)], subject: '${item.title} (Hermes)');
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Export failed: $e'), backgroundColor: HermesColors.veritasColor),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'remove',
                                              child: Text('Remove from Today\'s Pursuit', style: HermesTypography.bodySmall.copyWith(color: HermesColors.veritasColor)),
                                            ),
                                            PopupMenuItem(
                                              value: 'open',
                                              child: Text('Open Original Block', style: HermesTypography.bodySmall),
                                            ),
                                            PopupMenuItem(
                                              value: 'share_text',
                                              child: Text('Share Text Content', style: HermesTypography.bodySmall),
                                            ),
                                            PopupMenuItem(
                                              value: 'export_hitem',
                                              child: Text('Export as .hitem', style: HermesTypography.bodySmall),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: HermesSpacing.sm),
                                    Text(
                                      _getPreviewText(item.content),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: HermesTypography.body.copyWith(
                                        color: HermesColors.textSecondary, 
                                        height: 1.5,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: HermesSpacing.md),
                                    Text(
                                      (() {
                                        switch (item.type) {
                                          case ItemType.question: return 'Tap to evaluate';
                                          case ItemType.article: return 'Tap to read';
                                          case ItemType.idea: return 'Tap to expand';
                                          case ItemType.observation: return 'Tap to review';
                                          case ItemType.reflection: return 'Tap to reflect';
                                          case ItemType.note: return 'Tap to view note';
                                        }
                                      })(),
                                      style: HermesTypography.metadata,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: HermesSpacing.sectionGap),
              ),
            ],



            // ── Pinned Domains ──────────────────────────────────────
            if (!archivedSections.contains('pinned_domains') && pinnedDomains.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: HermesFadeIn(
                  delay: Duration.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HermesSpacing.screenHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HermesSectionHeader(
                          title: 'Pinned Domains',
                          onLongPress: () => showSectionOptions('pinned_domains', 'Pinned Domains'),
                        ),
                        const SizedBox(height: HermesSpacing.xs),
                        Wrap(
                          spacing: HermesSpacing.xs,
                          runSpacing: HermesSpacing.xs,
                          children: pinnedDomains.map((d) {
                            return HermesBlockChip(
                              icon: d.icon,
                              label: d.name,
                              color: HermesColors.accent,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => DomainDetailScreen(domain: d),
                                ));
                              },
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, size: 16, color: HermesColors.textTertiary),
                                padding: EdgeInsets.zero,
                                color: HermesColors.surfaceElevated,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'open', child: Text('Open Domain')),
                                  const PopupMenuItem(value: 'unpin', child: Text('Unpin From Home')),
                                  const PopupMenuItem(value: 'archive', child: Text('Archive Domain')),
                                ],
                                onSelected: (value) async {
                                  if (value == 'open') {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => DomainDetailScreen(domain: d)));
                                  } else if (value == 'unpin') {
                                    final updated = d.copyWith(pinned: false);
                                    await ref.read(storageEngineProvider).saveDomain(updated);
                                    ref.invalidate(domainsProvider);
                                  } else if (value == 'archive') {
                                    final updated = d.copyWith(archived: true);
                                    await ref.read(storageEngineProvider).saveDomain(updated);
                                    ref.invalidate(domainsProvider);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: HermesSpacing.sectionGap),
              ),
            ],

            // ── Pinned Blocks ───────────────────────────────────────
            if (!archivedSections.contains('pinned') && pinnedBlocks.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: HermesFadeIn(
                  delay: Duration.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HermesSpacing.screenHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HermesSectionHeader(
                          title: 'Pinned Blocks',
                          onLongPress: () => showSectionOptions('pinned', 'Pinned Blocks'),
                        ),
                        const SizedBox(height: HermesSpacing.xs),
                        Wrap(
                          spacing: HermesSpacing.xs,
                          runSpacing: HermesSpacing.xs,
                            children: pinnedBlocks.map((b) {
                              return HermesBlockChip(
                                icon: b.icon,
                                label: b.name,
                                color: Color(int.parse(b.colorHex.replaceAll('#', '0xFF'))),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => BlockDetailScreen(block: b),
                                  ));
                                },
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, size: 16, color: HermesColors.textTertiary),
                                  padding: EdgeInsets.zero,
                                  color: HermesColors.surfaceElevated,
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'open', child: Text('Open Block')),
                                    const PopupMenuItem(value: 'unpin', child: Text('Unpin From Home')),
                                    const PopupMenuItem(value: 'archive', child: Text('Archive Block')),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'open') {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => BlockDetailScreen(block: b)));
                                    } else if (value == 'unpin') {
                                      final updated = b.copyWith(pinned: false);
                                      await ref.read(storageEngineProvider).saveBlock(updated);
                                      ref.invalidate(allBlocksProvider);
                                    } else if (value == 'archive') {
                                      final updated = b.copyWith(archived: true);
                                      await ref.read(storageEngineProvider).saveBlock(updated);
                                      ref.invalidate(allBlocksProvider);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: HermesSpacing.sectionGap),
              ),
            ],

            // ── Today's Evolutios (Dynamic from storage) ─────────────
            if (!archivedSections.contains('evolutios')) ...[
              SliverToBoxAdapter(
                child: HermesFadeIn(
                  delay: Duration.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HermesSpacing.screenHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HermesSectionHeader(
                          title: "Recent Evolutios",
                          onLongPress: () => showSectionOptions('evolutios', "Recent Evolutios"),
                        ),
                        const SizedBox(height: HermesSpacing.xs),
                        if (recentEvolutios.isEmpty)
                          Text(
                            'No evolutios yet. Solve a question or read an article to generate one.',
                            style: HermesTypography.metadata,
                          )
                        else
                          ...recentEvolutios.where((e) => !e.hiddenFromHome).map((evo) {
                            final block = allBlocks.where((b) => b.id == evo.blockId).firstOrNull;
                            final blockName = block?.name ?? 'Unknown Block';
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: HermesSpacing.itemGap),
                              child: _EvolutioEntry(
                                text: evo.content,
                                block: blockName,
                                time: _formatTimeAgo(evo.createdAt),
                                onTap: () {
                                  final engine = ref.read(storageEngineProvider);
                                  final allReflections = engine.getAllReflections();
                                  final allItems = engine.getAllItems();
                                  
                                  final reflection = allReflections.where((r) => r.id == evo.reflectionId).firstOrNull;
                                  if (reflection != null) {
                                    final item = allItems.where((i) => i.id == reflection.itemId).firstOrNull;
                                    if (item != null && block != null) {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => HermesReaderScreen(item: item, block: block),
                                      ));
                                    }
                                  }
                                },
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: HermesColors.textTertiary),
                                  color: HermesColors.surfaceElevated,
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'copy', child: Text('Copy Text')),
                                    const PopupMenuItem(value: 'share', child: Text('Share')),
                                    const PopupMenuItem(value: 'hide', child: Text('Hide From Home')),
                                    const PopupMenuItem(value: 'archive', child: Text('Archive Evolutio')),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'copy') {
                                      final content = '${evo.content}'; // Optionally prefix with blockName or keep plain
                                      Clipboard.setData(ClipboardData(text: content));
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied text to clipboard.')));
                                    } else if (value == 'share') {
                                      final content = '${evo.content}';
                                      Share.share(content); // No title since Evolutio doesn't have a specific title field, but we can pass it if we want
                                    } else if (value == 'hide') {
                                      final updated = evo.copyWith(hiddenFromHome: true);
                                      await ref.read(storageEngineProvider).saveEvolutio(updated);
                                      ref.invalidate(recentEvolutiosProvider);
                                      ref.invalidate(allEvolutiosProvider);
                                    } else if (value == 'archive') {
                                      final updated = evo.copyWith(archived: true);
                                      await ref.read(storageEngineProvider).saveEvolutio(updated);
                                      ref.invalidate(recentEvolutiosProvider);
                                      ref.invalidate(allEvolutiosProvider);
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: HermesSpacing.sectionGap),
              ),
            ],

            // ── Veritas ─────────────────────────────────────────────
            if (!archivedSections.contains('veritas')) ...[
              SliverToBoxAdapter(
                child: HermesFadeIn(
                  delay: Duration.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HermesSpacing.screenHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HermesSectionHeader(
                          title: 'Veritas',
                          onLongPress: () => showSectionOptions('veritas', 'Veritas'),
                        ),
                        const SizedBox(height: HermesSpacing.xs),
                        HermesCard(
                            onTap: () {
                              VeritasSheet.show(context);
                            },
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    size: 18,
                                    color: HermesColors.veritasColor
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: HermesSpacing.xs),
                                  Text(
                                    workspace?.isEncrypted == true 
                                        ? 'Locked & Encrypted' 
                                        : 'Always available',
                                    style: HermesTypography.metadata.copyWith(
                                      color: HermesColors.veritasColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: HermesSpacing.sm),
                              Text(
                                'What happened today?',
                                style: HermesTypography.reflection.copyWith(
                                  fontStyle: FontStyle.normal,
                                  color: HermesColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: HermesSpacing.sm),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.xxxl),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
  
  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
    return 'Just now';
  }

  void _showWorkspaceSettings(BuildContext screenContext, WidgetRef ref, Workspace? currentWorkspace) {
    showModalBottomSheet(
      context: screenContext,
      backgroundColor: HermesColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(HermesSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workspace Settings', style: HermesTypography.sectionTitle),
                const SizedBox(height: HermesSpacing.md),
                
                // Current Workspace Info
                HermesCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(HermesSpacing.sm),
                        decoration: BoxDecoration(
                          color: currentWorkspace?.isEncrypted == true 
                              ? HermesColors.veritasColor.withValues(alpha: 0.1)
                              : HermesColors.evolutioGlow.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          currentWorkspace?.isEncrypted == true 
                              ? Icons.lock_rounded 
                              : Icons.public_rounded,
                          color: currentWorkspace?.isEncrypted == true 
                              ? HermesColors.veritasColor 
                              : HermesColors.evolutioGlow,
                        ),
                      ),
                      const SizedBox(width: HermesSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentWorkspace?.name ?? 'Personal', style: HermesTypography.itemTitle),
                            Text(
                              currentWorkspace?.isEncrypted == true 
                                  ? 'Encrypted & Locked' 
                                  : 'Public Workspace',
                              style: HermesTypography.metadata,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HermesSpacing.lg),

                // Actions
                Consumer(
                  builder: (consumerContext, consumerRef, child) {
                    final isLocked = consumerRef.watch(workspaceLockedProvider);
                    final ws = consumerRef.watch(currentWorkspaceProvider);
                    
                    if (isLocked) {
                      return ListTile(
                        leading: const Icon(Icons.lock_open_rounded, color: HermesColors.textPrimary),
                        title: Text('Unlock Workspace', style: HermesTypography.body),
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          showDialog(
                            context: screenContext,
                            barrierDismissible: false,
                            builder: (_) => const UnlockWorkspaceDialog(),
                          );
                        },
                      );
                    }
                    
                    final hasPin = ws?.pin != null && ws!.pin!.isNotEmpty;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.inventory_2_outlined, color: HermesColors.textPrimary),
                          title: Text('View Archive', style: HermesTypography.body),
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                            Navigator.push(
                              screenContext,
                              MaterialPageRoute(
                                builder: (context) => const ArchiveScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.visibility_off_outlined, color: HermesColors.textPrimary),
                          title: Text('Visibility', style: HermesTypography.body),
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                            Navigator.push(
                              screenContext,
                              MaterialPageRoute(
                                builder: (context) => const VisibilityScreen(),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: HermesSpacing.sm),
                        Text('Security', style: HermesTypography.metadata.copyWith(color: HermesColors.textSecondary)),
                        const SizedBox(height: HermesSpacing.xs),
                        
                        if (!hasPin)
                          ListTile(
                            leading: const Icon(Icons.security_rounded, color: HermesColors.textPrimary),
                            title: Text('Setup Workspace Lock', style: HermesTypography.body),
                            onTap: () {
                              Navigator.pop(bottomSheetContext);
                              showDialog(
                                context: screenContext,
                                barrierDismissible: false,
                                builder: (_) => const SetupLockDialog(),
                              );
                            },
                          )
                        else ...[
                          ListTile(
                            leading: const Icon(Icons.lock_outline, color: HermesColors.textPrimary),
                            title: Text('Lock Workspace', style: HermesTypography.body),
                            onTap: () {
                              ref.read(workspaceLockedProvider.notifier).setLocked(true);
                              Navigator.pop(bottomSheetContext);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.pin_outlined, color: HermesColors.textPrimary),
                            title: Text('Change PIN', style: HermesTypography.body),
                            onTap: () {
                              Navigator.pop(bottomSheetContext);
                              showDialog(
                                context: screenContext,
                                barrierDismissible: false,
                                builder: (_) => VerifyPinDialog(
                                  onSuccess: () {
                                    showDialog(
                                      context: screenContext,
                                      barrierDismissible: false,
                                      builder: (_) => const ChangePinDialog(),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.lock_reset_rounded, color: HermesColors.textPrimary),
                            title: Text('Change Recovery Question', style: HermesTypography.body),
                            onTap: () {
                              Navigator.pop(bottomSheetContext);
                              showDialog(
                                context: screenContext,
                                barrierDismissible: false,
                                builder: (_) => VerifyPinDialog(
                                  onSuccess: () {
                                    showDialog(
                                      context: screenContext,
                                      barrierDismissible: false,
                                      builder: (_) => const ChangeRecoveryQuestionDialog(),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.no_encryption_outlined, color: Colors.redAccent),
                            title: Text('Remove Workspace Lock', style: HermesTypography.body.copyWith(color: Colors.redAccent)),
                            onTap: () {
                              Navigator.pop(bottomSheetContext);
                              showDialog(
                                context: screenContext,
                                barrierDismissible: false,
                                builder: (_) => VerifyPinDialog(
                                  onSuccess: () async {
                                    if (ws != null) {
                                      final updated = ws.copyWith(
                                        pin: '',
                                        securityQuestion: '',
                                        securityAnswer: '',
                                        isEncrypted: false,
                                      );
                                      // Safely read providers after dialog pops
                                      final container = ProviderScope.containerOf(screenContext);
                                      await container.read(storageEngineProvider).saveWorkspace(updated);
                                      container.read(currentWorkspaceProvider.notifier).updateWorkspace(updated);
                                      container.read(workspaceLockedProvider.notifier).setLocked(false);
                                      
                                      if (screenContext.mounted) {
                                        ScaffoldMessenger.of(screenContext).showSnackBar(
                                          const SnackBar(content: Text('Workspace lock removed.')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                        
                        const SizedBox(height: HermesSpacing.sm),
                        const Divider(color: HermesColors.border),
                        const SizedBox(height: HermesSpacing.sm),
                        
                        ListTile(
                          leading: const Icon(Icons.swap_horiz_rounded, color: HermesColors.textSecondary),
                          title: Text('Switch Workspace', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary)),
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                          },
                        ),
                        const SizedBox(height: 90), // Extra padding above gesture bar
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EVOLUTIO ENTRY WIDGET
// ═══════════════════════════════════════════════════════════════════════════════


class _EvolutioEntry extends StatelessWidget {
  final String text;
  final String block;
  final String time;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _EvolutioEntry({
    required this.text,
    required this.block,
    required this.time,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return HermesCard(
      padding: const EdgeInsets.all(HermesSpacing.md),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Growth indicator
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: HermesColors.evolutioGlow.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: HermesSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: HermesTypography.evolutio.copyWith(
                    color: HermesColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: HermesSpacing.xs),
                Text(
                  '$block · $time',
                  style: HermesTypography.metadata,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: HermesSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
