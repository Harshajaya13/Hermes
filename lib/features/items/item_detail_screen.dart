import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final Item item;
  final Block block;

  const ItemDetailScreen({super.key, required this.item, required this.block});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  final _reflectionController = TextEditingController();
  bool _showEvolutioPrompt = false;

  void _submitReflection() {
    if (_reflectionController.text.trim().isEmpty) return;
    
    // According to Philosophy: 
    // Reflection -> Insight -> "Did this change you?"
    setState(() {
      _showEvolutioPrompt = true;
    });
  }

  void _recordEvolutio(bool didChange) async {
    final storage = ref.read(storageEngineProvider);
    
    final reflection = Reflection(
      itemId: widget.item.id,
      content: _reflectionController.text.trim(),
    );
    await storage.saveReflection(reflection);

    if (didChange) {
      final evolutio = Evolutio(
        reflectionId: reflection.id,
        blockId: widget.block.id,
        content: _reflectionController.text.trim(),
      );
      await storage.saveEvolutio(evolutio);
      ref.invalidate(allEvolutiosProvider);
      ref.invalidate(recentEvolutiosProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your evolution continues.', style: HermesTypography.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: HermesColors.evolutioGlow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.md)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
            HermesIconBadge(emoji: widget.block.icon, color: HermesColors.accent),
            const SizedBox(width: HermesSpacing.sm),
            Text(widget.block.name, style: HermesTypography.metadata),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(HermesSpacing.screenHorizontal),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.title, style: HermesTypography.screenTitle),
                    const SizedBox(height: HermesSpacing.lg),
                    
                    // Content Area (Reader / Question Engine goes here)
                    Text(
                      widget.item.content,
                      style: HermesTypography.body.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: HermesSpacing.xxxl),
                    
                    // Reflection Area
                    const HermesSectionHeader(title: 'Reflection'),
                    const SizedBox(height: HermesSpacing.sm),
                    Text(
                      'What did you learn? How does this connect?',
                      style: HermesTypography.metadata,
                    ),
                    const SizedBox(height: HermesSpacing.md),
                    
                    if (!_showEvolutioPrompt) ...[
                      TextField(
                        controller: _reflectionController,
                        maxLines: 5,
                        style: HermesTypography.reflection,
                        decoration: InputDecoration(
                          hintText: 'Type your reflection...',
                          hintStyle: HermesTypography.reflection.copyWith(color: HermesColors.textTertiary),
                          filled: true,
                          fillColor: HermesColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(HermesRadius.md),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: HermesSpacing.lg),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _submitReflection,
                          child: const Text('Save Reflection', style: TextStyle(color: HermesColors.accent)),
                        ),
                      ),
                    ] else ...[
                      // EVOLUTIO PROMPT (The core equation)
                      HermesFadeIn(
                        child: Container(
                          padding: const EdgeInsets.all(HermesSpacing.lg),
                          decoration: BoxDecoration(
                            color: HermesColors.evolutioGlow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(HermesRadius.lg),
                            border: Border.all(color: HermesColors.evolutioGlow.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Did this reflection genuinely change how you think or understand something?',
                                style: HermesTypography.itemTitle.copyWith(color: HermesColors.evolutioGlow),
                              ),
                              const SizedBox(height: HermesSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _recordEvolutio(false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: HermesColors.textSecondary,
                                        side: const BorderSide(color: HermesColors.border),
                                        padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                                      ),
                                      child: const Text('No, just save note'),
                                    ),
                                  ),
                                  const SizedBox(width: HermesSpacing.md),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _recordEvolutio(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: HermesColors.evolutioGlow,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                                      ),
                                      child: const Text('Yes, Record Evolutio'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
