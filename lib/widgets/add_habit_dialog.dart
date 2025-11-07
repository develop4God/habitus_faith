import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/predefined_habits_data.dart';
import '../features/habits/domain/models/predefined_habit.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../pages/habits_page.dart';
import '../l10n/app_localizations.dart';
import '../utils/predefined_habit_translations.dart';

/// Diálogo para agregar un nuevo hábito, con tabs para entrada manual y hábitos predefinidos
class AddHabitDiscoveryDialog extends StatelessWidget {
  final AppLocalizations l10n;

  const AddHabitDiscoveryDialog({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline, size: 56, color: Color(0xff6366f1)),
            const SizedBox(height: 16),
            Text(
              l10n.addHabit,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Lottie de mano para indicar tap
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: SizedBox(
                height: 80,
                width: 80,
                child: Lottie.asset(
                  'assets/lottie/tap_screen.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Text(
              l10n.chooseHabitType,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xff6366f1),
                      side: const BorderSide(color: Color(0xff6366f1), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AddHabitDialog(
                          l10n: l10n,
                          initialTab: 0,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_note, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          l10n.manual,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xff6366f1),
                      side: const BorderSide(color: Color(0xff6366f1), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AddHabitDialog(
                          l10n: l10n,
                          initialTab: 1,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          l10n.custom,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog para agregar hábito, ahora recibe initialTab para abrir la vista correcta
class AddHabitDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final int initialTab;

  const AddHabitDialog({super.key, required this.l10n, this.initialTab = 0});

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
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con tabs modernos
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.l10n.addHabit,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xff6366f1),
                          indicator: BoxDecoration(
                            color: const Color(0xff6366f1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          tabs: [
                            Tab(
                              icon: const Icon(Icons.edit_note),
                              text: widget.l10n.manual,
                            ),
                            Tab(
                              icon: const Icon(Icons.star),
                              text: widget.l10n.custom,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab views con mayor altura y scroll
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Manual entry tab
                      Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: _buildManualEntryTab(habitColor),
                        ),
                      ),
                      // Predefined habits tab
                      Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: _buildPredefinedHabitsTab(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _buildPredefinedHabitsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Título moderno
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xff6366f1)),
              const SizedBox(width: 8),
              Text(
                widget.l10n.chooseFromPredefined,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6366f1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: predefinedHabits.length,
            itemBuilder: (context, index) {
              final habit = predefinedHabits[index];
              final habitName = PredefinedHabitTranslations.getTranslatedName(
                  widget.l10n, habit.nameKey);
              final categoryColor = HabitColors.categoryColors[
                  PredefinedHabitCategoryX(habit.category).toDomainCategory()]!;

              return InkWell(
                onTap: () async {
                  await ref.read(jsonHabitsNotifierProvider.notifier).addHabit(
                        name: habitName,
                        description: PredefinedHabitTranslations.getTranslatedDescription(
                            widget.l10n, habit.descriptionKey),
                        category:
                            PredefinedHabitCategoryX(habit.category).toDomainCategory(),
                        emoji: habit.emoji,
                      );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          habit.emoji,
                          style: const TextStyle(fontSize: 44),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          habitName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1a202c),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
