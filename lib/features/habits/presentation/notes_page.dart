import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'notes_providers.dart';
import 'pets_providers.dart';
import '../domain/models/general_note_model.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final TextEditingController _noteController = TextEditingController();
  String? _selectedPetId;
  final List<String> _quickEmojis = [
    '🙏',
    '✨',
    '📖',
    '❤️',
    '🙌',
    '💪',
    '🌱',
    '☀️',
    '🕊️',
    '🔥',
    '😊',
    '😌',
    '🌟',
    '🌈',
    '💡',
    '🎉',
    '🏆',
    '🎯',
    '💧',
    '⛪',
  ];
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
      ref.read(jsonGeneralNotesRepositoryProvider).addNote(text, petId: _selectedPetId);
      _noteController.clear();
      setState(() => _selectedPetId = null);
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
                    style: TextStyle(
                      color: Color(0xFF1A1C1E),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    today,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
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
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('Error: $e'))),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Nueva Nota',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                onPressed: canSave ? _saveNote : null,
                icon: Icon(
                  Icons.send,
                  color: canSave ? Colors.orange : Colors.grey.shade300,
                ),
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
          // Character counter row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                isTooShort
                    ? 'Mínimo $_minChars caracteres'
                    : '$charCount / $_maxChars',
                style: TextStyle(
                  fontSize: 11,
                  color: isTooShort
                      ? Colors.red
                      : (isTooLong ? Colors.red : Colors.grey),
                  fontWeight: isTooShort ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Pet selector
          _buildPetSelector(),
          const SizedBox(height: 8),
          // Quick emoji row
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _quickEmojis
                  .map(
                    (e) => InkWell(
                      onTap: () => setState(() => _noteController.text += e),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelector() {
    final petsAsync = ref.watch(petsNotifierProvider);
    
    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) {
          return Row(
            children: [
              Icon(Icons.pets, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _showAddPetDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar mascota', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                const Text('Mascota:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showAddPetDialog,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Agregar', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // None option
                  _buildPetChip(null, '❌', 'Ninguna'),
                  ...pets.map((pet) => _buildPetChip(pet.id, pet.emoji, pet.name)),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
  
  Widget _buildPetChip(String? petId, String emoji, String label) {
    final isSelected = _selectedPetId == petId;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
        onSelected: (_) => setState(() => _selectedPetId = petId),
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.orange.shade100,
        checkmarkColor: Colors.orange.shade700,
      ),
    );
  }
  
  Future<void> _showAddPetDialog() async {
    final nameController = TextEditingController();
    String selectedEmoji = '🐕';
    final petEmojis = ['🐕', '🐈', '🐦', '🐠', '🐰', '🐹', '🐢', '🦎', '🐍'];
    
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Agregar Mascota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Selecciona un emoji:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: petEmojis.map((emoji) => InkWell(
                  onTap: () => setDialogState(() => selectedEmoji = emoji),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedEmoji == emoji ? Colors.orange : Colors.grey.shade300,
                        width: selectedEmoji == emoji ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await ref.read(petsNotifierProvider.notifier).addPet(
                    nameController.text.trim(),
                    selectedEmoji,
                  );
                  if (mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
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
              Text(
                dateStr,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (note.petId != null) ...[
                const SizedBox(width: 8),
                _buildNotePetBadge(note.petId!),
              ],
              const Spacer(),
              IconButton(
                onPressed: () => Share.share(note.content),
                icon: const Icon(
                  Icons.share_outlined,
                  size: 18,
                  color: Colors.blue,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => ref
                    .read(jsonGeneralNotesRepositoryProvider)
                    .deleteNote(note.id),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.redAccent,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF1A1C1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotePetBadge(String petId) {
    final petsAsync = ref.watch(petsNotifierProvider);
    
    return petsAsync.when(
      data: (pets) {
        final pet = pets.where((p) => p.id == petId).firstOrNull;
        if (pet == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pet.emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                pet.name,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay notas guardadas',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Text(
            'Tus pensamientos aparecerán aquí.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
