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

    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a PIN')));
      return;
    }

    setState(() => _isSettingUp = true);

    final ws = ref.read(currentWorkspaceProvider);
    if (ws != null) {
      final updated = ws.copyWith(
        pin: _hashString(pin),
        securityQuestion: question.isEmpty ? null : question,
        securityAnswer: answer.isEmpty ? null : _hashString(answer.toLowerCase()),
        isEncrypted: true,
      );
      await ref.read(storageEngineProvider).saveWorkspace(updated);
      ref.read(currentWorkspaceProvider.notifier).updateWorkspace(updated);
      ref.read(workspaceLockedProvider.notifier).setLocked(true);
    }

    if (mounted) {
      Navigator.pop(context);
    }
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
            Text('Security Question (Optional For Recovery)', style: HermesTypography.metadata),
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

class UnlockWorkspaceDialog extends ConsumerStatefulWidget {
  const UnlockWorkspaceDialog({super.key});

  @override
  ConsumerState<UnlockWorkspaceDialog> createState() => _UnlockWorkspaceDialogState();
}

class _UnlockWorkspaceDialogState extends ConsumerState<UnlockWorkspaceDialog> {
  final _pinController = TextEditingController();
  int _failedAttempts = 0;
  bool _isLockedOut = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verify() {
    final pin = _pinController.text.trim();
    final ws = ref.read(currentWorkspaceProvider);
    
    final hashedPin = _hashString(pin);

    if (ws?.pin == hashedPin || ws?.pin == null) {
      ref.read(workspaceLockedProvider.notifier).setLocked(false);
      Navigator.pop(context);
    } else {
      setState(() {
        _failedAttempts++;
        _pinController.clear();
        if (_failedAttempts >= 3) {
          _isLockedOut = true;
        }
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
              child: TextButton(
                onPressed: _showRecovery,
                child: Text('Forgot PIN?', style: TextStyle(color: HermesColors.accent)),
              ),
            ),
          ] else ...[
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: HermesColors.textSecondary)),
        ),
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

class RecoveryDialog extends ConsumerStatefulWidget {
  const RecoveryDialog({super.key});

  @override
  ConsumerState<RecoveryDialog> createState() => _RecoveryDialogState();
}

class _RecoveryDialogState extends ConsumerState<RecoveryDialog> {
  final _answerController = TextEditingController();
  bool _error = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _verify() {
    final answer = _answerController.text.trim().toLowerCase();
    final ws = ref.read(currentWorkspaceProvider);
    
    final hashedAnswer = _hashString(answer);

    if (ws?.securityAnswer == hashedAnswer) {
      Navigator.pop(context);
      showDialog(context: context, builder: (_) => const SetupLockDialog());
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
          Text(ws?.securityQuestion ?? 'No security question set. Workspace cannot be recovered.', style: HermesTypography.body),
          SizedBox(height: HermesSpacing.md),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: HermesColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: HermesColors.accent, foregroundColor: Colors.white),
          onPressed: _verify,
          child: const Text('Recover'),
        ),
      ],
    );
  }
}
