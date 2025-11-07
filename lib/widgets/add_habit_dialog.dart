import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/predefined_habits_data.dart';
import '../features/habits/domain/models/predefined_habit.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../pages/habits_page.dart';
import '../l10n/app_localizations.dart';
import '../utils/predefined_habit_translations.dart';
import 'dart:math';

/// Dialog tipo discovery para agregar hábito, con pasos y skip en campos opcionales
class AddHabitDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final int initialTab;

  const AddHabitDialog({super.key, required this.l10n, this.initialTab = 0});

  @override
  ConsumerState<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<AddHabitDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _gradientController;
  int _step = 0;

  // Campos del hábito
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final emojiCtrl = TextEditingController();
  HabitCategory selectedCategory = HabitCategory.mental;
  HabitDifficulty selectedDifficulty = HabitDifficulty.medium;
  Color? selectedColor;

  // Para expand/collapse de campos opcionales
  bool showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gradientController.dispose();
    nameCtrl.dispose();
    descCtrl.dispose();
    emojiCtrl.dispose();
    super.dispose();
  }

  // Gradiente animado para el header según tab
  Gradient _getHeaderGradient() {
    final t = _gradientController.value;
    if (_tabController.index == 0) {
      // Custom: púrpura
      return LinearGradient(
        colors: [
          Color.lerp(const Color(0xff7c3aed), const Color(0xffc4b5fd), (sin(t * 2 * pi) + 1) / 2)!,
          Color.lerp(const Color(0xffc4b5fd), const Color(0xff7c3aed), (cos(t * 2 * pi) + 1) / 2)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Default: cyan
      return LinearGradient(
        colors: [
          Color.lerp(const Color(0xff06b6d4), const Color(0xffa5f3fc), (sin(t * 2 * pi) + 1) / 2)!,
          Color.lerp(const Color(0xffa5f3fc), const Color(0xff06b6d4), (cos(t * 2 * pi) + 1) / 2)!,
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );
    }
  }

  // Wizard steps para agregar hábito manual
  final List<String> _steps = [
    'name', // obligatorio
    'desc', // opcional
    'emoji', // opcional
    'category', // opcional
    'difficulty', // opcional
    'color', // opcional
  ];

  void _nextStep() {
    setState(() {
      if (_step < _steps.length - 1) {
        _step++;
      }
    });
  }

  void _prevStep() {
    setState(() {
      if (_step > 0) {
        _step--;
      }
    });
  }


  Future<void> _saveHabit() async {
    final navigator = Navigator.of(context);
    await ref.read(jsonHabitsNotifierProvider.notifier).addHabit(
          name: nameCtrl.text,
          description: descCtrl.text,
          category: selectedCategory,
          emoji: emojiCtrl.text.isNotEmpty ? emojiCtrl.text : null,
          colorValue: selectedColor?.toARGB32(),
          difficulty: selectedDifficulty,
        );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = selectedColor ?? HabitColors.categoryColors[selectedCategory]!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: AnimatedBuilder(
        animation: Listenable.merge([_gradientController, _tabController]),
        builder: (context, _) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con gradiente animado y tabs modernos
                Container(
                  decoration: BoxDecoration(
                    gradient: _getHeaderGradient(),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                  child: Stack(
                    children: [
                      // Botón X arriba derecha
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 32, color: Colors.white),
                          splashRadius: 26,
                          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              widget.l10n.addHabit,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Tabs modernos
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _OptionTab(
                                  label: widget.l10n.custom,
                                  icon: Icons.edit_note,
                                  selected: _tabController.index == 0,
                                  color: const Color(0xff7c3aed),
                                  onTap: () {
                                    _tabController.animateTo(0);
                                    setState(() {
                                      _step = 0;
                                    });
                                  },
                                ),
                                _OptionTab(
                                  label: widget.l10n.defaultHabit,
                                  icon: Icons.checklist_outlined,
                                  selected: _tabController.index == 1,
                                  color: const Color(0xff06b6d4),
                                  onTap: () {
                                    _tabController.animateTo(1);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Cuerpo del dialogo
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Paso a paso para custom
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildDiscoveryStep(habitColor),
                      ),
                      // Default (predefinidos) habit tab
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: Color(0xff06b6d4)),
                                const SizedBox(width: 8),
                                Text(
                                  widget.l10n.chooseFromPredefined,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff06b6d4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: GridView.builder(
                                padding: EdgeInsets.zero,
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
                                          color: categoryColor.withValues(alpha:0.7),
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: categoryColor.withValues(alpha:0.13),
                                            blurRadius: 16,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
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
                            ),
                          ],
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

  Widget _buildDiscoveryStep(Color habitColor) {
    final stepKey = _steps[_step];
    final isLast = _step == _steps.length - 1;

    String stepLabel;
    bool isRequired = false;
    switch (stepKey) {
      case 'name':
        stepLabel = widget.l10n.name;
        isRequired = true;
        break;
      case 'desc':
        stepLabel = widget.l10n.description;
        break;
      case 'emoji':
        stepLabel = widget.l10n.emoji;
        break;
      case 'category':
        stepLabel = widget.l10n.category;
        break;
      case 'difficulty':
        stepLabel = widget.l10n.difficulty;
        break;
      case 'color':
        stepLabel = widget.l10n.color;
        break;
      default:
        stepLabel = '';
    }

    Widget stepWidget;
    switch (stepKey) {
      case 'name':
        stepWidget = TextField(
          key: const Key('habit_name_input'),
          controller: nameCtrl,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: '$stepLabel *',
            border: const OutlineInputBorder(),
            hintText: widget.l10n.previewHabitName,
            counterText: '${nameCtrl.text.length}/40',
            helperText: nameCtrl.text.length == 40 ? widget.l10n.maxThreeHabits : null,
          ),
          onChanged: (value) => setState(() {}),
          onSubmitted: (_) {
            if (nameCtrl.text.isNotEmpty) _nextStep();
          },
        );
        break;
      case 'desc':
        stepWidget = TextField(
          key: const Key('habit_description_input'),
          controller: descCtrl,
          maxLength: 120,
          decoration: InputDecoration(
            labelText: '${widget.l10n.description} (${widget.l10n.optional})',
            border: const OutlineInputBorder(),
            hintText: widget.l10n.previewHabitDescription,
            counterText: '${descCtrl.text.length}/120',
            helperText: descCtrl.text.length == 120 ? widget.l10n.maxThreeHabits : null,
          ),
          maxLines: 2,
          onChanged: (value) => setState(() {}),
          onSubmitted: (_) => _nextStep(),
        );
        break;
      case 'emoji':
        stepWidget = TextField(
          controller: emojiCtrl,
          decoration: InputDecoration(
            labelText: '${widget.l10n.emoji} (${widget.l10n.optional})',
            border: const OutlineInputBorder(),
            hintText: '🙏',
            counterText: '${emojiCtrl.text.length}/2',
            helperText: emojiCtrl.text.length == 2 ? widget.l10n.maxThreeHabits : null,
          ),
          maxLength: 2,
          onChanged: (value) => setState(() {}),
          onSubmitted: (_) => _nextStep(),
        );
        break;
      case 'category':
        stepWidget = DropdownButtonFormField<HabitCategory>(
          initialValue: selectedCategory,
          decoration: InputDecoration(
            labelText: '${widget.l10n.category} (${widget.l10n.optional})',
            border: const OutlineInputBorder(),
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
          onSaved: (_) => _nextStep(),
        );
        break;
      case 'difficulty':
        stepWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solo una vez el label, no duplicado
            const SizedBox(height: 8),
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
                      _nextStep();
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
          ],
        );
        break;
      case 'color':
        stepWidget = _ColorPickerSection(
          selectedColor: selectedColor,
          selectedCategory: selectedCategory,
          onColorSelected: (color) {
            setState(() {
              selectedColor = color;
            });
            _nextStep();
          },
          l10n: widget.l10n,
        );
        break;
      default:
        stepWidget = const SizedBox.shrink();
    }


    // Barra de pasos visual
    Widget stepsBar = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (i) {
        final isActive = i == _step;
        final isCompleted = i < _step;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 18,
          height: 8,
          decoration: BoxDecoration(
            color: isCompleted
                ? habitColor
                : isActive
                    ? habitColor.withValues(alpha:0.8)
                    : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
            border: isActive
                ? Border.all(color: habitColor, width: 2)
                : null,
          ),
        );
      }),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barra de pasos visual y progreso
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              stepsBar,
              const SizedBox(height: 8),
              Text(
                '${_step + 1} / ${_steps.length}  •  ${isRequired ? widget.l10n.requiredFieldLabel : widget.l10n.optional}',
                style: TextStyle(
                  fontSize: 13,
                  color: isRequired ? Colors.red : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Vista previa arriba
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: habitColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: habitColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emojiCtrl.text.isNotEmpty ? emojiCtrl.text : '✓',
                    style: const TextStyle(fontSize: 22),
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
                        fontSize: 15,
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
                        fontSize: 13,
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
        stepWidget,
        const SizedBox(height: 18),
        // Navegación clara: Back siempre izquierda, Continue siempre derecha
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: Text(widget.l10n.back),
              onPressed: _step > 0 ? _prevStep : null,
            ),
            if (!isLast)
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                onPressed: (stepKey == 'name' && nameCtrl.text.isEmpty)
                    ? null
                    : _nextStep,
                label: Text(widget.l10n.continueButton),
              )
            else
              ElevatedButton.icon(
                key: const Key('confirm_add_habit_button'),
                icon: const Icon(Icons.check),
                onPressed: nameCtrl.text.isNotEmpty ? _saveHabit : null,
                label: Text(widget.l10n.add),
              ),
          ],
        ),
        // Botón Skip centrado y más abajo
        if (_step < _steps.length - 1 && _step > 0)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.skip_next, size: 18),
                label: Text(widget.l10n.optional),
                onPressed: () {
                  setState(() {
                    _step = _steps.length - 1;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback? onTap;

  const _OptionTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Selector de color agrupado y moderno
class _ColorPickerSection extends StatelessWidget {
  final Color? selectedColor;
  final HabitCategory selectedCategory;
  final ValueChanged<Color?> onColorSelected;
  final AppLocalizations l10n;

  const _ColorPickerSection({
    required this.selectedColor,
    required this.selectedCategory,
    required this.onColorSelected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Agrupa colores por tono
    final List<List<Color>> colorGroups = [
      [const Color(0xff7c3aed), const Color(0xffa78bfa), const Color(0xffc4b5fd)], // Purple
      [const Color(0xff06b6d4), const Color(0xff67e8f9), const Color(0xffa5f3fc)], // Cyan
      [const Color(0xfff59e42), const Color(0xffffe0b2)], // Orange
      [const Color(0xff22c55e), const Color(0xffbbf7d0)], // Green
      [const Color(0xff6366f1), const Color(0xffa5b4fc)], // Indigo
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.color} (${l10n.optional})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildColorOption(
              null,
              HabitColors.categoryColors[selectedCategory]!,
              l10n.defaultColor,
            ),
            ...colorGroups.expand((group) => [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: group
                        .map((color) => _buildColorOption(color, color, null))
                        .toList(),
                  ),
                ]),
          ],
        ),
      ],
    );
  }

  Widget _buildColorOption(Color? colorValue, Color displayColor, String? label) {
    final isSelected = selectedColor == colorValue;

    return GestureDetector(
      onTap: () => onColorSelected(colorValue),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: displayColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
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
