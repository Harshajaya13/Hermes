import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import 'block_detail_screen.dart';
import 'create_block_sheet.dart';
import 'create_domain_sheet.dart';
import 'domain_detail_screen.dart';

class BlocksScreen extends ConsumerWidget {
  const BlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the dynamic data from the offline JSON storage
    final workspace = ref.watch(currentWorkspaceProvider);
    final domains = ref.watch(domainsProvider);

    return Scaffold(
      backgroundColor: HermesColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.xl),
            ),

            // ── Screen Title & Workspace Selector ───────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Blocks', style: HermesTypography.screenTitle),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.create_new_folder_outlined, color: HermesColors.textSecondary, size: 20),
                            onPressed: () {
                              CreateDomainSheet.show(context);
                            },
                          ),
                          if (workspace != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: HermesSpacing.sm,
                                vertical: HermesSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: HermesColors.surfaceElevated,
                                borderRadius:
                                    BorderRadius.circular(HermesRadius.pill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: workspace.isEncrypted 
                                          ? HermesColors.veritasColor 
                                          : HermesColors.evolutioGlow,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: HermesSpacing.xs),
                                  Text(
                                    workspace.name,
                                    style: HermesTypography.metadata.copyWith(
                                      color: HermesColors.textSecondary,
                                    ),
                                  ),
                                  if (workspace.isEncrypted) ...[
                                    const SizedBox(width: HermesSpacing.xs),
                                    const Icon(Icons.lock_rounded, size: 12, color: HermesColors.textTertiary),
                                  ]
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.sectionGap),
            ),

            // ── Domains List ────────────────────────────────────────
            if (domains.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                    vertical: HermesSpacing.xxxl,
                  ),
                  child: Center(
                    child: Text(
                      'No domains yet. Create one to organize your growth.',
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
                      final domain = domains[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: HermesSpacing.md),
                        child: HermesCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DomainDetailScreen(domain: domain),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(HermesSpacing.md),
                                decoration: BoxDecoration(
                                  color: HermesColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(HermesRadius.md),
                                ),
                                child: const Icon(
                                  Icons.folder_outlined,
                                  color: HermesColors.accent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: HermesSpacing.md),
                              Expanded(
                                child: Text(
                                  domain.name,
                                  style: HermesTypography.itemTitle.copyWith(fontSize: 18),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: HermesColors.textTertiary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: domains.length,
                  ),
                ),
              ),

            // ── Add Block FAB Area ──────────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 320),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                    vertical: HermesSpacing.lg,
                  ),
                  child: Center(
                    child: _AddBlockButton(
                      onTap: () {
                        CreateBlockSheet.show(context);
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.xxxl),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA CLASS (UI Helper)
// ═══════════════════════════════════════════════════════════════════════════════

class _BlockData {
  final String id;
  final String emoji;
  final String name;
  final int itemCount;
  final Color color;
  final String? recentEvolutio;

  const _BlockData({
    required this.id,
    required this.emoji,
    required this.name,
    required this.itemCount,
    required this.color,
    this.recentEvolutio,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOMAIN SECTION
// ═══════════════════════════════════════════════════════════════════════════════

class _DomainSection extends StatelessWidget {
  final String title;
  final List<_BlockData> blocks;

  const _DomainSection({
    required this.title,
    required this.blocks,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HermesSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HermesSectionHeader(title: title),
          const SizedBox(height: HermesSpacing.xs),
          ...blocks.map((block) => Padding(
                padding: const EdgeInsets.only(bottom: HermesSpacing.itemGap),
                child: _BlockRow(data: block),
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BLOCK ROW
// ═══════════════════════════════════════════════════════════════════════════════

class _BlockRow extends StatelessWidget {
  final _BlockData data;

  const _BlockRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return HermesCard(
      padding: const EdgeInsets.symmetric(
        horizontal: HermesSpacing.md,
        vertical: HermesSpacing.md,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlockDetailScreen(
              name: data.name,
              emoji: data.emoji,
              color: data.color,
            ),
          ),
        );
      },
      child: Row(
        children: [
          HermesIconBadge(
            emoji: data.emoji,
            color: data.color,
          ),
          const SizedBox(width: HermesSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name, style: HermesTypography.blockTitle),
                const SizedBox(height: 2),
                if (data.recentEvolutio != null)
                  Text(
                    '✓ ${data.recentEvolutio}',
                    style: HermesTypography.metadata.copyWith(
                      color: HermesColors.evolutioGlow.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    '${data.itemCount} items',
                    style: HermesTypography.metadata,
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: HermesColors.textDisabled,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADD BLOCK BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _AddBlockButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddBlockButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HermesRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: HermesSpacing.lg,
            vertical: HermesSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: HermesColors.border,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(HermesRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 18,
                color: HermesColors.textTertiary,
              ),
              const SizedBox(width: HermesSpacing.xs),
              Text(
                'Create Block',
                style: HermesTypography.bodySmall.copyWith(
                  color: HermesColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
