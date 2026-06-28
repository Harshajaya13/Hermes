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

  @override
  void initState() {
    super.initState();
    if (widget.existingDomain != null) {
      _nameController.text = widget.existingDomain!.name;
    }
  }

  void _saveDomain() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final workspace = ref.read(currentWorkspaceProvider);
    if (workspace == null) return;

    final newDomain = widget.existingDomain != null
        ? widget.existingDomain!.copyWith(name: name)
        : Domain(
            workspaceId: workspace.id,
            name: name,
          );

    await ref.read(storageEngineProvider).saveDomain(newDomain);
    ref.invalidate(domainsProvider);
    
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
            Text(widget.existingDomain == null ? 'Create Domain' : 'Edit Domain', style: HermesTypography.sectionTitle),
            const SizedBox(height: HermesSpacing.sm),
            Text(
              'A high-level area that groups related Blocks (e.g., Engineering, Thinking, Life).',
              style: HermesTypography.metadata,
            ),
            const SizedBox(height: HermesSpacing.xl),
            
            TextField(
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
            const SizedBox(height: HermesSpacing.xxxl),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDomain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HermesColors.accent,
                  foregroundColor: Colors.white,
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
