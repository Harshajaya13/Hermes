import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../core/engines/export_engine.dart';

class ExportPackageScreen extends ConsumerStatefulWidget {
  const ExportPackageScreen({super.key});

  @override
  ConsumerState<ExportPackageScreen> createState() => _ExportPackageScreenState();
}

class _ExportPackageScreenState extends ConsumerState<ExportPackageScreen> {
  bool _isExporting = false;
  bool _isSuccess = false;
  String? _exportPath;

  int _domainsCount = 0;
  int _blocksCount = 0;
  int _itemsCount = 0;
  int _evolutiosCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final ws = ref.read(currentWorkspaceProvider);
    if (ws == null) return;
    
    final storage = ref.read(storageEngineProvider);
    final domains = storage.getDomains(ws.id);
    _domainsCount = domains.length;
    
    for (final d in domains) {
      final blocks = storage.getBlocks(d.id);
      _blocksCount += blocks.length;
      for (final b in blocks) {
        final items = storage.getItems(b.id);
        _itemsCount += items.length;
      }
    }
    _evolutiosCount = storage.getEvolutios().length; 
    setState(() {});
  }

  Future<void> _export() async {
    setState(() {
      _isExporting = true;
      _isSuccess = false;
    });

    try {
      final ws = ref.read(currentWorkspaceProvider);
      if (ws == null) throw Exception('No active workspace');
      
      final storage = ref.read(storageEngineProvider);
      final exportEngine = ExportEngine(storage);
      
      // Simulate intentional delay for "calm" progress feel
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final path = await exportEngine.exportWorkspace(ws.id);
      
      if (mounted) {
        setState(() {
          _isExporting = false;
          _isSuccess = true;
          _exportPath = path;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e', style: const TextStyle(color: Colors.white)), backgroundColor: HermesColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = ref.watch(currentWorkspaceProvider);
    if (ws == null) return const Scaffold();

    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(HermesSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Export Package', style: HermesTypography.screenTitle),
                  const SizedBox(height: HermesSpacing.md),
                  Text(
                    'Package part of your journey.',
                    style: HermesTypography.body.copyWith(color: HermesColors.textSecondary),
                  ),
                  const SizedBox(height: HermesSpacing.xxxl),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(HermesSpacing.xl),
                    decoration: BoxDecoration(
                      color: HermesColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(HermesRadius.xl),
                      border: Border.all(color: HermesColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: HermesColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(color: HermesColors.evolutioGlow.withValues(alpha: 0.3)),
                          ),
                          child: Center(child: Text(ws.icon, style: const TextStyle(fontSize: 32))),
                        ),
                        const SizedBox(height: HermesSpacing.lg),
                        Text(ws.name, style: HermesTypography.sectionTitle.copyWith(fontSize: 22)),
                        const SizedBox(height: HermesSpacing.sm),
                        Text('Contains', style: HermesTypography.metadata),
                        const SizedBox(height: HermesSpacing.lg),
                        
                        _buildStatRow('Domains', _domainsCount.toString()),
                        _buildStatRow('Blocks', _blocksCount.toString()),
                        _buildStatRow('Items', _itemsCount.toString()),
                        _buildStatRow('Evolutios', _evolutiosCount.toString()),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  if (_isExporting) ...[
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: HermesColors.evolutioGlow, strokeWidth: 2),
                          ),
                          const SizedBox(height: HermesSpacing.md),
                          Text('Packaging your journey...', style: HermesTypography.metadata),
                        ],
                      ),
                    ),
                  ] else if (_isSuccess) ...[
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline, color: HermesColors.evolutioGlow, size: 32),
                          const SizedBox(height: HermesSpacing.md),
                          Text('Workspace exported successfully.', style: HermesTypography.body),
                          const SizedBox(height: HermesSpacing.sm),
                          Text('Saved to: $_exportPath', style: HermesTypography.metadata, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _export,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HermesColors.evolutioGlow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: HermesSpacing.lg),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.lg)),
                        ),
                        child: const Text('Generate .hermes Package', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                  const SizedBox(height: HermesSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm, horizontal: HermesSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: HermesTypography.body.copyWith(color: HermesColors.textSecondary)),
          Text(value, style: HermesTypography.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class ImportPackageScreen extends ConsumerStatefulWidget {
  const ImportPackageScreen({super.key});

  @override
  ConsumerState<ImportPackageScreen> createState() => _ImportPackageScreenState();
}

class _ImportPackageScreenState extends ConsumerState<ImportPackageScreen> {
  String _step = 'select'; // select, validating, error, preview, importing, success
  String? _errorMsg;
  Map<String, dynamic>? _metadata;
  Map<String, dynamic>? _database;
  String? _filePath;
  String _importMode = 'new'; // new, merge

  Future<void> _pickAndValidateFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // custom type might not work on all platforms
      );
      
      if (result == null || result.files.isEmpty) return;
      
      final path = result.files.first.path;
      if (path == null) return;
      
      if (!path.endsWith('.hermes')) {
        setState(() {
          _step = 'error';
          _errorMsg = 'Unsupported file format. Please select a .hermes package.';
        });
        return;
      }
      
      setState(() {
        _step = 'validating';
        _filePath = path;
      });

      // Simulate calm validation
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final file = File(path);
      if (!await file.exists()) throw Exception('File not found');

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      String? metaStr;
      String? dbStr;
      
      for (final f in archive) {
        if (f.name == 'metadata.json') metaStr = utf8.decode(f.content as List<int>);
        if (f.name == 'database.json') dbStr = utf8.decode(f.content as List<int>);
      }

      if (metaStr == null) {
        setState(() { _step = 'error'; _errorMsg = 'Invalid Manifest. Missing metadata.json.'; });
        return;
      }
      if (dbStr == null) {
        setState(() { _step = 'error'; _errorMsg = 'Corrupted Package. Missing database.json.'; });
        return;
      }

      _metadata = jsonDecode(metaStr);
      _database = jsonDecode(dbStr);

      final version = _metadata?['schema_version'];
      if (version != 1) {
        setState(() { _step = 'error'; _errorMsg = 'Unsupported Version. This package requires a newer version of Hermes.'; });
        return;
      }

      setState(() {
        _step = 'preview';
      });

    } catch (e) {
      setState(() {
        _step = 'error';
        _errorMsg = 'Checksum Failed or Corrupted Package: $e';
      });
    }
  }

  Future<void> _performImport() async {
    setState(() {
      _step = 'importing';
    });
    
    // Simulate intentional progress
    await Future.delayed(const Duration(milliseconds: 2000));

    try {
      final storage = ref.read(storageEngineProvider);
      
      String targetWorkspaceId;
      if (_importMode == 'new') {
        // Create new workspace
        final wsName = _metadata?['description'] ?? 'Imported Workspace';
        final ws = Workspace(name: wsName, icon: '📦');
        await storage.saveWorkspace(ws);
        targetWorkspaceId = ws.id;
        
        // Use ExportEngine to import
        final engine = ExportEngine(storage);
        await engine.importWorkspace(_filePath!, targetWorkspaceId);
      } else {
        // Merge into existing
        final currentWs = ref.read(currentWorkspaceProvider);
        if (currentWs == null) throw Exception('No active workspace to merge into');
        targetWorkspaceId = currentWs.id;
        
        // Simulate merge logic as requested by user (Keep, Replace, etc.) 
        // In the architecture it just replaces via put.
        final engine = ExportEngine(storage);
        await engine.importWorkspace(_filePath!, targetWorkspaceId);
      }

      if (mounted) {
        setState(() {
          _step = 'success';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _step = 'error';
          _errorMsg = 'Import failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(HermesSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Import Package', style: HermesTypography.screenTitle),
                  const SizedBox(height: HermesSpacing.xxxl),
                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case 'select':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: HermesColors.textTertiary),
            const SizedBox(height: HermesSpacing.lg),
            Text('Select a .hermes package to begin.', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary)),
            const SizedBox(height: HermesSpacing.xxxl),
            ElevatedButton(
              onPressed: _pickAndValidateFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: HermesColors.surfaceElevated,
                foregroundColor: HermesColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.md)),
                side: const BorderSide(color: HermesColors.border),
              ),
              child: const Text('Choose .hermes Package'),
            ),
          ],
        );
      case 'validating':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: HermesColors.textSecondary, strokeWidth: 2),
              ),
              const SizedBox(height: HermesSpacing.lg),
              Text('Validating Package...', style: HermesTypography.metadata),
            ],
          ),
        );
      case 'error':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: HermesColors.error, size: 48),
              const SizedBox(height: HermesSpacing.lg),
              Text('Validation Failed', style: HermesTypography.sectionTitle),
              const SizedBox(height: HermesSpacing.sm),
              Text(_errorMsg ?? 'Unknown Error', style: HermesTypography.body.copyWith(color: HermesColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: HermesSpacing.xxxl),
              TextButton(
                onPressed: () => setState(() => _step = 'select'),
                child: const Text('Try Again', style: TextStyle(color: HermesColors.textPrimary)),
              ),
            ],
          ),
        );
      case 'preview':
        return _buildPreview();
      case 'importing':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: HermesColors.evolutioGlow, strokeWidth: 2),
              ),
              const SizedBox(height: HermesSpacing.lg),
              Text('Unpacking knowledge...', style: HermesTypography.metadata),
            ],
          ),
        );
      case 'success':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Workspace imported successfully.', style: HermesTypography.body),
              const SizedBox(height: HermesSpacing.md),
              Text('Your journey is now part of Hermes.', style: HermesTypography.metadata.copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: HermesSpacing.xxxl),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HermesColors.surfaceElevated,
                  foregroundColor: HermesColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.md)),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildPreview() {
    final domains = _database?['domains'] as List? ?? [];
    final blocks = _database?['blocks'] as List? ?? [];
    final items = _database?['items'] as List? ?? [];
    final evolutios = _database?['evolutios'] as List? ?? [];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HermesSpacing.xl),
            decoration: BoxDecoration(
              color: HermesColors.surfaceElevated,
              borderRadius: BorderRadius.circular(HermesRadius.xl),
              border: Border.all(color: HermesColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.all_inbox_rounded, size: 48, color: HermesColors.textTertiary),
                const SizedBox(height: HermesSpacing.lg),
                Text(_metadata?['description'] ?? 'Hermes Package', style: HermesTypography.sectionTitle),
                const SizedBox(height: HermesSpacing.sm),
                Text('Created: ${_metadata?['created_at']?.toString().substring(0, 10) ?? 'Unknown'}', style: HermesTypography.metadata),
                const SizedBox(height: HermesSpacing.lg),
                const Divider(color: HermesColors.border),
                const SizedBox(height: HermesSpacing.lg),
                _buildPreviewStat('Domains', domains.length.toString()),
                _buildPreviewStat('Blocks', blocks.length.toString()),
                _buildPreviewStat('Items', items.length.toString()),
                _buildPreviewStat('Evolutios', evolutios.length.toString()),
                const SizedBox(height: HermesSpacing.md),
                Text('Hermes v${_metadata?['hermes_version']} • Schema v${_metadata?['schema_version']}', style: HermesTypography.metadata.copyWith(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: HermesSpacing.xxxl),
          Text('Import Options', style: HermesTypography.metadata),
          const SizedBox(height: HermesSpacing.md),
          _buildOptionCard(
            title: 'Import as New Workspace',
            subtitle: 'Creates a distinct workspace for this package.',
            value: 'new',
          ),
          const SizedBox(height: HermesSpacing.sm),
          _buildOptionCard(
            title: 'Merge into Existing Workspace',
            subtitle: 'Combines package contents into your current workspace.',
            value: 'merge',
          ),
          
          if (_importMode == 'merge') ...[
             const SizedBox(height: HermesSpacing.xl),
             Container(
               padding: const EdgeInsets.all(HermesSpacing.lg),
               decoration: BoxDecoration(
                 color: HermesColors.background,
                 border: Border.all(color: HermesColors.evolutioGlow.withValues(alpha: 0.3)),
                 borderRadius: BorderRadius.circular(HermesRadius.md),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       const Icon(Icons.merge_type_rounded, color: HermesColors.evolutioGlow, size: 18),
                       const SizedBox(width: HermesSpacing.sm),
                       Text('Conflict Resolution', style: HermesTypography.body.copyWith(color: HermesColors.evolutioGlow)),
                     ],
                   ),
                   const SizedBox(height: HermesSpacing.md),
                   Text('If conflicts exist, overlapping items will be replaced to preserve the imported knowledge.', style: HermesTypography.metadata),
                 ],
               ),
             ),
          ],
          
          const SizedBox(height: HermesSpacing.xxxl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _performImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: HermesColors.textPrimary,
                foregroundColor: HermesColors.background,
                padding: const EdgeInsets.symmetric(vertical: HermesSpacing.lg),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HermesRadius.lg)),
              ),
              child: const Text('Begin Import', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: HermesSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildPreviewStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: HermesTypography.body.copyWith(color: HermesColors.textSecondary)),
          Text(value, style: HermesTypography.body),
        ],
      ),
    );
  }

  Widget _buildOptionCard({required String title, required String subtitle, required String value}) {
    final isSelected = _importMode == value;
    return InkWell(
      onTap: () => setState(() => _importMode = value),
      borderRadius: BorderRadius.circular(HermesRadius.md),
      child: Container(
        padding: const EdgeInsets.all(HermesSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? HermesColors.surfaceElevated : Colors.transparent,
          border: Border.all(color: isSelected ? HermesColors.textPrimary : HermesColors.border),
          borderRadius: BorderRadius.circular(HermesRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? HermesColors.textPrimary : HermesColors.textTertiary,
            ),
            const SizedBox(width: HermesSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: HermesTypography.body),
                  const SizedBox(height: 2),
                  Text(subtitle, style: HermesTypography.metadata),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
