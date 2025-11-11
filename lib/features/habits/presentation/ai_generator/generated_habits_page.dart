import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/ai_providers.dart';
import '../../domain/models/micro_habit.dart';
import '../../domain/habit.dart';
import '../habits_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Page displaying AI-generated micro-habits for user selection
class GeneratedHabitsPage extends ConsumerStatefulWidget {
  const GeneratedHabitsPage({super.key});

  @override
  ConsumerState<GeneratedHabitsPage> createState() =>
      _GeneratedHabitsPageState();
}

class _GeneratedHabitsPageState extends ConsumerState<GeneratedHabitsPage> {
  final Set<String> _selectedHabitIds = {};
  final Map<String, HabitCategory> _habitCategories = {};

  /// Infers the most appropriate category based on habit action text
  HabitCategory _inferCategory(String action) {
    final lower = action.toLowerCase();

    // Physical keywords (Spanish and English)
    if (RegExp(
            r'ejercicio|correr|caminar|gym|deporte|dormir|agua|alimenta|exercise|run|walk|sleep|water|eat|stretch')
        .hasMatch(lower)) {
      return HabitCategory.physical;
    }

    // Mental keywords
    if (RegExp(
            r'leer|estudiar|aprender|escribir|meditar|reflexionar|read|study|learn|write|journal|think')
        .hasMatch(lower)) {
      return HabitCategory.mental;
    }

    // Relational keywords
    if (RegExp(
            r'familia|amigo|comunidad|llamar|visitar|compartir|family|friend|community|call|visit|share')
        .hasMatch(lower)) {
      return HabitCategory.relational;
    }

    // Spiritual (default for most Bible-based habits)
    return HabitCategory.spiritual;
  }

  Future<void> _saveSelected() async {
    if (_selectedHabitIds.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noHabitsSelected),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final generatedHabits = ref.read(microHabitGeneratorProvider).value ?? [];
    final selectedHabits =
        generatedHabits.where((h) => _selectedHabitIds.contains(h.id)).toList();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.saving),
              ],
            ),
          ),
        ),
      ),
    );

    // Add habits to repository with inferred categories
    for (final microHabit in selectedHabits) {
      final category =
          _habitCategories[microHabit.id] ?? HabitCategory.spiritual;
      final emoji = _getCategoryEmoji(category);

      await ref.read(habitsRepositoryProvider).createHabit(
            name: microHabit.action,
            description: microHabit.verseText != null
                ? '${microHabit.purpose}\n\n${microHabit.verse}: ${microHabit.verseText}'
                : '${microHabit.purpose}\n\n${microHabit.verse}',
            category: category,
            emoji: emoji,
          );
    }

    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context)
          .pop(selectedHabits.length); // Return count to generator page
    }
  }

  String _getCategoryEmoji(HabitCategory cat) {
    switch (cat) {
      case HabitCategory.spiritual:
        return '🙏';
      case HabitCategory.physical:
        return '💪';
      case HabitCategory.mental:
        return '🧠';
      case HabitCategory.relational:
        return '❤️';
      case HabitCategory.other:
        return '⭐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final generatorState = ref.watch(microHabitGeneratorProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: Text(l10n.generatedHabitsTitle),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1a202c),
        elevation: 0,
      ),
      body: generatorState.when(
        data: (habits) {
          // Initialize categories on first load
          if (_habitCategories.isEmpty && habits.isNotEmpty) {
            for (final habit in habits) {
              _habitCategories[habit.id] = _inferCategory(habit.action);
            }
          }

          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.generationFailed,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final isSelected = _selectedHabitIds.contains(habit.id);

                    return _MicroHabitCard(
                      habit: habit,
                      isSelected: isSelected,
                      initialCategory:
                          _habitCategories[habit.id] ?? HabitCategory.spiritual,
                      onToggle: () {
                        setState(() {
                          if (isSelected) {
                            _selectedHabitIds.remove(habit.id);
                          } else {
                            _selectedHabitIds.add(habit.id);
                          }
                        });
                      },
                      onCategoryChanged: (newCategory) {
                        setState(() {
                          _habitCategories[habit.id] = newCategory;
                        });
                      },
                    );
                  },
                ),
              ),

              // Bottom action bar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.selectHabitsToAdd,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff64748b),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed:
                          _selectedHabitIds.isEmpty ? null : _saveSelected,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff10b981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 2,
                      ),
                      child: Text(
                        l10n.saveSelected,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.generationFailed,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicroHabitCard extends StatefulWidget {
  final MicroHabit habit;
  final bool isSelected;
  final VoidCallback onToggle;
  final HabitCategory initialCategory;
  final ValueChanged<HabitCategory>? onCategoryChanged;

  const _MicroHabitCard({
    required this.habit,
    required this.isSelected,
    required this.onToggle,
    required this.initialCategory,
    this.onCategoryChanged,
  });

  @override
  State<_MicroHabitCard> createState() => _MicroHabitCardState();
}

class _MicroHabitCardState extends State<_MicroHabitCard> {
  late HabitCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  String _getCategoryEmoji(HabitCategory cat) {
    switch (cat) {
      case HabitCategory.spiritual:
        return '🙏';
      case HabitCategory.physical:
        return '💪';
      case HabitCategory.mental:
        return '🧠';
      case HabitCategory.relational:
        return '❤️';
      case HabitCategory.other:
        return '⭐';
    }
  }

  String _getCategoryName(HabitCategory cat, AppLocalizations l10n) {
    switch (cat) {
      case HabitCategory.spiritual:
        return l10n.spiritual;
      case HabitCategory.physical:
        return l10n.physical;
      case HabitCategory.mental:
        return l10n.mental;
      case HabitCategory.relational:
        return l10n.relational;
      case HabitCategory.other:
        return 'Other'; // Fallback category
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: widget.isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.isSelected
              ? const Color(0xff10b981)
              : Colors.grey.shade200,
          width: widget.isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    widget.isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: widget.isSelected
                        ? const Color(0xff10b981)
                        : Colors.grey.shade400,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.action,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1a202c),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.estimatedTime(widget.habit.estimatedMinutes),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Bible verse
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 20,
                    color: Colors.purple.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bibleVerse,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.habit.verse,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1a202c),
                          ),
                        ),
                        if (widget.habit.verseText != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.habit.verseText!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Purpose
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.purpose,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.habit.purpose,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Category selector (only visible when selected)
              if (widget.isSelected) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<HabitCategory>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: l10n.category,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: HabitCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Text(_getCategoryEmoji(cat)),
                                const SizedBox(width: 8),
                                Text(_getCategoryName(cat, l10n)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                            widget.onCategoryChanged?.call(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
