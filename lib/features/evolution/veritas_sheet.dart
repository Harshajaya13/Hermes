import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class VeritasSheet extends ConsumerStatefulWidget {
  final DateTime? dateMissed;
  
  const VeritasSheet({super.key, this.dateMissed});

  static void show(BuildContext context, {DateTime? dateMissed}) {
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
        child: VeritasSheet(dateMissed: dateMissed),
      ),
    );
  }

  @override
  ConsumerState<VeritasSheet> createState() => _VeritasSheetState();
}

class _VeritasSheetState extends ConsumerState<VeritasSheet> {
  final _reasonController = TextEditingController();

  void _saveVeritas() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) return;

    final workspace = ref.read(currentWorkspaceProvider);
    if (workspace == null) return;

    final storage = ref.read(storageEngineProvider);
    final veritas = Veritas(
      workspaceId: workspace.id,
      dateMissed: widget.dateMissed ?? DateTime.now(),
      reason: reason,
    );

    await storage.saveVeritas(veritas);
    if (mounted) Navigator.pop(context);
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
              children: [
                Icon(Icons.edit_note_rounded, color: HermesColors.veritasColor),
                const SizedBox(width: HermesSpacing.sm),
                Text('Veritas', style: HermesTypography.sectionTitle.copyWith(color: HermesColors.veritasColor)),
              ],
            ),
            const SizedBox(height: HermesSpacing.sm),
            Text(
              'No guilt. No broken streaks. Just the honest truth about why today didn\'t go as planned.',
              style: HermesTypography.metadata,
            ),
            const SizedBox(height: HermesSpacing.xl),
            
            TextField(
              controller: _reasonController,
              autofocus: true,
              maxLines: 4,
              style: HermesTypography.reflection,
              decoration: InputDecoration(
                hintText: 'Grandmother admitted to hospital...\nCollege record work...\nBurnout...',
                hintStyle: HermesTypography.reflection.copyWith(color: HermesColors.textTertiary),
                filled: true,
                fillColor: HermesColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HermesRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: HermesSpacing.xxxl),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveVeritas,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HermesColors.veritasColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HermesRadius.pill),
                  ),
                ),
                child: const Text('Record Truth'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
