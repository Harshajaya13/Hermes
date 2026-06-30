import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import 'edit_identity_dialog.dart';
import 'workspace_management_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pipeline/pipeline.dart';
import 'package_screens.dart';

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
              
              _buildSectionHeader('Knowledge Sources'),
              _buildKnowledgeSourcesSection(context, ref, workspace),
              const SizedBox(height: HermesSpacing.xxl),
              
              _buildSectionHeader('Appearance'),
              _buildAppearanceSection(context, ref),
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
                Icon(Icons.format_quote_rounded, color: HermesColors.textTertiary.withValues(alpha: 0.5), size: 16),
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
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const RenameWorkspaceDialog(),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.swap_horiz_rounded,
            title: 'Switch Workspace',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const SwitchWorkspaceDialog(),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.add_circle_outline,
            title: 'Create New Workspace',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const CreateWorkspaceDialog(),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.unarchive_outlined,
            title: 'Import .hermes Package',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportPackageScreen()));
            },
          ),
          _buildSettingsTile(
            icon: Icons.archive_outlined,
            title: 'Export Workspace',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportPackageScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeSourcesSection(BuildContext context, WidgetRef ref, Workspace? ws) {
    if (ws == null) return const SizedBox.shrink();

    return HermesCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.pan_tool_alt_rounded,
            title: 'Manual Collection',
            subtitle: 'Import JSON, specify limits, assign to Blocks.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManualPipelineScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.group_outlined,
            title: 'Community Collection',
            subtitle: 'Browse and subscribe to AI/community topics.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AutomatedPipelineScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.rss_feed_rounded,
            title: 'RSS Feeds',
            subtitle: 'Add blogs, journals, and newsletters.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RssPipelineScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceProvider);
    
    return HermesCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.format_size_rounded, 
            title: 'Font Size', 
            subtitle: appearance.fontSize, 
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: HermesColors.surfaceElevated,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
                builder: (_) => _buildOptionSheet(
                  context, ref,
                  'Font Size',
                  ['Small', 'Medium', 'Large'],
                  appearance.fontSize,
                  (val) => ref.read(appearanceProvider.notifier).updateAppearance(appearance.copyWith(fontSize: val)),
                ),
              );
            }
          ),
          _buildSettingsTile(
            icon: Icons.view_compact_alt_outlined, 
            title: 'Visual Density', 
            subtitle: appearance.visualDensity, 
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: HermesColors.surfaceElevated,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
                builder: (_) => _buildOptionSheet(
                  context, ref,
                  'Visual Density',
                  ['Comfortable', 'Compact'],
                  appearance.visualDensity,
                  (val) => ref.read(appearanceProvider.notifier).updateAppearance(appearance.copyWith(visualDensity: val)),
                ),
              );
            }
          ),
          _buildSettingsTile(
            icon: Icons.animation_rounded, 
            title: 'Motion Preferences', 
            subtitle: appearance.reducedMotion ? 'Reduced Motion' : 'Normal Motion', 
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: HermesColors.surfaceElevated,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl))),
                builder: (_) => _buildOptionSheet(
                  context, ref,
                  'Motion Preferences',
                  ['Normal Motion', 'Reduced Motion'],
                  appearance.reducedMotion ? 'Reduced Motion' : 'Normal Motion',
                  (val) => ref.read(appearanceProvider.notifier).updateAppearance(appearance.copyWith(reducedMotion: val == 'Reduced Motion')),
                ),
              );
            }
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined, 
            title: 'OLED Black', 
            trailing: Switch(
              value: appearance.oledBlack,
              activeColor: HermesColors.evolutioGlow,
              onChanged: (val) {
                ref.read(appearanceProvider.notifier).updateAppearance(appearance.copyWith(oledBlack: val));
              },
            ),
            onTap: () {
              ref.read(appearanceProvider.notifier).updateAppearance(appearance.copyWith(oledBlack: !appearance.oledBlack));
            }
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSheet(BuildContext context, WidgetRef ref, String title, List<String> options, String currentValue, Function(String) onSelect) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: HermesSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg),
              child: Text(title, style: HermesTypography.sectionTitle),
            ),
            const SizedBox(height: HermesSpacing.md),
            ...options.map((option) {
              final isSelected = option == currentValue;
              return ListTile(
                title: Text(option, style: HermesTypography.body),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: HermesColors.evolutioGlow) : null,
                onTap: () {
                  onSelect(option);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: HermesSpacing.md),
          ],
        ),
      ),
    );
  }


  Widget _buildAboutSection() {
    return HermesCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.rocket_launch_outlined, 
            title: 'About Hermes', 
            subtitle: 'The philosophy and purpose', 
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('About Hermes', style: HermesTypography.sectionTitle),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('What is Hermes?', style: HermesTypography.itemTitle),
                        const SizedBox(height: 4),
                        Text('A Personal Development Operating System built for deliberate growth.', style: HermesTypography.bodySmall),
                        const SizedBox(height: 16),
                        
                        Text('Why it exists', style: HermesTypography.itemTitle),
                        const SizedBox(height: 4),
                        Text('Because completion is not understanding. Hermes exists to preserve the moments in which knowledge changes the person who possesses it.', style: HermesTypography.bodySmall),
                        const SizedBox(height: 16),
                        
                        Text('The Growth Model', style: HermesTypography.itemTitle),
                        const SizedBox(height: 4),
                        Text('Experience → Reflection → Insight → Evolutio → Evolution', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        
                        Text('Veritas', style: HermesTypography.itemTitle),
                        const SizedBox(height: 4),
                        Text('The Latin word for truth. Guilt-driven productivity fails. Veritas is the mechanism for recording reality without judgment when life interrupts your pursuits.', style: HermesTypography.bodySmall),
                        const SizedBox(height: 16),
                        
                        Text('Evolutio', style: HermesTypography.itemTitle),
                        const SizedBox(height: 4),
                        Text('The atomic unit of growth. A documented, permanent cognitive shift. We measure changed thinking, not completed tasks.', style: HermesTypography.bodySmall),
                        const SizedBox(height: 16),
                        
                        Text('Offline-First Philosophy', style: HermesTypography.itemTitle),
                        const SizedBox(height: 4),
                        Text('Personal knowledge is the most intimate data you possess. Hermes uses local databases and plain Markdown so you physically own your thinking forever.', style: HermesTypography.bodySmall),
                        const SizedBox(height: 16),
                        
                        Text('The Architect & Code', style: HermesTypography.itemTitle),
                        const SizedBox(height: 4),
                        Text('Built intentionally by Harshajaya13.\ngithub.com/Harshajaya13/Hermes', style: HermesTypography.bodySmall),
                        const SizedBox(height: 16),
                        
                        Text('Version & License', style: HermesTypography.itemTitle),
                        const SizedBox(height: 4),
                        Text('v3.0.0 (Constellation) | MIT License FOSS', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textTertiary)),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
          _buildSettingsTile(
            icon: Icons.history_rounded, 
            title: 'Changelog', 
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: HermesColors.surfaceElevated,
                  title: Text('v3.0 Constellation', style: HermesTypography.sectionTitle),
                  content: Text('• Native .hitem OS Sharing\n• Finalized Reader Engine\n• Rewritten Founding Manifesto\n• Upgraded to OLED Themes', style: HermesTypography.body),
                ),
              );
            }
          ),
          _buildSettingsTile(
            icon: Icons.code_rounded,
            title: 'Developer',
            subtitle: 'github.com/Harshajaya13',
            onTap: () async {
              final url = Uri.parse('https://github.com/Harshajaya13');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
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
