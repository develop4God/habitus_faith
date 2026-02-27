import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'notes_providers.dart';
import '../domain/models/general_note_model.dart';

// ─── Rich note line model ─────────────────────────────────────────────────────

enum _NoteLineType { plain, checkbox, numbered }

class _NoteLine {
  final String id;
  final _NoteLineType type;
  String text;
  bool checked;

  _NoteLine({
    required this.type,
    this.text = '',
    this.checked = false,
    String? id,
  }) : id = id ?? UniqueKey().toString();

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

  _NoteLine copyWith({_NoteLineType? type, String? text, bool? checked}) {
    return _NoteLine(
      id: id,
      type: type ?? this.type,
      text: text ?? this.text,
      checked: checked ?? this.checked,
    );
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

String _serialiseLines(List<_NoteLine> lines) {
  int num = 1;
  final sb = StringBuffer();
  for (int i = 0; i < lines.length; i++) {
    if (i > 0) sb.write('\n');
    final line = lines[i];
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

// ─── Shared Modern Widgets ──────────────────────────────────────────────────

class _ModernCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  final double size;

  const _ModernCheckbox({
    required this.checked,
    required this.onTap,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: checked ? Colors.green.shade500 : Colors.transparent,
            borderRadius: BorderRadius.circular(size * 0.35),
            border: Border.all(
              color: checked ? Colors.green.shade500 : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: checked
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
      ),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  // Rich editor state
  late List<_NoteLine> _lines;
  String? _editingNoteId;
  final Map<String, TextEditingController> _controllers = {};
  int _focusedIndex = 0;
  int _lastAddedIndex = -1;

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

  static const int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _lines = [_NoteLine(type: _NoteLineType.plain)];
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(int index) {
    final line = _lines[index];
    if (!_controllers.containsKey(line.id)) {
      _controllers[line.id] = TextEditingController(text: line.text);
    }
    return _controllers[line.id]!;
  }

  // ── Serialise lines to flat text for storage ──────────────────────────────

  String get _serialised => _serialiseLines(_lines);

  bool get _canSave {
    final text = _serialised.trim();
    return text.isNotEmpty && text.length <= _maxChars;
  }

  void _changeCurrentLineType(_NoteLineType type) {
    setState(() {
      _lines[_focusedIndex] = _lines[_focusedIndex].copyWith(type: type);
    });
  }

  void _handleSubmitted(int index) {
    final line = _lines[index];
    final text = _getController(index).text;

    if (text.isEmpty && line.type != _NoteLineType.plain) {
      setState(() {
        _lines[index] = line.copyWith(type: _NoteLineType.plain);
        _lastAddedIndex = index;
        _focusedIndex = index;
      });
    } else {
      setState(() {
        final newLine = _NoteLine(type: line.type);
        _lines.insert(index + 1, newLine);
        _lastAddedIndex = index + 1;
        _focusedIndex = index + 1;
      });
    }
  }

  void _removeLine(int index) {
    if (_lines.length == 1) {
      setState(() {
        _getController(0).text = '';
        _lines[0].text = '';
        _lines[0].checked = false;
        _focusedIndex = 0;
      });
    } else {
      setState(() {
        final line = _lines.removeAt(index);
        _controllers[line.id]?.dispose();
        _controllers.remove(line.id);
        _focusedIndex = index > 0 ? index - 1 : 0;
        _lastAddedIndex = _focusedIndex;
      });
    }
  }

  void _insertEmoji(String emoji) {
    if (_lines.isNotEmpty) {
      final controller = _getController(_focusedIndex);
      final currentText = controller.text;
      final selection = controller.selection;

      String newText;
      int newOffset;

      if (selection.isValid) {
        newText =
            currentText.replaceRange(selection.start, selection.end, emoji);
        newOffset = selection.start + emoji.length;
      } else {
        newText = currentText + emoji;
        newOffset = newText.length;
      }

      setState(() {
        controller.text = newText;
        controller.selection = TextSelection.collapsed(offset: newOffset);
        _lines[_focusedIndex].text = newText;
      });
    }
  }

  void _saveNote() {
    final text = _serialised.trim();
    if (_canSave) {
      final repo = ref.read(jsonGeneralNotesRepositoryProvider);
      if (_editingNoteId != null) {
        repo.updateNote(_editingNoteId!, text);
      } else {
        repo.addNote(text);
      }
      _clearEditor();
    }
  }

  void _clearEditor() {
    setState(() {
      for (var c in _controllers.values) {
        c.dispose();
      }
      _controllers.clear();
      _lines = [_NoteLine(type: _NoteLineType.plain)];
      _editingNoteId = null;
      _lastAddedIndex = -1;
      _focusedIndex = 0;
    });
    FocusScope.of(context).unfocus();
  }

  void _editNote(GeneralNote note) {
    setState(() {
      for (var c in _controllers.values) {
        c.dispose();
      }
      _controllers.clear();
      _editingNoteId = note.id;
      _lines = _parseNote(note.content);
      if (_lines.isEmpty) _lines = [_NoteLine(type: _NoteLineType.plain)];
      _lastAddedIndex = 0;
      _focusedIndex = 0;
    });
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
    final isEditing = _editingNoteId != null;
    final currentType = _lines[_focusedIndex].type;
    final hasContent = _serialised.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isEditing
            ? Border.all(color: Colors.orange.shade200, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Icon(isEditing ? Icons.edit : Icons.edit_note,
                  color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                isEditing ? 'Editar Nota' : 'Nueva Nota',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (isEditing || hasContent)
                IconButton(
                  onPressed: _clearEditor,
                  icon: Icon(isEditing ? Icons.close : Icons.delete_outline,
                      color: Colors.grey.shade400),
                  tooltip: isEditing ? 'Cancelar edición' : 'Descartar nota',
                ),
              IconButton(
                onPressed: _canSave ? _saveNote : null,
                icon: Icon(
                  isEditing ? Icons.check_circle : Icons.send_rounded,
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
                isSelected: currentType == _NoteLineType.checkbox,
                onTap: () => _changeCurrentLineType(_NoteLineType.checkbox),
              ),
              _ToolbarButton(
                icon: Icons.format_list_numbered_rounded,
                label: 'Numerada',
                color: Colors.blue.shade700,
                isSelected: currentType == _NoteLineType.numbered,
                onTap: () => _changeCurrentLineType(_NoteLineType.numbered),
              ),
              _ToolbarButton(
                icon: Icons.text_fields_rounded,
                label: 'Texto',
                color: Colors.purple.shade700,
                isSelected: currentType == _NoteLineType.plain,
                onTap: () => _changeCurrentLineType(_NoteLineType.plain),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Lines editor
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < _lines.length; i++) _buildLineEditor(i),
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
    final controller = _getController(index);
    Widget leading;

    switch (line.type) {
      case _NoteLineType.checkbox:
        leading = _ModernCheckbox(
          checked: line.checked,
          onTap: () => setState(() => line.checked = !line.checked),
        );
        break;
      case _NoteLineType.numbered:
        int num = 1;
        for (int i = 0; i < index; i++) {
          if (_lines[i].type == _NoteLineType.numbered) num++;
        }
        leading = Container(
          width: 26,
          padding: const EdgeInsets.only(top: 2),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: leading,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: ValueKey(line.id),
              autofocus: index == _lastAddedIndex ||
                  (index == 0 && _lines.length == 1 && line.text.isEmpty),
              controller: controller,
              onTap: () => setState(() => _focusedIndex = index),
              onChanged: (v) {
                line.text = v;
                setState(() {}); // For character counter
              },
              style: TextStyle(
                fontSize: 15,
                decoration:
                    (line.type == _NoteLineType.checkbox && line.checked)
                        ? TextDecoration.lineThrough
                        : null,
                color: (line.type == _NoteLineType.checkbox && line.checked)
                    ? Colors.grey.shade400
                    : Colors.grey.shade900,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: line.type == _NoteLineType.checkbox
                    ? 'Elemento de lista...'
                    : line.type == _NoteLineType.numbered
                        ? 'Paso...'
                        : 'Escribe una nota...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSubmitted(index),
            ),
          ),
          if (_lines.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: GestureDetector(
                onTap: () => _removeLine(index),
                child: Icon(Icons.remove_circle_outline,
                    size: 16, color: Colors.grey.shade400),
              ),
            ),
        ],
      ),
    );
  }

  // ── Note cards ────────────────────────────────────────────────────────────

  Widget _buildNoteCard(GeneralNote note) {
    final dateStr = DateFormat('d MMM, HH:mm', 'es').format(note.createdAt);
    final lines = _parseNote(note.content);

    return _NoteCard(
      note: note,
      lines: lines,
      dateStr: dateStr,
      onEdit: () => _editNote(note),
      onDelete: () =>
          ref.read(jsonGeneralNotesRepositoryProvider).deleteNote(note.id),
      onShare: () => Share.share(note.content),
      onUpdate: (updatedContent) => ref
          .read(jsonGeneralNotesRepositoryProvider)
          .updateNote(note.id, updatedContent),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                )),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final Function(String updatedContent) onUpdate;

  const _NoteCard({
    required this.note,
    required this.lines,
    required this.dateStr,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.onUpdate,
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
  void didUpdateWidget(_NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note.content != oldWidget.note.content) {
      _lines = widget.lines;
    }
  }

  void _toggleLine(int index) {
    setState(() {
      _lines[index].checked = !_lines[index].checked;
    });
    widget.onUpdate(_serialiseLines(_lines));
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Text(widget.dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Spacer(),
              IconButton(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: Colors.orange),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
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
          child: InkWell(
            onTap: () => _toggleLine(index),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ModernCheckbox(
                  checked: line.checked,
                  onTap: () => _toggleLine(index),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: line.checked
                          ? Colors.grey.shade400
                          : const Color(0xFF1A1C1E),
                      decoration: line.checked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    child: Text(line.text),
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
