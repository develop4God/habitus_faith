import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/models/predefined_habits_data.dart';
import '../features/habits/domain/models/predefined_habit.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../features/habits/presentation/constants/habit_colors.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../l10n/app_localizations.dart';
import '../utils/predefined_habit_translations.dart';
import 'recurrence_config_dialog.dart';
import 'dart:math';

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

  final nameCtrl = TextEditingController();
  final emojiCtrl = TextEditingController();
  HabitCategory selectedCategory = HabitCategory.mental;
  HabitDifficulty selectedDifficulty = HabitDifficulty.medium;
  Color? selectedColor;
  HabitRecurrence? recurrence;

  // Add ScrollController for flash task
  final ScrollController _flashTaskScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _step = 0;
        });
        // Autofix: Scroll to top when flash task tab is selected
        if (_tabController.index == 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_flashTaskScrollController.hasClients) {
              _flashTaskScrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      }
    });
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
    emojiCtrl.dispose();
    _flashTaskScrollController.dispose();
    super.dispose();
  }

  Gradient _getHeaderGradient() {
    final t = _gradientController.value;
    if (_tabController.index == 0) {
      return LinearGradient(
        colors: [
          Color.lerp(
            const Color(0xff7c3aed),
            const Color(0xffc4b5fd),
            (sin(t * 2 * pi) + 1) / 2,
          )!,
          Color.lerp(
            const Color(0xffc4b5fd),
            const Color(0xff7c3aed),
            (cos(t * 2 * pi) + 1) / 2,
          )!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (_tabController.index == 1) {
      return LinearGradient(
        colors: [
          Color.lerp(
            const Color(0xff06b6d4),
            const Color(0xffa5f3fc),
            (sin(t * 2 * pi) + 1) / 2,
          )!,
          Color.lerp(
            const Color(0xffa5f3fc),
            const Color(0xff06b6d4),
            (cos(t * 2 * pi) + 1) / 2,
          )!,
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );
    } else {
      return LinearGradient(
        colors: [
          Color.lerp(
            const Color(0xffffd700),
            const Color(0xffffa500),
            (sin(t * 2 * pi) + 1) / 2,
          )!,
          Color.lerp(
            const Color(0xffffa500),
            const Color(0xffffd700),
            (cos(t * 2 * pi) + 1) / 2,
          )!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  final List<String> _steps = [
    'name',
    'emoji',
    'category',
    'difficulty',
    'color',
    'recurrence',
  ];

  void _nextStep() {
    setState(() {
      if (_step < _steps.length - 1) _step++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_step > 0) _step--;
    });
  }

  Future<void> _saveHabit() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(habitsNotifierProvider.notifier).addHabit(
          name: nameCtrl.text,
          category: selectedCategory,
          emoji: emojiCtrl.text.isNotEmpty ? emojiCtrl.text : null,
          colorValue: selectedColor?.toARGB32(),
          difficulty: selectedDifficulty,
        );

    if (recurrence != null && recurrence!.enabled) {
      final habits = await ref.read(habitsStreamProvider.future);
      final newHabit = habits.firstWhere((h) => h.name == nameCtrl.text);
      await ref
          .read(habitsNotifierProvider.notifier)
          .updateHabit(habitId: newHabit.id, recurrence: recurrence);
    }
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.l10n.habitCreated),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = _tabController.index == 2
        ? const Color(0xffb45309)
        : (selectedColor ?? HabitColors.categoryColors[selectedCategory]!);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: AnimatedBuilder(
        animation: Listenable.merge([_gradientController, _tabController]),
        builder: (context, _) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 620),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: _getHeaderGradient(),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 32,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  children: [
                                    _OptionTab(
                                      label: widget.l10n.custom,
                                      icon: Icons.edit_note,
                                      selected: _tabController.index == 0,
                                      color: const Color(0xff7c3aed),
                                      onTap: () => _tabController.animateTo(0),
                                    ),
                                    _OptionTab(
                                      label: widget.l10n.defaultHabit,
                                      icon: Icons.checklist_outlined,
                                      selected: _tabController.index == 1,
                                      color: const Color(0xff06b6d4),
                                      onTap: () => _tabController.animateTo(1),
                                    ),
                                    _OptionTab(
                                      label: widget.l10n.flashTask,
                                      icon: Icons.bolt,
                                      selected: _tabController.index == 2,
                                      color: const Color(0xffb45309),
                                      onTap: () => _tabController.animateTo(2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildDiscoveryStep(habitColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildPredefinedGrid(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildFlashTaskView(
                            habitColor, _flashTaskScrollController),
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

  Widget _buildFlashTaskView(Color habitColor, ScrollController controller) {
    final List<String> quickEmojis = [
      '⚡',
      '🙏',
      '✨',
      '📖',
      '🏃',
      '💧',
      '✅',
      '🔥',
    ];

    return SingleChildScrollView(
      controller: controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewCard(habitColor),
          const SizedBox(height: 24),
          // Name Input
          TextField(
            controller: nameCtrl,
            autofocus: true,
            maxLength: 40,
            decoration: InputDecoration(
              labelText: '${widget.l10n.name} *',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),
          // Emoji Input & Quick Select Row
          Text(
            '${widget.l10n.emoji} (${widget.l10n.optional})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 70,
                child: TextField(
                  controller: emojiCtrl,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  maxLength: 2,
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: quickEmojis
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () => setState(() => emojiCtrl.text = e),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: emojiCtrl.text == e
                                      ? habitColor.withValues(alpha: 0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: emojiCtrl.text == e
                                        ? habitColor
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  e,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Save Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 24),
              label: Text(
                widget.l10n.add,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: nameCtrl.text.isNotEmpty ? _saveHabit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: habitColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(Color habitColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: habitColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: habitColor.withValues(alpha: 0.3)),
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
            child: Text(
              nameCtrl.text.isNotEmpty
                  ? nameCtrl.text
                  : widget.l10n.previewHabitName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryStep(Color habitColor) {
    final stepKey = _steps[_step];
    final isLast = _step == _steps.length - 1;
    String stepLabel = '';
    bool isRequired = false;

    switch (stepKey) {
      case 'name':
        stepLabel = widget.l10n.name;
        isRequired = true;
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
      case 'recurrence':
        stepLabel = widget.l10n.repetition;
        break;
    }

    return Column(
      children: [
        _buildStepBar(habitColor),
        const SizedBox(height: 8),
        Text(
          '${_step + 1} / ${_steps.length} • ${isRequired ? widget.l10n.requiredFieldLabel : widget.l10n.optional}',
          style: TextStyle(
            fontSize: 13,
            color: isRequired ? Colors.red : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        _buildPreviewCard(habitColor),
        const SizedBox(height: 16),
        _buildStepInput(stepKey, stepLabel),
        const Spacer(),
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
                label: Text(widget.l10n.continueButton),
                onPressed: (stepKey == 'name' && nameCtrl.text.isEmpty)
                    ? null
                    : _nextStep,
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: Text(widget.l10n.add),
                onPressed: nameCtrl.text.isNotEmpty ? _saveHabit : null,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepBar(Color habitColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _steps.length,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _step ? 28 : 18,
          height: 8,
          decoration: BoxDecoration(
            color: i < _step
                ? habitColor
                : (i == _step
                    ? habitColor.withValues(alpha: 0.8)
                    : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
            border: i == _step ? Border.all(color: habitColor, width: 2) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStepInput(String stepKey, String stepLabel) {
    switch (stepKey) {
      case 'name':
        return TextField(
          controller: nameCtrl,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: '$stepLabel *',
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => setState(() {}),
        );
      case 'emoji':
        return TextField(
          controller: emojiCtrl,
          decoration: InputDecoration(
            labelText: '$stepLabel (${widget.l10n.optional})',
            border: const OutlineInputBorder(),
          ),
          maxLength: 2,
          onChanged: (v) => setState(() {}),
        );
      case 'category':
        return DropdownButtonFormField<HabitCategory>(
          value: selectedCategory,
          decoration: InputDecoration(
            labelText: '$stepLabel (${widget.l10n.optional})',
            border: const OutlineInputBorder(),
          ),
          items: HabitCategory.values
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(
                    HabitColors.getCategoryDisplayName(c, widget.l10n),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => selectedCategory = v!),
        );
      case 'difficulty':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: HabitDifficulty.values
              .map((d) => _buildDifficultyOption(d))
              .toList(),
        );
      case 'color':
        return _ColorPickerSection(
          selectedColor: selectedColor,
          selectedCategory: selectedCategory,
          onColorSelected: (c) => setState(() => selectedColor = c),
          l10n: widget.l10n,
        );
      case 'recurrence':
        return _buildRecurrenceCard();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDifficultyOption(HabitDifficulty d) {
    final isSelected = selectedDifficulty == d;
    final color = HabitColors.categoryColors[selectedCategory]!;
    return GestureDetector(
      onTap: () {
        setState(() => selectedDifficulty = d);
        _nextStep();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: List.generate(
                HabitDifficultyHelper.getDifficultyStars(d),
                (i) => Icon(
                  Icons.star,
                  size: 16,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ),
            Text(d.displayName, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceCard() {
    return Card(
      color: Colors.green.shade50,
      child: ListTile(
        leading: const Icon(Icons.repeat, color: Colors.green),
        title: Text(widget.l10n.repetition),
        subtitle: Text(
          recurrence?.enabled == true
              ? recurrence!.frequency.displayName
              : widget.l10n.noRepetition,
        ),
        onTap: () async {
          final res = await showDialog<HabitRecurrence>(
            context: context,
            builder: (c) =>
                RecurrenceConfigDialog(initialRecurrence: recurrence),
          );
          if (res != null) setState(() => recurrence = res);
        },
      ),
    );
  }

  Widget _buildPredefinedGrid() {
    // Group habits by category
    final Map<PredefinedHabitCategory, List<PredefinedHabit>> habitsByCategory =
        {};
    for (final habit in predefinedHabits) {
      habitsByCategory.putIfAbsent(habit.category, () => []).add(habit);
    }

    // Category order for display
    final categoryOrder = [
      PredefinedHabitCategory.spiritual,
      PredefinedHabitCategory.physical,
      PredefinedHabitCategory.mental,
      PredefinedHabitCategory.relational,
      PredefinedHabitCategory.household,
    ];

    return DefaultTabController(
      length: categoryOrder.length,
      child: Column(
        children: [
          // Header with title
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xff06b6d4)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.l10n.chooseFromPredefined,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff06b6d4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category tabs
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              isScrollable: true,
              labelColor: const Color(0xff06b6d4),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xff06b6d4),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              tabs: categoryOrder.map((category) {
                final categoryName = HabitColors.getCategoryDisplayName(
                  PredefinedHabitCategoryX(category).toDomainCategory(),
                  widget.l10n,
                );
                final habits = habitsByCategory[category] ?? [];
                final color = HabitColors.categoryColors[
                    PredefinedHabitCategoryX(category).toDomainCategory()]!;

                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Auto-fit tab label for small screens / large fonts
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('$categoryName (${habits.length})'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Tab content
          Expanded(
            child: TabBarView(
              children: categoryOrder.map((category) {
                final habits = habitsByCategory[category] ?? [];
                if (habits.isEmpty) {
                  return Center(
                    child: Text(
                      'No habits in this category',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                final categoryColor = HabitColors.categoryColors[
                    PredefinedHabitCategoryX(category).toDomainCategory()]!;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate optimal grid size based on available width
                    // Minimum 120px per card for accessibility, maximum 4 columns
                    const cardMinWidth = 120.0;
                    const spacing = 10.0;
                    final availableWidth = constraints.maxWidth;

                    int crossAxisCount =
                        (availableWidth / (cardMinWidth + spacing)).floor();
                    crossAxisCount = crossAxisCount.clamp(2, 4);

                    // Adjust card size for smaller screens or large fonts
                    final aspectRatio = crossAxisCount <= 2 ? 0.8 : 0.9;
                    final fontSize = crossAxisCount <= 2 ? 11.0 : 12.0;
                    final emojiSize = crossAxisCount <= 2 ? 32.0 : 36.0;

                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: habits.length,
                      itemBuilder: (c, i) {
                        final h = habits[i];
                        final name =
                            PredefinedHabitTranslations.getTranslatedName(
                          widget.l10n,
                          h.nameKey,
                        );
                        return InkWell(
                          onTap: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            await ref
                                .read(habitsNotifierProvider.notifier)
                                .addHabit(
                                  name: name,
                                  emoji: h.emoji,
                                  category: h.category.toDomainCategory(),
                                );
                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(widget.l10n.habitCreated),
                                    ),
                                  ],
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.green.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: categoryColor.withValues(alpha: 0.7),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  h.emoji,
                                  style: TextStyle(fontSize: emojiSize),
                                ),
                                const SizedBox(height: 2),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontSize,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _OptionTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : color, size: 18),
            const SizedBox(width: 6),
            // Auto-fit option tab label
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.color} (${l10n.optional})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildColorOption(
              null,
              HabitColors.categoryColors[selectedCategory]!,
              l10n.defaultColor,
            ),
            ...HabitColors.availableColors.map(
              (c) => _buildColorOption(c, c, null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorOption(Color? v, Color d, String? l) {
    final isS = selectedColor == v;
    return GestureDetector(
      onTap: () => onColorSelected(v),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: d,
              shape: BoxShape.circle,
              border: Border.all(
                color: isS ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: isS
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          if (l != null) Text(l, style: const TextStyle(fontSize: 8)),
        ],
      ),
    );
  }
}
