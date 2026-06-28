import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    final hermesDir = Directory('${dir.path}/hermes');
    if (!await hermesDir.exists()) {
      await hermesDir.create(recursive: true);
      // Create a default workspace if empty
      final defaultWorkspace = Workspace(name: 'Personal');
      await saveWorkspace(defaultWorkspace);
    } else {
      await _loadAllFromDisk(hermesDir);
    }
  }

  Future<File> _getFile(String collection) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/hermes/$collection.json');
  }

  Future<void> _saveToDisk(String collection, Map<String, dynamic> data) async {
    final file = await _getFile(collection);
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
  
  Future<void> saveWorkspace(Workspace workspace) async {
    _workspaces[workspace.id] = workspace;
    await _saveToDisk('workspaces', _workspaces.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Domains ─────────────────────────────────────────────────────────────────

  List<Domain> getDomains(String workspaceId) {
    return _domains.values
        .where((d) => d.workspaceId == workspaceId && !d.deleted)
        .toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> saveDomain(Domain domain) async {
    _domains[domain.id] = domain;
    await _saveToDisk('domains', _domains.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Blocks ──────────────────────────────────────────────────────────────────

  List<Block> getBlocks(String domainId) {
    return _blocks.values.where((b) => b.domainId == domainId && !b.deleted).toList();
  }

  List<Block> getAllBlocks() {
    return _blocks.values.where((b) => !b.deleted).toList();
  }

  Future<void> saveBlock(Block block) async {
    _blocks[block.id] = block;
    await _saveToDisk('blocks', _blocks.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Items ───────────────────────────────────────────────────────────────────

  List<Item> getItems(String blockId) {
    return _items.values.where((i) => i.blockId == blockId && !i.deleted).toList();
  }

  Future<void> saveItem(Item item) async {
    _items[item.id] = item;
    await _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Reflections ─────────────────────────────────────────────────────────────

  Future<void> saveReflection(Reflection reflection) async {
    _reflections[reflection.id] = reflection;
    await _saveToDisk('reflections', _reflections.map((k, v) => MapEntry(k, v.toJson())));
  }

  // ── Evolutios ───────────────────────────────────────────────────────────────

  List<Evolutio> getEvolutios() {
    final list = _evolutios.values.where((e) => !e.deleted).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
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

  Future<void> saveVeritas(Veritas veritas) async {
    _veritas[veritas.id] = veritas;
    await _saveToDisk('veritas', _veritas.map((k, v) => MapEntry(k, v.toJson())));
  }
}
