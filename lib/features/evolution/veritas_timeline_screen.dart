import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import 'package:intl/intl.dart';

class VeritasTimelineScreen extends ConsumerWidget {
  const VeritasTimelineScreen({super.key});

  void _editVeritas(BuildContext context, WidgetRef ref, Veritas veritas) {
    final controller = TextEditingController(text: veritas.reason);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.lg)),
        title: Text('Edit Veritas', style: HermesTypography.sectionTitle),
        content: TextField(
          controller: controller,
          maxLines: null,
          autofocus: true,
          style: HermesTypography.body,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Why did you pause?',
            hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: HermesColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: HermesColors.veritasColor, foregroundColor: Colors.white),
            onPressed: () async {
              final newReason = controller.text.trim();
              if (newReason.isNotEmpty && newReason != veritas.reason) {
                final updated = veritas.copyWith(reason: newReason);
                await ref.read(storageEngineProvider).saveVeritas(updated);
              }
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(currentWorkspaceProvider);
    final storage = ref.watch(storageEngineProvider);
    
    // Get veritas directly from storage engine for the current workspace
    final List<Veritas> veritasList = workspace != null 
        ? storage.getVeritas(workspace.id) 
        : [];

    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note_rounded, color: HermesColors.veritasColor, size: 20),
            const SizedBox(width: HermesSpacing.sm),
            Text('Veritas Timeline', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: veritasList.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(HermesSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.spa_rounded, size: 64, color: HermesColors.textTertiary.withValues(alpha: 0.3)),
                      const SizedBox(height: HermesSpacing.lg),
                      Text(
                        'No truths recorded yet.',
                        style: HermesTypography.itemTitle.copyWith(color: HermesColors.textSecondary),
                      ),
                      const SizedBox(height: HermesSpacing.sm),
                      Text(
                        'When you miss a day, record your truth here without guilt.',
                        textAlign: TextAlign.center,
                        style: HermesTypography.metadata,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(HermesSpacing.screenHorizontal),
                physics: const BouncingScrollPhysics(),
                itemCount: veritasList.length,
                itemBuilder: (context, index) {
                  final veritas = veritasList[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: HermesSpacing.xl),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Line & Dot
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                color: HermesColors.veritasColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: HermesColors.veritasColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            if (index != veritasList.length - 1)
                              Container(
                                width: 2,
                                height: 100, // Approximate height, or use IntrinsicHeight
                                margin: const EdgeInsets.only(top: 8),
                                color: HermesColors.border.withValues(alpha: 0.5),
                              ),
                          ],
                        ),
                        const SizedBox(width: HermesSpacing.lg),
                        
                        // Content Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(HermesSpacing.lg),
                            decoration: BoxDecoration(
                              color: HermesColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(HermesRadius.lg),
                              border: Border.all(color: HermesColors.border.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('EEEE, MMMM d, y').format(veritas.dateMissed),
                                      style: HermesTypography.metadata.copyWith(
                                        color: HermesColors.veritasColor.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(Icons.edit_rounded, size: 16, color: HermesColors.textTertiary),
                                      onPressed: () => _editVeritas(context, ref, veritas),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: HermesSpacing.sm),
                                Text(
                                  veritas.reason,
                                  style: HermesTypography.reflection.copyWith(
                                    color: HermesColors.textPrimary.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
