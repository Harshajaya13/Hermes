import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// LOCAL STORAGE ENGINE
/// ─────────────────────────────────────────────────────────────────────────────
/// Purpose: Offline-first persistence via pure JSON.
/// Codex: "Everything becomes JSON. Users own their data."
/// ─────────────────────────────────────────────────────────────────────────────

class LocalStorageEngine {
  // In-memory cache for ultra-fast UI rendering (never blocks UI)
  final Map<String, Workspace> _workspaces = {};
  final Map<String, Domain> _domains = {};
  final Map<String, Block> _blocks = {};
  final Map<String, Item> _items = {};
  final Map<String, Reflection> _reflections = {};
  final Map<String, Evolutio> _evolutios = {};
  final Map<String, Veritas> _veritas = {};
  final Map<String, KnowledgeSource> _sources = {};
  final Map<String, Connection> _connections = {};
  
  AppearanceSettings _appearance = const AppearanceSettings();

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    final hermesDir = Directory('${dir.path}/hermes');
    if (!await hermesDir.exists()) {
      await hermesDir.create(recursive: true);
    }
    
    await _loadAllFromDisk(hermesDir);
    
    if (_workspaces.values.where((w) => !w.deleted).isEmpty) {
      final defaultWorkspace = Workspace(name: 'Starter', isDefault: true, icon: '⭐');
      _workspaces[defaultWorkspace.id] = defaultWorkspace;
      await _saveToDisk('workspaces', _workspaces.map((k, v) => MapEntry(k, v.toJson())));
      await seedStarterWorkspace(defaultWorkspace);
    } else if (_workspaces.values.where((w) => !w.deleted && w.isDefault).isEmpty) {
      final firstActive = _workspaces.values.where((w) => !w.deleted).first;
      await saveWorkspace(firstActive.copyWith(isDefault: true));
    }
    
