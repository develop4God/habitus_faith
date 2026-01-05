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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Scrollbar(
          thumbVisibility: true,
          interactive: true,
          child: SingleChildScrollView(
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
                                    .withAlpha(179),
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

                // Actions Row moved above the TextField
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _noteController,
                    builder: (context, value, child) {
                      final hasText = value.text.trim().isNotEmpty;
                      if (!hasText) return const SizedBox.shrink();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: OutlinedButton.icon(
                              onPressed: _shareNote,
                              icon: const Icon(Icons.share, size: 18),
                              label: Text(l10n.shareNote),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: FilledButton.icon(
                              onPressed: () {
                                final note = _noteController.text.trim();
                                widget.onSave?.call(note);
                                Navigator.of(context).pop(note);
                              },
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(l10n.add),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 40),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                        label: Text(_showEmojiPicker ? l10n.hideEmojis : l10n.addEmoji),
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
                            color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
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
              ],
            ),
          ),
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
