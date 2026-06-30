import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class CreateManualEvolutioSheet extends ConsumerStatefulWidget {
  final DateTime date;

  const CreateManualEvolutioSheet({super.key, required this.date});

  static void show(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HermesColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: CreateManualEvolutioSheet(date: date),
        ),
      ),
    );
  }

  @override
  ConsumerState<CreateManualEvolutioSheet> createState() => _CreateManualEvolutioSheetState();
}

class _CreateManualEvolutioSheetState extends ConsumerState<CreateManualEvolutioSheet> {
  final _contentController = TextEditingController();
  Block? _selectedBlock;

  void _saveEvolutio() async {
    final content = _contentController.text.trim();
    if (content.isEmpty || _selectedBlock == null) return;

    final storage = ref.read(storageEngineProvider);

    // Create a dummy reflection to satisfy the required reflectionId for Evolutio.
    // This is because manual Evolutios don't come from a specific Item reflection.
    final reflection = Reflection(
      itemId: 'manual-evolutio',
      content: 'Manual Evolutio Entry',
      createdAt: widget.date, // Set to the selected date
    );
    await storage.saveReflection(reflection);

    final evolutio = Evolutio(
      reflectionId: reflection.id,
      blockId: _selectedBlock!.id,
      content: content,
      createdAt: widget.date, // Set to the selected date
    );
    await storage.saveEvolutio(evolutio);

    ref.invalidate(allEvolutiosProvider);
    ref.invalidate(recentEvolutiosProvider);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evolutio recorded for ${_formatDate(widget.date)}.', style: HermesTypography.bodySmall.copyWith(color: Colors.white)),
          backgroundColor: HermesColors.evolutioGlow,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(HermesSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Evolutio', style: HermesTypography.sectionTitle),
                Consumer(
                  builder: (context, ref, child) {
                    final blocks = ref.watch(allBlocksProvider);
                    if (_selectedBlock == null && blocks.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _selectedBlock = blocks.first);
                      });
                    }
                    return DropdownButton<Block>(
                      value: _selectedBlock,
                      dropdownColor: HermesColors.surfaceElevated,
                      style: HermesTypography.metadata,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: HermesColors.textSecondary),
                      items: blocks.map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b.name),
                      )).toList(),
                      onChanged: (val) {
                        setState(() => _selectedBlock = val);
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: HermesSpacing.sm),
            Text(
              'For ${_formatDate(widget.date)}',
              style: HermesTypography.metadata,
            ),
            const SizedBox(height: HermesSpacing.xl),
            
            TextField(
              controller: _contentController,
              autofocus: true,
              style: HermesTypography.body,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: HermesColors.surfaceElevated,
                hintText: 'What progress or insight did you gain?',
                hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                border: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.accent)),
              ),
            ),
            
            const SizedBox(height: HermesSpacing.xxxl),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveEvolutio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HermesColors.evolutioGlow,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HermesRadius.pill),
                  ),
                ),
                child: const Text('Record Evolutio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
