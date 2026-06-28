import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import 'block_detail_screen.dart';
import 'block_detail_screen.dart';
import 'create_block_sheet.dart';
import 'create_domain_sheet.dart';
class DomainDetailScreen extends ConsumerWidget {
  final Domain domain;

  const DomainDetailScreen({super.key, required this.domain});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watch(blocksByDomainProvider(domain.id));

    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(domain.name, style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: HermesColors.textSecondary, size: 20),
            onPressed: () {
              CreateDomainSheet.show(context, domain);
            },
          ),
          const SizedBox(width: HermesSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.lg),
            ),
            
            // ── Blocks List ─────────────────────────────────────────
            if (blocks.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                    vertical: HermesSpacing.xxxl,
                  ),
                  child: Center(
                    child: Text(
                      'Start with one Block.\nOne intentional environment today can become an Evolutio tomorrow.',
                      textAlign: TextAlign.center,
                      style: HermesTypography.metadata,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.screenHorizontal),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final block = blocks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: HermesSpacing.sm),
                        child: HermesCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlockDetailScreen(block: block),
                              ),
                            );
                          },
                          onLongPress: () {
                            _showArchiveDialog(context, ref, block.id, block.name);
                          },
                          child: Row(
                            children: [
                              HermesIconBadge(
                                emoji: block.icon,
                                color: HermesColors.accent,
                              ),
                              const SizedBox(width: HermesSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      block.name,
                                      style: HermesTypography.itemTitle,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '0 Items', // We'll hook up item count later
                                      style: HermesTypography.metadata,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: HermesColors.textTertiary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: blocks.length,
                  ),
                ),
              ),

            // ── Add Block FAB ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(HermesSpacing.screenHorizontal),
                child: Center(
                  child: InkWell(
                    onTap: () => CreateBlockSheet.show(context),
                    borderRadius: BorderRadius.circular(HermesRadius.pill),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: HermesSpacing.lg,
                        vertical: HermesSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: HermesColors.border),
                        borderRadius: BorderRadius.circular(HermesRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 16, color: HermesColors.textSecondary),
                          const SizedBox(width: HermesSpacing.xs),
                          Text('Create Block', style: HermesTypography.body),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArchiveDialog(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HermesColors.surfaceElevated,
        title: Text('Archive $name?', style: HermesTypography.body),
        content: Text(
          'This will move the Block and all its items to the archive.',
          style: HermesTypography.metadata,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(storageEngineProvider).deleteBlock(id);
              ref.invalidate(blocksByDomainProvider);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Archived $name.', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textPrimary)),
                  backgroundColor: HermesColors.surfaceElevated,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text('Archive', style: HermesTypography.bodySmall.copyWith(color: HermesColors.veritasColor)),
          ),
        ],
      ),
    );
  }
}
