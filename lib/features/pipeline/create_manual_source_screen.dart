import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class CreateManualSourceScreen extends ConsumerStatefulWidget {
  const CreateManualSourceScreen({super.key});

  @override
  ConsumerState<CreateManualSourceScreen> createState() => _CreateManualSourceScreenState();
}

class _CreateManualSourceScreenState extends ConsumerState<CreateManualSourceScreen> {
  int _currentStep = 0;
  ItemType _selectedType = ItemType.question;
  final _jsonController = TextEditingController();
  
  String? _validationError;
  List<Map<String, dynamic>> _parsedData = [];
  
  Domain? _selectedDomain;
  Block? _selectedBlock;
  bool _includeInToday = true;
  int _dailyLimit = 3;
  String _sourceName = '';

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final contents = await file.readAsString();
        setState(() {
          _jsonController.text = contents;
          _validationError = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error reading file: $e')));
    }
  }

  void _validateJson() {
    setState(() {
      _validationError = null;
      _parsedData = [];
    });
    
    try {
      final text = _jsonController.text.trim();
      if (text.isEmpty) {
        setState(() => _validationError = 'Please paste some JSON to validate.');
        return;
      }
      
      final dynamic decoded = jsonDecode(text);
      if (decoded is! List) {
        setState(() => _validationError = 'Root element must be a JSON array [...].');
        return;
      }
      
      if (decoded.isEmpty) {
        setState(() => _validationError = 'The JSON array is empty.');
        return;
      }
      
      if (decoded.length > 500) {
        setState(() => _validationError = 'Maximum of 500 items allowed per source to maintain performance.');
        return;
      }
      
      for (int i = 0; i < decoded.length; i++) {
        final item = decoded[i];
        if (item is! Map<String, dynamic>) {
          setState(() => _validationError = 'Item at index $i is not a JSON object {...}.');
          return;
        }
        if (item['title'] == null || item['title'].toString().trim().isEmpty) {
          setState(() => _validationError = 'Item at index $i is missing a required "title" field.');
          return;
        }
        if (item['content'] == null || item['content'].toString().trim().isEmpty) {
          setState(() => _validationError = 'Item at index $i is missing a required "content" field.');
          return;
        }
        
        final String? sourceUrl = item['sourceUrl']?.toString().trim();
        if (_selectedType == ItemType.article && (sourceUrl == null || sourceUrl.isEmpty)) {
          setState(() => _validationError = 'Item at index $i is an Article, which strictly requires a "sourceUrl".');
          return;
        }
        
        _parsedData.add({
          'title': item['title'].toString().trim(),
          'content': item['content'].toString().trim(),
          'sourceUrl': sourceUrl,
        });
      }
      
      // Success! Move to next step
      setState(() {
        _currentStep = 2; // Jump to configuration step
      });
      
    } catch (e) {
      setState(() => _validationError = 'Invalid JSON format:\n\n${e.toString()}');
    }
  }

