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
import 'scan_checklist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Search notes',
                  border: InputBorder.none,
                  filled: false,
                ),
              )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NoteMind',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (_selectedIndex != 2)
              Text(
                _selectedIndex == 0 ? 'Your ideas, in focus' : 'Small steps, visible progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
          ],
        ),
        actions: [
          if (_isSearching && _searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              tooltip: 'Clear search',
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _closeSearch,
              tooltip: 'Close search',
            )
          else if (_selectedIndex != 2)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
              tooltip: 'Search notes',
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
              _closeSearch();
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
        final allNotes = _selectedIndex == 0
            ? notesProvider.notes
            : notesProvider.checklistNotes;
        final notes = _searchQuery.trim().isEmpty
            ? allNotes
            : allNotes.where((note) {
                final query = _searchQuery.toLowerCase();
                return note.title.toLowerCase().contains(query) ||
                    note.content.toLowerCase().contains(query) ||
                    (note.checklist ?? []).any(
                      (item) => item.text.toLowerCase().contains(query),
                    );
              }).toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildOverview(notesProvider),
            ),
            if (notes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                sliver: SliverList.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return _buildNoteCard(notes[index], index);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void _closeSearch() {
    _searchController.clear();
    _searchQuery = '';
    _isSearching = false;
  }

  Widget _buildOverview(NotesProvider notesProvider) {
    final theme = Theme.of(context);
    final greeting = DateTime.now().hour < 12
        ? 'Good morning'
        : DateTime.now().hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedIndex == 0 ? 'Make room for your next thought.' : 'Keep the momentum going.',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                _buildStat(
                  context,
                  Icons.layers_outlined,
                  '${notesProvider.notes.length}',
                  'All notes',
                ),
                _buildStatDivider(context),
                _buildStat(
                  context,
                  Icons.checklist_outlined,
                  '${notesProvider.checklistNotes.length}',
                  'Checklists',
                ),
                _buildStatDivider(context),
                _buildStat(
                  context,
                  Icons.note_alt_outlined,
                  '${notesProvider.textNotes.length}',
                  'Notes',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            _selectedIndex == 0 ? 'Recent notes' : 'Your checklists',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 19, color: theme.primaryColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _selectedIndex == 0 ? Icons.sticky_note_2_outlined : Icons.checklist_outlined,
              size: 44,
              color: theme.primaryColor,
            ),
          )
              .animate()
              .fadeIn(duration: 1000.ms)
              .scale(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            _selectedIndex == 0 ? 'No notes yet' : 'No checklists yet',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Use the + button to capture your first ${_selectedIndex == 0 ? 'thought' : 'list'}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final theme = Theme.of(context);
    final accent = note.isChecklist
        ? theme.colorScheme.secondary
        : theme.primaryColor;
    final cardColor = Color.lerp(
      theme.colorScheme.surface,
      accent,
      theme.brightness == Brightness.light ? 0.045 : 0.1,
    )!;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withValues(alpha: 0.32)),
      ),
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
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
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          note.isChecklist ? Icons.checklist : Icons.notes_outlined,
                          size: 14,
                          color: accent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          note.isChecklist ? 'List' : 'Note',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteNote(note.id),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    tooltip: 'Delete note',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (note.isChecklist && note.checklist != null)
                _buildChecklistPreview(note.checklist!)
              else
                Text(
                  note.content.isEmpty ? 'No content' : note.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    note.isChecklist ? Icons.checklist : Icons.note,
                    size: 16,
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(note.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
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
      width: 220,
      height: _isFabExpanded ? 360 : 90,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          if (_isFabExpanded) ...[
            Positioned(
              bottom: 290,
              right: 0,
              child: FloatingActionButton.extended(
                heroTag: 'scan',
                onPressed: _scanChecklist,
                icon: const Icon(Icons.document_scanner_outlined),
                label: const Text('Scan to Checklist'),
              ),
            ),
            Positioned(
              bottom: 220,
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
            bottom: 150,
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
            bottom: 80,
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

  void _scanChecklist() {
    setState(() {
      _isFabExpanded = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanChecklistScreen()),
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
