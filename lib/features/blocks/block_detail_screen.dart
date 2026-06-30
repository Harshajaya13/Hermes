import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// BLOCK DETAIL SCREEN
/// ─────────────────────────────────────────────────────────────────────────────
/// Shows all Items inside a single Block.
///
/// Codex: "A Block is an interactive environment dedicated to
///         one specific area of growth."
///
/// Item Types: Question · Article · Note · Quote · Observation · Idea
/// Feeling: Curiosity.
/// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../items/item_detail_screen.dart';
import 'create_item_sheet.dart';
import 'create_block_sheet.dart';

class BlockDetailScreen extends ConsumerStatefulWidget {
  final Block block;

  const BlockDetailScreen({
    super.key,
    required this.block,
  });

  @override
  ConsumerState<BlockDetailScreen> createState() => _BlockDetailScreenState();
}

class _BlockDetailScreenState extends ConsumerState<BlockDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsByBlockProvider(widget.block.id));
    final evolutiosCount = ref.read(storageEngineProvider).getEvolutiosForBlock(widget.block.id).length;
    final color = Color(int.parse(widget.block.colorHex.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: HermesColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  HermesSpacing.xs,
                  HermesSpacing.md,
                  HermesSpacing.screenHorizontal,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: HermesColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        try {
                          final itemsToExport = ref.read(itemsByBlockProvider(widget.block.id));
                          if (itemsToExport.isEmpty) return;
                          
                          final engine = ref.read(exchangeEngineProvider);
                          final path = await engine.exportItems(itemsToExport);
                          await Share.shareXFiles([XFile(path)], subject: '${widget.block.name} (Hermes Block)');
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Export failed: $e'), backgroundColor: HermesColors.veritasColor),
                            );
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        color: HermesColors.textSecondary,
                        size: 20,
                      ),
                      tooltip: 'Share Block Items (.hitem)',
                    ),
                    IconButton(
                      onPressed: () {
                        CreateBlockSheet.show(context, widget.block);
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: HermesColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Block Header ────────────────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: HermesSpacing.md),
                      Row(
                        children: [
                          HermesIconBadge(
                            emoji: widget.block.icon,
                            color: color,
                            size: 48,
                          ),
                          const SizedBox(width: HermesSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.block.name,
                                style: HermesTypography.screenTitle,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${items.length} items · $evolutiosCount evolutios',
                                style: HermesTypography.metadata,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Section Gap ─────────────────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.lg),
            ),

            // ── Items List ──────────────────────────────────────────
            if (items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(HermesSpacing.xxxl),
                  child: Center(
                    child: Text(
                      'This environment is empty.\nAdd your first question or article.',
                      textAlign: TextAlign.center,
                      style: HermesTypography.metadata,
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: HermesFadeIn(
                  delay: const Duration(milliseconds: 160),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HermesSpacing.screenHorizontal,
                    ),
                    child: Column(
                      children: items.map((item) {
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: HermesSpacing.xl),
                            color: HermesColors.veritasColor.withValues(alpha: 0.2),
                            child: const Icon(Icons.archive_outlined, color: HermesColors.veritasColor),
                          ),
                          onDismissed: (_) {
                            ref.read(storageEngineProvider).deleteItem(item.id);
                            // Invalidating provider to refresh UI
                            ref.invalidate(itemsByBlockProvider);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Item archived.', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textPrimary)),
                                backgroundColor: HermesColors.surfaceElevated,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              _ItemRow(
                                item: item,
                                block: widget.block,
                              ),
                              const HermesDivider(),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
      // ── FAB — Add Item ─────────────────────────────────────────────
      floatingActionButton: HermesFadeIn(
        delay: const Duration(milliseconds: 400),
        child: FloatingActionButton.extended(
          onPressed: () {
            CreateItemSheet.show(context, block: widget.block);
          },
          backgroundColor: HermesColors.surfaceElevated,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HermesRadius.pill),
            side: const BorderSide(
              color: HermesColors.border,
              width: 0.5,
            ),
          ),
          icon: Icon(
            Icons.add_rounded,
            size: 20,
            color: color.withValues(alpha: 0.8),
          ),
          label: Text(
            'Add Item',
            style: HermesTypography.button.copyWith(
              color: HermesColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FILTER CHIP
// ═══════════════════════════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _FilterChip({
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HermesSpacing.md,
        vertical: HermesSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? HermesColors.textPrimary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(HermesRadius.pill),
        border: Border.all(
          color: isActive ? HermesColors.textTertiary : HermesColors.border,
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: HermesTypography.bodySmall.copyWith(
          color: isActive
              ? HermesColors.textPrimary
              : HermesColors.textTertiary,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ITEM TYPE
// ═══════════════════════════════════════════════════════════════════════════════

extension ItemTypeIcon on ItemType {
  IconData get icon {
    switch (this) {
      case ItemType.question:
        return Icons.help_outline_rounded;
      case ItemType.article:
        return Icons.article_outlined;
      case ItemType.observation:
        return Icons.visibility_outlined;
      case ItemType.idea:
        return Icons.lightbulb_outline_rounded;
      case ItemType.reflection:
        return Icons.psychology_outlined;
      case ItemType.note:
        return Icons.notes_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ItemType.question:
        return HermesColors.accent;
      case ItemType.article:
        return HermesColors.accentWarm;
      case ItemType.observation:
        return HermesColors.textTertiary;
      case ItemType.idea:
        return HermesColors.accentWarm;
      case ItemType.reflection:
        return HermesColors.reflectionColor;
      case ItemType.note:
        return HermesColors.textSecondary;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ITEM ROW — Clean, minimal, consistent
// ═══════════════════════════════════════════════════════════════════════════════

class _ItemRow extends ConsumerWidget {
  final Item item;
  final Block block;

  const _ItemRow({
    required this.item,
    required this.block,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(item: item, block: block),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: HermesSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  item.type.icon,
                  size: 18,
                  color: item.type.color.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: HermesSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: HermesTypography.itemTitle.copyWith(color: HermesColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: HermesSpacing.xxs),
                    Row(
                      children: [
                        Text(item.type.name.toUpperCase(), style: HermesTypography.metadata),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: HermesColors.textTertiary, size: 24),
                padding: EdgeInsets.zero,
                color: HermesColors.surfaceElevated,
                onSelected: (value) async {
                  if (value == 'rename') {
                    CreateItemSheet.show(context, existingItem: item, block: block);
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
                  } else if (value == 'archive') {
                    await ref.read(storageEngineProvider).deleteItem(item.id);
                    ref.invalidate(itemsByBlockProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Item archived.'),
                          backgroundColor: HermesColors.surfaceElevated,
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'rename', child: Text('Rename Item', style: HermesTypography.bodySmall)),
                  PopupMenuItem(value: 'share_text', child: Text('Share Text Content', style: HermesTypography.bodySmall)),
                  PopupMenuItem(value: 'export_hitem', child: Text('Export as .hitem', style: HermesTypography.bodySmall)),
                  PopupMenuItem(value: 'archive', child: Text('Archive Item', style: HermesTypography.bodySmall)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
