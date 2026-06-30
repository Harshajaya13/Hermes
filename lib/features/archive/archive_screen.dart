import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../today/workspace_security_dialogs.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _invalidateAll() {
    ref.invalidate(domainsProvider);
    ref.invalidate(allBlocksProvider);
    ref.invalidate(itemsByBlockProvider);
    ref.invalidate(allEvolutiosProvider);
    ref.invalidate(recentEvolutiosProvider);
    if (mounted) setState(() {});
  }

  void _confirmEmptyArchive() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesColors.surfaceElevated,
        title: Text('Empty Archive?', style: HermesTypography.screenTitle),
        content: Text(
          'This will permanently delete all archived objects. This action is irreversible.',
          style: HermesTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: HermesTypography.button.copyWith(color: HermesColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HermesColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              
              final workspace = ref.read(currentWorkspaceProvider);
              if (workspace?.isEncrypted == true) {
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => VerifyPinDialog(
                    onSuccess: () async {
                      await ref.read(storageEngineProvider).emptyArchive();
                      _invalidateAll();
                    },
                  ),
                );
              } else {
                await ref.read(storageEngineProvider).emptyArchive();
                _invalidateAll();
              }
            },
            child: const Text('Empty Archive'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String objectType, Function() onDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HermesColors.surfaceElevated,
        title: Text('Delete $objectType?', style: HermesTypography.screenTitle),
        content: Text(
          'This will permanently delete this $objectType. This action is irreversible.',
          style: HermesTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: HermesTypography.button.copyWith(color: HermesColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HermesColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final workspace = ref.read(currentWorkspaceProvider);
              if (workspace?.isEncrypted == true) {
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => VerifyPinDialog(onSuccess: onDelete),
                );
              } else {
                onDelete();
              }
            },
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _buildMenu(BuildContext context, String objectType, Function() onRestore, Function() onDelete) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HermesSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Archived $objectType Options', style: HermesTypography.sectionTitle),
              const SizedBox(height: HermesSpacing.md),
              ListTile(
                leading: const Icon(Icons.restore, color: HermesColors.textPrimary),
                title: Text('Restore', style: HermesTypography.body),
                onTap: () {
                  Navigator.pop(ctx);
                  onRestore();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: HermesColors.error),
                title: Text('Permanently Delete', style: HermesTypography.body.copyWith(color: HermesColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, objectType, onDelete);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageEngineProvider);
    
    var archivedDomains = storage.getAllDomainsRaw().where((d) => d.deleted).toList();
    var archivedBlocks = storage.getAllBlocksRaw().where((b) => b.deleted).toList();
    var archivedItems = storage.getAllItemsRaw().where((i) => i.deleted).toList();
    var archivedEvolutios = storage.getAllEvolutiosRaw().where((e) => e.deleted).toList();
    var archivedVeritas = storage.getAllVeritasRaw().where((v) => v.deleted).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      archivedDomains = archivedDomains.where((d) => d.name.toLowerCase().contains(q)).toList();
      archivedBlocks = archivedBlocks.where((b) => b.name.toLowerCase().contains(q)).toList();
      archivedItems = archivedItems.where((i) => i.title.toLowerCase().contains(q) || i.content.toLowerCase().contains(q)).toList();
      archivedEvolutios = archivedEvolutios.where((e) => e.content.toLowerCase().contains(q)).toList();
      archivedVeritas = archivedVeritas.where((v) => v.reason.toLowerCase().contains(q)).toList();
    }

    final bool isEmpty = archivedDomains.isEmpty &&
        archivedBlocks.isEmpty &&
        archivedItems.isEmpty &&
        archivedEvolutios.isEmpty &&
        archivedVeritas.isEmpty;

    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Archive', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(HermesSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: HermesTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Search archive...',
                      hintStyle: HermesTypography.metadata,
                      prefixIcon: const Icon(Icons.search, color: HermesColors.textTertiary),
                      filled: true,
                      fillColor: HermesColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(HermesRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: isEmpty ? null : () async {
                    await storage.restoreAll();
                    _invalidateAll();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All objects restored.')));
                  },
                  icon: const Icon(Icons.restore_page, size: 18),
                  label: const Text('Restore All'),
                  style: TextButton.styleFrom(foregroundColor: HermesColors.evolutioGlow),
                ),
                TextButton.icon(
                  onPressed: isEmpty ? null : _confirmEmptyArchive,
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Empty Archive'),
                  style: TextButton.styleFrom(foregroundColor: HermesColors.error),
                ),
              ],
            ),
          ),
          const SizedBox(height: HermesSpacing.md),
          Expanded(
            child: isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'The Archive is empty.' : 'No matches found.',
                      style: HermesTypography.metadata,
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      if (archivedDomains.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(HermesSpacing.lg),
                            child: HermesSectionHeader(title: 'Domains'),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final domain = archivedDomains[index];
                              return ListTile(
                                leading: Container(width: 10, height: 10, decoration: const BoxDecoration(color: HermesColors.textTertiary, shape: BoxShape.circle)),
                                title: Text(domain.name, style: HermesTypography.body),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert, color: HermesColors.textTertiary),
                                  onPressed: () => _buildMenu(
                                    context,
                                    'Domain',
                                    () async {
                                      await storage.restoreDomain(domain.id);
                                      _invalidateAll();
                                    },
                                    () async {
                                      await storage.permanentlyDeleteDomain(domain.id);
                                      _invalidateAll();
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount: archivedDomains.length,
                          ),
                        ),
                      ],
                      if (archivedBlocks.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(HermesSpacing.lg),
                            child: HermesSectionHeader(title: 'Blocks'),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final block = archivedBlocks[index];
                              return ListTile(
                                leading: Text(block.icon, style: const TextStyle(fontSize: 20)),
                                title: Text(block.name, style: HermesTypography.body),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert, color: HermesColors.textTertiary),
                                  onPressed: () => _buildMenu(
                                    context,
                                    'Block',
                                    () async {
                                      await storage.restoreBlock(block.id);
                                      _invalidateAll();
                                    },
                                    () async {
                                      await storage.permanentlyDeleteBlock(block.id);
                                      _invalidateAll();
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount: archivedBlocks.length,
                          ),
                        ),
                      ],
                      if (archivedItems.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(HermesSpacing.lg),
                            child: HermesSectionHeader(title: 'Items'),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = archivedItems[index];
                              return ListTile(
                                leading: const Icon(Icons.article, color: HermesColors.textTertiary),
                                title: Text(item.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: HermesTypography.body),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert, color: HermesColors.textTertiary),
                                  onPressed: () => _buildMenu(
                                    context,
                                    'Item',
                                    () async {
                                      await storage.restoreItem(item.id);
                                      _invalidateAll();
                                    },
                                    () async {
                                      await storage.permanentlyDeleteItem(item.id);
                                      _invalidateAll();
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount: archivedItems.length,
                          ),
                        ),
                      ],
                      if (archivedEvolutios.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(HermesSpacing.lg),
                            child: HermesSectionHeader(title: 'Evolutios'),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final evo = archivedEvolutios[index];
                              return ListTile(
                                leading: const Icon(Icons.auto_awesome, color: HermesColors.textTertiary),
                                title: Text(evo.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: HermesTypography.body),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert, color: HermesColors.textTertiary),
                                  onPressed: () => _buildMenu(
                                    context,
                                    'Evolutio',
                                    () async {
                                      await storage.restoreEvolutio(evo.id);
                                      _invalidateAll();
                                    },
                                    () async {
                                      await storage.permanentlyDeleteEvolutio(evo.id);
                                      _invalidateAll();
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount: archivedEvolutios.length,
                          ),
                        ),
                      ],
                      if (archivedVeritas.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(HermesSpacing.lg),
                            child: HermesSectionHeader(title: 'Veritas'),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final veritas = archivedVeritas[index];
                              return ListTile(
                                leading: const Icon(Icons.edit_note_rounded, color: HermesColors.textTertiary),
                                title: Text(veritas.reason, maxLines: 1, overflow: TextOverflow.ellipsis, style: HermesTypography.body),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert, color: HermesColors.textTertiary),
                                  onPressed: () => _buildMenu(
                                    context,
                                    'Veritas',
                                    () async {
                                      await storage.restoreVeritas(veritas.id);
                                      _invalidateAll();
                                    },
                                    () async {
                                      await storage.permanentlyDeleteVeritas(veritas.id);
                                      _invalidateAll();
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount: archivedVeritas.length,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
