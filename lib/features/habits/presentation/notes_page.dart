import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'notes_providers.dart';
import 'pets_providers.dart';
import '../domain/models/general_note_model.dart';
import '../domain/models/pet_model.dart';

// ─── Rich note line model ─────────────────────────────────────────────────────

enum _NoteLineType { plain, checkbox, numbered }

class _NoteLine {
  final _NoteLineType type;
  String text;
  bool checked;

  _NoteLine({required this.type, this.text = '', this.checked = false});

  String toStorageString(int numberIndex) {
    switch (type) {
      case _NoteLineType.checkbox:
        return '${checked ? '[x]' : '[ ]'} $text';
      case _NoteLineType.numbered:
        return '$numberIndex. $text';
      case _NoteLineType.plain:
        return text;
    }
  }
}

List<_NoteLine> _parseNote(String raw) {
  if (raw.isEmpty) return [];
  final lines = raw.split('\n');
  final result = <_NoteLine>[];
  for (final line in lines) {
    final checked = RegExp(r'^\[x\] (.*)$', caseSensitive: false);
    final unchecked = RegExp(r'^\[ \] (.*)$');
    final numbered = RegExp(r'^(\d+)\. (.*)$');
    if (checked.hasMatch(line)) {
      result.add(_NoteLine(
          type: _NoteLineType.checkbox,
          text: checked.firstMatch(line)!.group(1)!,
          checked: true));
    } else if (unchecked.hasMatch(line)) {
      result.add(_NoteLine(
          type: _NoteLineType.checkbox,
          text: unchecked.firstMatch(line)!.group(1)!,
          checked: false));
    } else if (numbered.hasMatch(line)) {
      result.add(_NoteLine(
          type: _NoteLineType.numbered,
          text: numbered.firstMatch(line)!.group(2)!));
    } else {
      result.add(_NoteLine(type: _NoteLineType.plain, text: line));
    }
  }
  return result;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  String? _selectedPetId;

  // Rich editor state
  late List<_NoteLine> _lines;

  final List<String> _quickEmojis = [
    '🙏', '✨', '📖', '❤️', '🙌', '💪', '🌱', '☀️', '🕊️', '🔥',
    '😊', '😌', '🌟', '🌈', '💡', '🎉', '🏆', '🎯', '💧', '⛪',
  ];

  static const int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _lines = [_NoteLine(type: _NoteLineType.plain)];
  }

  // ── Serialise lines to flat text for storage ──────────────────────────────

  String get _serialised {
    int num = 1;
    final sb = StringBuffer();
    for (int i = 0; i < _lines.length; i++) {
      if (i > 0) sb.write('\n');
      final line = _lines[i];
      if (line.type == _NoteLineType.numbered) {
        sb.write(line.toStorageString(num));
        num++;
      } else {
        num = 1;
        sb.write(line.toStorageString(0));
      }
    }
    return sb.toString();
  }

  bool get _canSave {
    final text = _serialised.trim();
    return text.isNotEmpty && text.length <= _maxChars;
  }

  void _addLine(_NoteLineType type) => setState(() {
        _lines.add(_NoteLine(type: type));
      });

  void _toggleCheckbox(int index) =>
      setState(() => _lines[index].checked = !_lines[index].checked);

  void _removeLine(int index) {
    if (_lines.length == 1) {
      setState(() => _lines[0].text = '');
    } else {
      setState(() => _lines.removeAt(index));
    }
  }

  void _insertEmoji(String emoji) => setState(() {
        if (_lines.isNotEmpty) _lines.last.text += emoji;
      });

  void _saveNote() {
    final text = _serialised.trim();
    if (_canSave) {
      ref
          .read(jsonGeneralNotesRepositoryProvider)
          .addNote(text, petId: _selectedPetId);
      setState(() {
        _lines = [_NoteLine(type: _NoteLineType.plain)];
        _selectedPetId = null;
      });
      FocusScope.of(context).unfocus();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
              child: _buildRichNoteInput(),
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

  // ── Rich input card ────────────────────────────────────────────────────────

  Widget _buildRichNoteInput() {
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
          // Header row
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
                onPressed: _canSave ? _saveNote : null,
                icon: Icon(
                  Icons.send_rounded,
                  color: _canSave ? Colors.orange : Colors.grey.shade300,
                ),
              ),
            ],
          ),

          // Formatting toolbar
          Wrap(
            spacing: 8,
            children: [
              _ToolbarButton(
                icon: Icons.format_list_bulleted_rounded,
                label: 'Casilla',
                color: Colors.green.shade700,
                onTap: () => _addLine(_NoteLineType.checkbox),
              ),
              _ToolbarButton(
                icon: Icons.format_list_numbered_rounded,
                label: 'Numerada',
                color: Colors.blue.shade700,
                onTap: () => _addLine(_NoteLineType.numbered),
              ),
              _ToolbarButton(
                icon: Icons.text_fields_rounded,
                label: 'Texto',
                color: Colors.grey.shade700,
                onTap: () => _addLine(_NoteLineType.plain),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Lines editor
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < _lines.length; i++)
                    _buildLineEditor(i),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Char counter
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_serialised.trim().length} / $_maxChars',
              style: TextStyle(
                fontSize: 11,
                color: _serialised.trim().length > _maxChars
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
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
                      onTap: () => _insertEmoji(e),
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

  Widget _buildLineEditor(int index) {
    final line = _lines[index];
    Widget leading;

    switch (line.type) {
      case _NoteLineType.checkbox:
        leading = GestureDetector(
          onTap: () => _toggleCheckbox(index),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              line.checked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              key: ValueKey(line.checked),
              color:
                  line.checked ? Colors.green.shade600 : Colors.grey.shade400,
              size: 22,
            ),
          ),
        );
        break;
      case _NoteLineType.numbered:
        int num = 1;
        for (int i = 0; i < index; i++) {
          if (_lines[i].type == _NoteLineType.numbered) num++;
        }
        leading = SizedBox(
          width: 26,
          child: Text(
            '$num.',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 14),
            textAlign: TextAlign.right,
          ),
        );
        break;
      case _NoteLineType.plain:
        leading = const SizedBox(width: 4);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              autofocus: index == _lines.length - 1,
              controller: TextEditingController(text: line.text)
                ..selection =
                    TextSelection.collapsed(offset: line.text.length),
              onChanged: (v) => _lines[index].text = v,
              style: TextStyle(
                fontSize: 15,
                decoration: (line.type == _NoteLineType.checkbox &&
                        line.checked)
                    ? TextDecoration.lineThrough
                    : null,
                color: (line.type == _NoteLineType.checkbox && line.checked)
                    ? Colors.grey.shade400
                    : Colors.grey.shade900,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: line.type == _NoteLineType.checkbox
                    ? 'Elemento de lista...'
                    : line.type == _NoteLineType.numbered
                        ? 'Paso...'
                        : 'Escribe un testimonio, oración o pensamiento...',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _addLine(line.type),
            ),
          ),
          if (_lines.length > 1)
            GestureDetector(
              onTap: () => _removeLine(index),
              child: Icon(Icons.remove_circle_outline,
                  size: 16, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }

  // ── Pet selector ──────────────────────────────────────────────────────────

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
                label: const Text('Agregar mascota',
                    style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                const Text('Mascota:',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showAddPetDialog,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Agregar', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
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
                  _buildPetChip(null, '❌', 'Ninguna'),
                  ...pets.map(
                      (pet) => _buildPetChip(pet.id, pet.emoji, pet.name)),
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
              const Text('Selecciona un emoji:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: petEmojis
                    .map((emoji) => InkWell(
                          onTap: () =>
                              setDialogState(() => selectedEmoji = emoji),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedEmoji == emoji
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                                width: selectedEmoji == emoji ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 24)),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await ref.read(petsNotifierProvider.notifier).addPet(
                        nameController.text.trim(),
                        selectedEmoji,
                      );
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Note cards ────────────────────────────────────────────────────────────

  Widget _buildNoteCard(GeneralNote note) {
    final dateStr = DateFormat('d MMM, HH:mm', 'es').format(note.createdAt);
    // Parse the stored content so we can render checkboxes interactively
    final lines = _parseNote(note.content);

    return _NoteCard(
      note: note,
      lines: lines,
      dateStr: dateStr,
      onDelete: () =>
          ref.read(jsonGeneralNotesRepositoryProvider).deleteNote(note.id),
      onShare: () => Share.share(note.content),
      petBadge: note.petId != null ? _buildNotePetBadge(note.petId!) : null,
    );
  }

  Widget _buildNotePetBadge(String petId) {
    final petsAsync = ref.watch(petsNotifierProvider);

    return petsAsync.when(
      data: (pets) {
        Pet? pet;
        try {
          pet = pets.firstWhere((p) => p.id == petId);
        } catch (e) {
          return const SizedBox.shrink();
        }

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
          Icon(Icons.sticky_note_2_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No hay notas guardadas',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text('Tus pensamientos aparecerán aquí.',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Toolbar button ───────────────────────────────────────────────────────────

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Note card with interactive checkboxes ───────────────────────────────────

class _NoteCard extends StatefulWidget {
  final GeneralNote note;
  final List<_NoteLine> lines;
  final String dateStr;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final Widget? petBadge;

  const _NoteCard({
    required this.note,
    required this.lines,
    required this.dateStr,
    required this.onDelete,
    required this.onShare,
    this.petBadge,
  });

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
  late List<_NoteLine> _lines;

  @override
  void initState() {
    super.initState();
    _lines = widget.lines;
  }

  @override
  Widget build(BuildContext context) {
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
              Text(widget.dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (widget.petBadge != null) ...[
                const SizedBox(width: 8),
                widget.petBadge!,
              ],
              const Spacer(),
              IconButton(
                onPressed: widget.onShare,
                icon: const Icon(Icons.share_outlined,
                    size: 18, color: Colors.blue),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.redAccent),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Render lines: plain lines as text, checkbox lines interactively
          for (int i = 0; i < _lines.length; i++) _buildReadLine(i),
        ],
      ),
    );
  }

  Widget _buildReadLine(int index) {
    final line = _lines[index];
    switch (line.type) {
      case _NoteLineType.checkbox:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: GestureDetector(
            onTap: () => setState(() => _lines[index].checked = !line.checked),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    line.checked
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    key: ValueKey(line.checked),
                    color: line.checked
                        ? Colors.green.shade600
                        : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: line.checked
                          ? Colors.grey.shade400
                          : const Color(0xFF1A1C1E),
                      decoration: line.checked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case _NoteLineType.numbered:
        int num = 1;
        for (int j = 0; j < index; j++) {
          if (_lines[j].type == _NoteLineType.numbered) num++;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$num. ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontSize: 15)),
              Expanded(
                child: Text(
                  line.text,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5, color: Color(0xFF1A1C1E)),
                ),
              ),
            ],
          ),
        );
      case _NoteLineType.plain:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Text(
            line.text,
            style: const TextStyle(
                fontSize: 15, height: 1.5, color: Color(0xFF1A1C1E)),
          ),
        );
    }
  }
}
