import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/providers/providers.dart';

class EditIdentityDialog extends ConsumerStatefulWidget {
  const EditIdentityDialog({super.key});

  @override
  ConsumerState<EditIdentityDialog> createState() => _EditIdentityDialogState();
}

class _EditIdentityDialogState extends ConsumerState<EditIdentityDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _loreController;
  late String _selectedIcon;

  final List<String> _avatars = [
    '🙂', '🤠', '😎', '🤓', '👽', '👾', '🤖', '🦊', '🦉', '🐉', '⚡', '🔥', '🌟', '🔮', '🎭'
  ];

  @override
  void initState() {
    super.initState();
    final ws = ref.read(currentWorkspaceProvider);
    _nameController = TextEditingController(text: ws?.ownerName ?? '');
    _nicknameController = TextEditingController(text: ws?.ownerNickname ?? '');
    _loreController = TextEditingController(text: ws?.lore ?? '');
    _selectedIcon = ws?.icon ?? '🙂';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _loreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ws = ref.read(currentWorkspaceProvider);
    if (ws != null) {
      final updated = ws.copyWith(
        ownerName: _nameController.text.trim(),
        ownerNickname: _nicknameController.text.trim(),
        lore: _loreController.text.trim(),
        icon: _selectedIcon,
      );
      await ref.read(storageEngineProvider).saveWorkspace(updated);
      ref.read(currentWorkspaceProvider.notifier).updateWorkspace(updated);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HermesColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.xl)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HermesSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Identity', style: HermesTypography.sectionTitle),
              const SizedBox(height: HermesSpacing.lg),
              
              Text('Avatar', style: HermesTypography.metadata),
              const SizedBox(height: HermesSpacing.sm),
              Wrap(
                spacing: HermesSpacing.sm,
                runSpacing: HermesSpacing.sm,
                children: _avatars.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(HermesSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected ? HermesColors.evolutioGlow.withValues(alpha: 0.2) : HermesColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? HermesColors.evolutioGlow : HermesColors.border,
                        ),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: HermesSpacing.lg),

              Text('Name', style: HermesTypography.metadata),
              const SizedBox(height: HermesSpacing.xs),
              TextField(
                controller: _nameController,
                style: HermesTypography.body,
                decoration: InputDecoration(
                  hintText: 'e.g. Harsha',
                  hintStyle: HermesTypography.metadata,
                  filled: true,
                  fillColor: HermesColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(HermesRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: HermesSpacing.md),

              Text('Title / Nickname', style: HermesTypography.metadata),
              const SizedBox(height: HermesSpacing.xs),
              TextField(
                controller: _nicknameController,
                style: HermesTypography.body,
                decoration: InputDecoration(
                  hintText: 'e.g. The Architect',
                  hintStyle: HermesTypography.metadata,
                  filled: true,
                  fillColor: HermesColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(HermesRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: HermesSpacing.md),

              Text('Personal Lore', style: HermesTypography.metadata),
              const SizedBox(height: HermesSpacing.xs),
              TextField(
                controller: _loreController,
                style: HermesTypography.body,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Deliberately becoming who I want to become.',
                  hintStyle: HermesTypography.metadata,
                  filled: true,
                  fillColor: HermesColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(HermesRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: HermesSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: HermesTypography.button.copyWith(color: HermesColors.textSecondary)),
                  ),
                  const SizedBox(width: HermesSpacing.sm),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HermesColors.evolutioGlow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.md)),
                    ),
                    child: const Text('Save Identity'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
