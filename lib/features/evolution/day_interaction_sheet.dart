import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import 'veritas_sheet.dart';
import 'create_manual_evolutio_sheet.dart';

class DayInteractionSheet extends ConsumerStatefulWidget {
  final DateTime date;
  final List<Evolutio> evolutios;
  final bool hasVeritas;
  final VoidCallback onFilterTimeline;

  const DayInteractionSheet({
    super.key,
    required this.date,
    required this.evolutios,
    required this.hasVeritas,
    required this.onFilterTimeline,
  });

  static void show(BuildContext context, {
    required DateTime date, 
    required List<Evolutio> evolutios,
    required bool hasVeritas,
    required VoidCallback onFilterTimeline,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HermesColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl)),
      ),
      builder: (context) => DayInteractionSheet(
        date: date,
        evolutios: evolutios,
        hasVeritas: hasVeritas,
        onFilterTimeline: onFilterTimeline,
      ),
    );
  }

  @override
  ConsumerState<DayInteractionSheet> createState() => _DayInteractionSheetState();
}

class _DayInteractionSheetState extends ConsumerState<DayInteractionSheet> {
  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.evolutios.isEmpty;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[widget.date.month - 1]} ${widget.date.day}, ${widget.date.year}';
    final blocks = ref.watch(allBlocksProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(HermesSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr, style: HermesTypography.metadata),
            const SizedBox(height: HermesSpacing.sm),
            
            if (isEmpty) ...[
              Text('What would you like to do for this day?', style: HermesTypography.screenTitle.copyWith(fontSize: 22)),
              const SizedBox(height: HermesSpacing.xxxl),
              
              _buildOptionCard(
                icon: Icons.edit_note_rounded,
                color: HermesColors.veritasColor,
                title: 'Record Veritas',
                subtitle: '"I want to explain this day."',
                onTap: () {
                  Navigator.pop(context);
                  VeritasSheet.show(context, dateMissed: widget.date);
                },
              ),
              const SizedBox(height: HermesSpacing.md),
              _buildOptionCard(
                icon: Icons.add_circle_outline,
                color: HermesColors.evolutioGlow,
                title: 'Add Evolutio',
                subtitle: '"I actually made progress but forgot to record it."',
                onTap: () {
                  Navigator.pop(context);
                  CreateManualEvolutioSheet.show(context, widget.date);
                },
              ),
            ] else ...[
              Text('Today\'s Evolutios', style: HermesTypography.screenTitle.copyWith(fontSize: 22)),
              const SizedBox(height: HermesSpacing.lg),
              
              // Render evolutios
              Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.evolutios.map((evo) {
                      final block = blocks.firstWhere((b) => b.id == evo.blockId, orElse: () => Block(domainId: '', name: 'Unknown', icon: '❓', colorHex: '#FFFFFF'));
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
                                    evo.content,
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
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: HermesSpacing.xl),
              const HermesDivider(),
              const SizedBox(height: HermesSpacing.xl),
              
              Text('Additional Actions', style: HermesTypography.sectionTitle),
              const SizedBox(height: HermesSpacing.md),
              
              _buildOptionCard(
                icon: Icons.add_circle_outline,
                color: HermesColors.evolutioGlow,
                title: 'Add another Evolutio',
                subtitle: '',
                onTap: () {
                  Navigator.pop(context);
                  CreateManualEvolutioSheet.show(context, widget.date);
                },
              ),
              const SizedBox(height: HermesSpacing.md),
              _buildOptionCard(
                icon: Icons.edit_note_rounded,
                color: HermesColors.veritasColor,
                title: 'Record Veritas',
                subtitle: '',
                onTap: () {
                  Navigator.pop(context);
                  VeritasSheet.show(context, dateMissed: widget.date);
                },
              ),
            ],
            
            const SizedBox(height: HermesSpacing.lg),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onFilterTimeline();
                },
                child: Text('Filter Timeline to this Date', style: TextStyle(color: HermesColors.textTertiary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionCard({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return HermesCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(HermesSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: HermesSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: HermesTypography.itemTitle),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: HermesTypography.metadata.copyWith(fontStyle: FontStyle.italic)),
                ]
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: HermesColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}
