import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermes/features/blocks/blocks_screen.dart';
import 'package:hermes/core/providers/providers.dart';
import 'package:hermes/core/engines/local_storage_engine.dart';

void main() {
  testWidgets('BlocksScreen empty domains test', (WidgetTester tester) async {
    final storageEngine = LocalStorageEngine();
    await storageEngine.initialize();
    
    // Clear all domains to ensure it's empty
    final workspace = storageEngine.workspaces.first;
    final domains = storageEngine.getDomains(workspace.id);
    for (var d in domains) {
      storageEngine.deleteDomain(d.id);
    }
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageEngineProvider.overrideWithValue(storageEngine),
        ],
        child: const MaterialApp(
          home: BlocksScreen(),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    expect(find.textContaining('NoSuchMethodError'), findsNothing);
  });
}
