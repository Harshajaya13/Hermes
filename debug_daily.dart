import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('/home/harsha/Documents/hermes');
  
  final sourcesFile = File('${dir.path}/sources.json');
  final itemsFile = File('${dir.path}/items.json');
  
  if (!sourcesFile.existsSync() || !itemsFile.existsSync()) {
    print("Files not found.");
    return;
  }
  
  final sourcesJson = jsonDecode(sourcesFile.readAsStringSync()) as Map;
  final itemsJson = jsonDecode(itemsFile.readAsStringSync()) as Map;
  
  final sources = sourcesJson.values.toList();
  final items = itemsJson.values.toList();
  
  print("Total sources: \${sources.length}");
  print("Total items: \${items.length}");
  
  int dailyGoalItems = 0;
  for (final item in items) {
    final meta = item['metadata'] as Map?;
    if (meta?['isDailyGoal'] == true) {
      dailyGoalItems++;
      print("Item: \${item['title']}");
      print("  sourceId: \${item['sourceId']}");
      print("  surfacedDate: \${meta?['surfacedDate']}");
      
      if (item['sourceId'] != null) {
        final source = sourcesJson[item['sourceId']];
        if (source != null) {
          print("  Source found: \${source['name']}");
          print("    includeInToday: \${source['includeInToday']}");
          print("    dailyLimit: \${source['dailyLimit']}");
        } else {
          print("  SOURCE NOT FOUND IN JSON!");
        }
      }
    }
  }
  print("Total daily goal items: \$dailyGoalItems");
}
