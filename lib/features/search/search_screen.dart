import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../reader/hermes_reader_screen.dart';
import '../blocks/block_detail_screen.dart';
import '../blocks/domain_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasQuery = false;
  
  List<Item> _questionResults = [];
  List<Item> _articleResults = [];
  List<Item> _ideaResults = [];
  List<Item> _observationResults = [];
  List<Reflection> _reflectionResults = [];
  List<Evolutio> _evolutioResults = [];
  List<Block> _blockResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _hasQuery = false;
        _clearResults();
      });
      return;
    }
    
    final storage = ref.read(storageEngineProvider);
    
    // Compute Results
    final blocks = storage.getAllBlocks()
        .where((b) => b.name.toLowerCase().contains(query))
        .toList();
        
    final items = storage.getAllItems()
        .where((i) => i.title.toLowerCase().contains(query) || i.content.toLowerCase().contains(query))
        .toList();
        
    final reflections = storage.getAllReflections()
        .where((r) => r.content.toLowerCase().contains(query))
        .toList();
        
    final evolutios = storage.getEvolutios()
        .where((e) => e.content.toLowerCase().contains(query))
        .toList();

    setState(() {
      _hasQuery = true;
      _blockResults = blocks;
      _questionResults = items.where((i) => i.type == ItemType.question).toList();
      _articleResults = items.where((i) => i.type == ItemType.article).toList();
      _ideaResults = items.where((i) => i.type == ItemType.idea).toList();
      _observationResults = items.where((i) => i.type == ItemType.observation).toList();
      _reflectionResults = reflections;
      _evolutioResults = evolutios;
    });
  }
  
  void _clearResults() {
    _questionResults.clear();
    _articleResults.clear();
    _ideaResults.clear();
    _observationResults.clear();
    _reflectionResults.clear();
    _evolutioResults.clear();
    _blockResults.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: HermesSpacing.xl),

            // ── Search Bar ──────────────────────────────────────────
            HermesFadeIn(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HermesSpacing.screenHorizontal,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: HermesColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(HermesRadius.md),
                    border: Border.all(
                      color: HermesColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: HermesColors.textTertiary,
                      ),
                      const SizedBox(width: HermesSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: HermesTypography.body.copyWith(
                            color: HermesColors.textPrimary,
                          ),
                          cursorColor: HermesColors.accent,
                          decoration: InputDecoration(
                            hintText: 'Search everything...',
                            hintStyle: HermesTypography.body.copyWith(
                              color: HermesColors.textDisabled,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: HermesSpacing.md,
                            ),
                          ),
                        ),
                      ),
                      if (_hasQuery)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: HermesColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: HermesSpacing.lg),

            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: _hasQuery ? _buildResults() : _buildSuggestions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return HermesFadeIn(
      delay: const Duration(milliseconds: 80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.manage_search_rounded,
              size: 48,
              color: HermesColors.surfaceElevated,
            ),
            const SizedBox(height: HermesSpacing.md),
            Text(
              'Find knowledge instantly.',
              style: HermesTypography.metadata,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final hasResults = _questionResults.isNotEmpty || 
                       _articleResults.isNotEmpty || 
                       _ideaResults.isNotEmpty ||
                       _observationResults.isNotEmpty ||
                       _reflectionResults.isNotEmpty || 
                       _evolutioResults.isNotEmpty || 
                       _blockResults.isNotEmpty;

    if (!hasResults) {
      return Center(
        child: Text(
          'No results found.',
          style: HermesTypography.metadata,
        ),
      );
    }

    final storage = ref.read(storageEngineProvider);
    final allBlocks = storage.getAllBlocks();
    final allItems = storage.getAllItems();
    final allReflections = storage.getAllReflections();

    void navigateToItem(Item item) {
      final block = allBlocks.where((b) => b.id == item.blockId).firstOrNull;
      if (block != null) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => HermesReaderScreen(item: item, block: block),
        ));
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: HermesSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_questionResults.isNotEmpty) ...[
            const HermesSectionHeader(title: 'Questions'),
            ..._questionResults.map((q) => _ResultItem(
              title: q.title,
              subtitle: 'Question',
              icon: Icons.help_outline_rounded,
              color: HermesColors.accent,
              onTap: () => navigateToItem(q),
            )),
            const SizedBox(height: HermesSpacing.lg),
          ],

          if (_articleResults.isNotEmpty) ...[
            const HermesSectionHeader(title: 'Articles'),
            ..._articleResults.map((a) => _ResultItem(
              title: a.title,
              subtitle: 'Article',
              icon: Icons.article_outlined,
              color: HermesColors.accentWarm,
              onTap: () => navigateToItem(a),
            )),
            const SizedBox(height: HermesSpacing.lg),
          ],

          if (_ideaResults.isNotEmpty) ...[
            const HermesSectionHeader(title: 'Ideas'),
            ..._ideaResults.map((i) => _ResultItem(
              title: i.title,
              subtitle: 'Idea',
              icon: Icons.lightbulb_outline_rounded,
              color: HermesColors.accentWarm,
              onTap: () => navigateToItem(i),
            )),
            const SizedBox(height: HermesSpacing.lg),
          ],

          if (_observationResults.isNotEmpty) ...[
            const HermesSectionHeader(title: 'Observations'),
            ..._observationResults.map((o) => _ResultItem(
              title: o.title,
              subtitle: 'Observation',
              icon: Icons.visibility_outlined,
              color: HermesColors.textTertiary,
              onTap: () => navigateToItem(o),
            )),
            const SizedBox(height: HermesSpacing.lg),
          ],

          if (_reflectionResults.isNotEmpty) ...[
            const HermesSectionHeader(title: 'Reflections'),
            ..._reflectionResults.map((r) {
              return _ResultItem(
                title: r.content,
                subtitle: 'Reflection',
                icon: Icons.edit_note_rounded,
                color: HermesColors.reflectionColor,
                onTap: () {
                  final item = allItems.where((i) => i.id == r.itemId).firstOrNull;
                  if (item != null) navigateToItem(item);
                },
              );
            }),
            const SizedBox(height: HermesSpacing.lg),
          ],

          if (_evolutioResults.isNotEmpty) ...[
            const HermesSectionHeader(title: 'Evolutios'),
            ..._evolutioResults.map((e) {
              return _ResultItem(
                title: e.content,
                subtitle: 'Evolutio',
                icon: Icons.auto_awesome_outlined,
                color: HermesColors.evolutioGlow,
                onTap: () {
                  final reflection = allReflections.where((r) => r.id == e.reflectionId).firstOrNull;
                  if (reflection != null) {
                    final item = allItems.where((i) => i.id == reflection.itemId).firstOrNull;
                    if (item != null) navigateToItem(item);
                  }
                },
              );
            }),
            const SizedBox(height: HermesSpacing.lg),
          ],

          if (_blockResults.isNotEmpty) ...[
            const HermesSectionHeader(title: 'Blocks'),
            ..._blockResults.map((b) => _ResultItem(
              title: b.name,
              subtitle: 'Block',
              icon: Icons.grid_view_rounded,
              color: HermesColors.accent,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => BlockDetailScreen(block: b),
                ));
              },
            )),
            const SizedBox(height: HermesSpacing.lg),
          ],
          
          const SizedBox(height: HermesSpacing.xxxl),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ResultItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HermesRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: HermesSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  icon,
                  size: 18,
                  color: color.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: HermesSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: HermesTypography.itemTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: HermesTypography.metadata,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
