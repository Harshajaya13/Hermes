import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/models/workspace.dart';
import '../../core/providers/providers.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../core/engines/local_storage_engine.dart';

String _hashString(String input) {
  return sha256.convert(utf8.encode(input)).toString();
}

// ── 1. Setup Lock Dialog (Initial Setup Only) ───────────────

class SetupLockDialog extends ConsumerStatefulWidget {
  const SetupLockDialog({super.key});

  @override
  ConsumerState<SetupLockDialog> createState() => _SetupLockDialogState();
}

class _SetupLockDialogState extends ConsumerState<SetupLockDialog> {
  final _pinController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  bool _isSettingUp = false;

  @override
  void dispose() {
    _pinController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pin = _pinController.text.trim();
    final question = _questionController.text.trim();
    final answer = _answerController.text.trim();

    if (pin.isEmpty || question.isEmpty || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are mandatory')));
      return;
    }

    setState(() => _isSettingUp = true);

    final ws = ref.read(currentWorkspaceProvider);
    if (ws != null) {
      final updated = ws.copyWith(
        pin: _hashString(pin),
        securityQuestion: question,
        securityAnswer: _hashString(answer.toLowerCase()),
        isEncrypted: true,
      );
      await ref.read(storageEngineProvider).saveWorkspace(updated);
      ref.read(currentWorkspaceProvider.notifier).updateWorkspace(updated);
      ref.read(workspaceLockedProvider.notifier).setLocked(true);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HermesColors.surfaceElevated,
      title: Text('Setup Workspace Lock', style: HermesTypography.itemTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set PIN', style: HermesTypography.metadata),
            SizedBox(height: HermesSpacing.xs),
            TextField(
              controller: _pinController,
              obscureText: true,
              style: HermesTypography.body,
              decoration: InputDecoration(
                hintText: 'Enter PIN',
                hintStyle: HermesTypography.metadata,
                filled: true,
                fillColor: HermesColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: HermesSpacing.md),
            Text('Recovery Question (Mandatory)', style: HermesTypography.metadata),
            SizedBox(height: HermesSpacing.xs),
            TextField(
              controller: _questionController,
              style: HermesTypography.body,
              decoration: InputDecoration(
                hintText: 'e.g. First pet name?',
                hintStyle: HermesTypography.metadata,
                filled: true,
                fillColor: HermesColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: HermesSpacing.sm),
            TextField(
              controller: _answerController,
              obscureText: true,
              style: HermesTypography.body,
              decoration: InputDecoration(
                hintText: 'Answer',
                hintStyle: HermesTypography.metadata,
                filled: true,
                fillColor: HermesColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSettingUp ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: HermesColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: HermesColors.veritasColor, foregroundColor: Colors.white),
          onPressed: _isSettingUp ? null : _save,
          child: _isSettingUp ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Lock Workspace'),
        ),
      ],
    );
  }
}

// ── 2. Verify PIN Dialog (For Settings) ─────────────────────

class VerifyPinDialog extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const VerifyPinDialog({super.key, required this.onSuccess});

  @override
  ConsumerState<VerifyPinDialog> createState() => _VerifyPinDialogState();
}

class _VerifyPinDialogState extends ConsumerState<VerifyPinDialog> {
  final _pinController = TextEditingController();
  bool _error = false;

