import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/engines/article_fetcher.dart';

class CreateItemSheet extends ConsumerStatefulWidget {
  final Block? initialBlock;
  final Item? existingItem;
  final ItemType? initialType;
  final bool isDailyGoal;
  
  const CreateItemSheet({super.key, this.initialBlock, this.existingItem, this.initialType, this.isDailyGoal = false});

  static void show(BuildContext context, {Block? block, Item? existingItem, ItemType? initialType, bool isDailyGoal = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HermesColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HermesRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: CreateItemSheet(initialBlock: block, existingItem: existingItem, initialType: initialType, isDailyGoal: isDailyGoal),
        ),
      ),
    );
  }

  @override
  ConsumerState<CreateItemSheet> createState() => _CreateItemSheetState();
}

class _CreateItemSheetState extends ConsumerState<CreateItemSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _urlController = TextEditingController();
  final _officialAnswerController = TextEditingController();
  final _explanationController = TextEditingController();
  late ItemType _selectedType;
  Block? _selectedBlock;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? ItemType.question;
    _selectedBlock = widget.initialBlock;
    
    if (widget.existingItem != null) {
      _titleController.text = widget.existingItem!.title;
      _contentController.text = widget.existingItem!.content;
      _urlController.text = widget.existingItem!.sourceUrl ?? '';
      if (widget.existingItem!.metadata?['officialAnswer'] != null) {
        _officialAnswerController.text = widget.existingItem!.metadata!['officialAnswer'];
      }
      if (widget.existingItem!.metadata?['explanation'] != null) {
        _explanationController.text = widget.existingItem!.metadata!['explanation'];
      }
      _selectedType = widget.existingItem!.type;
    }
  }

  void _saveItem() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _isFetching = true;
    });

    if (widget.isDailyGoal && widget.existingItem == null) {
      final allItems = ref.read(storageEngineProvider).getAllItemsRaw();
      final dailyGoalCount = allItems.where((i) => i.metadata?['isDailyGoal'] == true && i.metadata?['isSolved'] != true).length;
      if (dailyGoalCount >= 20) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 20 goals can be pinned to Home. Please solve or remove existing goals.', style: HermesTypography.bodySmall.copyWith(color: HermesColors.textPrimary)),
              backgroundColor: HermesColors.surfaceElevated,
            ),
          );
        }
        setState(() => _isFetching = false);
        return;
      }
    }

    String finalContent = _contentController.text.trim();
    String? sourceUrl;

    if (_selectedType == ItemType.article && _urlController.text.isNotEmpty) {
      sourceUrl = _urlController.text.trim();
      final fetchedMarkdown = await ArticleFetcher.fetchAndConvertToMarkdown(sourceUrl);
      if (finalContent.isEmpty) {
        finalContent = fetchedMarkdown;
      } else {
        finalContent = '$finalContent\n\n---\n\n$fetchedMarkdown';
      }
    }

    if (_selectedBlock == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a block')));
      return;
    }

    Map<String, dynamic> metadata = widget.existingItem != null ? Map<String, dynamic>.from(widget.existingItem!.metadata ?? {}) : {};
    if (widget.isDailyGoal) {
      metadata['isDailyGoal'] = true;
      metadata['isManualDailyGoal'] = true;
    }
    
    if (_selectedType == ItemType.question) {
      if (_officialAnswerController.text.trim().isNotEmpty) {
        metadata['officialAnswer'] = _officialAnswerController.text.trim();
      } else {
        metadata.remove('officialAnswer');
      }
      if (_explanationController.text.trim().isNotEmpty) {
        metadata['explanation'] = _explanationController.text.trim();
      } else {
        metadata.remove('explanation');
      }
    }

    final newItem = widget.existingItem != null
        ? widget.existingItem!.copyWith(
            type: _selectedType,
            title: title,
            content: finalContent,
            sourceUrl: sourceUrl,
            metadata: metadata.isNotEmpty ? metadata : null,
          )
        : Item(
            blockId: _selectedBlock!.id,
            type: _selectedType,
            title: title,
            content: finalContent,
            sourceUrl: sourceUrl,
            metadata: metadata.isNotEmpty ? metadata : null,
          );

    await ref.read(storageEngineProvider).saveItem(newItem);
    // Invalidate the provider so UI updates
    ref.invalidate(itemsByBlockProvider(_selectedBlock!.id));
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(HermesSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.existingItem == null ? 'Create Item' : 'Edit Item', style: HermesTypography.sectionTitle),
                if (widget.existingItem == null)
                  Consumer(
                    builder: (context, ref, child) {
                      final blocks = ref.watch(allBlocksProvider);
                      if (_selectedBlock == null && blocks.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _selectedBlock = blocks.first);
                        });
                      }
                      return DropdownButton<Block>(
                        value: _selectedBlock,
                        dropdownColor: HermesColors.surfaceElevated,
                        style: HermesTypography.metadata,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: HermesColors.textSecondary),
                        items: blocks.map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(b.name),
                        )).toList(),
                        onChanged: (val) {
                          setState(() => _selectedBlock = val);
                        },
                      );
                    },
                  ),
              ],
            ),
            if (widget.existingItem != null) ...[
              const SizedBox(height: HermesSpacing.sm),
              Text(
                'In ${_selectedBlock?.name ?? "Unknown Block"}',
                style: HermesTypography.metadata,
              ),
            ],
            const SizedBox(height: HermesSpacing.xl),
            
            // Type Selector
            Wrap(
              spacing: HermesSpacing.sm,
              runSpacing: HermesSpacing.sm,
              children: ItemType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                  backgroundColor: HermesColors.surfaceElevated,
                  selectedColor: HermesColors.accent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : HermesColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: HermesSpacing.lg),
            
            TextField(
              controller: _titleController,
              autofocus: true,
              style: HermesTypography.body,
              decoration: InputDecoration(
                filled: true,
                fillColor: HermesColors.surfaceElevated,
                hintText: 'Title (e.g., Expected Value Formula)',
                hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                border: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.accent)),
              ),
            ),
            
            const SizedBox(height: HermesSpacing.md),
            
            TextField(
              controller: _contentController,
              style: HermesTypography.body,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: HermesColors.surfaceElevated,
                hintText: _selectedType == ItemType.article ? 'Custom notes (optional if fetching URL)...' : 'Content or prompt...',
                hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                border: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.accent)),
              ),
            ),
            
            if (_selectedType == ItemType.article) ...[
              const SizedBox(height: HermesSpacing.md),
              TextField(
                controller: _urlController,
                style: HermesTypography.body,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: HermesColors.surfaceElevated,
                  hintText: 'Article URL (will fetch and clean automatically)',
                  hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.accent)),
                  prefixIcon: const Icon(Icons.link, color: HermesColors.textTertiary),
                ),
              ),
            ],
            
            if (_selectedType == ItemType.question) ...[
              const SizedBox(height: HermesSpacing.md),
              TextField(
                controller: _officialAnswerController,
                style: HermesTypography.body,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: HermesColors.surfaceElevated,
                  hintText: 'Official Answer (optional for manual questions)',
                  hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.accent)),
                ),
              ),
              const SizedBox(height: HermesSpacing.md),
              TextField(
                controller: _explanationController,
                style: HermesTypography.body,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: HermesColors.surfaceElevated,
                  hintText: 'Explanation (optional)',
                  hintStyle: HermesTypography.body.copyWith(color: HermesColors.textTertiary),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.border)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: HermesColors.accent)),
                ),
              ),
            ],
            
            const SizedBox(height: HermesSpacing.xxxl),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFetching ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HermesColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: HermesSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HermesRadius.pill),
                  ),
                ),
                child: _isFetching
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.existingItem == null ? 'Add Item' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
