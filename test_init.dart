import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/core/engines/local_storage_engine.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';

class MockPathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = Directory.systemTemp.createTempSync('hermes_test');
    return dir.path;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockPathProviderPlatform();
  final engine = LocalStorageEngine();
  try {
    await engine.initialize();
    print('Workspaces: \${engine.workspaces.length}');
  } catch (e, st) {
    print('Failed with $e\n$st');
  }
}
