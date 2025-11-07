import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/predefined_habits_data.dart';
import '../features/habits/domain/models/predefined_habit.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../pages/habits_page.dart';
import '../l10n/app_localizations.dart';
import '../utils/predefined_habit_translations.dart';

/// Dialog for adding a new habit with tabs for manual entry and predefined habits
class AddHabitDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;

  const AddHabitDialog({super.key, required this.l10n});

  @override
  ConsumerState<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<AddHabitDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final emojiCtrl = TextEditingController();
  HabitCategory selectedCategory = HabitCategory.mental;
  HabitDifficulty selectedDifficulty = HabitDifficulty.medium;
  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameCtrl.dispose();
    descCtrl.dispose();
    emojiCtrl.dispose();
    super.dispose();
  }

  // Helper function to translate predefined habit names

  @override
  Widget build(BuildContext context) {
    final habitColor =
        selectedColor ?? HabitColors.categoryColors[selectedCategory]!;

    return Dialog(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with title and tabs
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.l10n.addHabit,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TabBar(
                          controller: _tabController,
                          labelColor: const Color(0xff6366f1),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color(0xff6366f1),
                          tabs: [
                            Tab(text: widget.l10n.addManually),
                            Tab(text: widget.l10n.createCustomHabit),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tab views
                  SizedBox(
                    height: 500, // Ajusta este valor si es necesario
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Manual entry tab
                        _buildManualEntryTab(habitColor),
                        // Predefined habits tab
                        _buildPredefinedHabitsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManualEntryTab(Color habitColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quitar subtítulo de vista previa
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: habitColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: habitColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Color indicator
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habitColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Emoji en la vista previa
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      emojiCtrl.text.isNotEmpty ? emojiCtrl.text : '✓',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameCtrl.text.isNotEmpty
                            ? nameCtrl.text
                            : widget.l10n.previewHabitName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descCtrl.text.isNotEmpty
                            ? descCtrl.text
                            : widget.l10n.previewHabitDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          TextField(
            key: const Key('habit_name_input'),
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: widget.l10n.name,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('habit_description_input'),
            controller: descCtrl,
            decoration: InputDecoration(
              labelText: widget.l10n.description,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emojiCtrl,
            decoration: const InputDecoration(
              labelText: 'Emoji',
              border: OutlineInputBorder(),
              hintText: '🙏',
            ),
            maxLength: 2,
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),
          // Quitar subtítulo de categoría
          DropdownButtonFormField<HabitCategory>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: HabitCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      HabitColors.getCategoryIcon(category),
                      size: 20,
                      color: HabitColors.categoryColors[category],
                    ),
                    const SizedBox(width: 8),
                    Text(HabitColors.getCategoryDisplayName(
                        category, widget.l10n))
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCategory = value;
                  selectedColor = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // Quitar subtítulo de dificultad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: HabitDifficulty.values.map((difficulty) {
              final isSelected = selectedDifficulty == difficulty;
              final color = HabitColors.categoryColors[selectedCategory]!;

              return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDifficulty = difficulty;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            HabitDifficultyHelper.getDifficultyStars(difficulty),
                            (index) => Icon(
                              Icons.star,
                              size: 18,
                              color: isSelected ? color : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          difficulty.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? color : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ));
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Quitar subtítulo de color
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildColorOption(
                null,
                HabitColors.categoryColors[selectedCategory]!,
                widget.l10n.defaultColor,
              ),
              ...HabitColors.availableColors.map(
                (color) => _buildColorOption(color, color, null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(widget.l10n.cancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                key: const Key('confirm_add_habit_button'),
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                    await ref.read(jsonHabitsNotifierProvider.notifier).addHabit(
                          name: nameCtrl.text,
                          description: descCtrl.text,
                          category: selectedCategory,
                          emoji: emojiCtrl.text.isNotEmpty ? emojiCtrl.text : null,
                          colorValue: selectedColor?.toARGB32(),
                          difficulty: selectedDifficulty,
                        );
                    if (!mounted) return;
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.l10n.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredefinedHabitsTab() {
    return SizedBox(
      height: 500, // Igual que el TabBarView principal
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: predefinedHabits.length,
        itemBuilder: (context, index) {
          final habit = predefinedHabits[index];
          final habitName = PredefinedHabitTranslations.getTranslatedName(
              widget.l10n, habit.nameKey);
          final habitDescription =
              PredefinedHabitTranslations.getTranslatedDescription(
                  widget.l10n, habit.descriptionKey);
          final categoryColor = HabitColors.categoryColors[
              PredefinedHabitCategoryX(habit.category).toDomainCategory()]!;

          return InkWell(
            onTap: () async {
              // Add the predefined habit
              await ref.read(jsonHabitsNotifierProvider.notifier).addHabit(
                    name: habitName,
                    description: habitDescription,
                    category:
                        PredefinedHabitCategoryX(habit.category).toDomainCategory(),
                    emoji: habit.emoji,
                  );
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Color indicator
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Emoji
                    Flexible(
                      child: Text(
                        habit.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Name
                    Flexible(
                      child: Text(
                        habitName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1a202c),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Expanded(
                      child: Text(
                        habitDescription,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorOption(Color? colorValue, Color displayColor, String? label) {
    final isSelected = selectedColor == colorValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = colorValue;
        });
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: displayColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

// Helper extension for converting predefined category
extension PredefinedHabitCategoryX on PredefinedHabitCategory {
  HabitCategory toDomainCategory() {
    switch (this) {
      case PredefinedHabitCategory.spiritual:
        return HabitCategory.spiritual;
      case PredefinedHabitCategory.physical:
        return HabitCategory.physical;
      case PredefinedHabitCategory.mental:
        return HabitCategory.mental;
      case PredefinedHabitCategory.relational:
        return HabitCategory.relational;
    }
  }
}
