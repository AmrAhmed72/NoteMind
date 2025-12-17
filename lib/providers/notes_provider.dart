import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class NotesProvider extends ChangeNotifier {
  static const String _notesBoxName = 'notesBox';
  late Box<Note> _notesBox;
  List<Note> _notes = [];
  bool _isInitialized = false;

  List<Note> get notes => _notes;
  List<Note> get textNotes => _notes.where((note) => !note.isChecklist).toList();
  List<Note> get checklistNotes => _notes.where((note) => note.isChecklist).toList();
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _notesBox = await Hive.openBox<Note>(_notesBoxName);
    _notes = _notesBox.values.toList();
    _notes.sort((a, b) => b.date.compareTo(a.date));
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await _notesBox.put(note.id, note);
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    await _notesBox.put(note.id, note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  Future<void> clearAllNotes() async {
    await _notesBox.clear();
    _notes.clear();
    notifyListeners();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes;
    
    final lowerQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
             note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
