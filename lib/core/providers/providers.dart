import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engines/local_storage_engine.dart';
import '../models/models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// STATE MANAGEMENT
/// ─────────────────────────────────────────────────────────────────────────────
/// Wiring the UI to the offline-first JSON storage.
/// ─────────────────────────────────────────────────────────────────────────────

import '../engines/exchange_engine.dart';
import '../engines/export_engine.dart';
final storageEngineProvider = Provider<LocalStorageEngine>((ref) {
  throw UnimplementedError('Storage engine not initialized');
});

final exchangeEngineProvider = Provider<ExchangeEngine>((ref) {
  return ExchangeEngine(ref.watch(storageEngineProvider));
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
    return workspaces.where((w) => w.isDefault).firstOrNull ?? (workspaces.isNotEmpty ? workspaces.first : null);
  }

  void updateWorkspace(Workspace? ws) {
    state = ws;
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
  final domains = ref.watch(domainsProvider);
  final domainIds = domains.map((d) => d.id).toSet();
  return storage.getAllBlocks().where((b) => domainIds.contains(b.domainId)).toList();
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

final sourcesProvider = Provider<List<KnowledgeSource>>((ref) {
  final storage = ref.watch(storageEngineProvider);
  final currentWorkspace = ref.watch(currentWorkspaceProvider);
  if (currentWorkspace == null) return [];
  return storage.getSources(currentWorkspace.id);
});

// ── Evolutios ────────────────────────────────────────────────────────────────

final allEvolutiosProvider = Provider<List<Evolutio>>((ref) {
  final storage = ref.watch(storageEngineProvider);
  final allBlocks = ref.watch(allBlocksProvider);
  final blockIds = allBlocks.map((b) => b.id).toSet();
  return storage.getEvolutios().where((e) => blockIds.contains(e.blockId)).toList();
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

class TodaySectionFormatNotifier extends Notifier<String> {
  @override
  String build() => 'question'; // 'question' or 'article'

  void setFormat(String format) {
    state = format;
  }
}

final todaySectionFormatProvider = NotifierProvider<TodaySectionFormatNotifier, String>(
  TodaySectionFormatNotifier.new,
);

// ── Appearance ───────────────────────────────────────────────────────────────

class AppearanceNotifier extends Notifier<AppearanceSettings> {
  @override
  AppearanceSettings build() {
    return ref.watch(storageEngineProvider).appearance;
  }

  Future<void> updateAppearance(AppearanceSettings settings) async {
    state = settings;
    await ref.read(storageEngineProvider).saveAppearance(settings);
  }
}

final appearanceProvider = NotifierProvider<AppearanceNotifier, AppearanceSettings>(
  AppearanceNotifier.new,
);

class WorkspaceLockedNotifier extends Notifier<bool> {
  @override
  bool build() {
    final ws = ref.watch(currentWorkspaceProvider);
    return ws?.isEncrypted ?? false;
  }

  void setLocked(bool locked) {
    state = locked;
  }
}

final workspaceLockedProvider = NotifierProvider<WorkspaceLockedNotifier, bool>(
  WorkspaceLockedNotifier.new,
);
