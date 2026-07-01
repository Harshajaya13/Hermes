import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../reader/hermes_reader_screen.dart';
import '../../main.dart';

class DeveloperScreen extends ConsumerWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(developerModeProvider)) {
      return const SizedBox.shrink(); // Failsafe if accessed without unlocking
    }

    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Developer Tools', style: HermesTypography.screenTitle.copyWith(color: HermesColors.error)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HermesSpacing.lg),
          children: [
            _buildSectionHeader('Environment & State', Icons.build_circle_rounded),
            _buildActionTile(
              context, 
              'Camouflage Mode', 
              ref.watch(camouflageModeProvider) ? 'Active. Screen UI obfuscated.' : 'Masks sensitive UI elements', 
              Icons.visibility_off_rounded, 
              () {
                ref.read(camouflageModeProvider.notifier).toggle();
              }
            ),
            _buildActionTile(context, 'Reload Hermes', 'Completely reload the UI and rebuild state', Icons.refresh_rounded, () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
            }),
            _buildActionTile(context, "Regenerate Today's Pursuit", 'Clear today\'s queue and run scheduler again', Icons.auto_awesome_rounded, () async {
              await ref.read(storageEngineProvider).regenerateTodayPursuit();
              if (context.mounted) {
                HermesToast.show(context, 'Success: Pursuit Regenerated.');
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
              }
            }),
            _buildActionTile(context, 'Advance One Day', 'Simulate tomorrow and generate new pursuit', Icons.skip_next_rounded, () async {
              await ref.read(storageEngineProvider).advanceOneDay();
              if (context.mounted) {
                HermesToast.show(context, 'Time advanced. Generating tomorrow\'s pursuit...');
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
              }
            }),
            if (ref.watch(storageEngineProvider).isPursuitReset)
              _buildActionTile(context, "Restore Today's Pursuit", 'Restore the queue that existed before reset', Icons.restore_rounded, () async {
                await ref.read(storageEngineProvider).restoreTodayPursuit();
                if (context.mounted) {
                  HermesToast.show(context, 'Success: Pursuit Restored.');
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
                }
              })
            else
              _buildActionTile(context, "Reset Today's Pursuit", 'Clear today\'s generated goals', Icons.clear_all_rounded, () async {
                await ref.read(storageEngineProvider).resetTodayPursuit();
                if (context.mounted) {
                  HermesToast.show(context, 'Pursuit Cleared. Queue is empty.');
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
                }
              }),
            _buildActionTile(context, 'Rebuild Search Index', 'Completely rebuild the FTS index in memory', Icons.search_rounded, () async {
              await ref.read(storageEngineProvider).rebuildSearchIndex();
              if (context.mounted) {
                HermesToast.show(context, 'Search indexing triggered in memory.');
              }
            }),
            
            const SizedBox(height: HermesSpacing.xl),
            _buildSectionHeader('Database Operations', Icons.storage_rounded),
            _buildActionTile(context, 'Database Statistics', 'Show size, row counts, fragmentation', Icons.analytics_rounded, () {
              final storage = ref.read(storageEngineProvider);
              final ws = ref.read(currentWorkspaceProvider);
              if (ws == null) return;
              final domains = storage.getDomains(ws.id);
              int bCount = 0; int iCount = 0;
              for (var d in domains) {
                final blocks = storage.getBlocks(d.id);
                bCount += blocks.length;
                for (var b in blocks) {
                  iCount += storage.getItems(b.id).length;
                }
              }
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('Database Statistics', style: HermesTypography.sectionTitle),
                  content: Text('Workspace: ${ws.name}\nDomains: ${domains.length}\nBlocks: $bCount\nItems: $iCount\nGlobal Evolutios: ${storage.getAllEvolutiosRaw().length}', style: HermesTypography.body),
                )
              );
            }),
            _buildActionTile(context, 'Database Export', 'Dump raw SQLite file to external storage', Icons.file_download_rounded, () async {
              try {
                final ws = ref.read(currentWorkspaceProvider);
                if (ws != null) {
                  final engine = ref.read(exportEngineProvider);
                  final path = await engine.exportWorkspace(ws.id);
                  HermesToast.show(context, 'Database Exported to: $path');
                }
              } catch (e) {
                HermesToast.show(context, 'Export Failed: $e', isError: true);
              }
            }),
            _buildActionTile(context, 'Database Import', 'Overwrite current database with external file', Icons.file_upload_rounded, () {
              HermesToast.show(context, 'Use the standard pipeline UI to import.');
            }),
            _buildActionTile(context, 'SQLite Vacuum', 'Rebuild database file and free space', Icons.cleaning_services_rounded, () async {
              await ref.read(storageEngineProvider).vacuum();
              if (context.mounted) HermesToast.show(context, 'Vacuum executed successfully.');
            }),
            
            const SizedBox(height: HermesSpacing.xl),
            _buildSectionHeader('Render Testing', Icons.design_services_rounded),
            _buildActionTile(context, 'Reader Test Page', 'Load standard reader UI harness', Icons.menu_book_rounded, () {
              _openReaderTest(context, 'Standard Test', 'This is a standard text test. Nothing fancy.');
            }),
            _buildActionTile(context, 'Markdown Test', 'Renders all edge-case Markdown elements', Icons.text_format_rounded, () {
              _openReaderTest(context, 'Markdown Stress Test', '# Header 1\n## Header 2\n\n**Bold**, *Italic*, `Code`\n\n> Blockquote\n\n- List 1\n- List 2\n\n```python\nprint("Hello")\n```');
            }),
            _buildActionTile(context, 'LaTeX Test', 'Renders complex MathJax/KaTeX formulas', Icons.functions_rounded, () {
              _openReaderTest(context, 'LaTeX Test', 'Here is an inline equation: <math>E = mc^2</math>\n\nAnd a block equation:\n<math>\\int_0^\\infty e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}</math>');
            }),
            _buildActionTile(context, 'Large Article Test', 'Loads a 50,000 word dummy article to test FPS', Icons.speed_rounded, () {
              _openReaderTest(context, 'Large Article Test', List.generate(500, (i) => 'This is a massive paragraph block to test the scroll performance of the markdown renderer. $i').join('\n\n'));
            }),
            
            const SizedBox(height: HermesSpacing.xl),
            _buildSectionHeader('System Information', Icons.info_outline_rounded),
            _buildActionTile(context, 'Feature Flags / Experimental Features', 'Toggle WIP features', Icons.flag_rounded, () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('Feature Flags', style: HermesTypography.sectionTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: Text('Sync to Cloud (WIP)', style: HermesTypography.body),
                        value: false,
                        onChanged: (v) => HermesToast.show(context, 'Feature not implemented yet.'),
                        activeColor: HermesColors.evolutioGlow,
                      ),
                      SwitchListTile(
                        title: Text('AI Tagging (WIP)', style: HermesTypography.body),
                        value: false,
                        onChanged: (v) => HermesToast.show(context, 'Feature not implemented yet.'),
                        activeColor: HermesColors.evolutioGlow,
                      ),
                    ],
                  ),
                )
              );
            }),
            _buildActionTile(context, 'Debug Information', 'Show IDs, render times, diagnostics', Icons.bug_report_rounded, () {
              final ws = ref.read(currentWorkspaceProvider);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('Debug Information', style: HermesTypography.sectionTitle),
                  content: Text(
                    'Workspace ID:\n${ws?.id ?? 'NULL'}\n\n'
                    'Screen Size:\n${MediaQuery.of(context).size.width.toStringAsFixed(0)}x${MediaQuery.of(context).size.height.toStringAsFixed(0)}\n\n'
                    'Platform: Flutter Desktop (Linux)',
                    style: HermesTypography.bodySmall,
                  ),
                )
              );
            }),
            
            const SizedBox(height: HermesSpacing.xl),
            _buildSectionHeader('Danger Zone', Icons.warning_rounded, color: Colors.redAccent),
            _buildActionTile(context, 'Generate Dummy Workspace', 'Creates a fake demo workspace only', Icons.add_to_photos_rounded, () async {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('Generate Dummy Workspace', style: HermesTypography.sectionTitle),
                  content: Text('This will create a completely separate demo workspace labeled "Dummy Workspace" and switch you into it. Your real workspace will NOT be touched.', style: HermesTypography.body),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: HermesColors.evolutioGlow, foregroundColor: Colors.white),
                      child: const Text('Confirm'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final storage = ref.read(storageEngineProvider);
                        final dummyWs = Workspace(id: 'dummy_workspace', name: 'Dummy Workspace', isDefault: false, icon: '🤖');
                        await storage.saveWorkspace(dummyWs);
                        final d = Domain(workspaceId: dummyWs.id, name: 'Dummy Domain', icon: '🤖');
                        await storage.saveDomain(d);
                        final b = Block(domainId: d.id, name: 'Dummy Block', icon: '🧱');
                        await storage.saveBlock(b);
                        final i = Item(id: 'dummy_item', blockId: b.id, sourceId: 'system', type: ItemType.article, title: 'Dummy Article', content: 'This is a test article.', createdAt: DateTime.now());
                        await storage.saveItem(i);
                        
                        ref.read(currentWorkspaceProvider.notifier).updateWorkspace(dummyWs);
                        ref.invalidate(domainsProvider);
                        ref.invalidate(allBlocksProvider);
                        if (context.mounted) {
                          HermesToast.show(context, 'Success: Demo Workspace Generated.');
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
                        }
                      },
                    ),
                  ],
                ),
              );
            }, isDanger: true),
            _buildActionTile(context, 'Remove Dummy Workspace', 'Delete only the dummy workspace', Icons.delete_outline_rounded, () async {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('Remove Dummy Workspace', style: HermesTypography.sectionTitle.copyWith(color: Colors.redAccent)),
                  content: Text('This will delete ONLY the "Dummy Workspace" and its contents. It will then switch back to your real workspace. Your personal data will NOT be deleted.', style: HermesTypography.body),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      child: const Text('Confirm'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final storage = ref.read(storageEngineProvider);
                        await storage.deleteWorkspace('dummy_workspace');
                        
                        ref.invalidate(currentWorkspaceProvider);
                        ref.invalidate(domainsProvider);
                        ref.invalidate(allBlocksProvider);
                        if (context.mounted) {
                          HermesToast.show(context, 'Success: Demo Workspace Cleared.');
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
                        }
                      },
                    ),
                  ],
                ),
              );
            }, isDanger: true),
            _buildActionTile(context, 'Recreate Starter Workspace', 'Create a brand new Starter Workspace', Icons.auto_awesome_rounded, () async {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('Recreate Starter Workspace', style: HermesTypography.sectionTitle),
                  content: Text('This will create a brand new Starter Workspace only if it does not already exist. It will NEVER modify your existing workspaces.', style: HermesTypography.body),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: HermesColors.evolutioGlow, foregroundColor: Colors.white),
                      child: const Text('Confirm'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final storage = ref.read(storageEngineProvider);
                        final existing = storage.workspaces.where((w) => w.name == 'Starter').firstOrNull;
                        if (existing == null) {
                          final ws = Workspace(name: 'Starter', isDefault: true, icon: '⭐');
                          await storage.saveWorkspace(ws);
                          await storage.seedStarterWorkspace(ws);
                          ref.invalidate(currentWorkspaceProvider);
                          ref.invalidate(domainsProvider);
                          if (context.mounted) {
                            HermesToast.show(context, 'Success: Starter Workspace Regenerated.');
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
                          }
                        } else {
                          if (context.mounted) HermesToast.show(context, 'Starter workspace already exists.');
                        }
                      },
                    ),
                  ],
                ),
              );
            }, isDanger: true),
            _buildActionTile(context, 'Reset Current Workspace', 'Delete everything in the currently selected workspace', Icons.delete_forever_rounded, () async {
              final ws = ref.read(currentWorkspaceProvider);
              if (ws == null) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('Reset Workspace: ${ws.name}', style: HermesTypography.sectionTitle.copyWith(color: Colors.redAccent)),
                  content: Text('This will delete all Domains, Blocks, and Items inside ONLY the "${ws.name}" workspace. It will leave the workspace completely empty. This cannot be undone.', style: HermesTypography.body),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      child: const Text('Confirm'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref.read(storageEngineProvider).resetWorkspace(ws.id);
                        ref.invalidate(currentWorkspaceProvider);
                        ref.invalidate(domainsProvider);
                        if (context.mounted) {
                          HermesToast.show(context, 'Success: Current Workspace Emptied.');
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
                        }
                      },
                    ),
                  ],
                ),
              );
            }, isDanger: true),
            _buildActionTile(context, 'Factory Reset Hermes', 'Restart Hermes into a true first-install state', Icons.local_fire_department_rounded, () async {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('FACTORY RESET', style: HermesTypography.sectionTitle.copyWith(color: Colors.redAccent)),
                  content: Text('This will delete EVERY workspace, EVERY database, and EVERY preference. Hermes will restart into a true first-install state and automatically create a fresh Starter Workspace. You CANNOT undo this.', style: HermesTypography.body),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref.read(storageEngineProvider).factoryReset();
                        ref.invalidate(currentWorkspaceProvider);
                        ref.invalidate(domainsProvider);
                        ref.invalidate(allBlocksProvider);
                        if (context.mounted) {
                          HermesToast.show(context, 'Success: System Factory Reset.');
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HermesShell()), (route) => false);
                        }
                      },
                      child: const Text('NUKE EVERYTHING'),
                    ),
                  ],
                )
              );
            }, isDanger: true),
            
            const SizedBox(height: 100), // padding
          ],
        ),
      ),
    );
  }

  void _openReaderTest(BuildContext context, String title, String content) {
    final item = Item(
      id: 'test_dev',
      blockId: 'test_block',
      sourceId: 'dev',
      type: ItemType.article,
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    final block = Block(id: 'test_block', domainId: 'dev', name: 'Test Tools', icon: '🛠️', createdAt: DateTime.now());
    Navigator.push(context, MaterialPageRoute(builder: (_) => HermesReaderScreen(item: item, block: block)));
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color color = HermesColors.textPrimary}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HermesSpacing.md, top: HermesSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: HermesSpacing.sm),
          Text(title, style: HermesTypography.sectionTitle.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback? onTap, {bool isDanger = false}) {
    final color = isDanger ? Colors.redAccent : HermesColors.textPrimary;
    final bgColor = isDanger ? Colors.redAccent.withValues(alpha: 0.05) : HermesColors.surfaceElevated;
    
    return Container(
      margin: const EdgeInsets.only(bottom: HermesSpacing.sm),
      child: InkWell(
        onTap: onTap != null ? () {
          HermesToast.show(context, 'Developer tool invoked: $title');
          onTap();
        } : () {
          HermesToast.show(context, '$title - Not Implemented Yet');
        },
        borderRadius: BorderRadius.circular(HermesRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.md, vertical: HermesSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(HermesRadius.md),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: HermesSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: HermesTypography.body.copyWith(color: color)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: HermesTypography.metadata),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: HermesColors.textTertiary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
