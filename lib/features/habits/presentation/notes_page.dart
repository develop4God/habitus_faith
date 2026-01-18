import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'notes_providers.dart';
import '../domain/models/general_note_model.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final TextEditingController _noteController = TextEditingController();
  final List<String> _quickEmojis = ['🙏', '✨', '📖', '❤️', '🙌', '💪', '🌱', '☀️', '🕊️', '🔥'];
  static const int _minChars = 10;
  static const int _maxChars = 500;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final text = _noteController.text.trim();
    if (text.length >= _minChars && text.length <= _maxChars) {
      ref.read(jsonGeneralNotesRepositoryProvider).addNote(text);
      _noteController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(generalNotesStreamProvider);
    final today = DateFormat('EEEE, d MMMM', 'es').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mis Notas',
                    style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.w900),
                  ),
                  Text(
                    today,
                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade50, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildNewNoteInput(),
            ),
          ),
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildNoteCard(notes[index]),
                    childCount: notes.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildNewNoteInput() {
    final charCount = _noteController.text.length;
    final isTooShort = charCount > 0 && charCount < _minChars;
    final isTooLong = charCount > _maxChars;
    final canSave = charCount >= _minChars && charCount <= _maxChars;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Nueva Nota', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              IconButton(
                onPressed: canSave ? _saveNote : null,
                icon: Icon(Icons.send, color: canSave ? Colors.orange : Colors.grey.shade300),
              ),
            ],
          ),
          TextField(
            controller: _noteController,
            maxLines: 3,
            onChanged: (v) => setState(() {}),
            maxLength: _maxChars,
            decoration: InputDecoration(
              hintText: 'Escribe un testimonio, oración o pensamiento...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              border: InputBorder.none,
              counterText: '', // Hide default counter to use our custom one
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isTooShort 
                    ? 'Mínimo $_minChars caracteres' 
                    : '$charCount / $_maxChars',
                  style: TextStyle(
                    fontSize: 11, 
                    color: isTooShort ? Colors.red : (isTooLong ? Colors.red : Colors.grey),
                    fontWeight: isTooShort ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickEmojis.map((e) => InkWell(
                    onTap: () => setState(() => _noteController.text += e),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(GeneralNote note) {
    final dateStr = DateFormat('d MMM, HH:mm', 'es').format(note.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Spacer(),
              IconButton(
                onPressed: () => Share.share(note.content),
                icon: const Icon(Icons.share_outlined, size: 18, color: Colors.blue),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => ref.read(jsonGeneralNotesRepositoryProvider).deleteNote(note.id),
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.content,
            style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF1A1C1E)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sticky_note_2_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No hay notas guardadas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text('Tus pensamientos aparecerán aquí.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
