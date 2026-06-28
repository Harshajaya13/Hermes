import 'package:flutter/material.dart';
import '../theme/hermes_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Shared Hermes Widgets
/// ─────────────────────────────────────────────────────────────────────────────
/// Codex: "Every button behaves the same. Every dialog looks the same.
///         Every list scrolls the same. Consistency builds trust."
/// ─────────────────────────────────────────────────────────────────────────────

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class HermesSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const HermesSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HermesSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: HermesTypography.sectionTitle,
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HERMES CARD — Lightweight, one clear purpose
// ═══════════════════════════════════════════════════════════════════════════════

class HermesCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;

  const HermesCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HermesColors.surfaceElevated,
      borderRadius: BorderRadius.circular(HermesRadius.md),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(HermesRadius.md),
        splashColor: HermesColors.accent.withValues(alpha: 0.06),
        highlightColor: HermesColors.accent.withValues(alpha: 0.03),
        child: Padding(
          padding: padding ??
              const EdgeInsets.all(HermesSpacing.cardPadding),
          child: child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BLOCK CHIP — The mini Block indicator for Today screen
// ═══════════════════════════════════════════════════════════════════════════════

class HermesBlockChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const HermesBlockChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(HermesRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HermesRadius.md),
        splashColor: color.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HermesSpacing.md,
            vertical: HermesSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: HermesSpacing.xs),
              Text(
                label,
                style: HermesTypography.bodySmall.copyWith(
                  color: color.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
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
// HERMES LIST TILE — Calm, breathable rows
// ═══════════════════════════════════════════════════════════════════════════════

class HermesListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const HermesListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HermesRadius.sm),
        splashColor: HermesColors.accent.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: HermesSpacing.sm,
            horizontal: HermesSpacing.xxs,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: HermesSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: HermesTypography.itemTitle),
                    if (subtitle != null) ...[
                      const SizedBox(height: HermesSpacing.xxs),
                      Text(subtitle!, style: HermesTypography.metadata),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HERMES DIVIDER — Intentional breathing space
// ═══════════════════════════════════════════════════════════════════════════════

class HermesDivider extends StatelessWidget {
  const HermesDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: HermesColors.divider,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE — Codex: "Empty states should educate, never punish."
// ═══════════════════════════════════════════════════════════════════════════════

class HermesEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const HermesEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HermesSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 48,
                color: HermesColors.textDisabled,
              ),
            if (icon != null) const SizedBox(height: HermesSpacing.lg),
            Text(
              title,
              style: HermesTypography.blockTitle.copyWith(
                color: HermesColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HermesSpacing.xs),
            Text(
              subtitle,
              style: HermesTypography.bodySmall.copyWith(
                color: HermesColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: HermesSpacing.lg),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: HermesColors.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: HermesSpacing.lg,
                    vertical: HermesSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HermesRadius.pill),
                    side: BorderSide(
                      color: HermesColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Text(actionLabel!, style: HermesTypography.button),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FADE-IN WRAPPER — Calm entrance animations
// ═══════════════════════════════════════════════════════════════════════════════

class HermesFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const HermesFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<HermesFadeIn> createState() => _HermesFadeInState();
}

class _HermesFadeInState extends State<HermesFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HERMES ICON BADGE — Block icon with color background
// ═══════════════════════════════════════════════════════════════════════════════

class HermesIconBadge extends StatelessWidget {
  final String emoji;
  final Color color;
  final double size;

  const HermesIconBadge({
    super.key,
    required this.emoji,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(HermesRadius.sm),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.45),
        ),
      ),
    );
  }
}
