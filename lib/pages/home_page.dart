import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_page.dart';

import 'settings_page.dart';
import 'bible_reader_page.dart';
import 'devotional_discovery_page.dart';
import '../features/statistics/statistics_page.dart'; // Importa la página correcta
import '../l10n/app_localizations.dart';
import '../providers/devotional_providers.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../core/models/devocional_model.dart';

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

    // Devocional de hoy
    final devotionalState = ref.watch(devotionalProvider);
    final todayDevocional = devotionalState.all.firstWhere(
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
    final completedHabits = habits.where((h) => h.completedToday).length;
    final totalHabits = habits.length;
    final remainingHabits = totalHabits - completedHabits;
    final completionPercentage = totalHabits > 0 ? (completedHabits / totalHabits * 100).round() : 0;
    
    // Calculate weekly consistency (last 7 days)
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    final tomorrowStart = today.add(const Duration(days: 1));
    int totalPossibleCompletions = 0;
    int actualCompletions = 0;
    
    for (final habit in habits) {
      // Calculate days this habit has existed in the 7-day window
      final habitStart = habit.createdAt.isAfter(sevenDaysAgo) ? habit.createdAt : sevenDaysAgo;
      final daysSinceCreation = today.difference(habitStart).inDays + 1;
      final daysInWindow = daysSinceCreation.clamp(0, 7);
      
      final relevantCompletions = habit.completionHistory.where((date) => 
        date.isAfter(sevenDaysAgo) && date.isBefore(tomorrowStart)
      ).length;
      actualCompletions += relevantCompletions;
      totalPossibleCompletions += daysInWindow;
    }
    
    final weeklyConsistency = totalPossibleCompletions > 0 
        ? (actualCompletions / totalPossibleCompletions * 100).round() 
        : 0;
    
    // Calculate longest streak across all habits
    final longestStreak = habits.isNotEmpty 
        ? habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b)
        : 0;

    final List<Widget> pages = [
      // UX-optimized home: Progress → Habits → Streaks → Inspiration
      Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.appTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepOrange.shade700,
          elevation: 0,
        ),
        backgroundColor: Colors.grey.shade50,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // A. DAILY PROGRESS (PRIMARY) - Dominant visual indicator with animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(
                      color: completedHabits == totalHabits && totalHabits > 0
                          ? Colors.green.shade300
                          : Colors.blue.shade300,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      children: [
                        // Circular progress indicator (ring) - ANIMATED
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          tween: Tween<double>(
                            begin: 0,
                            end: totalHabits > 0 ? completedHabits / totalHabits : 0,
                          ),
                          builder: (context, value, _) => SizedBox(
                            width: 160,
                            height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 160,
                                  height: 160,
                                  child: CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 13,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      completedHabits == totalHabits && totalHabits > 0
                                          ? Colors.green.shade400
                                          : Colors.blue.shade400,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TweenAnimationBuilder<int>(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      tween: IntTween(
                                        begin: 0,
                                        end: completionPercentage,
                                      ),
                                      builder: (context, value, _) => Text(
                                        '$value%',
                                        style: TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: completedHabits == totalHabits && totalHabits > 0
                                              ? Colors.green.shade700
                                              : Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      l10n.habitsCompletedCount(completedHabits, totalHabits),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 18),
                        
                        // Motivational micro-copy (dynamic)
                        if (totalHabits == 0)
                          Text(
                            l10n.startJourney,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          )
                        else if (completedHabits == totalHabits)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.celebration, color: Colors.green.shade600, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.allHabitsCompleted,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        else if (completedHabits == 0)
                          Text(
                            l10n.buildConsistency,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text(
                            l10n.greatProgress,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // C. REMAINING HABITS INDICATOR
              if (totalHabits > 0 && remainingHabits > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.habitsRemaining(remainingHabits),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              
              if (totalHabits > 0 && remainingHabits > 0)
                const SizedBox(height: 12),
              
              // B. TODAY'S HABITS (PRIMARY ACTIONS) - One-gesture completion with animation
              if (habits.isNotEmpty)
                ...habits.map((habit) {
                  final isCompleted = habit.completedToday;
                  return AnimatedScale(
                    scale: isCompleted ? 0.98 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Dismissible(
                        key: Key('habit_${habit.id}'),
                      direction: isCompleted 
                          ? DismissDirection.none 
                          : DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        if (!isCompleted) {
                          final notifier = ref.read(habitsNotifierProvider.notifier);
                          await notifier.completeHabit(habit.id);
                        }
                        return false; // Don't actually dismiss
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      child: InkWell(
                        onTap: isCompleted ? null : () async {
                          final notifier = ref.read(habitsNotifierProvider.notifier);
                          await notifier.completeHabit(habit.id);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Card(
                          elevation: 0,
                          color: isCompleted ? Colors.green.shade50 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isCompleted 
                                  ? Colors.green.shade300 
                                  : Colors.grey.shade300,
                              width: isCompleted ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Habit icon
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isCompleted 
                                        ? Colors.green.shade100 
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      habit.emoji ?? '✓',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Habit info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isCompleted 
                                              ? Colors.green.shade900 
                                              : Colors.grey.shade900,
                                          decoration: isCompleted 
                                              ? TextDecoration.lineThrough 
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_fire_department,
                                            size: 14,
                                            color: habit.currentStreak > 0 
                                                ? Colors.orange.shade600 
                                                : Colors.grey.shade400,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            l10n.dayStreak(habit.currentStreak),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Completion indicator
                                if (isCompleted)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 32,
                                  )
                                else
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                }),
              
              // Swipe hint for first-time users
              if (habits.isNotEmpty && habits.any((h) => !h.completedToday))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_left, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Text(
                        l10n.swipeToComplete,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // D. STREAKS & MOMENTUM (SECONDARY)
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
              
              // E. INSPIRATIONAL CONTENT (TERTIARY)
              if (todayDevocional.versiculo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 0,
                    color: Colors.amber.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.amber.shade200),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        leading: Icon(
                          Icons.auto_stories,
                          color: Colors.amber.shade700,
                          size: 24,
                        ),
                        title: Text(
                          l10n.todaysVerse,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        children: [
                          Text(
                            todayDevocional.versiculo,
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 14,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      const HabitsPage(),
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
}
