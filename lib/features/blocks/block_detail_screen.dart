import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';

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

class BlockDetailScreen extends StatelessWidget {
  final String name;
  final String emoji;
  final Color color;

  const BlockDetailScreen({
    super.key,
    required this.name,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () {
                        // TODO: Block settings / options
                      },
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: HermesColors.textTertiary,
                        size: 22,
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
                            emoji: emoji,
                            color: color,
                            size: 48,
                          ),
                          const SizedBox(width: HermesSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: HermesTypography.screenTitle,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '24 items · 5 evolutios',
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
              child: SizedBox(height: HermesSpacing.sectionGap),
            ),

            // ── Item Type Filter Chips ──────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 80),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: HermesSpacing.screenHorizontal,
                    ),
                    children: const [
                      _FilterChip(label: 'All', isActive: true),
                      SizedBox(width: HermesSpacing.xs),
                      _FilterChip(label: 'Questions'),
                      SizedBox(width: HermesSpacing.xs),
                      _FilterChip(label: 'Articles'),
                      SizedBox(width: HermesSpacing.xs),
                      _FilterChip(label: 'Notes'),
                      SizedBox(width: HermesSpacing.xs),
                      _FilterChip(label: 'Quotes'),
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
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 160),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                  ),
                  child: Column(
                    children: [
                      _ItemRow(
                        type: ItemType.question,
                        title:
                            'A fair coin is flipped 3 times. What is the expected number of heads?',
                        meta: 'Expected Value · Medium',
                        hasEvolutio: true,
                      ),
                      const HermesDivider(),
                      _ItemRow(
                        type: ItemType.question,
                        title:
                            'How should one divide money when betting on independent events?',
                        meta: 'Probability · Hard',
                        hasEvolutio: true,
                      ),
                      const HermesDivider(),
                      _ItemRow(
                        type: ItemType.article,
                        title: 'Why Intuition Fails in Probability',
                        meta: 'Medium · 8 min read',
                        hasEvolutio: false,
                      ),
                      const HermesDivider(),
                      _ItemRow(
                        type: ItemType.question,
                        title:
                            'Given P(A) = 0.3 and P(B|A) = 0.7, find P(A∩B)',
                        meta: 'Bayes · Easy',
                        hasEvolutio: false,
                      ),
                      const HermesDivider(),
                      _ItemRow(
                        type: ItemType.quote,
                        title:
                            '"Probability is not about the odds. It\'s about what you can\'t predict."',
                        meta: 'Nassim Taleb',
                        hasEvolutio: false,
                      ),
                      const HermesDivider(),
                      _ItemRow(
                        type: ItemType.note,
                        title:
                            'Connection between expected value and startup risk assessment',
                        meta: 'Personal note · Today',
                        hasEvolutio: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Spacing ──────────────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
      // ── FAB — Record Evolutio ─────────────────────────────────────
      floatingActionButton: HermesFadeIn(
        delay: const Duration(milliseconds: 400),
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Record Evolutio flow
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

enum ItemType { question, article, note, quote, observation, idea }

extension ItemTypeIcon on ItemType {
  IconData get icon {
    switch (this) {
      case ItemType.question:
        return Icons.help_outline_rounded;
      case ItemType.article:
        return Icons.article_outlined;
      case ItemType.note:
        return Icons.sticky_note_2_outlined;
      case ItemType.quote:
        return Icons.format_quote_rounded;
      case ItemType.observation:
        return Icons.visibility_outlined;
      case ItemType.idea:
        return Icons.lightbulb_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ItemType.question:
        return HermesColors.accent;
      case ItemType.article:
        return HermesColors.accentWarm;
      case ItemType.note:
        return HermesColors.accentSoft;
      case ItemType.quote:
        return HermesColors.accentMuted;
      case ItemType.observation:
        return HermesColors.textTertiary;
      case ItemType.idea:
        return HermesColors.accentWarm;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ITEM ROW — Clean, minimal, consistent
// ═══════════════════════════════════════════════════════════════════════════════

class _ItemRow extends StatelessWidget {
  final ItemType type;
  final String title;
  final String meta;
  final bool hasEvolutio;

  const _ItemRow({
    required this.type,
    required this.title,
    required this.meta,
    required this.hasEvolutio,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to Item detail
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
                  type.icon,
                  size: 18,
                  color: type.color.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: HermesSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: HermesTypography.itemTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: HermesSpacing.xxs),
                    Row(
                      children: [
                        if (hasEvolutio) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: HermesColors.evolutioGlow
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(width: HermesSpacing.xxs),
                        ],
                        Text(meta, style: HermesTypography.metadata),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
