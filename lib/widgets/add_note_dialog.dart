import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';

/// Minimalist dialog for adding notes to completed habits
/// Features:
/// - Clean, intuitive UI
/// - Emoji picker for enhanced expression
/// - Share functionality
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
  bool _showEmojiPicker = false;

  // Curated list of faith-related and positive emojis
  final List<String> _emojis = [
    '🙏', '✝️', '❤️', '🕊️', '⭐', '🌟', '💫', '✨',
    '😊', '😌', '🙌', '💪', '👍', '🎯', '🔥', '💯',
    '📖', '⛪', '🎵', '🎶', '🌅', '🌄', '🌈', '☀️',
    '💡', '🎉', '🎊', '🏆', '🎁', '💝', '🌺', '🌸',
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
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );
    _noteController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.length,
      ),
    );
  }

  void _shareNote() {
    final note = _noteController.text.trim();
    if (note.isNotEmpty) {
      Share.share(
        '${widget.habitName}\n\n$note',
        subject: widget.habitName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.addNoteDialog,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.habitName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // Note input
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.noteHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Emoji toggle button
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showEmojiPicker = !_showEmojiPicker;
                      });
                    },
                    icon: Icon(_showEmojiPicker ? Icons.close : Icons.emoji_emotions),
                    label: Text(_showEmojiPicker ? 'Hide Emojis' : 'Add Emoji'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  // Emoji picker
                  if (_showEmojiPicker) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _emojis.map((emoji) {
                          return InkWell(
                            onTap: () => _insertEmoji(emoji),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Share button
                  OutlinedButton.icon(
                    onPressed: _shareNote,
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(l10n.shareNote),
                  ),

                  // Save button
                  FilledButton.icon(
                    onPressed: () {
                      final note = _noteController.text.trim();
                      widget.onSave?.call(note);
                      Navigator.of(context).pop(note);
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the add note dialog and returns the note text
Future<String?> showAddNoteDialog({
  required BuildContext context,
  required String habitName,
  String? existingNote,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => AddNoteDialog(
      habitName: habitName,
      existingNote: existingNote,
    ),
  );
}