    // Load Appearance
    final appearanceFile = await _getFile('appearance');
    if (await appearanceFile.exists()) {
      final json = jsonDecode(await appearanceFile.readAsString());
      _appearance = AppearanceSettings.fromJson(json);
    }
  }
  Future<void> seedStarterWorkspace(Workspace workspace) async {
    // ── DOMAINS ─────────────────────────────────────────
    final engineeringDomain = Domain(workspaceId: workspace.id, name: 'Engineering', sortOrder: 0, pinned: true, icon: '🔧');
    final startupDomain = Domain(workspaceId: workspace.id, name: 'Startup', sortOrder: 1, pinned: true, icon: '🚀');
    final thinkingDomain = Domain(workspaceId: workspace.id, name: 'Thinking', sortOrder: 2, pinned: true, icon: '💭');
    final lifeDomain = Domain(workspaceId: workspace.id, name: 'Life', sortOrder: 3, pinned: true, icon: '🌱');
    
    await saveDomain(engineeringDomain);
    await saveDomain(startupDomain);
    await saveDomain(thinkingDomain);
    await saveDomain(lifeDomain);
    
    // ── BLOCKS ──────────────────────────────────────────
    final mathBlock = Block(domainId: engineeringDomain.id, name: 'Mathematics', icon: '📐', colorHex: '#7C9EBC', pinned: true);
    final pythonBlock = Block(domainId: engineeringDomain.id, name: 'Python', icon: '🐍', colorHex: '#8BAA8E', pinned: true);
    
    final designBlock = Block(domainId: startupDomain.id, name: 'Product Design', icon: '🎨', colorHex: '#BFA07A', pinned: true);
    
    final modelsBlock = Block(domainId: thinkingDomain.id, name: 'Mental Models', icon: '🧠', colorHex: '#6B6B6B', pinned: true);
    final decisionBlock = Block(domainId: thinkingDomain.id, name: 'Decision Making', icon: '⚖️', colorHex: '#A08EB4', pinned: true);

    final stoicismBlock = Block(domainId: lifeDomain.id, name: 'Stoicism', icon: '🏛️', colorHex: '#D3A37C', pinned: true);

    await saveBlock(mathBlock);
    await saveBlock(pythonBlock);
    await saveBlock(designBlock);
    await saveBlock(modelsBlock);
    await saveBlock(decisionBlock);
    await saveBlock(stoicismBlock);

    final showcaseBlock = Block(domainId: lifeDomain.id, name: 'Hermes Showcase', icon: '✨', colorHex: '#F2C94C', pinned: true);
    await saveBlock(showcaseBlock);

    // ── TODAY'S PURSUIT ITEMS ──────────────────────────────────
    
    final dailyMeta = {'isDailyGoal': true};

    // ── STARTER ARTICLE ────────────────────────────────────────

    final showcaseArticle = Item(
      blockId: showcaseBlock.id,
      type: ItemType.article,
      title: 'Welcome to Hermes v3.0',
      content: '''**👋 Note: This is an auto-generated Starter Workspace.** 
This workspace exists only to show you how Hermes works. Please read this entire article first. Once you understand the core philosophy behind Hermes, using the other formats (Questions, Notes, Ideas) will feel completely natural. 

After you finish experimenting, you can safely delete this workspace and create your own from the Control Center.

---

# The Philosophy of Hermes

Information is easy to collect. Understanding is difficult to preserve.

Hermes is a quiet, offline-first operating system designed to transform scattered information into permanent knowledge. It does not want to trap your attention with feeds or notifications. 

You can use the **Fetch Article** tool to instantly strip away distractions from any web page and read it cleanly inside Hermes.

Discover the complete guide, philosophy, and features of Hermes here:
[hermes.harshalabs.me](https://hermes.harshalabs.me/)''',
      metadata: dailyMeta,
    );
    await saveItem(showcaseArticle);

    // ── EVOLUTIOS AND VERITAS (Timeline Demonstration) ────────────────

    // Day 1: Today (Evolutio Only - State 1)
    final day1 = DateTime.now();
    final evo1Ref = Reflection(itemId: showcaseArticle.id, content: 'Dummy', createdAt: day1);
    await saveReflection(evo1Ref);
    final evo1 = Evolutio(
      reflectionId: evo1Ref.id,
      blockId: showcaseBlock.id,
      content: 'Installed Hermes and began building my knowledge base.',
      createdAt: day1,
    );
    await saveEvolutio(evo1);

    // Day 2: Today - 3 Days (Veritas Only)
    final day2 = DateTime.now().subtract(const Duration(days: 3));
    final veritas2 = Veritas(
      workspaceId: workspace.id,
      reason: 'I was traveling and could not complete my reading. Hermes acknowledges this honestly.',
      dateMissed: day2,
      createdAt: day2,
    );
    await saveVeritas(veritas2);
  }
  Future<File> _getFile(String collection) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/hermes/$collection.json');
  }

  Future<void> _saveToDisk(String collection, Map<String, dynamic> data) async {
    final file = await _getFile(collection);
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> _loadAllFromDisk(Directory dir) async {
    await _loadCollection('workspaces', _workspaces, (json) => Workspace.fromJson(json));
    await _loadCollection('domains', _domains, (json) => Domain.fromJson(json));
    await _loadCollection('blocks', _blocks, (json) => Block.fromJson(json));
    await _loadCollection('items', _items, (json) => Item.fromJson(json));
    await _loadCollection('reflections', _reflections, (json) => Reflection.fromJson(json));
    await _loadCollection('evolutios', _evolutios, (json) => Evolutio.fromJson(json));
    await _loadCollection('veritas', _veritas, (json) => Veritas.fromJson(json));
    await _loadCollection('sources', _sources, (json) => KnowledgeSource.fromJson(json));
    await _loadCollection('connections', _connections, (json) => Connection.fromJson(json));
  }

  Future<void> _loadCollection<T>(
    String name,
    Map<String, T> cache,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final file = await _getFile(name);
    if (await file.exists()) {
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);
      for (final entry in data.entries) {
        cache[entry.key] = fromJson(entry.value as Map<String, dynamic>);
      }
    }
  }

  // ── Workspaces ──────────────────────────────────────────────────────────────

  List<Workspace> get workspaces => _workspaces.values.where((e) => !e.deleted).toList();
  
  Workspace? getWorkspace(String id) => _workspaces[id];
  Future<void> saveWorkspace(Workspace workspace) async {
    _workspaces[workspace.id] = workspace;
    await _saveToDisk('workspaces', _workspaces.map((k, v) => MapEntry(k, v.toJson())));
    
    // Safety check: if there are no active workspaces left, recreate Starter Workspace
    if (_workspaces.values.where((w) => !w.deleted).isEmpty) {
      final defaultWorkspace = Workspace(name: 'Starter', isDefault: true, icon: '⭐');
      _workspaces[defaultWorkspace.id] = defaultWorkspace;
      await _saveToDisk('workspaces', _workspaces.map((k, v) => MapEntry(k, v.toJson())));
      await seedStarterWorkspace(defaultWorkspace);
    }
  }

  Future<void> factoryReset() async {
    _workspaces.clear();
    _domains.clear();
    _blocks.clear();
    _items.clear();
    _evolutios.clear();
    _veritas.clear();
    
    await _saveToDisk('workspaces', {});
    await _saveToDisk('domains', {});
    await _saveToDisk('blocks', {});
    await _saveToDisk('items', {});
    await _saveToDisk('evolutios', {});
    await _saveToDisk('veritas', {});
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    await prefs.clear();
    
    await initialize();
  }

  int _simulatedDaysOffset = 0;
  DateTime get currentDate => DateTime.now().add(Duration(days: _simulatedDaysOffset));

  Future<void> advanceTime(int days) async {
    _simulatedDaysOffset += days;
  }

  Future<void> jumpToDate(DateTime date) async {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    _simulatedDaysOffset = difference;
  }

  Future<void> resetTime() async {
    _simulatedDaysOffset = 0;
  }

  // State to hold the restored queue
  List<Item>? _restoredPursuitQueue;
  bool _isPursuitReset = false;

  bool get isPursuitReset => _isPursuitReset;

  Future<void> resetTodayPursuit() async {
    final todayStr = currentDate.toIso8601String().substring(0, 10);
    final todayItems = _items.values.where((i) => i.metadata?['surfacedDate'] == todayStr).toList();
    
    _restoredPursuitQueue = List.from(todayItems); // Backup for restore
    _isPursuitReset = true;
    
    for (var item in todayItems) {
      final meta = Map<String, dynamic>.from(item.metadata ?? {});
      meta.remove('surfacedDate');
      // We don't remove isDailyGoal here so it can be restored or regenerated if needed.
      _items[item.id] = item.copyWith(metadata: meta);
    }
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> restoreTodayPursuit() async {
    if (_restoredPursuitQueue != null) {
      for (var item in _restoredPursuitQueue!) {
        _items[item.id] = item; // Restore exact state
      }
      _restoredPursuitQueue = null;
    }
    _isPursuitReset = false;
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> regenerateTodayPursuit() async {
    _isPursuitReset = false;
    _restoredPursuitQueue = null;
    final todayStr = currentDate.toIso8601String().substring(0, 10);
    final todayItems = _items.values.where((i) => i.metadata?['surfacedDate'] == todayStr).toList();
    
    // Demote current items so next ones are picked
    for (var item in todayItems) {
      final meta = Map<String, dynamic>.from(item.metadata ?? {});
      meta.remove('surfacedDate');
      meta.remove('isDailyGoal');
      _items[item.id] = item.copyWith(metadata: meta);
    }
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> rebuildSearchIndex() async {
    // In-memory indexing is fast, but we can simulate a full rebuild process
    // For now, this is a placeholder as SQLite FTS5 is not used in JSON mode.
    // If we migrate to SQLite, this will run 'INSERT INTO fts_table(fts_table) VALUES('rebuild');'
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> vacuum() async {
    // Overwrite all disk files to remove any unlinked or orphaned JSON fragments
    await _saveToDisk('workspaces', _workspaces.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToDisk('domains', _domains.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToDisk('blocks', _blocks.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToDisk('evolutios', _evolutios.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToDisk('veritas', _veritas.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> resetWorkspace(String workspaceId) async {
    // Keep the workspace itself, but clear all domains, blocks, items, evolutios
    final domainsToRemove = getDomains(workspaceId, includeHidden: true);
    final blocksToRemove = <Block>[];
    for (var d in domainsToRemove) {
      blocksToRemove.addAll(getBlocks(d.id, includeHidden: true));
    }
    final itemsToRemove = <Item>[];
    for (var b in blocksToRemove) {
      itemsToRemove.addAll(getItems(b.id));
    }
    
    for (var item in itemsToRemove) {
      _items.remove(item.id);
    }
    for (var block in blocksToRemove) {
      _blocks.remove(block.id);
    }
    for (var domain in domainsToRemove) {
      _domains.remove(domain.id);
    }
    
    final evolutiosToRemove = <Evolutio>[];
    for (var b in blocksToRemove) {
      evolutiosToRemove.addAll(getEvolutiosForBlock(b.id));
    }
    for (var e in evolutiosToRemove) {
      _evolutios.remove(e.id);
    }
    
    final veritasToRemove = getVeritas(workspaceId);
    for (var v in veritasToRemove) {
      _veritas.remove(v.id);
    }
    
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToDisk('blocks', _blocks.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToDisk('domains', _domains.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToDisk('evolutios', _evolutios.map((k, v) => MapEntry(k, v.toJson())));
    await _saveToDisk('veritas', _veritas.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> deleteWorkspace(String workspaceId) async {
    await resetWorkspace(workspaceId);
    _workspaces.remove(workspaceId);
    await _saveToDisk('workspaces', _workspaces.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Appearance ──────────────────────────────────────────────────────────────

  AppearanceSettings get appearance => _appearance;

  Future<void> saveAppearance(AppearanceSettings settings) async {
    _appearance = settings;
    final file = await _getFile('appearance');
    await file.writeAsString(jsonEncode(settings.toJson()));
  }

  // ── Domains ─────────────────────────────────────────────────────────────────

  List<Domain> getDomains(String workspaceId, {bool includeHidden = false}) {
    return _domains.values
        .where((d) => d.workspaceId == workspaceId && !d.deleted && (includeHidden || !d.hidden))
        .toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<Domain> getAllDomainsRaw() {
    return _domains.values.toList();
  }

  Future<void> saveDomain(Domain domain) async {
    _domains[domain.id] = domain;
    await _saveToDisk('domains', _domains.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> deleteDomain(String domainId) async {
    final domain = _domains[domainId];
    if (domain == null) return;
    
    // Soft delete domain
    _domains[domainId] = domain.copyWith(deleted: true, archived: true);
    await _saveToDisk('domains', _domains.map((k, v) => MapEntry(k, v.toJson())));
    
    // Cascade delete blocks
    final childBlocks = _blocks.values.where((b) => b.domainId == domainId).toList();
    for (final b in childBlocks) {
      await deleteBlock(b.id);
    }
  }

  Future<void> restoreDomain(String domainId) async {
    final domain = _domains[domainId];
    if (domain == null) return;
    _domains[domainId] = domain.copyWith(deleted: false, archived: false);
    await _saveToDisk('domains', _domains.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Blocks ──────────────────────────────────────────────────────────────────

  List<Block> getBlocks(String domainId, {bool includeHidden = false}) {
    return _blocks.values.where((b) => b.domainId == domainId && !b.deleted && (includeHidden || !b.hidden)).toList();
  }

  List<Block> getAllBlocks({bool includeHidden = false}) {
    return _blocks.values.where((b) => !b.deleted && (includeHidden || !b.hidden)).toList();
  }

  List<Block> getAllBlocksRaw() {
    return _blocks.values.toList();
  }

  Future<void> saveBlock(Block block) async {
    _blocks[block.id] = block;
    await _saveToDisk('blocks', _blocks.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> deleteBlock(String blockId) async {
    final block = _blocks[blockId];
    if (block == null) return;
    
    // Soft delete block
    _blocks[blockId] = block.copyWith(deleted: true, archived: true);
    await _saveToDisk('blocks', _blocks.map((k, v) => MapEntry(k, v.toJson())));
    
    // Cascade delete items
    final childItems = _items.values.where((i) => i.blockId == blockId).toList();
    for (final i in childItems) {
      await deleteItem(i.id);
    }
  }

  Future<void> restoreBlock(String blockId) async {
    final block = _blocks[blockId];
    if (block == null) return;
    
    String finalDomainId = block.domainId;
    final parentDomain = _domains[block.domainId];
    
    // If parent domain is missing or deleted, move to Felix Domain
    if (parentDomain == null || parentDomain.deleted) {
      Domain? felixDomain;
      for (final d in _domains.values) {
        if (d.name == 'Felix' && !d.deleted) {
          felixDomain = d;
          break;
        }
      }
      
      if (felixDomain == null) {
        final workspaceId = parentDomain?.workspaceId ?? 'default';
        felixDomain = Domain(workspaceId: workspaceId, name: 'Felix');
        await saveDomain(felixDomain);
      }
      finalDomainId = felixDomain.id;
    }

    _blocks[blockId] = block.copyWith(
      domainId: finalDomainId,
      deleted: false, 
      archived: false,
    );
    await _saveToDisk('blocks', _blocks.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Items ───────────────────────────────────────────────────────────────────

  List<Item> getItems(String blockId) {
    return _items.values.where((i) => i.blockId == blockId && !i.deleted).toList();
  }

  List<Item> getAllItems() {
    return _items.values.where((i) => !i.deleted).toList();
  }

  List<Item> getAllItemsRaw() {
    return _items.values.toList();
  }

  Domain? getDomainById(String id) => _domains[id];
  Block? getBlockById(String id) => _blocks[id];
  Item? getItemById(String id) => _items[id];
  KnowledgeSource? getSourceById(String id) => _sources[id];
  Evolutio? getEvolutioById(String id) => _evolutios[id];
  Future<void> saveItem(Item item) async {
    _items[item.id] = item;
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> saveItems(List<Item> items) async {
    for (final item in items) {
      _items[item.id] = item;
    }
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> deleteItem(String itemId) async {
    final item = _items[itemId];
    if (item == null) return;
    
    _items[itemId] = item.copyWith(deleted: true, archived: true);
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  // --- KNOWLEDGE SOURCES ---

  List<KnowledgeSource> getSources(String workspaceId, {bool includeHidden = false}) {
    return _sources.values
        .where((s) => s.workspaceId == workspaceId && (!s.deleted) && (includeHidden || !s.archived))
        .toList();
  }

  Future<void> saveSource(KnowledgeSource source) async {
    _sources[source.id] = source;
    await _saveToDisk('sources', _sources.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> deleteSource(String sourceId) async {
    final source = _sources[sourceId];
    if (source == null) return;
    
    // Mark source as deleted
    _sources[sourceId] = source.copyWith(deleted: true, archived: true);
    await _saveToDisk('sources', _sources.map((k, v) => MapEntry(k, v.toJson())));
    
    // Cascade to items
    final childItems = _items.values.where((i) => i.sourceId == sourceId).toList();
    for (final item in childItems) {
      _items[item.id] = item.copyWith(deleted: true, archived: true);
    }
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> restoreItem(String itemId) async {
    final item = _items[itemId];
    if (item == null) return;
    
    // If the parent block is missing or deleted, we should also restore the item into a fallback.
    // But since the user specifically requested Felix Domain for blocks, we can just cascade-restore the parent block.
    // Or we can move it to a Felix Block. Let's just restore the parent block for now, or let it fail gracefully.
    // Actually, to be safe, if we restore an item and its block is deleted, we just restore it. But it won't show in UI.
    // Let's create a Felix Block if parent block is dead.
    
    String finalBlockId = item.blockId;
    final parentBlock = _blocks[item.blockId];
    
    if (parentBlock == null || parentBlock.deleted) {
      Block? felixBlock;
      for (final b in _blocks.values) {
        if (b.name == 'Felix Block' && !b.deleted) {
          felixBlock = b;
          break;
        }
      }
      
      if (felixBlock == null) {
        // Need a domain for Felix Block. Let's just find any valid domain or create Felix Domain.
        Domain? felixDomain;
        for (final d in _domains.values) {
          if (d.name == 'Felix' && !d.deleted) {
            felixDomain = d;
            break;
          }
        }
        if (felixDomain == null) {
          felixDomain = Domain(workspaceId: 'default', name: 'Felix');
          await saveDomain(felixDomain);
        }
        felixBlock = Block(domainId: felixDomain.id, name: 'Felix Block', icon: '✨');
        await saveBlock(felixBlock);
      }
      finalBlockId = felixBlock.id;
    }

    _items[itemId] = item.copyWith(
      blockId: finalBlockId,
      deleted: false, 
      archived: false,
    );
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Reflections ─────────────────────────────────────────────────────────────

  List<Reflection> getAllReflections() {
    return _reflections.values.where((r) => !r.deleted).toList();
  }

  Reflection? getReflectionForItem(String itemId) {
    return _reflections.values.where((r) => r.itemId == itemId && !r.deleted).firstOrNull;
  }

  Future<void> saveReflection(Reflection reflection) async {
    _reflections[reflection.id] = reflection;
    await _saveToDisk('reflections', _reflections.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Connections ─────────────────────────────────────────────────────────────

  List<Connection> getConnectionsForItem(String itemId) {
    return _connections.values.where((c) => c.itemAId == itemId || c.itemBId == itemId).toList();
  }
  
  Connection? getConnection(String id) {
    return _connections[id];
  }

  Future<void> saveConnection(Connection connection) async {
    _connections[connection.id] = connection;
    await _saveToDisk('connections', _connections.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> deleteConnection(String id) async {
    _connections.remove(id);
    await _saveToDisk('connections', _connections.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Evolutios ───────────────────────────────────────────────────────────────

  List<Evolutio> getEvolutios() {
    final list = _evolutios.values.where((e) => !e.deleted).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
  
  List<Evolutio> getAllEvolutiosRaw() {
    return _evolutios.values.toList();
  }
  
  List<Evolutio> getEvolutiosForBlock(String blockId) {
    final list = _evolutios.values.where((e) => e.blockId == blockId && !e.deleted).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> saveEvolutio(Evolutio evolutio) async {
    _evolutios[evolutio.id] = evolutio;
    await _saveToDisk('evolutios', _evolutios.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Veritas ─────────────────────────────────────────────────────────────────

  List<Veritas> getVeritas(String workspaceId) {
    final list = _veritas.values.where((v) => v.workspaceId == workspaceId && !v.deleted).toList();
    list.sort((a, b) => b.dateMissed.compareTo(a.dateMissed));
    return list;
  }
  
  List<Veritas> getAllVeritasRaw() {
    return _veritas.values.toList();
  }

  Future<void> saveVeritas(Veritas veritas) async {
    _veritas[veritas.id] = veritas;
    await _saveToDisk('veritas', _veritas.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Archive Management ──────────────────────────────────────────────────────

  Future<void> permanentlyDeleteDomain(String id) async {
    _domains.remove(id);
    await _saveToDisk('domains', _domains.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> permanentlyDeleteBlock(String id) async {
    _blocks.remove(id);
    await _saveToDisk('blocks', _blocks.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> permanentlyDeleteItem(String id) async {
    _items.remove(id);
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> permanentlyDeleteEvolutio(String id) async {
    _evolutios.remove(id);
    await _saveToDisk('evolutios', _evolutios.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> permanentlyDeleteVeritas(String id) async {
    _veritas.remove(id);
    await _saveToDisk('veritas', _veritas.map((k, v) => MapEntry(k, v.toJson())));
  }

  Future<void> restoreEvolutio(String id) async {
    final evo = _evolutios[id];
    if (evo != null) {
      _evolutios[id] = evo.copyWith(deleted: false, archived: false);
      await _saveToDisk('evolutios', _evolutios.map((k, v) => MapEntry(k, v.toJson())));
    }
  }

  Future<void> restoreVeritas(String id) async {
    final v = _veritas[id];
    if (v != null) {
      _veritas[id] = v.copyWith(deleted: false, archived: false);
      await _saveToDisk('veritas', _veritas.map((k, v) => MapEntry(k, v.toJson())));
    }
  }

  Future<void> emptyArchive() async {
    _domains.removeWhere((_, v) => v.deleted);
    _blocks.removeWhere((_, v) => v.deleted);
    _items.removeWhere((_, v) => v.deleted);
    _evolutios.removeWhere((_, v) => v.deleted);
    _veritas.removeWhere((_, v) => v.deleted);
    // Connections don't have deleted flag currently, so we don't need to empty them.

    await Future.wait([
      _saveToDisk('domains', _domains.map((k, v) => MapEntry(k, v.toJson()))),
      _saveToDisk('blocks', _blocks.map((k, v) => MapEntry(k, v.toJson()))),
      _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson()))),
      _saveToDisk('evolutios', _evolutios.map((k, v) => MapEntry(k, v.toJson()))),
      _saveToDisk('veritas', _veritas.map((k, v) => MapEntry(k, v.toJson()))),
      _saveToDisk('connections', _connections.map((k, v) => MapEntry(k, v.toJson()))),
    ]);
  }

  Future<void> restoreAll() async {
    final deletedDomains = _domains.values.where((d) => d.deleted).map((d) => d.id).toList();
    for (final id in deletedDomains) {
      await restoreDomain(id);
    }
    
    final deletedBlocks = _blocks.values.where((b) => b.deleted).map((b) => b.id).toList();
    for (final id in deletedBlocks) {
      await restoreBlock(id);
    }
    
    final deletedItems = _items.values.where((i) => i.deleted).map((i) => i.id).toList();
    for (final id in deletedItems) {
      await restoreItem(id);
    }
    
    final deletedEvolutios = _evolutios.values.where((e) => e.deleted).map((e) => e.id).toList();
    for (final id in deletedEvolutios) {
      await restoreEvolutio(id);
    }
    
    final deletedVeritas = _veritas.values.where((v) => v.deleted).map((v) => v.id).toList();
    for (final id in deletedVeritas) {
      await restoreVeritas(id);
    }
  }
}
