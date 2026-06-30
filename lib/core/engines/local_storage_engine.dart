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
  final Map<String, KnowledgeSource> _sources = {};
  
  AppearanceSettings _appearance = const AppearanceSettings();

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    final hermesDir = Directory('${dir.path}/hermes');
    if (!await hermesDir.exists()) {
      await hermesDir.create(recursive: true);
      // Create a default workspace if empty
      final defaultWorkspace = Workspace(name: 'Starter', isDefault: true, icon: '⭐');
      await saveWorkspace(defaultWorkspace);
      try {
        await seedStarterWorkspace(defaultWorkspace);
      } catch (e, stack) {
        print('Starter workspace seed failed: $e');
        print(stack);
      }
    } else {
      await _loadAllFromDisk(hermesDir);
      
      // Safety check: ensure at least one default workspace exists
      if (_workspaces.values.where((w) => !w.deleted && w.isDefault).isEmpty) {
        final firstActive = _workspaces.values.where((w) => !w.deleted).firstOrNull;
        if (firstActive != null) {
          await saveWorkspace(firstActive.copyWith(isDefault: true));
        } else {
          final defaultWorkspace = Workspace(name: 'Starter', isDefault: true, icon: '⭐');
          await saveWorkspace(defaultWorkspace);
          try {
            await seedStarterWorkspace(defaultWorkspace);
          } catch (e, stack) {
            print('Starter workspace seed failed: $e');
            print(stack);
          }
        }
      }
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
    final engineeringDomain = Domain(workspaceId: workspace.id, name: 'Engineering', sortOrder: 0, pinned: true);
    final startupDomain = Domain(workspaceId: workspace.id, name: 'Startup', sortOrder: 1, pinned: true);
    final thinkingDomain = Domain(workspaceId: workspace.id, name: 'Thinking', sortOrder: 2, pinned: true);
    final lifeDomain = Domain(workspaceId: workspace.id, name: 'Life', sortOrder: 3, pinned: true);
    
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

    // ── TODAY'S PURSUIT ITEMS (Living Showroom) ────────────────
    
    final dailyMeta = {'isDailyGoal': true, 'isManualDailyGoal': true};

    // 1. Question (Probability - Monty Hall)
    final qProb1 = Item(
      blockId: mathBlock.id,
      type: ItemType.question,
      title: 'The Monty Hall Problem (N doors variant)',
      content: 'If there are N doors, and you pick 1, and Monty opens N-2 doors with goats, what is the exact probability of winning if you switch? How does the math scale as N approaches infinity?',
      metadata: dailyMeta,
    );
    await saveItem(qProb1);

    // Question (Probability - Boy or Girl Paradox)
    final qProb2 = Item(
      blockId: mathBlock.id,
      type: ItemType.question,
      title: 'The Boy or Girl Paradox',
      content: 'A family has two children. You are told that at least one of them is a boy. What is the probability that both children are boys? Why is the answer 1/3 and not 1/2, and how does the sample space change if you are told the *older* child is a boy?',
      metadata: dailyMeta,
    );
    await saveItem(qProb2);

    // Question (Probability - Base Rate Fallacy)
    final qProb3 = Item(
      blockId: mathBlock.id,
      type: ItemType.question,
      title: 'Base Rate Fallacy in Medical Testing',
      content: 'A disease affects 1 in 10,000 people. A test for it is 99% accurate (1% false positive, 1% false negative). If you test positive, what is the actual probability you have the disease? How do I use Bayes\' Theorem to build an intuition for this?',
      metadata: dailyMeta,
    );
    await saveItem(qProb3);

    // Question (Probability - Birthday Paradox)
    final qProb4 = Item(
      blockId: mathBlock.id,
      type: ItemType.question,
      title: 'The Birthday Paradox',
      content: 'How many people do you need in a room to have a 50% chance that two of them share the same birthday? Why does the human brain so dramatically underestimate this probability, and what is the mathematical formula to calculate it?',
      metadata: dailyMeta,
    );
    await saveItem(qProb4);

    // Question (Probability - St. Petersburg Paradox)
    final qProb5 = Item(
      blockId: mathBlock.id,
      type: ItemType.question,
      title: 'The St. Petersburg Paradox',
      content: 'A casino offers a game: a fair coin is tossed at each stage. The pot starts at \$2 and is doubled every time a head appears. The first time a tail appears, the game ends and you win whatever is in the pot. The expected value of this game is infinite. So how much should a rational person pay to play it?',
      metadata: dailyMeta,
    );
    await saveItem(qProb5);

    // 2. Article (Long-form)
    final articleToday = Item(
      blockId: modelsBlock.id,
      type: ItemType.article,
      title: 'The Psychology of Deep Work',
      content: '''# The Psychology of Deep Work

Deep work is the ability to focus without distraction on a cognitively demanding task. It's a skill that allows you to quickly master complicated information and produce better results in less time.

![Deep Work Space](https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&w=800&q=80)

## The Attention Economy

We live in a world where distraction is the default. Notifications, endless feeds, and shallow work consume our cognitive resources.

> "To produce at your peak level you need to work for extended periods with full concentration on a single task free from distraction."
> — Cal Newport

## Attention Residue

When you switch from Task A to Task B, your attention doesn't immediately follow. A residue of your attention remains stuck thinking about the original task. This is why checking email for "just one minute" during a coding session destroys your productivity for the next twenty minutes.

### The Rules of Deep Work

1. **Work Deeply**: Institutionalize the habit. Build a physical and temporal space where focus is sacred.
2. **Embrace Boredom**: If you train your brain to seek novel stimuli whenever you're bored (e.g., waiting in line and pulling out your phone), you lose the ability to sustain focus when work gets hard.
3. **Quit Social Media**: Evaluate tools based on whether they substantially help you achieve your core goals.
4. **Drain the Shallows**: Schedule every minute of your day to ruthlessly eliminate shallow, low-value work.

## Conclusion

Deep work is not a luxury; it is a necessity for anyone looking to build meaningful things in the modern economy. It requires deliberate practice and a rejection of the superficial.
''',
      metadata: dailyMeta,
    );
    await saveItem(articleToday);

    // 3. Meaningful Note
    final noteToday = Item(
      blockId: mathBlock.id,
      type: ItemType.note,
      title: 'Mathematics Is a Language',
      content: '''# Mathematics Is a Language

We often treat mathematics as a series of computations to be executed. This is fundamentally wrong. Mathematics is a language designed to describe truth with absolute precision.

## The Problem with Memorization

When you memorize a formula, you are memorizing a sentence without understanding its grammar. 

Take Expected Value, for example. The formula is:

```latex
E(X) = \\sum x P(x)
```

If you memorize this, it's just symbols. But if you understand the language, it translates to: *"The average outcome of a situation is the sum of every possible event multiplied by how likely that event is to occur."*

This is the exact same logic we use to cross the street. We subconsciously weigh the magnitude of an event (getting hit by a car) against its probability.

![Math Notebook](https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=800&q=80)

## Application in Code

Understanding this language makes programming much more powerful. 

```python
# Calculating Expected Value
outcomes = [(100, 0.2), (-10, 0.8)]
expected_value = sum(magnitude * probability for magnitude, probability in outcomes)

if expected_value > 0:
    print("This is a positive expected value bet.")
```

When you stop treating math as computation and start treating it as language, the world becomes much easier to read.
''',
      metadata: dailyMeta,
    );
    await saveItem(noteToday);

    // 4. Observation
    final obsToday = Item(
      blockId: stoicismBlock.id,
      type: ItemType.observation,
      title: 'The cost of comparison',
      content: 'I noticed that whenever I browse social media before working, my baseline level of satisfaction drops and my work feels less meaningful. Comparison isn\'t just the thief of joy; it\'s the thief of focus.',
      metadata: dailyMeta,
    );
    await saveItem(obsToday);

    // 5. Idea
    final ideaToday = Item(
      blockId: designBlock.id,
      type: ItemType.idea,
      title: 'Products That Last',
      content: 'Most apps try to keep you inside them for as long as possible. What if we designed a tool that actively tries to get you to close it and return to reality as quickly as possible?',
      metadata: dailyMeta,
    );
    await saveItem(ideaToday);

    // ── GENERAL CAPABILITY DEMOS (Museum Pieces) ────────────────

    // Note: Building Knowledge Through Reflection
    final refNote = Item(
      blockId: modelsBlock.id,
      type: ItemType.note,
      title: 'Building Knowledge Through Reflection',
      content: '''# Building Knowledge Through Reflection

Information consumption is passive. Knowledge generation is active. 

Most people consume hundreds of hours of podcasts and books but retain almost nothing because they never stop to synthesize.

## The Synthesis Loop

1. **Capture**: Store raw insights.
2. **Distill**: Write it down in your own words.
3. **Reflect**: Connect the new insight to an existing mental model.

> "We do not learn from experience... we learn from reflecting on experience." — John Dewey

Without reflection, experience is just a series of events. With reflection, experience becomes wisdom.
''',
    );
    await saveItem(refNote);

    // ── EVOLUTIOS AND VERITAS (Timeline Demonstration) ────────────────

    // Day 1: Today (Evolutio Only)
    final day1 = DateTime.now();
    final evo1Ref = Reflection(itemId: noteToday.id, content: 'Dummy', createdAt: day1);
    await saveReflection(evo1Ref);
    final evo1 = Evolutio(
      reflectionId: evo1Ref.id,
      blockId: mathBlock.id,
      content: 'Expected Value changed how I evaluate risk.',
      createdAt: day1,
    );
    await saveEvolutio(evo1);

    // Day 2: Today - 3 Days (Evolutio + Veritas)
    final day2 = DateTime.now().subtract(const Duration(days: 3));
    final evo2Ref = Reflection(itemId: articleToday.id, content: 'I realized that focused work matters more than the number of hours.', createdAt: day2);
    await saveReflection(evo2Ref);
    final evo2 = Evolutio(
      reflectionId: evo2Ref.id,
      blockId: modelsBlock.id,
      content: 'Reading Deep Work changed how I study.',
      createdAt: day2,
    );
    await saveEvolutio(evo2);

    final veritas2 = Veritas(
      workspaceId: workspace.id,
      reason: 'I was mentally tired after college, but I still finished one article.',
      dateMissed: day2,
      createdAt: day2,
    );
    await saveVeritas(veritas2);

    // Day 3: Today - 8 Days (Veritas Only)
    final day3 = DateTime.now().subtract(const Duration(days: 8));
    final veritas3 = Veritas(
      workspaceId: workspace.id,
      reason: 'Semester exams took all of my attention this week. I\'ll continue once they\'re over.',
      dateMissed: day3,
      createdAt: day3,
    );
    await saveVeritas(veritas3);
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
    await _loadCollection('sources', _sources, (json) => KnowledgeSource.fromJson(json));
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
      try {
        await seedStarterWorkspace(defaultWorkspace);
      } catch (e, stack) {
        print('Starter workspace seed failed: $e');
        print(stack);
      }
    }
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

    await Future.wait([
      _saveToDisk('domains', _domains.map((k, v) => MapEntry(k, v.toJson()))),
      _saveToDisk('blocks', _blocks.map((k, v) => MapEntry(k, v.toJson()))),
      _saveToDisk('items', _items.map((k, v) => MapEntry(k, v.toJson()))),
      _saveToDisk('evolutios', _evolutios.map((k, v) => MapEntry(k, v.toJson()))),
      _saveToDisk('veritas', _veritas.map((k, v) => MapEntry(k, v.toJson()))),
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
