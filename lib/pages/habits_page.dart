import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/habit.dart';
import '../features/habits/domain/failures.dart';
import '../features/habits/data/storage/storage_providers.dart';
import '../features/habits/presentation/widgets/habit_completion_card.dart';
import '../features/habits/presentation/widgets/mini_calendar_heatmap.dart';
import '../l10n/app_localizations.dart';

// New providers for JSON-based habits
final jsonHabitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(jsonHabitsRepositoryProvider);
  debugPrint('jsonHabitsStreamProvider: repository watched -> $repository');
  final stream = repository.watchHabits().map((list) {
    debugPrint('jsonHabitsStreamProvider: stream emitted ${list.length} habits');
    return list;
  }).handleError((e, st) {
    debugPrint('jsonHabitsStreamProvider: stream error -> $e');
  });
  return stream;
});

class JsonHabitsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  JsonHabitsNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> completeHabit(String habitId) async {
    debugPrint('JsonHabitsNotifier.completeHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
    final result = await repository.completeHabit(habitId);

    result.fold(
          (failure) {
        debugPrint('JsonHabitsNotifier.completeHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
          (habit) {
        debugPrint('JsonHabitsNotifier.completeHabit: success -> ${habit.id}');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> deleteHabit(String habitId) async {
    debugPrint('JsonHabitsNotifier.deleteHabit: start -> $habitId');
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
    final result = await repository.deleteHabit(habitId);

    result.fold(
          (failure) {
        debugPrint('JsonHabitsNotifier.deleteHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
          (_) {
        debugPrint('JsonHabitsNotifier.deleteHabit: success -> $habitId');
        state = const AsyncData(null);
      },
    );
  }

  Future<void> addHabit({
    required String name,
    required String description,
    HabitCategory category = HabitCategory.other,
  }) async {
    debugPrint('JsonHabitsNotifier.addHabit: start -> name:$name desc:$description');
    state = const AsyncLoading();

    final repository = ref.read(jsonHabitsRepositoryProvider);
    final result = await repository.createHabit(
      name: name,
      description: description,
      category: category,
    );

    result.fold(
          (failure) {
        debugPrint('JsonHabitsNotifier.addHabit: failure -> $failure');
        state = AsyncError(failure, StackTrace.current);
      },
          (habit) {
        debugPrint('JsonHabitsNotifier.addHabit: success -> ${habit.id}');
        state = const AsyncData(null);
      },
    );
  }
}

final jsonHabitsNotifierProvider =
StateNotifierProvider<JsonHabitsNotifier, AsyncValue<void>>((ref) {
  return JsonHabitsNotifier(ref);
});

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('HabitsPage.build: started');
    final habitsAsync = ref.watch(jsonHabitsStreamProvider);

    // Listen for errors
    ref.listen<AsyncValue<void>>(jsonHabitsNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          debugPrint('HabitsPage: notifier error -> $error');
          if (error is HabitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: Text(l10n.myHabits),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xff1a202c),
      ),
      body: habitsAsync.when(
        data: (habits) {
          debugPrint('HabitsPage: data received -> ${habits.length} habits');
          if (habits.isEmpty) {
            debugPrint('HabitsPage: no habits -> showing empty state');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noHabits,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final notifier = ref.watch(jsonHabitsNotifierProvider);
              final isCompleting = notifier.isLoading;
              debugPrint('HabitsPage.itemBuilder: habit ${habit.id}, isCompleting: $isCompleting');

              return Column(
                children: [
                  HabitCompletionCard(
                    habit: habit,
                    isCompleting: isCompleting,
                    onTap: () async {
                      debugPrint('HabitsPage.onTap: completing habit -> ${habit.id}');
                      await ref
                          .read(jsonHabitsNotifierProvider.notifier)
                          .completeHabit(habit.id);
                      debugPrint('HabitsPage.onTap: completeHabit awaited -> ${habit.id}');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.habitCompleted)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  MiniCalendarHeatmap(
                    completionDates: habit.completionHistory,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
        loading: () {
          debugPrint('HabitsPage: loading state -> showing spinner');
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stack) {
          debugPrint('HabitsPage: error state -> $error');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_habit_fab'),
        onPressed: () {
          debugPrint('HabitsPage: FAB pressed -> showing add habit dialog');
          _showAddHabitDialog(context, ref, l10n);
        },
        backgroundColor: const Color(0xff6366f1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddHabitDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addHabit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('habit_name_input'),
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l10n.name),
            ),
            TextField(
              key: const Key('habit_description_input'),
              controller: descCtrl,
              decoration: InputDecoration(labelText: l10n.description),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('AddHabitDialog: cancel pressed');
              Navigator.pop(context);
            },
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            key: const Key('confirm_add_habit_button'),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                debugPrint('AddHabitDialog: adding habit -> name:${nameCtrl.text} desc:${descCtrl.text}');
                await ref.read(jsonHabitsNotifierProvider.notifier).addHabit(
                  name: nameCtrl.text,
                  description: descCtrl.text,
                );
                debugPrint('AddHabitDialog: addHabit awaited');
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } else {
                debugPrint('AddHabitDialog: missing name or description');
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      descCtrl.dispose();
      debugPrint('AddHabitDialog: disposed controllers');
    });
  }
}