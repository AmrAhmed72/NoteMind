import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/note_model.dart';
import '../providers/scan_checklist_provider.dart';
import 'checklist_screen.dart';

class ScanChecklistScreen extends StatefulWidget {
  const ScanChecklistScreen({super.key});

  @override
  State<ScanChecklistScreen> createState() => _ScanChecklistScreenState();
}

class _ScanChecklistScreenState extends State<ScanChecklistScreen> {
  bool _reviewOpened = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanChecklistProvider(),
      child: Consumer<ScanChecklistProvider>(
        builder: (context, provider, child) {
          if (provider.status == ScanChecklistStatus.success &&
              provider.result != null &&
              !_reviewOpened) {
            _reviewOpened = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final result = provider.result!;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ChecklistScreen(
                    note: Note(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: result.title,
                      content: '',
                      isChecklist: true,
                      checklist: result.items,
                      date: DateTime.now(),
                    ),
                  ),
                ),
              );
            });
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Scan to Checklist')),
            body: _buildBody(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ScanChecklistProvider provider) {
    if (provider.status == ScanChecklistStatus.processing ||
        provider.status == ScanChecklistStatus.success) {
      return _buildProcessing(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (provider.image == null) _buildIntro(context),
          if (provider.image != null) ...[
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.memory(
                    provider.imageBytes!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Image ready to analyze',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (provider.errorMessage != null) _buildError(context, provider),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.selectImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.selectImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          if (provider.image != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.analyzeImage,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Analyze Image'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan to Checklist',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Turn printed or handwritten tasks into an editable checklist.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessing(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('Analyzing your note...',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Extracting actionable tasks for your review.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, ScanChecklistProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(provider.errorMessage!)),
          IconButton(
            onPressed: provider.clearError,
            icon: const Icon(Icons.close),
            tooltip: 'Dismiss error',
          ),
        ],
      ),
    );
  }
}