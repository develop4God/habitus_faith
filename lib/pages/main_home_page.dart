import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/devotional_providers.dart';
import '../features/habits/presentation/habits_providers.dart';
import '../core/models/devocional_model.dart';

class MainHomePage extends ConsumerWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final formattedDate = '${today.day}/${today.month}/${today.year}';

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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.home, size: 28),
            const SizedBox(width: 12),
            Text(l10n.appTitle),
          ],
        ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section con transición de hábitos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade200, Colors.deepOrange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.introMessage,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (habits.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: PageView.builder(
                        itemCount: habits.length,
                        controller: PageController(viewportFraction: 0.7),
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return Hero(
                            tag: 'habit_${habit.id}',
                            child: Card(
                              color: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Text(habit.emoji ?? '✓',
                                        style: const TextStyle(fontSize: 28)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        habit.name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (habit.completedToday)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
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
            const SizedBox(height: 24),
            // Versículo del día (del devocional)
            if (todayDevocional.versiculo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  color: Colors.yellow.shade50,
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayDevocional.versiculo,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.orange.shade900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          todayDevocional.reflexion,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Resumen de hábitos para hoy
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.habitsCompleted,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.habitsCompletedCount(completedHabits, totalHabits),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Resumen de tus hábitos para hoy.',
                        style: Theme.of(context).textTheme.bodyMedium,
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
    );
  }
}
