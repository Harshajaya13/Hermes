import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import 'veritas_sheet.dart';
import '../today/workspace_security_dialogs.dart';

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
  bool _showVeritas = true;
  bool _showEvolutios = true;

  @override
  Widget build(BuildContext context) {
    // Dynamic Data
    final evolutios = ref.watch(allEvolutiosProvider);
    final blocks = ref.watch(allBlocksProvider);
    final storage = ref.watch(storageEngineProvider);
    final activeWorkspace = ref.watch(currentWorkspaceProvider);
    
    final evolutiosCount = evolutios.length;
    final blocksCount = blocks.length;
    final List<Veritas> veritasEntries = _showVeritas && activeWorkspace != null ? storage.getVeritas(activeWorkspace.id) : <Veritas>[];
    final List<Evolutio> displayedEvolutios = _showEvolutios ? evolutios : <Evolutio>[];
    
    // Active Days = unique days of Evolutios + unique days of Veritas
    final Set<String> uniqueDays = {};
    for (var evo in displayedEvolutios) {
      uniqueDays.add(evo.createdAt.toString().substring(0, 10));
    }
    for (var v in veritasEntries) {
      uniqueDays.add(v.dateMissed.toString().substring(0, 10));
    }
    final activeDaysCount = uniqueDays.length;

    final archivedSections = ref.watch(archivedSectionsProvider);

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Evolution', style: HermesTypography.screenTitle),
                          const SizedBox(height: HermesSpacing.xxs),
                          Text('Your journey, visualized', style: HermesTypography.metadata),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.settings_rounded, color: HermesColors.textTertiary),
                        color: HermesColors.surfaceElevated,
                        itemBuilder: (context) {
                          final isPinned = !archivedSections.contains('evolutios');
                          return [
                            PopupMenuItem(
                              value: 'toggle_veritas',
                              child: Text(_showVeritas ? 'Hide Veritas' : 'Show Veritas', style: HermesTypography.bodySmall),
                            ),
                            PopupMenuItem(
                              value: 'toggle_evolutios',
                              child: Text(_showEvolutios ? 'Hide Evolutios' : 'Show Evolutios', style: HermesTypography.bodySmall),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'toggle_pin',
                              child: Text(isPinned ? 'Remove from Home' : 'Pin Evolution to Home', style: HermesTypography.bodySmall),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          if (value == 'toggle_veritas') {
                            setState(() => _showVeritas = !_showVeritas);
                          } else if (value == 'toggle_evolutios') {
                            setState(() => _showEvolutios = !_showEvolutios);
                          } else if (value == 'toggle_pin') {
                            final isPinned = !archivedSections.contains('evolutios');
                            if (isPinned) {
                              ref.read(archivedSectionsProvider.notifier).archiveSection('evolutios');
                            } else {
                              ref.read(archivedSectionsProvider.notifier).restoreSection('evolutios');
                            }
                          }
                        },
                      ),
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
                        evolutios: displayedEvolutios,
                        veritasEntries: veritasEntries,
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
                      if (displayedEvolutios.isEmpty && veritasEntries.isEmpty)
                        Text(
                          'Your timeline is empty. Start exploring to generate evolutios.',
                          style: HermesTypography.metadata,
                        )
                      else ..._buildTimeline(displayedEvolutios, veritasEntries, blocks),
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
  final List<Veritas> veritasEntries;
  final Function(DateTime) onDateSelected;

  const _ContributionGraph({
    required this.evolutios,
    required this.veritasEntries,
    required this.onDateSelected,
  });

  String _formatTooltipDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTooltip(DateTime date, int evoCount, bool hasVeritas) {
    final dateStr = _formatTooltipDate(date);
    if (evoCount == 0 && !hasVeritas) {
      return '$dateStr\nNo Activity';
    }
    List<String> parts = [dateStr];
    if (evoCount > 0) {
      parts.add('✓ $evoCount Evolutio${evoCount > 1 ? 's' : ''}');
    }
    if (hasVeritas) {
      parts.add('✓ Veritas Recorded');
    }
    return parts.join('\n');
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: HermesTypography.metadata.copyWith(fontSize: 10)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate actual 4-week grid ending today
    final now = DateTime.now();
    // Normalize to start of day
    final today = DateTime(now.year, now.month, now.day);
    // Find the Monday of the week that is 25 weeks ago (total 26 weeks)
    int weekday = today.weekday; // 1=Mon, 7=Sun
    final startDate = today.subtract(Duration(days: (weekday - 1) + 175)); // 25 weeks * 7 = 175 days + days to Monday
    
    // Build frequency map for Evolutios
    final Map<String, int> freq = {};
    for (var e in evolutios) {
      final d = e.createdAt.toString().substring(0, 10);
      freq[d] = (freq[d] ?? 0) + 1;
    }
    
    // Build set for Veritas
    final Set<String> veritasDays = {};
    for (var v in veritasEntries) {
      veritasDays.add(v.dateMissed.toString().substring(0, 10));
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
                      final evoCount = freq[dateStr] ?? 0;
                      final hasVeritas = veritasDays.contains(dateStr);
                      
                      Color cellColor;
                      if (evoCount > 0) {
                        cellColor = evoCount == 1 
                            ? HermesColors.evolutioGlow.withValues(alpha: 0.6)
                            : HermesColors.evolutioGlow;
                      } else if (hasVeritas) {
                        cellColor = HermesColors.veritasColor.withValues(alpha: 0.8);
                      } else {
                        cellColor = Colors.white.withValues(alpha: 0.05);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Tooltip(
                          message: _formatTooltip(date, evoCount, hasVeritas),
                          decoration: BoxDecoration(
                            color: HermesColors.surfaceElevated.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(HermesRadius.sm),
                            border: Border.all(color: HermesColors.border),
                          ),
                          textStyle: HermesTypography.metadata.copyWith(color: Colors.white, height: 1.4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: GestureDetector(
                            onTap: () {
                              if (evoCount == 0 && !hasVeritas) {
                                VeritasSheet.show(context, dateMissed: date);
                              } else {
                                onDateSelected(date);
                              }
                            },
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
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
              _buildLegendItem(Colors.white.withValues(alpha: 0.05), 'Inactive'),
              const SizedBox(width: HermesSpacing.sm),
              _buildLegendItem(HermesColors.veritasColor.withValues(alpha: 0.8), 'Veritas'),
              const SizedBox(width: HermesSpacing.sm),
              _buildLegendItem(HermesColors.evolutioGlow.withValues(alpha: 0.6), '1 Evolutio'),
              const SizedBox(width: HermesSpacing.sm),
              _buildLegendItem(HermesColors.evolutioGlow, '2+ Evolutios'),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TIMELINE
// ═══════════════════════════════════════════════════════════════════════════════

class _TimelineEntry extends ConsumerWidget {
  final String date;
  final List<dynamic> items; // Evolutios or Veritas
  final List<Block> blocks;

  const _TimelineEntry({
    required this.date,
    required this.items,
    required this.blocks,
  });

  void _confirmDelete(BuildContext context, WidgetRef ref, String objectType, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.lg)),
        title: Text('Delete $objectType?', style: HermesTypography.screenTitle),
        content: Text(
          'This will permanently delete this $objectType. This action is irreversible.',
          style: HermesTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: HermesTypography.button.copyWith(color: HermesColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HermesColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final workspace = ref.read(currentWorkspaceProvider);
              final deleteFunc = () async {
                if (objectType == 'Evolutio') {
                  await ref.read(storageEngineProvider).permanentlyDeleteEvolutio(id);
                  ref.invalidate(allEvolutiosProvider);
                } else if (objectType == 'Veritas') {
                  await ref.read(storageEngineProvider).permanentlyDeleteVeritas(id);
                }
                // Trigger a UI refresh.
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$objectType permanently deleted.')));
                  // To trigger a rebuild for Veritas (since it's not a riverpod provider directly in this screen)
                  ref.invalidate(allEvolutiosProvider);
                  // Optionally invalidate the screen state or use a generic provider
                }
              };

              if (workspace?.isEncrypted == true) {
                showDialog(
                  context: context,
                  builder: (_) => VerifyPinDialog(onSuccess: deleteFunc),
                );
              } else {
                deleteFunc();
              }
            },
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _VeritasContent(text: item.reason)),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, size: 16, color: HermesColors.textTertiary),
                          padding: EdgeInsets.zero,
                          color: HermesColors.surfaceElevated,
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'delete', child: Text('Delete Veritas', style: TextStyle(color: HermesColors.error))),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _confirmDelete(context, ref, 'Veritas', item.id);
                            }
                          },
                        ),
                      ],
                    ),
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
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, size: 16, color: HermesColors.textTertiary),
                          padding: EdgeInsets.zero,
                          color: HermesColors.surfaceElevated,
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'delete', child: Text('Delete Evolutio', style: TextStyle(color: HermesColors.error))),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _confirmDelete(context, ref, 'Evolutio', item.id);
                            }
                          },
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
