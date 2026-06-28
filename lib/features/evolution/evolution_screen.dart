import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import 'veritas_sheet.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// EVOLUTION SCREEN (Dynamic & Redesigned)
/// ─────────────────────────────────────────────────────────────────────────────
/// Codex: "Evolution isn't stored. Evolution is generated from all Evolutios."
/// ─────────────────────────────────────────────────────────────────────────────

class EvolutionScreen extends ConsumerStatefulWidget {
  const EvolutionScreen({super.key});

  @override
  ConsumerState<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends ConsumerState<EvolutionScreen> {
  String? _selectedDateFilter;

  @override
  Widget build(BuildContext context) {
    // Dynamic Data
    final evolutios = ref.watch(allEvolutiosProvider);
    final blocks = ref.watch(allBlocksProvider);
    final storage = ref.watch(storageEngineProvider);
    final activeWorkspace = ref.watch(currentWorkspaceProvider);
    
    final evolutiosCount = evolutios.length;
    final blocksCount = blocks.length;
    final List<Veritas> veritasEntries = activeWorkspace != null ? storage.getVeritas(activeWorkspace.id) : <Veritas>[];
    
    // Active Days = unique days of Evolutios + unique days of Veritas
    final Set<String> uniqueDays = {};
    for (var evo in evolutios) {
      uniqueDays.add(evo.createdAt.toString().substring(0, 10));
    }
    for (var v in veritasEntries) {
      uniqueDays.add(v.dateMissed.toString().substring(0, 10));
    }
    final activeDaysCount = uniqueDays.length;

    return Scaffold(
      backgroundColor: HermesColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: HermesSpacing.xl)),

            // ── Screen Title ────────────────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Evolution', style: HermesTypography.screenTitle),
                      const SizedBox(height: HermesSpacing.xxs),
                      Text('Your journey, visualized', style: HermesTypography.metadata),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: HermesSpacing.xl)),

            // ── Minimal Stats Summary ───────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 80),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.screenHorizontal),
                  child: Row(
                    children: [
                      _StatCard(
                        value: evolutiosCount.toString(),
                        label: 'Evolutios',
                        color: HermesColors.evolutioGlow,
                      ),
                      const SizedBox(width: HermesSpacing.md),
                      _StatCard(
                        value: activeDaysCount.toString(),
                        label: 'Active Days',
                        color: HermesColors.accent,
                      ),
                      const SizedBox(width: HermesSpacing.md),
                      _StatCard(
                        value: blocksCount.toString(),
                        label: 'Blocks',
                        color: HermesColors.accentWarm,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: HermesSpacing.xxxl)),

            // ── Contribution Graph ──────────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 160),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          HermesSectionHeader(
                            title: _selectedDateFilter != null ? 'Growth Map (Filtered)' : 'Growth Map'
                          ),
                          if (_selectedDateFilter != null)
                            GestureDetector(
                              onTap: () => setState(() => _selectedDateFilter = null),
                              child: Text('Clear', style: HermesTypography.metadata.copyWith(color: HermesColors.evolutioGlow)),
                            )
                          else
                            Text(_getMonthYear(DateTime.now()), style: HermesTypography.metadata),
                        ],
                      ),
                      const SizedBox(height: HermesSpacing.lg),
                      _ContributionGraph(
                        evolutios: evolutios,
                        onDateSelected: (date) {
                          setState(() => _selectedDateFilter = date.toString().substring(0, 10));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: HermesSpacing.xxxl)),

            // ── Dynamic Timeline ────────────────────────────────────
            SliverToBoxAdapter(
              child: HermesFadeIn(
                delay: const Duration(milliseconds: 240),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HermesSectionHeader(title: 'Timeline'),
                      const SizedBox(height: HermesSpacing.lg),
                      if (evolutios.isEmpty && veritasEntries.isEmpty)
                        Text(
                          'Your timeline is empty. Start exploring to generate evolutios.',
                          style: HermesTypography.metadata,
                        )
                      else ..._buildTimeline(evolutios, veritasEntries, blocks),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
  
  String _getMonthYear(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.year}';
  }

  List<Widget> _buildTimeline(List<Evolutio> evolutios, List<Veritas> veritas, List<Block> blocks) {
    // Combine and sort
    final Map<String, List<dynamic>> grouped = {};
    
    for (var e in evolutios) {
      final dateStr = e.createdAt.toString().substring(0, 10);
      grouped.putIfAbsent(dateStr, () => []).add(e);
    }
    
    for (var v in veritas) {
      final dateStr = v.dateMissed.toString().substring(0, 10);
      grouped.putIfAbsent(dateStr, () => []).add(v);
    }
    
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    
    final filteredDates = _selectedDateFilter != null 
        ? sortedDates.where((d) => d == _selectedDateFilter).toList()
        : sortedDates;

    if (filteredDates.isEmpty && _selectedDateFilter != null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.xl),
          child: Center(
            child: Text('No activity on this date.', style: HermesTypography.metadata),
          ),
        )
      ];
    }
    
    return filteredDates.map((date) {
      final items = grouped[date]!;
      
      return _TimelineEntry(
        date: _formatTimelineDate(date),
        items: items,
        blocks: blocks,
      );
    }).toList();
  }
  
  String _formatTimelineDate(String yyyymmdd) {
    final now = DateTime.now();
    final todayStr = now.toString().substring(0, 10);
    if (yyyymmdd == todayStr) return 'Today';
    
    final date = DateTime.parse(yyyymmdd);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MINIMAL STAT CARD
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
        padding: const EdgeInsets.symmetric(vertical: HermesSpacing.lg, horizontal: HermesSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(HermesRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: HermesTypography.stat.copyWith(
                color: color.withValues(alpha: 0.9),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: HermesTypography.metadata.copyWith(
                color: color.withValues(alpha: 0.6),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TIGHT CONTRIBUTION GRAPH
// ═══════════════════════════════════════════════════════════════════════════════

class _ContributionGraph extends StatelessWidget {
  final List<Evolutio> evolutios;
  final Function(DateTime) onDateSelected;

  const _ContributionGraph({
    required this.evolutios,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Generate actual 4-week grid ending today
    final now = DateTime.now();
    // Normalize to start of day
    final today = DateTime(now.year, now.month, now.day);
    // Find the Monday of the week that is 25 weeks ago (total 26 weeks)
    int weekday = today.weekday; // 1=Mon, 7=Sun
    final startDate = today.subtract(Duration(days: (weekday - 1) + 175)); // 25 weeks * 7 = 175 days + days to Monday
    
    // Build frequency map
    final Map<String, int> freq = {};
    for (var e in evolutios) {
      final d = e.createdAt.toString().substring(0, 10);
      freq[d] = (freq[d] ?? 0) + 1;
    }

    final List<List<DateTime>> weeks = [];
    DateTime curr = startDate;
    for (int i = 0; i < 26; i++) {
      final List<DateTime> week = [];
      for (int j = 0; j < 7; j++) {
        week.add(curr);
        curr = curr.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    return Container(
      padding: const EdgeInsets.all(HermesSpacing.lg),
      decoration: BoxDecoration(
        color: HermesColors.surfaceElevated,
        borderRadius: BorderRadius.circular(HermesRadius.lg),
        border: Border.all(color: HermesColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Days labels
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['M', 'W', 'F'].map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      d,
                      style: HermesTypography.metadata.copyWith(fontSize: 9, color: HermesColors.textDisabled),
                    ),
                  )).toList(),
                ),
              ),
              // Weeks
              ...weeks.map((week) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Column(
                    children: week.map((date) {
                      // Don't show future days
                      if (date.isAfter(today)) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: SizedBox(width: 14, height: 14),
                        );
                      }
                      
                      final dateStr = date.toString().substring(0, 10);
                      final count = freq[dateStr] ?? 0;
                      int level = 0;
                      if (count > 0) level = 1;
                      if (count > 2) level = 2;
                      if (count > 4) level = 3;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            if (count == 0) {
                              VeritasSheet.show(context, dateMissed: date);
                            } else {
                              onDateSelected(date);
                            }
                          },
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _getCommitColor(level),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
          ),
          
          const SizedBox(height: HermesSpacing.md),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: HermesTypography.metadata.copyWith(fontSize: 10)),
              const SizedBox(width: HermesSpacing.xs),
              ...[0, 1, 2, 3].map((level) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getCommitColor(level),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
              const SizedBox(width: HermesSpacing.xs),
              Text('More', style: HermesTypography.metadata.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCommitColor(int level) {
    switch (level) {
      case 0: return Colors.white.withValues(alpha: 0.05); // Visible empty state
      case 1: return HermesColors.evolutioGlow.withValues(alpha: 0.3);
      case 2: return HermesColors.evolutioGlow.withValues(alpha: 0.6);
      case 3: return HermesColors.evolutioGlow;
      default: return HermesColors.evolutioGlow;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TIMELINE
// ═══════════════════════════════════════════════════════════════════════════════

class _TimelineEntry extends StatelessWidget {
  final String date;
  final List<dynamic> items; // Evolutios or Veritas
  final List<Block> blocks;

  const _TimelineEntry({
    required this.date,
    required this.items,
    required this.blocks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HermesSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date column
          SizedBox(
            width: 50,
            child: Text(
              date,
              style: HermesTypography.metadata.copyWith(
                color: HermesColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: HermesSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                if (item is Veritas) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: HermesSpacing.md),
                    child: _VeritasContent(text: item.reason),
                  );
                } else if (item is Evolutio) {
                  final block = blocks.firstWhere(
                    (b) => b.id == item.blockId,
                    orElse: () => Block(domainId: '', name: 'Unknown', icon: '❓', colorHex: '#FFFFFF'),
                  );
                  final color = Color(int.parse(block.colorHex.replaceFirst('#', '0xFF')));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: HermesSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: HermesSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.content,
                                style: HermesTypography.bodySmall.copyWith(
                                  color: HermesColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                block.name,
                                style: HermesTypography.metadata.copyWith(
                                  color: color.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ),
        ],
      ),
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
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 14, color: HermesColors.veritasColor.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text(
                'Veritas',
                style: HermesTypography.metadata.copyWith(
                  color: HermesColors.veritasColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: HermesSpacing.xs),
          Text(
            text.isEmpty ? 'No notes provided.' : text,
            style: HermesTypography.bodySmall.copyWith(
              color: HermesColors.veritasColor.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
