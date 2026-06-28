import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engines/local_storage_engine.dart';
import '../models/models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// STATE MANAGEMENT
/// ─────────────────────────────────────────────────────────────────────────────
/// Wiring the UI to the offline-first JSON storage.
/// ─────────────────────────────────────────────────────────────────────────────

final storageEngineProvider = Provider<LocalStorageEngine>((ref) {
  throw UnimplementedError('Storage engine not initialized');
});

// ── Active Workspace ─────────────────────────────────────────────────────────

class CurrentWorkspaceNotifier extends Notifier<Workspace?> {
  @override
  Workspace? build() {
    final storage = ref.watch(storageEngineProvider);
    final workspaces = storage.workspaces;
    return workspaces.isNotEmpty ? workspaces.first : null;
  }
}

final currentWorkspaceProvider = NotifierProvider<CurrentWorkspaceNotifier, Workspace?>(
  CurrentWorkspaceNotifier.new,
);

// ── Domains & Blocks ─────────────────────────────────────────────────────────

final domainsProvider = Provider<List<Domain>>((ref) {
  final storage = ref.watch(storageEngineProvider);
  final workspace = ref.watch(currentWorkspaceProvider);
  if (workspace == null) return [];
  return storage.getDomains(workspace.id);
});

final allBlocksProvider = Provider<List<Block>>((ref) {
  final storage = ref.watch(storageEngineProvider);
  return storage.getAllBlocks();
});

final blocksByDomainProvider = Provider.family<List<Block>, String>((ref, domainId) {
  final storage = ref.watch(storageEngineProvider);
  return storage.getBlocks(domainId);
});

// ── Items ────────────────────────────────────────────────────────────────────

final itemsByBlockProvider = Provider.family<List<Item>, String>((ref, blockId) {
  final storage = ref.watch(storageEngineProvider);
  return storage.getItems(blockId);
});

// ── Evolutios ────────────────────────────────────────────────────────────────

final allEvolutiosProvider = Provider<List<Evolutio>>((ref) {
  final storage = ref.watch(storageEngineProvider);
  return storage.getEvolutios();
});

final recentEvolutiosProvider = Provider<List<Evolutio>>((ref) {
  final evolutios = ref.watch(allEvolutiosProvider);
  return evolutios.take(5).toList();
});

// ── App Initialization ───────────────────────────────────────────────────────

final appInitializationProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(storageEngineProvider);
  await storage.initialize();
  // We can seed initial data here if empty
  if (storage.workspaces.isNotEmpty && storage.getDomains(storage.workspaces.first.id).isEmpty) {
    final workspace = storage.workspaces.first;
    
    // Seed Engineering Domain
    final engDomain = Domain(workspaceId: workspace.id, name: 'Engineering', sortOrder: 0);
    await storage.saveDomain(engDomain);
    
    // Seed Blocks
    final mathBlock = Block(domainId: engDomain.id, name: 'Mathematics', icon: '📘', colorHex: '#7C9EBC');
    final aiBlock = Block(domainId: engDomain.id, name: 'AI', icon: '🤖', colorHex: '#A08EB4');
    await storage.saveBlock(mathBlock);
    await storage.saveBlock(aiBlock);
    
    // Seed Item
    final qItem = Item(
      blockId: mathBlock.id, 
      type: ItemType.question, 
      title: 'A fair coin is flipped 3 times. What is the expected number of heads?', 
      content: 'Expected Value formula...'
    );
    await storage.saveItem(qItem);
  }
});
