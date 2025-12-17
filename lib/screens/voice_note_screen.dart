import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../services/speech_service.dart';

class VoiceNoteScreen extends StatefulWidget {
  final Note note;

  const VoiceNoteScreen({
    super.key,
    required this.note,
  });

  @override
  State<VoiceNoteScreen> createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
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
  }

  Future<void> _initSpeech() async {
    _isInitialized = await _speechService.initSpeech();
    print('🎤 Voice Note: Speech initialized = $_isInitialized');
    if (mounted) {
      setState(() {});
    }
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
          content: const Text('Voice note saved'),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showAIAssistant() {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Assistant coming soon!'),
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
        title: const Row(
          children: [
            Icon(Icons.mic, size: 20),
            SizedBox(width: 8),
            Text('Voice Note'),
          ],
        ),
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
          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                        fontSize: 28,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Content field
                  TextField(
                    controller: _contentController,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Tap the mic button below to start recording...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 10,
                  ),
                ],
              ),
            ),
          ),
          
          // Listening indicator
          if (_isListening)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.green.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.mic,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _recognizedText.isEmpty
                          ? 'Listening...'
                          : _recognizedText,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Character count
                  Expanded(
                    child: Text(
                      '${_contentController.text.length} characters',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Mic button - ALWAYS VISIBLE
                  FloatingActionButton(
                    onPressed: _isInitialized ? _toggleListening : null,
                    backgroundColor: _isListening ? Colors.red : Colors.blue,
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
