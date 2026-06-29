import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import 'create_manual_source_screen.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Knowledge Sources', style: HermesTypography.sectionTitle),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateManualSourceScreen()));
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Source'),
                    style: TextButton.styleFrom(foregroundColor: HermesColors.evolutioGlow),
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
                      } else if (val == 'replace') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Replace JSON feature coming soon.')));
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

  void _showEditRulesDialog(BuildContext context, WidgetRef ref, KnowledgeSource source) {
    bool includeInToday = source.includeInToday;
    int dailyLimit = source.dailyLimit;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: HermesColors.surfaceElevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.lg)),
              title: Text('Edit Rules: ${source.name}', style: HermesTypography.sectionTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Include in Today\'s Pursuit?', style: TextStyle(fontSize: 14)),
                    value: includeInToday,
                    activeColor: HermesColors.evolutioGlow,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => includeInToday = val),
                  ),
                  if (includeInToday) ...[
                    const SizedBox(height: HermesSpacing.md),
                    Text('Daily Maximum Limit:', style: HermesTypography.metadata),
                    const SizedBox(height: HermesSpacing.sm),
                    Wrap(
                      spacing: HermesSpacing.sm,
                      children: [1, 3, 5, 10, 20].map((limit) {
                        return ChoiceChip(
                          label: Text('$limit'),
                          selected: dailyLimit == limit,
                          onSelected: (val) {
                            if (val) setState(() => dailyLimit = limit);
                          },
                          selectedColor: HermesColors.evolutioGlow.withValues(alpha: 0.2),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: HermesColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () async {
                    final updated = source.copyWith(
                      includeInToday: includeInToday,
                      dailyLimit: dailyLimit,
                    );
                    await ref.read(storageEngineProvider).saveSource(updated);
                    ref.invalidate(sourcesProvider);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Rules', style: TextStyle(color: HermesColors.evolutioGlow)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
