import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import 'note_editor_screen.dart';
import 'checklist_screen.dart';
import 'settings_screen.dart';
import 'voice_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'All Notes'
              : _selectedIndex == 1
              ? 'Checklists'
              : 'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          if (_selectedIndex != 2)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {

              },
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 2
          ? null
          : _buildAnimatedFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _isFabExpanded = false;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sticky_note_2),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'Checklists',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 2) {
      return const SettingsScreen();
    }

    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final notes = _selectedIndex == 0
            ? notesProvider.notes
            : notesProvider.checklistNotes;

        if (notes.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return _buildNoteCard(notes[index], index);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedIndex == 0 ? Icons.sticky_note_2 : Icons.checklist_outlined,
            size: 80,
            color: Colors.grey,
          )
              .animate()
              .fadeIn(duration: 1000.ms)
              .scale(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            _selectedIndex == 0 ? 'No notes yet' : 'No checklists yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first ${_selectedIndex == 0 ? 'note' : 'checklist'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openNote(note),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteNote(note.id),
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (note.isChecklist && note.checklist != null)
                _buildChecklistPreview(note.checklist!)
              else
                Text(
                  note.content.isEmpty ? 'No content' : note.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    note.isChecklist ? Icons.checklist : Icons.note,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(note.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 300.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildChecklistPreview(List<ChecklistItem> checklist) {
    final completedCount = checklist.where((item) => item.isDone).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...checklist.take(2).map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                item.isDone
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 20,
                color: item.isDone
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: item.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.isDone ? Colors.grey : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
        if (checklist.length > 2)
          Text(
            '+ ${checklist.length - 2} more items',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          '$completedCount of ${checklist.length} completed',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedFAB() {
    return SizedBox(
      width: 200,
      height: 250,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          if (_isFabExpanded) ...[
            Positioned(
              bottom: 180,
              right: 0,
              child: FloatingActionButton.extended(
              heroTag: 'voice',
                onPressed: () => _createNote(),
              icon: const Icon(Icons.mic),
              label: const Text('Voice Note'),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(delay: 100.ms, duration: 200.ms)
                .slideY(begin: 1, end: 0),
          ),
          Positioned(
            bottom: 110,
            right: 0,
            child: FloatingActionButton.extended(
              heroTag: 'checklist',
              onPressed: () => _createNote(isChecklist: true),
              icon: const Icon(Icons.checklist),
              label: const Text('Checklist'),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(delay: 50.ms, duration: 200.ms)
                .slideY(begin: 1, end: 0),
          ),
          Positioned(
            bottom: 40,
            right: 0,
            child: FloatingActionButton.extended(
              heroTag: 'text',
              onPressed: () => _createNote(),
              icon: const Icon(Icons.edit),
              label: const Text('Text Note'),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(duration: 200.ms)
                .slideY(begin: 1, end: 0),
          ),
        ],

        // Main FAB
        Positioned(
          bottom: 0,
          right: 0,
          child: FloatingActionButton(
            heroTag: 'main',
            onPressed: () {
              setState(() {
                _isFabExpanded = !_isFabExpanded;
              });
            },
            child: AnimatedRotation(
              turns: _isFabExpanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(_isFabExpanded ? Icons.close : Icons.add),
            ),
          ),
        ),
      ],
      ),
    );
  }

  void _createNote({bool isChecklist = false, bool isVoice = false}) {
    setState(() {
      _isFabExpanded = false;
    });

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: '',
      isChecklist: isChecklist,
      checklist: isChecklist ? [] : null,
      date: DateTime.now(),
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          if (isChecklist) {
            return ChecklistScreen(note: note);
          } else if (isVoice) {
            return VoiceNoteScreen(note: note);
          } else {
            return NoteEditorScreen(note: note, startWithVoice: false);
          }
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openNote(Note note) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return note.isChecklist
              ? ChecklistScreen(note: note)
              : NoteEditorScreen(note: note);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _deleteNote(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<NotesProvider>(context, listen: false).deleteNote(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
