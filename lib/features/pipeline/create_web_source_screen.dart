import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/hermes_theme.dart';
import '../../core/widgets/hermes_widgets.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/web_scraper.dart';

class CreateWebSourceScreen extends ConsumerStatefulWidget {
  const CreateWebSourceScreen({super.key});

  @override
  ConsumerState<CreateWebSourceScreen> createState() => _CreateWebSourceScreenState();
}

class _CreateWebSourceScreenState extends ConsumerState<CreateWebSourceScreen> {
  int _currentStep = 0;
  final _urlController = TextEditingController();
  
  String? _validationError;
  bool _isFetching = false;
  Map<String, String>? _fetchedData;
  
  Domain? _selectedDomain;
  Block? _selectedBlock;
  bool _includeInToday = true;
  String _sourceName = '';

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _fetchUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      setState(() => _validationError = 'Please enter a valid HTTP/HTTPS URL.');
      return;
    }

    setState(() {
      _validationError = null;
      _isFetching = true;
      _fetchedData = null;
    });

    try {
      final result = await WebScraper.fetchArticle(url);
      setState(() {
        _fetchedData = result;
        _isFetching = false;
        _currentStep = 2; // Jump to configuration step
      });
    } catch (e) {
      setState(() {
        _validationError = e.toString();
        _isFetching = false;
      });
    }
  }

  Future<void> _importData() async {
    if (_selectedBlock == null || _sourceName.trim().isEmpty || _fetchedData == null) return;
    
    final storage = ref.read(storageEngineProvider);
    final ws = ref.read(currentWorkspaceProvider);
    if (ws == null) return;
    
    final source = KnowledgeSource(
      workspaceId: ws.id,
      name: _sourceName.trim(),
      type: SourceType.manualArticle, // Treat it similar to manual for now, or we could add webArticle
      targetDomainId: _selectedDomain!.id,
      targetBlockId: _selectedBlock!.id,
      includeInToday: _includeInToday,
      dailyLimit: 1, // Single article
    );
    
    await storage.saveSource(source);
    
    final item = Item(
      blockId: _selectedBlock!.id,
      sourceId: source.id,
      type: ItemType.article,
      title: _fetchedData!['title']!,
      content: _fetchedData!['content']!,
      sourceUrl: _urlController.text.trim(),
      metadata: {
        'isDailyGoal': _includeInToday,
      },
    );
    
    await storage.saveItems([item]);
    
    ref.invalidate(itemsByBlockProvider(_selectedBlock!.id));
    ref.invalidate(sourcesProvider);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported "${source.name}"!', style: const TextStyle(color: HermesColors.textSecondary)),
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
        title: Text('Import Web Link', style: HermesTypography.screenTitle.copyWith(fontSize: 20)),
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
                if (_sourceName.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a Source Name.')));
                  return;
                }
                setState(() => _currentStep += 1);
              } else if (_currentStep == 1) {
                _fetchUrl();
              } else if (_currentStep == 2) {
                if (_selectedBlock != null) {
                  _importData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Target Block.')));
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
                        onPressed: _isFetching ? null : _fetchUrl,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HermesColors.evolutioGlow,
                          foregroundColor: Colors.black,
                        ),
                        child: _isFetching 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text('Fetch Article'),
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
      title: Text('Name the Source', style: HermesTypography.sectionTitle),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: HermesSpacing.sm),
          Text('Give this web article a memorable name:', style: HermesTypography.body),
          const SizedBox(height: HermesSpacing.sm),
          TextField(
            onChanged: (val) => _sourceName = val,
            decoration: InputDecoration(
              hintText: 'e.g. Paul Graham Essay',
              filled: true,
              fillColor: HermesColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStep2() {
    return Step(
      title: Text('Paste URL', style: HermesTypography.sectionTitle),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: HermesSpacing.sm),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'https://...',
              hintStyle: const TextStyle(color: HermesColors.textTertiary),
              filled: true,
              fillColor: HermesColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HermesRadius.md), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.link_rounded, color: HermesColors.textTertiary),
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
      title: Text('Integration', style: HermesTypography.sectionTitle),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_fetchedData != null) ...[
            const SizedBox(height: HermesSpacing.sm),
            Container(
              padding: const EdgeInsets.all(HermesSpacing.md),
              decoration: BoxDecoration(color: HermesColors.evolutioGlow.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(HermesRadius.md)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: HermesColors.evolutioGlow),
                      const SizedBox(width: HermesSpacing.md),
                      Expanded(child: Text('Successfully extracted text!', style: HermesTypography.body)),
                    ],
                  ),
                  const SizedBox(height: HermesSpacing.sm),
                  Text('Title: ${_fetchedData!['title']}', style: HermesTypography.metadata, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Length: ${_fetchedData!['content']!.length} characters', style: HermesTypography.metadata),
                ],
              ),
            ),
            const SizedBox(height: HermesSpacing.xl),
          ],
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
            subtitle: const Text('Read this article immediately?'),
            value: _includeInToday,
            activeColor: HermesColors.evolutioGlow,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _includeInToday = val),
          ),
        ],
      ),
      isActive: _currentStep >= 2,
    );
  }
}
