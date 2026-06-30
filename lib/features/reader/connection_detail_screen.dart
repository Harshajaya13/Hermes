import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class ConnectionDetailScreen extends ConsumerStatefulWidget {
  final Connection connection;
  final Item itemA;
  final Item itemB;

  const ConnectionDetailScreen({
    super.key,
    required this.connection,
    required this.itemA,
    required this.itemB,
  });

  @override
  ConsumerState<ConnectionDetailScreen> createState() => _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState extends ConsumerState<ConnectionDetailScreen> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.connection.note);
  }

  @override
  void dispose() {
    _saveNote();
    _noteController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final note = _noteController.text.trim();
    if (note != widget.connection.note) {
      final updated = widget.connection.copyWith(
        note: note,
        modifiedAt: DateTime.now(),
      );
      ref.read(storageEngineProvider).saveConnection(updated);
      ref.invalidate(itemConnectionsProvider(widget.itemA.id));
      ref.invalidate(itemConnectionsProvider(widget.itemB.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesColors.background,
      appBar: AppBar(
        backgroundColor: HermesColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textSecondary),
          onPressed: () {
            _saveNote();
            Navigator.pop(context);
          },
        ),
        title: Text(widget.connection.title, style: HermesTypography.screenTitle.copyWith(fontSize: 16, color: HermesColors.textSecondary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: HermesSpacing.lg, vertical: HermesSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connection Note',
                style: HermesTypography.sectionTitle,
              ),
              const SizedBox(height: HermesSpacing.md),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: HermesColors.surfaceOverlay,
                    borderRadius: BorderRadius.circular(HermesRadius.md),
                    border: Border.all(color: HermesColors.border.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: HermesTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Explain why these items are connected...',
                      hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(HermesSpacing.md),
                    ),
                    onChanged: (_) {
                      // Optional: Autosave logic if desired
                    },
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
