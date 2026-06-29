import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/hermes_theme.dart';
import 'features/today/today_screen.dart';
import 'features/blocks/blocks_screen.dart';
import 'features/evolution/evolution_screen.dart';
import 'features/search/search_screen.dart';
import 'features/workspace/control_center_screen.dart';
import 'features/today/workspace_locked_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Hermes — Personal Development Operating System
/// ─────────────────────────────────────────────────────────────────────────────
/// "How do I deliberately become the person I want to become?"
///
/// Nothing enters Hermes accidentally.
/// Everything inside Hermes exists because the user deliberately chose it
/// to become part of their journey.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/engines/local_storage_engine.dart';
import 'core/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageEngine = LocalStorageEngine();
  await storageEngine.initialize();

  // OLED-optimized system chrome
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: HermesColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        storageEngineProvider.overrideWithValue(storageEngine),
      ],
      child: const HermesApp(),
    ),
  );
}

class HermesApp extends StatelessWidget {
  const HermesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hermes',
      debugShowCheckedModeBanner: false,
      theme: buildHermesTheme(),
      home: const HermesShell(),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// App Shell — Bottom Navigation (Codex: "Tabs" for clear navigation)
/// ─────────────────────────────────────────────────────────────────────────────
/// Codex Navigation Philosophy:
/// "Showing the user which navigation they are on."
///
/// 4 tabs — Today · Blocks · Evolution · Search
/// One purpose per screen. Never overwhelm.
/// ─────────────────────────────────────────────────────────────────────────────

class HermesShell extends ConsumerStatefulWidget {
  const HermesShell({super.key});

  @override
  ConsumerState<HermesShell> createState() => _HermesShellState();
}

class _HermesShellState extends ConsumerState<HermesShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TodayScreen(),
    BlocksScreen(),
    EvolutionScreen(),
    SearchScreen(),
    ControlCenterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(workspaceLockedProvider);
    if (isLocked) {
      return const WorkspaceLockedScreen();
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: HermesDurations.normal,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: HermesColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: HermesSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.wb_sunny_outlined,
                activeIcon: Icons.wb_sunny_rounded,
                label: 'Today',
                isActive: _currentIndex == 0,
                onTap: () => _switchTab(0),
              ),
              _NavItem(
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Domains',
                isActive: _currentIndex == 1,
                onTap: () => _switchTab(1),
              ),
              _NavItem(
                icon: Icons.timeline_outlined,
                activeIcon: Icons.timeline_rounded,
                label: 'Evolution',
                isActive: _currentIndex == 2,
                onTap: () => _switchTab(2),
              ),
              _NavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: 'Search',
                isActive: _currentIndex == 3,
                onTap: () => _switchTab(3),
              ),
              _NavItem(
                icon: Icons.tune_outlined,
                activeIcon: Icons.tune_rounded,
                label: 'Control',
                isActive: _currentIndex == 4,
                onTap: () => _switchTab(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _switchTab(int index) {
    if (index != _currentIndex) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUSTOM NAV ITEM — Minimal, calm, clear
// ═══════════════════════════════════════════════════════════════════════════════

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: HermesDurations.fast,
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive
                    ? HermesColors.textPrimary
                    : HermesColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: HermesTypography.tabLabel.copyWith(
                color: isActive
                    ? HermesColors.textPrimary
                    : HermesColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
