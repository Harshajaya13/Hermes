import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SEARCH SCREEN
/// ─────────────────────────────────────────────────────────────────────────────
/// Purpose: Find knowledge instantly.
/// Never: Require users to remember where something was stored.
///
/// Codex: "One search. Everything. Like Raycast."
/// Codex: "Searching should feel immediate."
///
/// Search spans: Questions · Articles · Reflections · Evolutios · Blocks
/// Feeling: Confidence.
/// ─────────────────────────────────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasQuery = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _hasQuery = _searchController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Spacing ─────────────────────────────────────────
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
                          onTap: () => _searchController.clear(),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH SUGGESTIONS (when empty)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSuggestions() {
    return HermesFadeIn(
      delay: const Duration(milliseconds: 80),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: HermesSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HermesSectionHeader(title: 'Recent'),
            const SizedBox(height: HermesSpacing.xs),
            _RecentItem(
              icon: Icons.help_outline_rounded,
              text: 'Expected value',
              type: 'Question',
              color: HermesColors.accent,
            ),
            _RecentItem(
              icon: Icons.article_outlined,
              text: 'Why Intuition Fails in Probability',
              type: 'Article',
              color: HermesColors.accentWarm,
            ),
            _RecentItem(
              icon: Icons.auto_awesome_outlined,
              text: 'Positioning matters more than features',
              type: 'Evolutio',
              color: HermesColors.evolutioGlow,
            ),

            const SizedBox(height: HermesSpacing.sectionGap),

            const HermesSectionHeader(title: 'Browse'),
            const SizedBox(height: HermesSpacing.xs),
            _BrowseCategory(
              icon: Icons.help_outline_rounded,
              label: 'All Questions',
              count: '47',
            ),
            _BrowseCategory(
              icon: Icons.article_outlined,
              label: 'All Articles',
              count: '23',
            ),
            _BrowseCategory(
              icon: Icons.auto_awesome_outlined,
              label: 'All Evolutios',
              count: '23',
            ),
            _BrowseCategory(
              icon: Icons.edit_note_rounded,
              label: 'All Reflections',
              count: '31',
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH RESULTS — Raycast-style grouped results
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildResults() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: HermesSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Questions
          const HermesSectionHeader(title: 'Questions'),
          _ResultItem(
            title:
                'How should I divide betting money across independent events?',
            subtitle: 'Mathematics · Probability',
            icon: Icons.help_outline_rounded,
            color: HermesColors.accent,
          ),
          _ResultItem(
            title:
                'A fair coin is flipped 3 times. What is the expected number of heads?',
            subtitle: 'Mathematics · Expected Value',
            icon: Icons.help_outline_rounded,
            color: HermesColors.accent,
          ),

          const SizedBox(height: HermesSpacing.lg),

          // Articles
          const HermesSectionHeader(title: 'Articles'),
          _ResultItem(
            title: 'Why Intuition Fails in Probability',
            subtitle: 'Medium · 8 min read',
            icon: Icons.article_outlined,
            color: HermesColors.accentWarm,
          ),

          const SizedBox(height: HermesSpacing.lg),

          // Reflections
          const HermesSectionHeader(title: 'Reflections'),
          _ResultItem(
            title:
                'Today I finally understood why expected value matters for real-world decisions...',
            subtitle: 'Mathematics · 2 days ago',
            icon: Icons.edit_note_rounded,
            color: HermesColors.reflectionColor,
          ),

          const SizedBox(height: HermesSpacing.lg),

          // Evolutios
          const HermesSectionHeader(title: 'Evolutios'),
          _ResultItem(
            title:
                'Expected value finally clicked — it\'s about the long-run average',
            subtitle: 'Mathematics · Today',
            icon: Icons.auto_awesome_outlined,
            color: HermesColors.evolutioGlow,
          ),

          const SizedBox(height: HermesSpacing.lg),

          // Blocks
          const HermesSectionHeader(title: 'Blocks'),
          _ResultItem(
            title: 'Mathematics',
            subtitle: 'Engineering · 24 items',
            icon: Icons.grid_view_rounded,
            color: HermesColors.accent,
          ),

          const SizedBox(height: HermesSpacing.xxxl),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RECENT ITEM
// ═══════════════════════════════════════════════════════════════════════════════

class _RecentItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String type;
  final Color color;

  const _RecentItem({
    required this.icon,
    required this.text,
    required this.type,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to item
        },
        borderRadius: BorderRadius.circular(HermesRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: HermesSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color.withValues(alpha: 0.5),
              ),
              const SizedBox(width: HermesSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: HermesTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                type,
                style: HermesTypography.metadata.copyWith(
                  color: color.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BROWSE CATEGORY
// ═══════════════════════════════════════════════════════════════════════════════

class _BrowseCategory extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;

  const _BrowseCategory({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Browse category
        },
        borderRadius: BorderRadius.circular(HermesRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: HermesSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: HermesColors.textTertiary,
              ),
              const SizedBox(width: HermesSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: HermesTypography.bodySmall,
                ),
              ),
              Text(
                count,
                style: HermesTypography.metadata,
              ),
              const SizedBox(width: HermesSpacing.xxs),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: HermesColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEARCH RESULT ITEM
// ═══════════════════════════════════════════════════════════════════════════════

class _ResultItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ResultItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to result
        },
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
