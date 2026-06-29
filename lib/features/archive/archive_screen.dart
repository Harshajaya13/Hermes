import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageEngineProvider);
    
    // Quick hack: we don't have a provider for deleted items yet, so we'll fetch them directly
    // In a real app we'd want proper providers, but this satisfies the immediate need.
    final archivedDomains = storage.getAllDomainsRaw().where((d) => d.deleted).toList();
    final archivedBlocks = storage.getAllBlocksRaw().where((b) => b.deleted).toList();
    final archivedItems = storage.getAllItemsRaw().where((i) => i.deleted).toList();
    final hiddenSections = ref.watch(archivedSectionsProvider);

    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Archive', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          if (archivedDomains.isEmpty && archivedBlocks.isEmpty && archivedItems.isEmpty && hiddenSections.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('The Archive is empty.', style: HermesTypography.metadata),
              ),
            )
          else ...[
            if (hiddenSections.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(HermesSpacing.lg),
                  child: HermesSectionHeader(title: 'Home Sections'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sectionId = hiddenSections.elementAt(index);
                    final todayFormat = ref.watch(todaySectionFormatProvider);
                    String sectionName = sectionId;
                    if (sectionId == 'question') sectionName = todayFormat == 'article' ? "Today's Article" : "Today's Question";
                    if (sectionId == 'pinned') sectionName = "Pinned Blocks";
                    if (sectionId == 'evolutios') sectionName = "Recent Evolutios";
                    if (sectionId == 'veritas') sectionName = "Veritas";

                    return ListTile(
                      leading: const Icon(Icons.visibility_off, color: HermesColors.textTertiary),
                      title: Text(sectionName, style: HermesTypography.body),
                      trailing: TextButton(
                        onPressed: () {
                          if (sectionId == 'question') {
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
                                      Text('Restore $sectionName', style: HermesTypography.sectionTitle),
                                      const SizedBox(height: HermesSpacing.md),
                                      ListTile(
                                        leading: const Icon(Icons.help_outline_rounded, color: HermesColors.textPrimary),
                                        title: Text('Restore as a Question', style: HermesTypography.body),
                                        onTap: () {
                                          ref.read(todaySectionFormatProvider.notifier).setFormat('question');
                                          ref.read(archivedSectionsProvider.notifier).restoreSection(sectionId);
                                          Navigator.pop(ctx);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.article_outlined, color: HermesColors.textPrimary),
                                        title: Text('Change format to an Article/Reading', style: HermesTypography.body),
                                        onTap: () {
                                          ref.read(todaySectionFormatProvider.notifier).setFormat('article');
                                          ref.read(archivedSectionsProvider.notifier).restoreSection(sectionId);
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Format changed to Article/Reading')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            ref.read(archivedSectionsProvider.notifier).restoreSection(sectionId);
                          }
                        },
                        child: Text('Restore', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow)),
                      ),
                    );
                  },
                  childCount: hiddenSections.length,
                ),
              ),
            ],
            if (archivedDomains.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(HermesSpacing.lg),
                  child: HermesSectionHeader(title: 'Domains'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final domain = archivedDomains[index];
                    return ListTile(
                      leading: const Icon(Icons.folder, color: HermesColors.textTertiary),
                      title: Text(domain.name, style: HermesTypography.body),
                      trailing: TextButton(
                        onPressed: () async {
                          await storage.restoreDomain(domain.id);
                          ref.invalidate(domainsProvider);
                          ref.invalidate(allBlocksProvider);
                          ref.invalidate(allEvolutiosProvider);
                          if (mounted) setState(() {});
                        },
                        child: Text('Restore', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow)),
                      ),
                    );
                  },
                  childCount: archivedDomains.length,
                ),
              ),
            ],
            
            if (archivedBlocks.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(HermesSpacing.lg),
                  child: HermesSectionHeader(title: 'Blocks'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final block = archivedBlocks[index];
                    return ListTile(
                      leading: Text(block.icon, style: const TextStyle(fontSize: 20)),
                      title: Text(block.name, style: HermesTypography.body),
                      trailing: TextButton(
                        onPressed: () async {
                          await storage.restoreBlock(block.id);
                          ref.invalidate(allBlocksProvider);
                          ref.invalidate(allEvolutiosProvider);
                          if (mounted) setState(() {});
                        },
                        child: Text('Restore', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow)),
                      ),
                    );
                  },
                  childCount: archivedBlocks.length,
                ),
              ),
            ],

            if (archivedItems.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(HermesSpacing.lg),
                  child: HermesSectionHeader(title: 'Items'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = archivedItems[index];
                    return ListTile(
                      leading: const Icon(Icons.article, color: HermesColors.textTertiary),
                      title: Text(item.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: HermesTypography.body),
                      trailing: TextButton(
                        onPressed: () async {
                          await storage.restoreItem(item.id);
                          ref.invalidate(itemsByBlockProvider);
                          if (mounted) setState(() {});
                        },
                        child: Text('Restore', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow)),
                      ),
                    );
                  },
                  childCount: archivedItems.length,
                ),
              ),
            ],
          ]
        ],
      ),
    );
  }
}
