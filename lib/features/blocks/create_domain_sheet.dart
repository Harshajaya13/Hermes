import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class CreateDomainSheet extends ConsumerStatefulWidget {
  final Domain? existingDomain;

  const CreateDomainSheet({super.key, this.existingDomain});

  static void show(BuildContext context, [Domain? existingDomain]) {
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
        child: CreateDomainSheet(existingDomain: existingDomain),
      ),
    );
  }

  @override
  ConsumerState<CreateDomainSheet> createState() => _CreateDomainSheetState();
}

class _CreateDomainSheetState extends ConsumerState<CreateDomainSheet> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController(text: '📁');

  @override
  void initState() {
    super.initState();
    if (widget.existingDomain != null) {
      _nameController.text = widget.existingDomain!.name;
      _emojiController.text = widget.existingDomain!.icon;
    }
  }

  void _saveDomain() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final workspace = ref.read(currentWorkspaceProvider);
    if (workspace == null) return;

    final allDomains = ref.read(domainsProvider);
    if (widget.existingDomain == null || widget.existingDomain!.name != name) {
      if (allDomains.any((d) => d.name.toLowerCase() == name.toLowerCase())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('A domain with this name already exists', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textPrimary)),
            backgroundColor: HermesColors.surfaceElevated,
          ));
        }
        return;
      }
    }

    final newDomain = widget.existingDomain != null
        ? widget.existingDomain!.copyWith(
            name: name,
            icon: _emojiController.text.trim().isEmpty ? '📁' : _emojiController.text.trim(),
          )
        : Domain(
            workspaceId: workspace.id,
            name: name,
            icon: _emojiController.text.trim().isEmpty ? '📁' : _emojiController.text.trim(),
          );

    if (mounted) Navigator.pop(context);
    await ref.read(storageEngineProvider).saveDomain(newDomain);
    ref.invalidate(domainsProvider);
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
            Text(widget.existingDomain == null ? 'Create Domain' : 'Edit Domain', style: HermesTypography.sectionTitle),
            const SizedBox(height: HermesSpacing.sm),
            Text(
              'A high-level area that groups related Blocks (e.g., Engineering, Thinking, Life).',
              style: HermesTypography.metadata,
            ),
            const SizedBox(height: HermesSpacing.xl),
            
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
                      hintText: 'Domain Name',
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
            const SizedBox(height: HermesSpacing.xxxl),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDomain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HermesColors.accent,
                  foregroundColor: HermesColors.background,
                  padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HermesRadius.pill),
                  ),
                ),
                child: Text(widget.existingDomain == null ? 'Create Domain' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
