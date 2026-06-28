import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// EVOLUTION SCREEN
/// ─────────────────────────────────────────────────────────────────────────────
/// Purpose: Show evolution through time.
/// Never: Replace Google Calendar.
///
/// Codex: "Evolution isn't stored. Evolution is generated from all Evolutios."
/// Codex: "Not Event Calendar — Evolution Calendar."
///
/// This screen shows:
/// 1. Contribution graph (like GitHub but for growth)
/// 2. Recent Evolutios timeline
/// 3. Monthly stats
///
/// Feeling: Progress.
/// ─────────────────────────────────────────────────────────────────────────────

class EvolutionScreen extends StatelessWidget {
  const EvolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top Spacing ─────────────────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.xl),
            ),

            // ── Screen Title ────────────────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evolution',
                        style: HermesTypography.screenTitle,
                      ),
                      const SizedBox(height: HermesSpacing.xxs),
                      Text(
                        'Your journey, visualized',
                        style: HermesTypography.metadata,
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

            // ── Stats Summary ───────────────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 80),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                  ),
                  child: Row(
                    children: [
                      _StatCard(
                        value: '23',
                        label: 'Evolutios',
                        color: HermesColors.evolutioGlow,
                      ),
                      const SizedBox(width: HermesSpacing.sm),
                      _StatCard(
                        value: '12',
                        label: 'Active Days',
                        color: HermesColors.accent,
                      ),
                      const SizedBox(width: HermesSpacing.sm),
                      _StatCard(
                        value: '4',
                        label: 'Blocks',
                        color: HermesColors.accentWarm,
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

            // ── Contribution Graph ──────────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 160),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const HermesSectionHeader(title: 'Growth Map'),
                          Text(
                            'June 2026',
                            style: HermesTypography.metadata,
                          ),
                        ],
                      ),
                      const SizedBox(height: HermesSpacing.md),
                      const _ContributionGraph(),
                    ],
                  ),
                ),
              ),
            ),

            // ── Section Gap ─────────────────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.sectionGap),
            ),

            // ── Recent Evolutios Timeline ───────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 240),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HermesSectionHeader(title: 'Recent Evolutios'),
                      const SizedBox(height: HermesSpacing.xs),
                      _TimelineEntry(
                        date: 'Today',
                        entries: [
                          _TimelineEvolutio(
                            text:
                                'Expected value finally clicked — it\'s about the long-run average.',
                            block: 'Mathematics',
                            blockColor: HermesColors.accent,
                          ),
                          _TimelineEvolutio(
                            text:
                                'Positioning matters more than features in a startup\'s first year.',
                            block: 'Startup',
                            blockColor: HermesColors.accentWarm,
                          ),
                        ],
                      ),
                      const SizedBox(height: HermesSpacing.lg),
                      _TimelineEntry(
                        date: 'Yesterday',
                        entries: [
                          _TimelineEvolutio(
                            text:
                                'Cognitive dissonance explains most resistance to change.',
                            block: 'Psychology',
                            blockColor: HermesColors.accentMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: HermesSpacing.lg),
                      _TimelineEntry(
                        date: 'June 25',
                        entries: [
                          _TimelineEvolutio(
                            text:
                                'Neural networks are just function approximators — everything clicked.',
                            block: 'AI',
                            blockColor: HermesColors.accentMuted,
                          ),
                          _TimelineEvolutio(
                            text:
                                'Decorators in Python are essentially higher-order functions.',
                            block: 'Python',
                            blockColor: HermesColors.accentSoft,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Veritas Entries on Missing Days ─────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 320),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: HermesSpacing.screenHorizontal,
                    right: HermesSpacing.screenHorizontal,
                    top: HermesSpacing.lg,
                  ),
                  child: _TimelineEntry(
                    date: 'June 24',
                    isVeritas: true,
                    entries: const [],
                    veritasText: 'College record work. Reached home at 10 PM.',
                  ),
                ),
              ),
            ),

            // ── Bottom Spacing ──────────────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: HermesSpacing.xxxl * 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: HermesSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(HermesRadius.md),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: HermesTypography.stat.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: HermesTypography.metadata.copyWith(
                color: color.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONTRIBUTION GRAPH — GitHub-style growth visualization
// ═══════════════════════════════════════════════════════════════════════════════

