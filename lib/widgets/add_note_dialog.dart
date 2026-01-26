import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';

/// Minimalist dialog for adding notes to completed habits
/// Features:
/// - Modern, user-friendly bottom sheet style
/// - One-tap quick emojis
/// - Intuitive visual hierarchy
class AddNoteDialog extends StatefulWidget {
  final String habitName;
  final String? existingNote;
  final VoidCallback? onCancel;
  final Function(String note)? onSave;

  const AddNoteDialog({
    super.key,
    required this.habitName,
    this.existingNote,
    this.onCancel,
    this.onSave,
  });

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  late TextEditingController _noteController;

  // Curated quick emojis for daily reflection
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
    '🔥'
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.existingNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _insertEmoji(String emoji) {
    final text = _noteController.text;
    final selection = _noteController.selection;

    // If no selection, just append
    if (selection.start == -1) {
      setState(() => _noteController.text += emoji);
      return;
    }

    final newText = text.replaceRange(selection.start, selection.end, emoji);
    _noteController.value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: selection.start + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle for bottom sheet look
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.addNoteDialog,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        widget.habitName,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Quick Emoji Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _quickEmojis
                    .map((emoji) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _insertEmoji(emoji),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(emoji,
                                  style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  autofocus: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.noteHint,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final note = _noteController.text.trim();
                          if (note.isNotEmpty) {
                            Share.share('${widget.habitName}\n\n$note');
                          }
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: Text(l10n.shareNote),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final note = _noteController.text.trim();
                          widget.onSave?.call(note);
                          Navigator.of(context).pop(note);
                        },
                        icon: const Icon(Icons.check),
                        label: Text(l10n.save),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the modern add note bottom sheet
Future<String?> showAddNoteDialog({
  required BuildContext context,
  required String habitName,
  String? existingNote,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddNoteDialog(
      habitName: habitName,
      existingNote: existingNote,
    ),
  );
}
