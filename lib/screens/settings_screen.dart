import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notes_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Theme Section
        _buildSectionTitle(context, 'Appearance'),
        const SizedBox(height: 8),
        _buildThemeCard(context),
        
        const SizedBox(height: 24),
        
        // Data Section
        _buildSectionTitle(context, 'Data'),
        const SizedBox(height: 8),
        _buildDataCard(context),
        
        const SizedBox(height: 24),
        
        // About Section
        _buildSectionTitle(context, 'About'),
        const SizedBox(height: 8),
        _buildAboutCard(context),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildThemeCard(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark Mode',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toggle between light and dark theme',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: const Text('Storage Info'),
            subtitle: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                return Text(
                  '${notesProvider.notes.length} notes stored locally',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
            title: const Text('Clear All Notes'),
            subtitle: Text(
              'Delete all notes permanently',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            onTap: () => _showClearNotesDialog(context),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🧠',
                style: TextStyle(fontSize: 48),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .scale(delay: 400.ms, duration: 400.ms),
            
            const SizedBox(height: 16),
            
            // App Name
            Text(
              'NoteMind',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 300.ms),
            
            const SizedBox(height: 8),
            
            // Version
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 300.ms),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'NoteMind helps you capture ideas, tasks, and thoughts easily — by typing, checking, or speaking.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 300.ms),
            
            const SizedBox(height: 20),
            
            // Features
            _buildFeatureRow(
              context,
              Icons.edit,
              'Text Notes',
              'Write and organize your thoughts',
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 300.ms)
                .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 12),
            
            _buildFeatureRow(
              context,
              Icons.checklist,
              'Checklists',
              'Track tasks with animated checkboxes',
            )
                .animate()
                .fadeIn(delay: 900.ms, duration: 300.ms)
                .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 12),
            
            _buildFeatureRow(
              context,
              Icons.mic,
              'Voice Notes',
              'Convert speech to text in real-time',
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 300.ms)
                .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 20),
            
            // Footer
            Text(
              'Made with ❤️ for productivity',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
            )
                .animate()
                .fadeIn(delay: 1100.ms, duration: 300.ms),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildFeatureRow(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearNotesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notes'),
        content: const Text(
          'Are you sure you want to delete all notes? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<NotesProvider>(context, listen: false).clearAllNotes();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notes cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
