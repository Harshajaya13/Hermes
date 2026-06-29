import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../items/item_detail_screen.dart';
import '../evolution/veritas_sheet.dart';
import '../archive/archive_screen.dart';
import '../blocks/block_detail_screen.dart';
import 'package:file_picker/file_picker.dart';
import '../blocks/create_item_sheet.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    
    // Read dynamic data from offline storage
    final recentEvolutios = ref.watch(recentEvolutiosProvider);
    final workspace = ref.watch(currentWorkspaceProvider);
    final archivedSections = ref.watch(archivedSectionsProvider);
    final allBlocks = ref.watch(allBlocksProvider);
    var pinnedBlocks = allBlocks.where((b) => b.pinned && !b.deleted && !b.archived).toList();
    if (pinnedBlocks.isEmpty) {
      pinnedBlocks = allBlocks.take(4).toList(); // Fallback if none pinned
    }

    // Dynamic daily item calculation based on selected format
    final todayFormatStr = ref.watch(todaySectionFormatProvider);
    final List<MapEntry<Block, Item>> dailyItems = [];
    
    if (allBlocks.isNotEmpty) {
      for (final block in allBlocks) {
        final items = ref.watch(itemsByBlockProvider(block.id));
        dailyItems.addAll(
          items.where((i) => i.metadata?['isDailyGoal'] == true &&
                             i.createdAt.year == now.year && 
                             i.createdAt.month == now.month && 
                             i.createdAt.day == now.day)
               .map((i) => MapEntry(block, i))
        );
      }
      // Sort by newest first
      dailyItems.sort((a, b) => b.value.createdAt.compareTo(a.value.createdAt));
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
            child: Column(
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
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CreateItemSheet(initialBlock: blockToUse, initialType: ItemType.question, isDailyGoal: true),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please create a block first.')));
                      }
                    },
                  ),
                ],
                
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: HermesColors.textPrimary),
                  title: Text('Lock Section', style: HermesTypography.body),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section Locked (Placeholder)')));
                  },
                ),
                  
                if (!isDailySection)
                  ListTile(
                    leading: const Icon(Icons.archive_outlined, color: HermesColors.textPrimary),
                    title: Text(sectionId == 'evolutios' ? 'Hide Recent Evolutios' : 'Archive Section', style: HermesTypography.body),
                    onTap: () {
                      Navigator.pop(ctx);
                      ref.read(archivedSectionsProvider.notifier).archiveSection(sectionId);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$sectionName hidden.')));
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: HermesColors.background,
      body: SafeArea(
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
                          ...dailyItems.take(5).map((entry) {
                            final item = entry.value;
                            final block = entry.key;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: HermesSpacing.sm),
                              child: HermesCard(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => ItemDetailScreen(item: item, block: block),
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
                                            item.title, // Just show item title!
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
                                            } else if (value == 'pin') {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item pinned (Placeholder)')));
                                            } else if (value == 'lock') {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item locked (Placeholder)')));
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
                                              value: 'pin',
                                              child: Text('Pin', style: HermesTypography.bodySmall),
                                            ),
                                            PopupMenuItem(
                                              value: 'lock',
                                              child: Text('Lock', style: HermesTypography.bodySmall),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: HermesSpacing.sm),
                                    Text(
                                      item.content,
                                      style: HermesTypography.itemTitle.copyWith(height: 1.5),
                                    ),
                                    const SizedBox(height: HermesSpacing.md),
                                    Text(
                                      item.type == ItemType.question ? 'Tap to evaluate' : 'Tap to read',
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

            // ── Pinned Blocks ───────────────────────────────────────
            if (!archivedSections.contains('pinned')) ...[
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
                        if (pinnedBlocks.isEmpty)
                          Text('No pinned blocks yet.', style: HermesTypography.metadata)
                        else
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
                          ...recentEvolutios.map((evo) {
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
                                        builder: (context) => ItemDetailScreen(item: item, block: block),
                                      ));
                                    }
                                  }
                                },
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

  void _showWorkspaceSettings(BuildContext context, WidgetRef ref, Workspace? currentWorkspace) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl)),
      ),
      builder: (context) {
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
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: HermesColors.textPrimary),
                  title: Text('View Archive', style: HermesTypography.body),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArchiveScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: HermesColors.textPrimary),
                  title: Text('Export Workspace (.hermes)', style: HermesTypography.body),
                  onTap: () async {
                    Navigator.pop(context);
                    if (currentWorkspace == null) return;
                    try {
                      final exportEngine = ref.read(exportEngineProvider);
                      final path = await exportEngine.exportWorkspace(currentWorkspace.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Exported successfully to: $path')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export failed: $e')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined, color: HermesColors.textPrimary),
                  title: Text('Import Community Bundle', style: HermesTypography.body),
                  onTap: () async {
                    Navigator.pop(context);
                    if (currentWorkspace == null) return;
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['hermes'],
                      );
                      
                      if (result != null && result.files.single.path != null) {
                        final exportEngine = ref.read(exportEngineProvider);
                        await exportEngine.importWorkspace(result.files.single.path!, currentWorkspace.id);
                        
                        // Force refresh everything
                        ref.invalidate(domainsProvider);
                        ref.invalidate(allBlocksProvider);
                        ref.invalidate(allEvolutiosProvider);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Import successful!')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Import failed: $e')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security_rounded, color: HermesColors.textPrimary),
                  title: Text('Lock Workspace', style: HermesTypography.body),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement Encryption toggle
                  },
                ),
                const SizedBox(height: HermesSpacing.sm),
                const Divider(color: HermesColors.border),
                const SizedBox(height: HermesSpacing.sm),
                ListTile(
                  leading: const Icon(Icons.swap_horiz_rounded, color: HermesColors.textSecondary),
                  title: Text('Switch Workspace', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(context);
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

  const _EvolutioEntry({
    required this.text,
    required this.block,
    required this.time,
    this.onTap,
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
        ],
      ),
    );
  }
}
