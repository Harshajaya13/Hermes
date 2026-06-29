import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'local_storage_engine.dart';
import '../models/models.dart';

class ExportEngine {
  final LocalStorageEngine storage;

  ExportEngine(this.storage);

  /// Exports the entire active workspace into a .hermes ZIP container.
  Future<String> exportWorkspace(String workspaceId) async {
    // 1. Gather Data
    final domains = storage.getDomains(workspaceId);
    final blocks = <Block>[];
    final items = <Item>[];
    final evolutios = storage.getEvolutios(); // We might want to filter by workspace, but let's just grab all for now

    for (final d in domains) {
      final dBlocks = storage.getBlocks(d.id);
      blocks.addAll(dBlocks);
      for (final b in dBlocks) {
        items.addAll(storage.getItems(b.id));
      }
    }

    final databaseJson = {
      'domains': domains.map((e) => e.toJson()).toList(),
      'blocks': blocks.map((e) => e.toJson()).toList(),
      'items': items.map((e) => e.toJson()).toList(),
      'evolutios': evolutios.map((e) => e.toJson()).toList(),
    };

    final metadataJson = {
      'schema_version': 1,
      'hermes_version': '1.0',
      'created_at': DateTime.now().toIso8601String(),
      'description': 'Exported Hermes Workspace',
    };

    // 2. Create Archive
    final archive = Archive();
    
    archive.addFile(ArchiveFile(
      'metadata.json', 
      jsonEncode(metadataJson).length, 
      utf8.encode(jsonEncode(metadataJson))
    ));
    
    archive.addFile(ArchiveFile(
      'database.json', 
      jsonEncode(databaseJson).length, 
      utf8.encode(jsonEncode(databaseJson))
    ));

    // 3. Save to Disk
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    
    if (zipData == null) throw Exception('Failed to encode ZIP data');

    final dir = await getApplicationDocumentsDirectory();
    final exportPath = '${dir.path}/export_${DateTime.now().millisecondsSinceEpoch}.hermes';
    final file = File(exportPath);
    await file.writeAsBytes(zipData);

    return exportPath;
  }

  /// Imports a .hermes file and merges its contents into the current workspace.
  Future<void> importWorkspace(String filePath, String targetWorkspaceId) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception('File not found');

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    String? dbJsonString;
    for (final archiveFile in archive) {
      if (archiveFile.name == 'database.json') {
        dbJsonString = utf8.decode(archiveFile.content as List<int>);
        break;
      }
    }

    if (dbJsonString == null) throw Exception('Invalid .hermes file: Missing database.json');

    final Map<String, dynamic> dbJson = jsonDecode(dbJsonString);

    // Parse and save
    if (dbJson.containsKey('domains')) {
      for (final d in dbJson['domains']) {
        final domain = Domain.fromJson(d).copyWith(workspaceId: targetWorkspaceId);
        await storage.saveDomain(domain);
      }
    }
    
    if (dbJson.containsKey('blocks')) {
      for (final b in dbJson['blocks']) {
        await storage.saveBlock(Block.fromJson(b));
      }
    }
    
    if (dbJson.containsKey('items')) {
      for (final i in dbJson['items']) {
        await storage.saveItem(Item.fromJson(i));
      }
    }
    
    if (dbJson.containsKey('evolutios')) {
      for (final e in dbJson['evolutios']) {
        await storage.saveEvolutio(Evolutio.fromJson(e));
      }
    }
  }
}