class _ContributionGraph extends StatelessWidget {
  const _ContributionGraph();

  @override
  Widget build(BuildContext context) {
    // Sample data — 4 weeks × 7 days
    final List<List<int>> weeks = [
      [0, 1, 0, 2, 1, 0, 0], // Week 1
      [1, 0, 3, 1, 0, 2, 0], // Week 2
      [0, 2, 1, 0, 0, 1, 3], // Week 3
      [2, 1, 0, 3, 2, 0, 0], // Week 4
    ];

    return Column(
      children: [
        // Day labels
        Padding(
          padding: const EdgeInsets.only(
            left: 32,
            bottom: HermesSpacing.xxs,
          ),
          child: Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(
                      child: Text(
                        d,
                        style: HermesTypography.metadata.copyWith(
                          fontSize: 10,
                          color: HermesColors.textDisabled,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ))
                .toList(),
          ),
        ),
        // Grid
        ...weeks.asMap().entries.map((weekEntry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    'W${weekEntry.key + 1}',
                    style: HermesTypography.metadata.copyWith(
                      fontSize: 10,
                      color: HermesColors.textDisabled,
                    ),
                  ),
                ),
                ...weekEntry.value.map((level) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getCommitColor(level),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        // Legend
        Padding(
          padding: const EdgeInsets.only(top: HermesSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: HermesTypography.metadata.copyWith(fontSize: 10),
              ),
              const SizedBox(width: HermesSpacing.xxs),
              ...[0, 1, 2, 3].map((level) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCommitColor(level),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
              const SizedBox(width: HermesSpacing.xxs),
              Text(
                'More',
                style: HermesTypography.metadata.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCommitColor(int level) {
    switch (level) {
      case 0:
        return HermesColors.commitEmpty;
      case 1:
        return HermesColors.commitLight;
      case 2:
        return HermesColors.commitMedium;
      case 3:
        return HermesColors.commitStrong;
      default:
        return HermesColors.commitFull;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TIMELINE
// ═══════════════════════════════════════════════════════════════════════════════

class _TimelineEvolutio {
  final String text;
  final String block;
  final Color blockColor;

  const _TimelineEvolutio({
    required this.text,
    required this.block,
    required this.blockColor,
  });
}

class _TimelineEntry extends StatelessWidget {
  final String date;
  final List<_TimelineEvolutio> entries;
  final bool isVeritas;
  final String? veritasText;

  const _TimelineEntry({
    required this.date,
    required this.entries,
    this.isVeritas = false,
    this.veritasText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date column
        SizedBox(
          width: 60,
          child: Text(
            date,
            style: HermesTypography.metadata.copyWith(
              color: isVeritas
                  ? HermesColors.veritasColor.withValues(alpha: 0.6)
                  : HermesColors.textTertiary,
            ),
          ),
        ),

        // Timeline line
        Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isVeritas
                    ? HermesColors.veritasColor.withValues(alpha: 0.5)
                    : HermesColors.evolutioGlow.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (entries.length > 1 || isVeritas)
              Container(
                width: 1,
                height: isVeritas ? 40 : (entries.length - 1) * 70.0 + 50,
                color: HermesColors.divider,
              ),
          ],
        ),

        const SizedBox(width: HermesSpacing.sm),

        // Content
        Expanded(
          child: isVeritas
              ? _VeritasContent(text: veritasText ?? '')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.asMap().entries.map((entry) {
                    final e = entry.value;
                    final isLast = entry.key == entries.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0 : HermesSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓ ${e.text}',
                            style: HermesTypography.bodySmall.copyWith(
                              color: HermesColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.block,
                            style: HermesTypography.metadata.copyWith(
                              color: e.blockColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VERITAS CONTENT
// ═══════════════════════════════════════════════════════════════════════════════

class _VeritasContent extends StatelessWidget {
  final String text;

  const _VeritasContent({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HermesSpacing.sm),
      decoration: BoxDecoration(
        color: HermesColors.veritasColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(HermesRadius.sm),
        border: Border.all(
          color: HermesColors.veritasColor.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veritas',
            style: HermesTypography.metadata.copyWith(
              color: HermesColors.veritasColor.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: HermesSpacing.xxs),
          Text(
            text,
            style: HermesTypography.bodySmall.copyWith(
              color: HermesColors.veritasColor.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
