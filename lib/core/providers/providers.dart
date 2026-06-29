import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engines/local_storage_engine.dart';
import '../models/models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// STATE MANAGEMENT
/// ─────────────────────────────────────────────────────────────────────────────
/// Wiring the UI to the offline-first JSON storage.
/// ─────────────────────────────────────────────────────────────────────────────

import '../engines/export_engine.dart';

final storageEngineProvider = Provider<LocalStorageEngine>((ref) {
  throw UnimplementedError('Storage engine not initialized');
});

final exportEngineProvider = Provider<ExportEngine>((ref) {
  return ExportEngine(ref.watch(storageEngineProvider));
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

// ── App State (UI) ───────────────────────────────────────────────────────────

class ArchivedSectionsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void archiveSection(String sectionId) {
    state = {...state, sectionId};
  }

  void restoreSection(String sectionId) {
    state = {...state}..remove(sectionId);
  }
}

final archivedSectionsProvider = NotifierProvider<ArchivedSectionsNotifier, Set<String>>(
  ArchivedSectionsNotifier.new,
);

