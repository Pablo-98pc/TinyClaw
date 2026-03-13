import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../store/database.dart';
import '../theme/theme.dart';
import 'note_card.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TcColors.of(context);
    final noteDao = ref.watch(noteDaoProvider);

    return Scaffold(
      backgroundColor: colors.surface0,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TcSpacing.lg, vertical: TcSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notes', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: TcSpacing.sm),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(color: colors.textTertiary),
                      prefixIcon: Icon(Icons.search, color: colors.textTertiary),
                      filled: true,
                      fillColor: colors.surface1,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(TcRadius.md), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<NoteItem>>(
                stream: noteDao.watchAllNotes(),
                builder: (context, snapshot) {
                  var notes = snapshot.data ?? [];
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    notes = notes.where((n) =>
                      n.content.toLowerCase().contains(q) ||
                      n.title.toLowerCase().contains(q) ||
                      (n.tags?.toLowerCase().contains(q) ?? false)
                    ).toList();
                  }
                  if (notes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.note_outlined, size: 64, color: colors.textTertiary),
                          const SizedBox(height: TcSpacing.lg),
                          Text(_searchQuery.isEmpty ? 'No notes yet' : 'No matches', style: TextStyle(color: colors.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: TcSpacing.lg, vertical: TcSpacing.sm),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: TcSpacing.sm),
                        child: Dismissible(
                          key: ValueKey(note.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: TcSpacing.lg),
                            decoration: BoxDecoration(color: colors.error, borderRadius: BorderRadius.circular(TcRadius.md)),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => noteDao.deleteNote(note.id),
                          child: NoteCard(title: note.title, content: note.content, tags: note.tags, timeAgo: _timeAgo(note.updatedAt)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}
