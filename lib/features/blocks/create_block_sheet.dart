import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class CreateBlockSheet extends ConsumerStatefulWidget {
  final Block? existingBlock;
  final String? initialDomainId;

  const CreateBlockSheet({super.key, this.existingBlock, this.initialDomainId});

  static void show(BuildContext context, [Block? existingBlock, String? initialDomainId]) {
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
        child: CreateBlockSheet(existingBlock: existingBlock, initialDomainId: initialDomainId),
      ),
    );
  }

  @override
  ConsumerState<CreateBlockSheet> createState() => _CreateBlockSheetState();
}

class _CreateBlockSheetState extends ConsumerState<CreateBlockSheet> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController(text: '📘');
  String _selectedDomainId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.existingBlock != null) {
        setState(() {
          _nameController.text = widget.existingBlock!.name;
          _emojiController.text = widget.existingBlock!.icon;
          _selectedDomainId = widget.existingBlock!.domainId;
        });
        if (widget.initialDomainId != null) {
          setState(() {
            _selectedDomainId = widget.initialDomainId!;
          });
        } else {
          final domains = ref.read(domainsProvider);
          if (domains.isNotEmpty) {
            setState(() {
              _selectedDomainId = domains.first.id;
            });
          }
        }
      }
    });
  }

  void _saveBlock() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedDomainId.isEmpty) return;

    final storage = ref.read(storageEngineProvider);
    final allBlocks = ref.read(allBlocksProvider);
    if (widget.existingBlock == null || widget.existingBlock!.name != name) {
      if (allBlocks.any((b) => b.name.toLowerCase() == name.toLowerCase())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('A block with this name already exists', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textPrimary)),
            backgroundColor: HermesColors.surfaceElevated,
          ));
        }
        return;
      }
    }

    final newBlock = widget.existingBlock != null
        ? widget.existingBlock!.copyWith(
            domainId: _selectedDomainId,
            name: name,
            icon: _emojiController.text.trim().isEmpty ? '📘' : _emojiController.text.trim(),
          )
        : Block(
            domainId: _selectedDomainId,
            name: name,
            icon: _emojiController.text.trim().isEmpty ? '📘' : _emojiController.text.trim(),
            colorHex: '#7C9EBC', // Default accent
          );

    await ref.read(storageEngineProvider).saveBlock(newBlock);
    
    // Invalidate the provider so UI updates
    ref.invalidate(allBlocksProvider);
    ref.invalidate(blocksByDomainProvider(_selectedDomainId));
    
    if (mounted) Navigator.pop(context);
    ref.invalidate(allBlocksProvider);
  }

  @override
  Widget build(BuildContext context) {
    final domains = ref.watch(domainsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(HermesSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existingBlock == null ? 'Create Block' : 'Edit Block', style: HermesTypography.sectionTitle),
            const SizedBox(height: HermesSpacing.sm),
            Text(
              'An intentional environment for a specific area of growth.',
              style: HermesTypography.metadata,
            ),
            const SizedBox(height: HermesSpacing.xl),
            
            // Emoji and Name Input
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: HermesColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(HermesRadius.md),
                    border: Border.all(color: HermesColors.border),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _emojiController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    maxLength: 1,
                  ),
                ),
                const SizedBox(width: HermesSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: HermesTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Block Name (e.g., Mathematics)',
                      hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: HermesColors.border),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: HermesColors.border),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: HermesColors.accent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: HermesSpacing.xl),
            
            // Domain Selection
            Text('Select Domain', style: HermesTypography.metadata),
            const SizedBox(height: HermesSpacing.sm),
            Wrap(
              spacing: HermesSpacing.sm,
              children: domains.map((d) {
                final isSelected = d.id == _selectedDomainId;
                return ChoiceChip(
                  label: Text(d.name),
                  selected: isSelected,
                  selectedColor: HermesColors.accent.withValues(alpha: 0.2),
                  backgroundColor: HermesColors.surfaceElevated,
                  labelStyle: HermesTypography.metadata.copyWith(
                    color: isSelected ? HermesColors.accent : HermesColors.textSecondary,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDomainId = d.id);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: HermesSpacing.xxxl),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBlock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HermesColors.accent,
                  foregroundColor: HermesColors.background,
                  padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HermesRadius.pill),
                  ),
                ),
                child: Text(widget.existingBlock == null ? 'Create Block' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
