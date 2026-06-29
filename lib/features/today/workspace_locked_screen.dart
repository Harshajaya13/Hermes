import 'package:flutter/material.dart';
import '../../core/theme/hermes_theme.dart';
import 'workspace_security_dialogs.dart';

class WorkspaceLockedScreen extends StatelessWidget {
  const WorkspaceLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 64, color: HermesColors.textTertiary),
            const SizedBox(height: HermesSpacing.lg),
            Text('Workspace Locked', style: HermesTypography.screenTitle),
            const SizedBox(height: HermesSpacing.xl),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: HermesColors.accent, foregroundColor: Colors.white),
              onPressed: () {
                showDialog(context: context, builder: (_) => const UnlockWorkspaceDialog());
              },
              child: const Text('Unlock Workspace'),
            ),
          ],
        ),
      ),
    );
  }
}
