import 'package:flutter_test/flutter_test.dart';
import 'lib/core/engines/local_storage_engine.dart';
import 'lib/core/models/models.dart';
import 'dart:io';

void main() async {
  print("Testing seedStarterWorkspace...");
  final engine = LocalStorageEngine();
  // We need to bypass getApplicationDocumentsDirectory since it's Flutter only.
  // Actually we can't run LocalStorageEngine outside Flutter because it uses path_provider.
}
