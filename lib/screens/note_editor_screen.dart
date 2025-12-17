import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../services/speech_service.dart';
import '../widgets/ai_assistant_sheet.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note note;
  final bool startWithVoice;

  const NoteEditorScreen({
    super.key,
    required this.note,
    this.startWithVoice = false,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  bool _isInitialized = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _initSpeech();

    if (widget.startWithVoice) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _toggleListening();
      });
    }
  }

  Future<void> _initSpeech() async {
    _isInitialized = await _speechService.initSpeech();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isListening) {
      await _speechService.stopListening();
      // Add the final recognized text to content
      if (_recognizedText.isNotEmpty) {
        final existingText = _contentController.text.trim();
        if (existingText.isEmpty) {
          _contentController.text = _recognizedText;
        } else {
          _contentController.text = '$existingText ${_recognizedText}';
        }
        _contentController.selection = TextSelection.collapsed(
          offset: _contentController.text.length,
        );
      }
      setState(() {
        _isListening = false;
        _recognizedText = '';
      });
    } else {
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });

      await _speechService.startListening((text) {
        if (mounted && _isListening) {
          setState(() {
            // Just show what's being recognized, don't add to content yet
            _recognizedText = text;
          });
        }
      });
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedNote = widget.note.copyWith(
      title: title,
      content: content,
      date: DateTime.now(),
    );

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    if (widget.note.title.isEmpty && widget.note.content.isEmpty) {
      await notesProvider.addNote(updatedNote);
    } else {
      await notesProvider.updateNote(updatedNote);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note saved!'),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showAIAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIAssistantSheet(
        currentText: _contentController.text,
        onTextProcessed: (processedText) {
          setState(() {
            _contentController.text = processedText;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Note'),
        actions: [
          IconButton(
            icon: const Text('🤖', style: TextStyle(fontSize: 20)),
            onPressed: _showAIAssistant,
            tooltip: 'AI Assistant',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Title field
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),

                  const SizedBox(height: 16),

                  // Content field with animated cursor
                  TextField(
                    controller: _contentController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Start typing or use the Mic...',
                      hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 10,
                  ),
                ],
              ),
            ),
          ),

          // Speech-to-text indicator
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.mic,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _recognizedText.isEmpty
                          ? 'Listening...'
                          : _recognizedText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom toolbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_contentController.text.length} characters',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                FloatingActionButton(
                  onPressed: _toggleListening,
                  backgroundColor: _isListening
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}