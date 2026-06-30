import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class SwitchWorkspaceDialog extends ConsumerStatefulWidget {
  const SwitchWorkspaceDialog({super.key});

  @override
  ConsumerState<SwitchWorkspaceDialog> createState() => _SwitchWorkspaceDialogState();
}

class _SwitchWorkspaceDialogState extends ConsumerState<SwitchWorkspaceDialog> {
  Future<void> _setAsDefault(Workspace ws) async {
    final storage = ref.read(storageEngineProvider);
    // Unset all others
    for (final w in storage.workspaces) {
      if (w.isDefault) {
        await storage.saveWorkspace(w.copyWith(isDefault: false));
      }
    }
    // Set this one
    final updated = ws.copyWith(isDefault: true);
    await storage.saveWorkspace(updated);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final workspaces = ref.watch(storageEngineProvider).workspaces;
    final currentWs = ref.watch(currentWorkspaceProvider);

    return Dialog(
      backgroundColor: HermesColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.xl)),
      child: Padding(
        padding: const EdgeInsets.all(HermesSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Switch Workspace', style: HermesTypography.sectionTitle),
            const SizedBox(height: HermesSpacing.lg),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: workspaces.length,
                separatorBuilder: (context, index) => const Divider(color: HermesColors.border, height: 1),
                itemBuilder: (context, index) {
                  final ws = workspaces[index];
                  final isActive = ws.id == currentWs?.id;
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isActive ? HermesColors.evolutioGlow.withValues(alpha: 0.1) : HermesColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: isActive ? HermesColors.evolutioGlow : HermesColors.border),
                      ),
                      child: Center(child: Text(ws.icon, style: const TextStyle(fontSize: 20))),
                    ),
                    title: Row(
                      children: [
                        if (ws.isDefault) const Text('⭐ ', style: TextStyle(fontSize: 14)),
                        Expanded(child: Text(ws.name, style: HermesTypography.body)),
                      ],
                    ),
                    subtitle: isActive ? Text('Active Workspace', style: HermesTypography.metadata.copyWith(color: HermesColors.evolutioGlow)) : null,
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: HermesColors.textTertiary),
                      color: HermesColors.surfaceElevated,
                      itemBuilder: (context) => [
                        if (!ws.isDefault)
                          const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                        if (!isActive && workspaces.length > 1)
                          const PopupMenuItem(value: 'archive', child: Text('Archive Workspace')),
                        if (!isActive && workspaces.length > 1)
                          const PopupMenuItem(value: 'delete', child: Text('Delete Workspace', style: TextStyle(color: HermesColors.error))),
                      ],
                      onSelected: (val) async {
                        if (val == 'default') {
                          await _setAsDefault(ws);
                        } else if (val == 'archive') {
                          final storage = ref.read(storageEngineProvider);
                          await storage.saveWorkspace(ws.copyWith(archived: true));
                          if (mounted) setState(() {});
                        } else if (val == 'delete') {
                          final storage = ref.read(storageEngineProvider);
                          await storage.saveWorkspace(ws.copyWith(deleted: true));
                          if (mounted) setState(() {});
                        }
                      },
                    ),
                    onTap: () {
                      if (!isActive) {
                        ref.read(currentWorkspaceProvider.notifier).updateWorkspace(ws);
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: HermesSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: HermesTypography.button.copyWith(color: HermesColors.textSecondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RenameWorkspaceDialog extends ConsumerStatefulWidget {
  const RenameWorkspaceDialog({super.key});
  @override
  ConsumerState<RenameWorkspaceDialog> createState() => _RenameWorkspaceDialogState();
}

class _RenameWorkspaceDialogState extends ConsumerState<RenameWorkspaceDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final ws = ref.read(currentWorkspaceProvider);
    _controller = TextEditingController(text: ws?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _rename() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    
    final ws = ref.read(currentWorkspaceProvider);
    if (ws != null) {
      final updated = ws.copyWith(name: name);
      await ref.read(storageEngineProvider).saveWorkspace(updated);
      ref.read(currentWorkspaceProvider.notifier).updateWorkspace(updated);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HermesColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(HermesSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rename Workspace', style: HermesTypography.sectionTitle),
            const SizedBox(height: HermesSpacing.md),
            TextField(
              controller: _controller,
              style: HermesTypography.body,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: HermesColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HermesRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: HermesSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: HermesTypography.button.copyWith(color: HermesColors.textSecondary)),
                ),
                const SizedBox(width: HermesSpacing.sm),
                ElevatedButton(
                  onPressed: _rename,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HermesColors.evolutioGlow,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Rename'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreateWorkspaceDialog extends ConsumerStatefulWidget {
  const CreateWorkspaceDialog({super.key});
  @override
  ConsumerState<CreateWorkspaceDialog> createState() => _CreateWorkspaceDialogState();
}

class _CreateWorkspaceDialogState extends ConsumerState<CreateWorkspaceDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    
    final storage = ref.read(storageEngineProvider);
    final existingNames = storage.workspaces.where((w) => !w.deleted).map((w) => w.name.toLowerCase()).toSet();
    if (existingNames.contains(name.toLowerCase())) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A workspace with this name already exists')));
      return;
    }

    final ws = Workspace(name: name);
    await storage.saveWorkspace(ws);
    
    // We intentionally DO NOT seed the starter workspace here. 
    // New workspaces should be completely blank.
    // We also DO NOT auto-jump to the new workspace.
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HermesColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(HermesSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Workspace', style: HermesTypography.sectionTitle),
            const SizedBox(height: HermesSpacing.xs),
            Text('A new blank workspace will be created.', style: HermesTypography.metadata),
            const SizedBox(height: HermesSpacing.md),
            TextField(
              controller: _controller,
              style: HermesTypography.body,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Startup, College',
                hintStyle: HermesTypography.metadata,
                filled: true,
                fillColor: HermesColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HermesRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: HermesSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: HermesTypography.button.copyWith(color: HermesColors.textSecondary)),
                ),
                const SizedBox(width: HermesSpacing.sm),
                ElevatedButton(
                  onPressed: _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HermesColors.evolutioGlow,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
