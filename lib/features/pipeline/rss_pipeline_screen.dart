import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';

class RssPipelineScreen extends ConsumerWidget {
  const RssPipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RSS Feeds', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.screenHorizontal, vertical: HermesSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manage Feeds', style: HermesTypography.sectionTitle),
              const SizedBox(height: HermesSpacing.xs),
              Text('Add your favorite blogs, newsletters, or journals.', style: HermesTypography.metadata),
              const SizedBox(height: HermesSpacing.xl),
              // Placeholder for upcoming pipeline workflow
              HermesCard(
                child: Padding(
                  padding: const EdgeInsets.all(HermesSpacing.lg),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.build_circle_outlined, size: 48, color: HermesColors.textTertiary),
                        const SizedBox(height: HermesSpacing.md),
                        Text('Pipeline Under Construction', style: HermesTypography.body),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
