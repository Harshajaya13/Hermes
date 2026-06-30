import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';

class VisibilityScreen extends ConsumerStatefulWidget {
  const VisibilityScreen({super.key});

  @override
  ConsumerState<VisibilityScreen> createState() => _VisibilityScreenState();
}

class _VisibilityScreenState extends ConsumerState<VisibilityScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageEngineProvider);
    
    final hiddenDomains = storage.getAllDomainsRaw().where((d) => d.hidden && !d.deleted).toList();
    final hiddenBlocks = storage.getAllBlocksRaw().where((b) => b.hidden && !b.deleted).toList();
    final archivedSections = ref.watch(archivedSectionsProvider);

    String _getSectionName(String id) {
      switch (id) {
        case 'question': return "Today's Pursuit";
        case 'evolutios': return "Recent Evolutios";
        case 'veritas': return "Veritas";
        case 'pinned': return "Pinned Blocks";
        case 'pinned_domains': return "Pinned Domains";
        default: return id;
      }
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
        title: Text('Visibility', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          if (hiddenDomains.isEmpty && hiddenBlocks.isEmpty && archivedSections.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No hidden content.', style: HermesTypography.metadata),
              ),
            )
          else ...[
            if (archivedSections.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(HermesSpacing.lg),
                  child: HermesSectionHeader(title: 'Hidden Home Sections'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sectionId = archivedSections.toList()[index];
                    return ListTile(
                      leading: const Icon(Icons.dashboard_rounded, color: HermesColors.textTertiary),
                      title: Text(_getSectionName(sectionId), style: HermesTypography.body),
                      trailing: TextButton(
                        onPressed: () {
                          ref.read(archivedSectionsProvider.notifier).restoreSection(sectionId);
                        },
                        child: Text('Pin to Home', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow)),
                      ),
                    );
                  },
                  childCount: archivedSections.length,
                ),
              ),
            ],
            if (hiddenDomains.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(HermesSpacing.lg),
                  child: HermesSectionHeader(title: 'Hidden Domains'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final domain = hiddenDomains[index];
                    return ListTile(
                      leading: Container(width: 10, height: 10, decoration: const BoxDecoration(color: HermesColors.textTertiary, shape: BoxShape.circle)),
                      title: Text(domain.name, style: HermesTypography.body),
                      trailing: TextButton(
                        onPressed: () async {
                          final updated = domain.copyWith(hidden: false);
                          await storage.saveDomain(updated);
                          ref.invalidate(domainsProvider);
                          if (mounted) setState(() {});
                        },
                        child: Text('Restore Visibility', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow)),
                      ),
                    );
                  },
                  childCount: hiddenDomains.length,
                ),
              ),
            ],
            
            if (hiddenBlocks.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(HermesSpacing.lg),
                  child: HermesSectionHeader(title: 'Hidden Blocks'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final block = hiddenBlocks[index];
                    return ListTile(
                      leading: Text(block.icon, style: const TextStyle(fontSize: 20)),
                      title: Text(block.name, style: HermesTypography.body),
                      trailing: TextButton(
                        onPressed: () async {
                          final updated = block.copyWith(hidden: false);
                          await storage.saveBlock(updated);
                          ref.invalidate(blocksByDomainProvider);
                          ref.invalidate(allBlocksProvider);
                          if (mounted) setState(() {});
                        },
                        child: Text('Restore Visibility', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow)),
                      ),
                    );
                  },
                  childCount: hiddenBlocks.length,
                ),
              ),
            ],
          ]
        ],
      ),
    );
  }
}
