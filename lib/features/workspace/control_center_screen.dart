import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../today/workspace_security_dialogs.dart';
import '../today/visibility_screen.dart';
import '../archive/archive_screen.dart';
import 'edit_identity_dialog.dart';

class ControlCenterScreen extends ConsumerStatefulWidget {
  const ControlCenterScreen({super.key});

  @override
  ConsumerState<ControlCenterScreen> createState() => _ControlCenterScreenState();
}

class _ControlCenterScreenState extends ConsumerState<ControlCenterScreen> {
  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(currentWorkspaceProvider);
    final isLocked = ref.watch(workspaceLockedProvider);
    
    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        title: Text('Control Center', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: HermesSpacing.screenHorizontal,
            vertical: HermesSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIdentitySection(context, ref, workspace),
              const SizedBox(height: HermesSpacing.xxl),
              
              _buildSectionHeader('Workspace'),
              _buildWorkspaceSection(context, ref, workspace, isLocked),
              const SizedBox(height: HermesSpacing.xxl),
              
              _buildSectionHeader('Data Pipeline'),
              _buildDataPipelineSection(),
              const SizedBox(height: HermesSpacing.xxl),
              
              _buildSectionHeader('Appearance'),
              _buildAppearanceSection(),
              const SizedBox(height: HermesSpacing.xxl),
              

              
              _buildSectionHeader('About'),
              _buildAboutSection(),
              
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HermesSpacing.md),
      child: Text(
        title.toUpperCase(),
        style: HermesTypography.metadata.copyWith(
          color: HermesColors.textSecondary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIdentitySection(BuildContext context, WidgetRef ref, Workspace? workspace) {
    final ownerName = workspace?.ownerName?.isNotEmpty == true ? workspace!.ownerName! : 'The Architect';
    final ownerNickname = workspace?.ownerNickname?.isNotEmpty == true ? workspace!.ownerNickname! : 'Anonymous';
    final lore = workspace?.lore?.isNotEmpty == true ? workspace!.lore! : 'Deliberately becoming who I want to become.';
    
    return HermesCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: HermesSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: HermesColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: HermesColors.border),
                  ),
                  child: Center(
                    child: Text(workspace?.icon ?? '🙂', style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: HermesSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ownerName, style: HermesTypography.sectionTitle.copyWith(fontSize: 22)),
                      Text(ownerNickname, style: HermesTypography.metadata.copyWith(color: HermesColors.evolutioGlow)),
                      const SizedBox(height: 4),
                      Text(workspace?.name ?? 'Personal Workspace', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: HermesColors.textTertiary, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const EditIdentityDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: HermesSpacing.lg),
            const Divider(color: HermesColors.border),
            const SizedBox(height: HermesSpacing.md),
            Row(
              children: [
                Icon(Icons.format_quote_rounded, color: HermesColors.textTertiary.withOpacity(0.5), size: 16),
                const SizedBox(width: HermesSpacing.sm),
                Expanded(
                  child: Text(
                    lore,
                    style: HermesTypography.bodySmall.copyWith(
                      color: HermesColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceSection(BuildContext context, WidgetRef ref, Workspace? ws, bool isLocked) {
    return HermesCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.edit_outlined,
            title: 'Rename Workspace',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.swap_horiz_rounded,
            title: 'Switch Workspace',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workspace switching coming soon')));
            },
          ),
          _buildSettingsTile(
            icon: Icons.add_circle_outline,
            title: 'Create New Workspace',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workspace creation coming soon')));
            },
          ),
          const Divider(color: HermesColors.border, height: 1),
          _buildSettingsTile(
            icon: Icons.archive_outlined,
            title: 'Archive Workspace',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: 'Delete Workspace',
            textColor: HermesColors.error,
            iconColor: HermesColors.error,
            onTap: () {},
          ),
          const Divider(color: HermesColors.border, height: 1),
          _buildSettingsTile(
            icon: Icons.download_rounded,
            title: 'Import Workspace (.hermes)',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.upload_rounded,
            title: 'Export Workspace (.hermes)',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDataPipelineSection() {
    return HermesCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.pan_tool_alt_rounded,
            title: 'Manual Mode',
            subtitle: 'You add everything manually.',
            trailing: const Icon(Icons.check_circle_rounded, color: HermesColors.evolutioGlow, size: 20),
            onTap: () {},
          ),
          const Divider(color: HermesColors.border, height: 1),
          _buildSettingsTile(
            icon: Icons.auto_awesome_rounded,
            title: 'Automated Mode',
            subtitle: 'Automatically import content based on sources.',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.rss_feed_rounded,
            title: 'Manage Integrations',
            subtitle: 'RSS, GitHub, Dev.to, Wikipedia...',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return HermesCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(icon: Icons.color_lens_outlined, title: 'Theme', subtitle: 'Dark', onTap: () {}),
          _buildSettingsTile(icon: Icons.format_paint_outlined, title: 'Accent Color', subtitle: 'Green', onTap: () {}),
          _buildSettingsTile(icon: Icons.dark_mode_outlined, title: 'OLED Mode', trailing: const Icon(Icons.toggle_off, color: HermesColors.textTertiary, size: 36), onTap: () {}),
          _buildSettingsTile(icon: Icons.view_compact_alt_outlined, title: 'Compact Mode', trailing: const Icon(Icons.toggle_off, color: HermesColors.textTertiary, size: 36), onTap: () {}),
          _buildSettingsTile(icon: Icons.format_size_rounded, title: 'Font Size', subtitle: 'Medium', onTap: () {}),
        ],
      ),
    );
  }


  Widget _buildAboutSection() {
    return HermesCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(icon: Icons.info_outline, title: 'Version', subtitle: '1.0.0 (Codex)', onTap: () {}),
          _buildSettingsTile(icon: Icons.gavel_rounded, title: 'License', subtitle: 'FOSS (MIT)', onTap: () {}),
          _buildSettingsTile(icon: Icons.menu_book_rounded, title: 'Hermes Codex', onTap: () {}),
          _buildSettingsTile(icon: Icons.history_rounded, title: 'Changelog', onTap: () {}),
          _buildSettingsTile(icon: Icons.group_outlined, title: 'Contributors', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    Color? iconColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(HermesRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg, vertical: HermesSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? HermesColors.textTertiary, size: 22),
            const SizedBox(width: HermesSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: HermesTypography.body.copyWith(color: textColor ?? HermesColors.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: HermesTypography.metadata),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing else const Icon(Icons.chevron_right_rounded, color: HermesColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