  Future<void> _importData() async {
    if (_selectedBlock == null || _sourceName.trim().isEmpty) return;
    
    final storage = ref.read(storageEngineProvider);
    final ws = ref.read(currentWorkspaceProvider);
    if (ws == null) return;
    
    final source = KnowledgeSource(
      workspaceId: ws.id,
      name: _sourceName.trim(),
      type: _selectedType == ItemType.question ? SourceType.manualQuestion : SourceType.manualArticle,
      targetDomainId: _selectedDomain!.id,
      targetBlockId: _selectedBlock!.id,
      includeInToday: _includeInToday,
      dailyLimit: _dailyLimit,
    );
    
    await storage.saveSource(source);
    
    final itemsToSave = _parsedData.map((data) => Item(
      blockId: _selectedBlock!.id,
      sourceId: source.id,
      type: _selectedType,
      title: data['title'],
      content: data['content'],
      sourceUrl: data['sourceUrl'],
      metadata: {
        'isDailyGoal': _includeInToday,
      },
    )).toList();
    
    await storage.saveItems(itemsToSave);
    
    // Invalidate providers
    ref.invalidate(itemsByBlockProvider(_selectedBlock!.id));
    ref.invalidate(sourcesProvider);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully created source "${source.name}"!', style: const TextStyle(color: HermesColors.textSecondary)),
          backgroundColor: HermesColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
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
          icon: const Icon(Icons.arrow_back_rounded, color: HermesColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Source', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: HermesColors.evolutioGlow,
              onSurface: HermesColors.textPrimary,
            ),
          ),
          child: Stepper(
            currentStep: _currentStep,
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                Navigator.pop(context);
              }
            },
            onStepContinue: () {
              if (_currentStep == 0) {
                setState(() => _currentStep += 1);
              } else if (_currentStep == 1) {
                _validateJson();
              } else if (_currentStep == 2) {
                if (_selectedBlock != null && _sourceName.trim().isNotEmpty) {
                  _importData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Target Block and enter a Source Name.')));
                }
              }
            },
            onStepTapped: (index) {
              if (index < _currentStep) {
                setState(() => _currentStep = index);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: HermesSpacing.lg),
                child: Row(
                  children: [
                    if (_currentStep != 1)
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HermesColors.evolutioGlow,
                          foregroundColor: Colors.black,
                        ),
                        child: Text(_currentStep == 2 ? 'Import Now' : 'Continue'),
                      ),
                    if (_currentStep == 1)
                      ElevatedButton(
                        onPressed: _validateJson,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HermesColors.evolutioGlow,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Validate & Proceed'),
                      ),
                    const SizedBox(width: HermesSpacing.md),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text(_currentStep == 0 ? 'Cancel' : 'Back', style: const TextStyle(color: HermesColors.textSecondary)),
                    ),
                  ],
                ),
              );
            },
            steps: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: Text('Choose Content Type', style: HermesTypography.sectionTitle),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: HermesSpacing.sm),
          Text('Name this source collection:', style: HermesTypography.body),
          const SizedBox(height: HermesSpacing.sm),
          TextField(
            onChanged: (val) => _sourceName = val,
            decoration: InputDecoration(
              hintText: 'e.g. Probability Pack',
              filled: true,
              fillColor: HermesColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: HermesSpacing.xl),
          Text('What kind of knowledge are you importing?', style: HermesTypography.body),
          const SizedBox(height: HermesSpacing.md),
          Wrap(
            spacing: HermesSpacing.md,
            children: [
              ChoiceChip(
                label: const Text('Questions'),
                selected: _selectedType == ItemType.question,
                onSelected: (val) {
                  if (val) setState(() => _selectedType = ItemType.question);
                },
                selectedColor: HermesColors.evolutioGlow.withValues(alpha: 0.2),
              ),
              ChoiceChip(
                label: const Text('Articles'),
                selected: _selectedType == ItemType.article,
                onSelected: (val) {
                  if (val) setState(() => _selectedType = ItemType.article);
                },
                selectedColor: HermesColors.evolutioGlow.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStep2() {
    final template = '''
[
  {
    "title": "Sample ${_selectedType.name.toUpperCase()}",
    "content": "The actual text or markdown content goes here.",
    "sourceUrl": "https://optional-source.com"
  }
]''';

    return Step(
      title: Text('Prepare & Upload', style: HermesTypography.sectionTitle),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: HermesSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hermes Official JSON Format:', style: HermesTypography.metadata),
              TextButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file_rounded, size: 16),
                label: const Text('Upload .json'),
                style: TextButton.styleFrom(
                  foregroundColor: HermesColors.evolutioGlow,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: HermesSpacing.sm),
          Container(
            padding: const EdgeInsets.all(HermesSpacing.md),
            decoration: BoxDecoration(
              color: HermesColors.background,
              borderRadius: BorderRadius.circular(HermesRadius.sm),
              border: Border.all(color: HermesColors.border),
            ),
            width: double.infinity,
            child: Stack(
              children: [
                Text(template, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: HermesColors.textSecondary)),
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: template));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format copied to clipboard!')));
                    },
                    child: const Icon(Icons.copy_rounded, size: 16, color: HermesColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: HermesSpacing.lg),
          TextField(
            controller: _jsonController,
            maxLines: 8,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Paste your generated JSON array here...',
              hintStyle: const TextStyle(color: HermesColors.textTertiary),
              filled: true,
              fillColor: HermesColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: HermesSpacing.md),
            Container(
              padding: const EdgeInsets.all(HermesSpacing.md),
              decoration: BoxDecoration(color: HermesColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(HermesRadius.sm)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: HermesColors.error, size: 20),
                  const SizedBox(width: HermesSpacing.sm),
                  Expanded(child: Text(_validationError!, style: HermesTypography.metadata.copyWith(color: HermesColors.error))),
                ],
              ),
            ),
          ],
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStep3() {
    final domains = ref.watch(domainsProvider);
    final blocks = _selectedDomain != null ? ref.watch(blocksByDomainProvider(_selectedDomain!.id)) : <Block>[];

    return Step(
      title: Text('Integration & Rules', style: HermesTypography.sectionTitle),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: HermesSpacing.sm),
          Container(
            padding: const EdgeInsets.all(HermesSpacing.md),
            decoration: BoxDecoration(color: HermesColors.evolutioGlow.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(HermesRadius.md)),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: HermesColors.evolutioGlow),
                const SizedBox(width: HermesSpacing.md),
                Expanded(child: Text('Successfully validated ${_parsedData.length} items.', style: HermesTypography.body)),
              ],
            ),
          ),
          const SizedBox(height: HermesSpacing.xl),
          Text('Where should this knowledge go?', style: HermesTypography.sectionTitle),
          const SizedBox(height: HermesSpacing.md),
          DropdownButtonFormField<Domain>(
            value: _selectedDomain,
            hint: const Text('Target Domain'),
            dropdownColor: HermesColors.surfaceElevated,
            items: domains.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedDomain = val;
                _selectedBlock = null;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: HermesColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: HermesSpacing.md),
          DropdownButtonFormField<Block>(
            value: _selectedBlock,
            hint: const Text('Target Block'),
            dropdownColor: HermesColors.surfaceElevated,
            items: blocks.map((b) => DropdownMenuItem(value: b, child: Text('${b.icon} ${b.name}'))).toList(),
            onChanged: _selectedDomain == null ? null : (val) => setState(() => _selectedBlock = val),
            decoration: InputDecoration(
              filled: true,
              fillColor: HermesColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
          ),
          
          const SizedBox(height: HermesSpacing.xxl),
          Text("Today's Pursuit Rules", style: HermesTypography.sectionTitle),
          const SizedBox(height: HermesSpacing.md),
          SwitchListTile(
            title: const Text('Include in Today\'s Pursuit?'),
            subtitle: const Text('Should these items be surfaced daily?'),
            value: _includeInToday,
            activeColor: HermesColors.evolutioGlow,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _includeInToday = val),
          ),
          if (_includeInToday) ...[
            const SizedBox(height: HermesSpacing.md),
            Text('Daily Maximum Limit:', style: HermesTypography.metadata),
            const SizedBox(height: HermesSpacing.sm),
            Wrap(
              spacing: HermesSpacing.md,
              children: [1, 3, 5, 10].map((limit) {
                return ChoiceChip(
                  label: Text('$limit'),
                  selected: _dailyLimit == limit,
                  onSelected: (val) {
                    if (val) setState(() => _dailyLimit = limit);
                  },
                  selectedColor: HermesColors.evolutioGlow.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: HermesSpacing.xs),
            Text('Hermes will conservatively pull up to $_dailyLimit items per day.', style: HermesTypography.metadata),
          ]
        ],
      ),
      isActive: _currentStep >= 2,
    );
  }
}
