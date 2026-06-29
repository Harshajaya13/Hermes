import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/engines/exchange_engine.dart';

class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key});

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  ExchangePackagePreview? _preview;
  String? _selectedFilePath;

  Future<void> _handleExport() async {
    final workspace = ref.read(currentWorkspaceProvider);
    if (workspace == null) return;
    
    setState(() => _isExporting = true);
    try {
      final engine = ref.read(exchangeEngineProvider);
      final path = await engine.exportWorkspace(workspace.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Workspace exported to $path', style: HermesTypography.body),
          backgroundColor: HermesColors.evolutioGlow,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e', style: HermesTypography.body),
          backgroundColor: HermesColors.error,
        ));
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _handleImportSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['hermes'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setState(() {
        _selectedFilePath = path;
        _isImporting = true;
      });

      try {
        final engine = ref.read(exchangeEngineProvider);
        final preview = await engine.previewPackage(path);
        setState(() {
          _preview = preview;
          _isImporting = false;
        });
        _showPreviewDialog();
      } catch (e) {
        setState(() => _isImporting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Validation Failed: $e', style: HermesTypography.body),
            backgroundColor: HermesColors.error,
          ));
        }
      }
    }
  }

  void _showPreviewDialog() {
    if (_preview == null || _selectedFilePath == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HermesColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(HermesSpacing.xl),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Package Preview', style: HermesTypography.screenTitle.copyWith(fontSize: 24)),
                const SizedBox(height: HermesSpacing.md),
                Text('Valid .hermes package detected.', style: HermesTypography.body.copyWith(color: HermesColors.evolutioGlow)),
                const SizedBox(height: HermesSpacing.lg),
                
                HermesCard(
                  child: Column(
                    children: [
                      _buildPreviewRow('Workspace Name', _preview!.manifest['Workspace Name']),
                      _buildPreviewRow('Created By', _preview!.manifest['Created By'] ?? 'Unknown'),
                      _buildPreviewRow('Hermes Version', _preview!.manifest['Hermes Version'] ?? 'Unknown'),
                      const Divider(color: HermesColors.border, height: HermesSpacing.xl),
                      _buildPreviewRow('Domains', '${_preview!.domainCount}'),
                      _buildPreviewRow('Blocks', '${_preview!.blockCount}'),
                      _buildPreviewRow('Items', '${_preview!.itemCount}'),
                      _buildPreviewRow('Sources', '${_preview!.sourceCount}'),
                    ],
                  )
                ),
                const SizedBox(height: HermesSpacing.xl),
                Text('Import As:', style: HermesTypography.sectionTitle),
                const SizedBox(height: HermesSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HermesColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _processImport(asNewWorkspace: true);
                        },
                        child: const Text('New Workspace'),
                      ),
                    ),
                    const SizedBox(width: HermesSpacing.md),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HermesColors.textSecondary,
                          side: const BorderSide(color: HermesColors.border),
                          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showMergeStrategyDialog();
                        },
                        child: const Text('Merge'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showMergeStrategyDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(HermesSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Merge Strategy', style: HermesTypography.screenTitle.copyWith(fontSize: 24)),
              const SizedBox(height: HermesSpacing.sm),
              Text('How should conflicts (duplicates) be handled?', style: HermesTypography.bodySmall),
              const SizedBox(height: HermesSpacing.lg),
              
              _buildStrategyTile('Skip', 'Keep existing items. Ignore package duplicates.', 'skip'),
              _buildStrategyTile('Replace', 'Overwrite existing items with package data.', 'replace'),
              _buildStrategyTile('Duplicate', 'Keep both. Appends (Copy) to package data.', 'duplicate'),
              _buildStrategyTile('Rename', 'Rename imported items slightly.', 'rename'),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStrategyTile(String title, String subtitle, String strategy) {
    return ListTile(
      title: Text(title, style: HermesTypography.body),
      subtitle: Text(subtitle, style: HermesTypography.metadata),
      trailing: const Icon(Icons.chevron_right, color: HermesColors.textTertiary),
      onTap: () {
        Navigator.pop(context);
        _processImport(asNewWorkspace: false, mergeStrategy: strategy);
      },
    );
  }

  Future<void> _processImport({required bool asNewWorkspace, String mergeStrategy = 'skip'}) async {
    if (_selectedFilePath == null) return;
    
    setState(() => _isImporting = true);
    try {
      final engine = ref.read(exchangeEngineProvider);
      final targetId = asNewWorkspace ? null : ref.read(currentWorkspaceProvider)?.id;
      
      await engine.importPackage(
        filePath: _selectedFilePath!,
        asNewWorkspace: asNewWorkspace,
        targetWorkspaceId: targetId,
        mergeStrategy: mergeStrategy,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Import successful!', style: HermesTypography.body),
          backgroundColor: HermesColors.evolutioGlow,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Import failed: $e', style: HermesTypography.body),
          backgroundColor: HermesColors.error,
        ));
      }
    } finally {
      setState(() {
        _isImporting = false;
        _selectedFilePath = null;
        _preview = null;
      });
      // Refresh state
      ref.invalidate(domainsProvider);
      ref.invalidate(allBlocksProvider);
    }
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: HermesTypography.bodySmall),
          Text(value, style: HermesTypography.body.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        title: Text('Exchange', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HermesSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Exchange .hermes', style: HermesTypography.screenTitle),
              const SizedBox(height: HermesSpacing.sm),
              Text(
                'Knowledge should be portable. Back up your journey, move between devices, or share complete learning environments.',
                style: HermesTypography.bodySmall,
              ),
              const SizedBox(height: HermesSpacing.xxl),
              
              HermesCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: HermesColors.evolutioGlow.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.upload_rounded, color: HermesColors.evolutioGlow),
                      ),
                      title: Text('Export Workspace', style: HermesTypography.body.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Create a portable .hermes package of this entire workspace.', style: HermesTypography.metadata),
                      trailing: _isExporting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.chevron_right, color: HermesColors.textTertiary),
                      onTap: _isExporting ? null : _handleExport,
                    ),
                    const Divider(color: HermesColors.border, height: HermesSpacing.xl),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: HermesColors.accent.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.download_rounded, color: HermesColors.accent),
                      ),
                      title: Text('Import Package', style: HermesTypography.body.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Import a .hermes file to merge or create a new workspace.', style: HermesTypography.metadata),
                      trailing: _isImporting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.chevron_right, color: HermesColors.textTertiary),
                      onTap: _isImporting ? null : _handleImportSelection,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