  void _verify() {
    final pin = _pinController.text.trim();
    final ws = ref.read(currentWorkspaceProvider);
    if (ws?.pin == _hashString(pin)) {
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      setState(() {
        _error = true;
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HermesColors.surfaceElevated,
      title: Text('Verify Current PIN', style: HermesTypography.itemTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            obscureText: true,
            autofocus: true,
            style: HermesTypography.body,
            decoration: InputDecoration(
              hintText: 'Enter Current PIN',
              hintStyle: HermesTypography.metadata,
              filled: true,
              fillColor: HermesColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
            onSubmitted: (_) => _verify(),
          ),
          if (_error)
            Padding(
              padding: EdgeInsets.only(top: HermesSpacing.xs),
              child: Text('Incorrect PIN', style: HermesTypography.metadata.copyWith(color: Colors.redAccent)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: HermesColors.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: HermesColors.accent, foregroundColor: Colors.white),
          onPressed: _verify,
          child: const Text('Verify'),
        ),
      ],
    );
  }
}

// ── 3. Change PIN Dialog (After Verification) ───────────────

class ChangePinDialog extends ConsumerStatefulWidget {
  const ChangePinDialog({super.key});

  @override
  ConsumerState<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends ConsumerState<ChangePinDialog> {
  final _pinController = TextEditingController();

  void _save() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    final ws = ref.read(currentWorkspaceProvider);
    if (ws != null) {
      final updated = ws.copyWith(pin: _hashString(pin));
      await ref.read(storageEngineProvider).saveWorkspace(updated);
      ref.read(currentWorkspaceProvider.notifier).updateWorkspace(updated);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HermesColors.surfaceElevated,
      title: Text('Change PIN', style: HermesTypography.itemTitle),
      content: TextField(
        controller: _pinController,
        obscureText: true,
        autofocus: true,
        style: HermesTypography.body,
        decoration: InputDecoration(
          hintText: 'Enter New PIN',
          hintStyle: HermesTypography.metadata,
          filled: true,
          fillColor: HermesColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
        ),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: HermesColors.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: HermesColors.accent, foregroundColor: Colors.white),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ── 4. Change Recovery Question Dialog ──────────────────────

class ChangeRecoveryQuestionDialog extends ConsumerStatefulWidget {
  const ChangeRecoveryQuestionDialog({super.key});

  @override
  ConsumerState<ChangeRecoveryQuestionDialog> createState() => _ChangeRecoveryQuestionDialogState();
}

class _ChangeRecoveryQuestionDialogState extends ConsumerState<ChangeRecoveryQuestionDialog> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  void _save() async {
    final q = _questionController.text.trim();
    final a = _answerController.text.trim();
    if (q.isEmpty || a.isEmpty) return;

    final ws = ref.read(currentWorkspaceProvider);
    if (ws != null) {
      final updated = ws.copyWith(securityQuestion: q, securityAnswer: _hashString(a.toLowerCase()));
      await ref.read(storageEngineProvider).saveWorkspace(updated);
      ref.read(currentWorkspaceProvider.notifier).updateWorkspace(updated);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HermesColors.surfaceElevated,
      title: Text('Change Recovery Question', style: HermesTypography.itemTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _questionController,
            autofocus: true,
            style: HermesTypography.body,
            decoration: InputDecoration(
              hintText: 'New Question',
              hintStyle: HermesTypography.metadata,
              filled: true,
              fillColor: HermesColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: HermesSpacing.sm),
          TextField(
            controller: _answerController,
            obscureText: true,
            style: HermesTypography.body,
            decoration: InputDecoration(
              hintText: 'Answer',
              hintStyle: HermesTypography.metadata,
              filled: true,
              fillColor: HermesColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: HermesColors.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: HermesColors.accent, foregroundColor: Colors.white),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ── 5. Normal Unlock Dialog ─────────────────────────────────

class UnlockWorkspaceDialog extends ConsumerStatefulWidget {
  const UnlockWorkspaceDialog({super.key});

  @override
  ConsumerState<UnlockWorkspaceDialog> createState() => _UnlockWorkspaceDialogState();
}

class _UnlockWorkspaceDialogState extends ConsumerState<UnlockWorkspaceDialog> {
  final _pinController = TextEditingController();
  int _failedAttempts = 0;
  bool _isLockedOut = false;

  void _verify() {
    final pin = _pinController.text.trim();
    final ws = ref.read(currentWorkspaceProvider);
    if (ws?.pin == _hashString(pin) || ws?.pin == null) {
      ref.read(workspaceLockedProvider.notifier).setLocked(false);
      Navigator.pop(context);
    } else {
      setState(() {
        _failedAttempts++;
        _pinController.clear();
        if (_failedAttempts >= 3) _isLockedOut = true;
      });
    }
  }

  void _showRecovery() {
    Navigator.pop(context);
    showDialog(context: context, builder: (_) => const RecoveryDialog());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HermesColors.surfaceElevated,
      title: Text('Unlock Workspace', style: HermesTypography.itemTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLockedOut) ...[
            Text('Too many incorrect attempts.', style: HermesTypography.body.copyWith(color: Colors.red)),
            SizedBox(height: HermesSpacing.md),
            Center(
              child: TextButton(onPressed: _showRecovery, child: Text('Forgot PIN?', style: TextStyle(color: HermesColors.accent))),
            ),
          ] else ...[
            TextField(
              controller: _pinController,
              obscureText: true,
              autofocus: true,
              style: HermesTypography.body,
              decoration: InputDecoration(
                hintText: 'Enter PIN',
                hintStyle: HermesTypography.metadata,
                filled: true,
                fillColor: HermesColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _verify(),
            ),
            if (_failedAttempts > 0)
              Padding(
                padding: EdgeInsets.only(top: HermesSpacing.xs),
                child: Text('Incorrect PIN. Attempt $_failedAttempts of 3.', style: HermesTypography.metadata.copyWith(color: Colors.redAccent)),
              ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: HermesColors.textSecondary))),
        if (!_isLockedOut)
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: HermesColors.accent, foregroundColor: Colors.white),
            onPressed: _verify,
            child: const Text('Unlock'),
          ),
      ],
    );
  }
}

// ── 6. Forgot PIN Recovery Dialog ───────────────────────────

class RecoveryDialog extends ConsumerStatefulWidget {
  const RecoveryDialog({super.key});

  @override
  ConsumerState<RecoveryDialog> createState() => _RecoveryDialogState();
}

class _RecoveryDialogState extends ConsumerState<RecoveryDialog> {
  final _answerController = TextEditingController();
  bool _error = false;

  void _verify() {
    final answer = _answerController.text.trim().toLowerCase();
    final ws = ref.read(currentWorkspaceProvider);
    if (ws?.securityAnswer == _hashString(answer)) {
      Navigator.pop(context);
      showDialog(context: context, barrierDismissible: false, builder: (_) => const ResetPinDialog());
    } else {
      setState(() {
        _error = true;
        _answerController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = ref.read(currentWorkspaceProvider);
    return AlertDialog(
      backgroundColor: HermesColors.surfaceElevated,
      title: Text('Workspace Recovery', style: HermesTypography.itemTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ws?.securityQuestion ?? 'No security question set.', style: HermesTypography.body),
          SizedBox(height: HermesSpacing.md),
          TextField(
            controller: _answerController,
            obscureText: true,
            autofocus: true,
            style: HermesTypography.body,
            decoration: InputDecoration(
              hintText: 'Answer',
              hintStyle: HermesTypography.metadata,
              filled: true,
              fillColor: HermesColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
            onSubmitted: (_) => _verify(),
          ),
          if (_error)
            Padding(
              padding: EdgeInsets.only(top: HermesSpacing.xs),
              child: Text('Incorrect answer.', style: HermesTypography.metadata.copyWith(color: Colors.redAccent)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: HermesColors.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: HermesColors.accent, foregroundColor: Colors.white),
          onPressed: _verify,
          child: const Text('Recover'),
        ),
      ],
    );
  }
}

// ── 7. Reset PIN Dialog (After Successful Recovery) ─────────

class ResetPinDialog extends ConsumerStatefulWidget {
  const ResetPinDialog({super.key});

  @override
  ConsumerState<ResetPinDialog> createState() => _ResetPinDialogState();
}

class _ResetPinDialogState extends ConsumerState<ResetPinDialog> {
  final _pinController = TextEditingController();

  Future<void> _savePinAndProceed(bool changeQuestion) async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    final ws = ref.read(currentWorkspaceProvider);
    if (ws != null) {
      final updated = ws.copyWith(pin: _hashString(pin));
      await ref.read(storageEngineProvider).saveWorkspace(updated);
      ref.read(currentWorkspaceProvider.notifier).updateWorkspace(updated);
      
      // Auto-unlock workspace
      ref.read(workspaceLockedProvider.notifier).setLocked(false);
    }
    
    if (mounted) {
      Navigator.pop(context); // Close ResetPinDialog
      if (changeQuestion) {
        showDialog(context: context, builder: (_) => const ChangeRecoveryQuestionDialog());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workspace recovered and unlocked.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HermesColors.surfaceElevated,
      title: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
          SizedBox(width: HermesSpacing.xs),
          Text('Recovery Verified', style: HermesTypography.itemTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create a New PIN / Pattern', style: HermesTypography.metadata),
          SizedBox(height: HermesSpacing.xs),
          TextField(
            controller: _pinController,
            obscureText: true,
            autofocus: true,
            style: HermesTypography.body,
            decoration: InputDecoration(
              hintText: 'New PIN',
              hintStyle: HermesTypography.metadata,
              filled: true,
              fillColor: HermesColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: HermesSpacing.xl),
          Text('(Optional) Would you like to update your Recovery Question?', style: HermesTypography.metadata.copyWith(height: 1.4)),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => _savePinAndProceed(false),
          child: Text('Keep Current', style: TextStyle(color: HermesColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: HermesColors.accent, foregroundColor: Colors.white),
          onPressed: () => _savePinAndProceed(true),
          child: const Text('Change Question'),
        ),
      ],
    );
  }
}
