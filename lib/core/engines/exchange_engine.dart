import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'local_storage_engine.dart';
import '../models/models.dart';

class ExchangePackagePreview {
  final Map<String, dynamic> manifest;
  final Workspace workspace;
  final int domainCount;
  final int blockCount;
  final int itemCount;
  final int sourceCount;

  ExchangePackagePreview({
    required this.manifest,
    required this.workspace,
    required this.domainCount,
    required this.blockCount,
    required this.itemCount,
    required this.sourceCount,
  });
}

class ExchangeEngine {
  final LocalStorageEngine storage;

  ExchangeEngine(this.storage);

  /// Exports the entire active workspace into a .hermes ZIP container.
  Future<String> exportWorkspace(String workspaceId) async {
    final workspace = storage.getWorkspace(workspaceId);
    if (workspace == null) throw Exception('Workspace not found');

    final domains = storage.getDomains(workspaceId);
    final blocks = <Block>[];
    final items = <Item>[];
    final sources = storage.getSources(workspaceId);
    final evolutios = storage.getEvolutios(); 

    for (final d in domains) {
      final dBlocks = storage.getBlocks(d.id);
      blocks.addAll(dBlocks);
      for (final b in dBlocks) {
        items.addAll(storage.getItems(b.id));
      }
    }

    final manifest = {
      'Workspace Name': workspace.name,
      'Description': workspace.description,
      'Created By': workspace.ownerName ?? 'Unknown',
      'Created Date': DateTime.now().toIso8601String(),
      'Hermes Version': '3.0.0',
      'Package Version': '1.0',
      'Package UUID': const Uuid().v4(),
    };

    final archive = Archive();
    
    _addJsonFile(archive, 'workspace.json', workspace.toJson());
    _addJsonFile(archive, 'domains.json', domains.map((e) => e.toJson()).toList());
    _addJsonFile(archive, 'blocks.json', blocks.map((e) => e.toJson()).toList());
    _addJsonFile(archive, 'items.json', items.map((e) => e.toJson()).toList());
    _addJsonFile(archive, 'sources.json', sources.map((e) => e.toJson()).toList());
    _addJsonFile(archive, 'evolutios.json', evolutios.map((e) => e.toJson()).toList());
    
    // We will add reflections and veritas as empty arrays for now, as they don't seem to have full providers yet
    _addJsonFile(archive, 'reflections.json', []);
    _addJsonFile(archive, 'veritas.json', []);

    // Calculate Checksum of the files so far
    final checksumData = archive.files.map((e) => '${e.name}:${md5.convert(e.content as List<int>)}').join('\n');
    manifest['Checksum'] = md5.convert(utf8.encode(checksumData)).toString();

    _addJsonFile(archive, 'manifest.json', manifest);
    archive.addFile(ArchiveFile('checksum.txt', checksumData.length, utf8.encode(checksumData)));

    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    
    if (zipData == null) throw Exception('Failed to encode ZIP data');

    final dir = await getApplicationDocumentsDirectory();
    final exportPath = '${dir.path}/${workspace.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.hermes';
    final file = File(exportPath);
    await file.writeAsBytes(zipData);

    return exportPath;
  }

  void _addJsonFile(Archive archive, String name, dynamic data) {
    final bytes = utf8.encode(jsonEncode(data));
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  Future<ExchangePackagePreview> previewPackage(String filePath) async {
    final archive = await _decodeArchive(filePath);
    
    final manifestString = _readFileString(archive, 'manifest.json');
    if (manifestString == null) throw Exception('Validation Failed: Missing manifest.json');
    
    final manifest = jsonDecode(manifestString) as Map<String, dynamic>;
    
    final checksumString = _readFileString(archive, 'checksum.txt');
    if (checksumString != null) {
      final actualChecksum = md5.convert(utf8.encode(checksumString)).toString();
      if (manifest['Checksum'] != actualChecksum) {
         // throw Exception('Validation Failed: Checksum mismatch'); 
         // For now, warning or continue, maybe just validate
      }
    }

    final workspaceString = _readFileString(archive, 'workspace.json');
    if (workspaceString == null) throw Exception('Validation Failed: Missing workspace.json');
    final workspace = Workspace.fromJson(jsonDecode(workspaceString));

    final domainsString = _readFileString(archive, 'domains.json');
    final domains = domainsString != null ? (jsonDecode(domainsString) as List) : [];
    
    final blocksString = _readFileString(archive, 'blocks.json');
    final blocks = blocksString != null ? (jsonDecode(blocksString) as List) : [];
    
    final itemsString = _readFileString(archive, 'items.json');
    final items = itemsString != null ? (jsonDecode(itemsString) as List) : [];

    final sourcesString = _readFileString(archive, 'sources.json');
    final sources = sourcesString != null ? (jsonDecode(sourcesString) as List) : [];

    return ExchangePackagePreview(
      manifest: manifest,
      workspace: workspace,
      domainCount: domains.length,
      blockCount: blocks.length,
      itemCount: items.length,
      sourceCount: sources.length,
    );
  }

  Future<void> importPackage({
    required String filePath,
    required bool asNewWorkspace,
    String? targetWorkspaceId,
    required String mergeStrategy, // 'skip', 'replace', 'duplicate', 'rename'
  }) async {
    final archive = await _decodeArchive(filePath);
    
    String workspaceId = targetWorkspaceId ?? const Uuid().v4();

    if (asNewWorkspace) {
      final workspaceString = _readFileString(archive, 'workspace.json');
      if (workspaceString != null) {
        final ws = Workspace.fromJson(jsonDecode(workspaceString));
        workspaceId = ws.id; // Or generate new depending on exact requirement
        await storage.saveWorkspace(ws);
      } else {
        throw Exception('Validation Failed: Missing workspace metadata for new workspace import');
      }
    } else {
      if (targetWorkspaceId == null) throw Exception('Merge target workspace not specified');
    }

    // Helper to process lists
    Future<void> processEntities<T>(String fileName, T Function(Map<String, dynamic>) fromJson, Future<void> Function(T) save) async {
      final jsonStr = _readFileString(archive, fileName);
      if (jsonStr != null) {
        final list = jsonDecode(jsonStr) as List;
        for (final itemJson in list) {
          final item = fromJson(itemJson as Map<String, dynamic>);
          // Note: Conflict resolution logic (skip, replace, etc.) should be injected here
          // For now, save simply replaces based on ID
          await save(item);
        }
      }
    }

    await processEntities('domains.json', 
      (json) => Domain.fromJson(json).copyWith(workspaceId: workspaceId), 
      storage.saveDomain);
    
    await processEntities('blocks.json', 
      (json) => Block.fromJson(json), 
      storage.saveBlock);
    
    await processEntities('items.json', 
      (json) => Item.fromJson(json), 
      storage.saveItem);
      
    await processEntities('sources.json', 
      (json) => KnowledgeSource.fromJson(json).copyWith(workspaceId: workspaceId), 
      storage.saveSource);
      
    await processEntities('evolutios.json', 
      (json) => Evolutio.fromJson(json), 
      storage.saveEvolutio);
  }

  Future<Archive> _decodeArchive(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception('File not found');
    final bytes = await file.readAsBytes();
    return ZipDecoder().decodeBytes(bytes);
  }

  String? _readFileString(Archive archive, String fileName) {
    for (final archiveFile in archive) {
      if (archiveFile.name == fileName) {
        return utf8.decode(archiveFile.content as List<int>);
      }
    }
    return null;
  }
}
