import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_page.dart';
import '../features/habits/presentation/goals_page.dart';
import '../features/habits/presentation/notes_page.dart';
import '../features/habits/presentation/pets_providers.dart';

import 'settings_page.dart';
import 'bible_reader_page.dart';
import 'devotional_discovery_page.dart';
import '../features/statistics/statistics_page.dart';
import '../l10n/app_localizations.dart';
import '../providers/devotional_providers.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../features/habits/domain/habit.dart'; // Import for HabitDailyStatus
import '../core/models/devocional_model.dart';
import '../utils/date_format_utils.dart';
import '../widgets/unified_habit_list.dart';
import '../widgets/background_image_card.dart';
import 'edit_habit_dialog.dart';
import '../features/gamification/presentation/pages/faith_journey_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final formattedDate = formatDevotionalDate(today, context);

    // Devocional de hoy
    final devotionalState = ref.watch(devotionalProvider);
    devotionalState.all.firstWhere(
      (d) =>
          d.date.year == today.year &&
          d.date.month == today.month &&
          d.date.day == today.day,
      orElse: () => Devocional(
        id: '',
        versiculo: '',
        reflexion: '',
        paraMeditar: [],
        oracion: '',
        date: today,
      ),
    );

    // Hábitos de hoy
    final habitsAsync = ref.watch(habitsStreamProvider);
    final habits = habitsAsync.asData?.value ?? [];
    // Exclude skipped habits from both completed and total counts
    final activeHabits =
        habits.where((h) => h.dailyStatus != HabitDailyStatus.skipped).toList();
    final completedHabits = activeHabits.where((h) => h.completedToday).length;
    final totalHabits = activeHabits.length;
    final completionPercentage =
        totalHabits > 0 ? (completedHabits / totalHabits * 100).round() : 0;

    // Calculate weekly consistency
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final sevenDaysAgo = normalizedToday.subtract(const Duration(days: 7));
    final tomorrowStart = normalizedToday.add(const Duration(days: 1));
    int totalPossibleCompletions = 0;
    int actualCompletions = 0;

    for (final habit in habits) {
      final normalizedHabitCreated = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );

      final habitStart = normalizedHabitCreated.isAfter(sevenDaysAgo)
          ? normalizedHabitCreated
          : sevenDaysAgo;
      final daysSinceCreation =
          normalizedToday.difference(habitStart).inDays + 1;
      final daysSinceCreationInWindow = daysSinceCreation.clamp(0, 7);

      final relevantCompletions = habit.completionHistory.where((date) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        return !normalizedDate.isBefore(sevenDaysAgo) &&
            normalizedDate.isBefore(tomorrowStart);
      }).length;
      actualCompletions += relevantCompletions;
      totalPossibleCompletions += daysSinceCreationInWindow;
    }

    final weeklyConsistency = totalPossibleCompletions > 0
        ? (actualCompletions / totalPossibleCompletions * 100).round()
        : 0;

    final longestStreak = habits.isNotEmpty
        ? habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b)
        : 0;

    final List<Widget> pages = [
      Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Hero section with gradient
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.orange.shade300,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.shade200.withAlpha(128),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.introMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // A. DAILY PROGRESS inside BackgroundImageCard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BackgroundImageCard(
                  borderSide: BorderSide(
                    color: completedHabits == totalHabits && totalHabits > 0
                        ? Colors.green.shade300
                        : Colors.blue.shade300,
                    width: 2,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          tween: Tween<double>(
                            begin: 0,
                            end: totalHabits > 0
                                ? completedHabits / totalHabits
                                : 0,
                          ),
                          builder: (context, value, _) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const StatisticsPage(),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 110,
                              height: 110,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 110,
                                    height: 110,
                                    child: CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 9,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        completedHabits == totalHabits &&
                                                totalHabits > 0
                                            ? Colors.green.shade600
                                            : Colors.blue.shade600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TweenAnimationBuilder<int>(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          curve: Curves.easeInOut,
                                          tween: IntTween(
                                            begin: 0,
                                            end: completionPercentage,
                                          ),
                                          builder: (context, value, _) => Text(
                                            '$value%',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.habitsCompletedCount(
                                            completedHabits,
                                            totalHabits,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildHighlightContainer(
                          child: totalHabits == 0
                              ? Text(
                                  l10n.startJourney,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : completedHabits == totalHabits
                                  ? Text(
                                      l10n.allHabitsCompleted,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  : completedHabits == 0
                                      ? Text(
                                          l10n.buildConsistency,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue.shade900,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                      : Text(
                                          l10n.greatProgress,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              UnifiedHabitList(
                shrinkWrap:
                    true, // Crucial for visibility in scrollable home page
                onComplete: (habitId) async {
                  final notifier = ref.read(habitsNotifierProvider.notifier);
                  await notifier.completeHabit(habitId);
                },
                onUncheck: (habitId) async {
                  final notifier = ref.read(habitsNotifierProvider.notifier);
                  await notifier.uncheckHabit(habitId);
                },
                onDelete: (habitId) async {
                  final notifier = ref.read(habitsNotifierProvider.notifier);
                  await notifier.deleteHabit(habitId);
                },
                onEdit: (habit) async {
                  final l10n = AppLocalizations.of(context)!;
                  await showDialog(
                    context: context,
                    builder: (ctx) => EditHabitDialog(l10n: l10n, habit: habit),
                  );
                },
              ),

              const SizedBox(height: 20),

              if (habits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 0,
                          color: Colors.orange.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.orange.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange.shade600,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$longestStreak',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.longestStreakCard,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          elevation: 0,
                          color: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.blue.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: Colors.blue.shade600,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$weeklyConsistency%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.weeklyConsistencyCard,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Pets Section
              _buildPetsSection(),

              const SizedBox(height: 32),

              // Gamification Section Header - REIMAGINED WITH FOMO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.faithJourney,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey.shade900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'En construcción 🚧',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade600, Colors.orange.shade700],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Text(
                        'PRÓXIMAMENTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Gamification Card - REIMAGINED WITH FOMO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FaithJourneyPage(),
                      ),
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 180),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.shade700,
                          Colors.indigo.shade800,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 150,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Prepárate para el\nSiguiente Nivel',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Misiones exclusivas y premios pronto...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w500,
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
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      const HabitsPage(),
      const GoalsPage(),
      const NotesPage(),
      const BibleReaderPage(),
      const DevotionalDiscoveryPage(),
      const StatisticsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_filled),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.playlist_add_check_circle_outlined),
            label: l10n.routine,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            label: 'Metas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_outlined),
            label: 'Notas',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_stories_outlined),
            label: l10n.readBible,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_library_outlined),
            label: 'Devotionals',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n.statistics,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHighlightContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildPetsSection() {
    final petsAsync = ref.watch(petsNotifierProvider);

    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    color: Colors.pink.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mis Mascotas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade50, Colors.purple.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.pink.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pet.emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pet.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
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
}
