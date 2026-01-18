import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../l10n/app_localizations.dart';
import 'habits_providers.dart';
import '../domain/habit.dart';

class DailyReflectionPage extends ConsumerStatefulWidget {
  const DailyReflectionPage({super.key});

  @override
  ConsumerState<DailyReflectionPage> createState() =>
      _DailyReflectionPageState();
}

class _DailyReflectionPageState extends ConsumerState<DailyReflectionPage> {
  final TextEditingController _globalNoteController = TextEditingController();
  final List<String> _quickEmojis = [
    '🙏',
    '✨',
    '📖',
    '❤️',
    '🙌',
    '💪',
    '🌱',
    '☀️',
    '🕊️',
    '🔥'
  ];

  @override
  void dispose() {
    _globalNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habitsAsync = ref.watch(habitsStreamProvider);
    final today = DateFormat('EEEE, d MMMM', 'es').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mi Reflexión',
                    style: TextStyle(
                        color: Color(0xFF1A1C1E), fontWeight: FontWeight.w900),
                  ),
                  Text(
                    today,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade50, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGlobalNoteInput(l10n),
                  const SizedBox(height: 32),
                  const Text(
                    'Hábitos del Día',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Añade pensamientos específicos a tus logros.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          habitsAsync.when(
            data: (habits) {
              final completedHabits =
                  habits.where((h) => h.completedToday).toList();
              if (completedHabits.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildHabitNoteCard(completedHabits[index], l10n),
                    childCount: completedHabits.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildGlobalNoteInput(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Nota General',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              IconButton(
                onPressed: () {
                  if (_globalNoteController.text.isNotEmpty) {
                    Share.share(
                        'Reflexión del día (${DateFormat('d/M').format(DateTime.now())}):\n\n${_globalNoteController.text}');
                  }
                },
                icon: const Icon(Icons.share_outlined, size: 20),
              ),
            ],
          ),
          TextField(
            controller: _globalNoteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '¿Cómo estuvo tu comunión con Dios hoy?',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickEmojis
                  .map((e) => InkWell(
                        onTap: () =>
                            setState(() => _globalNoteController.text += e),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(e, style: const TextStyle(fontSize: 22)),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitNoteCard(Habit habit, AppLocalizations l10n) {
    final note = ref
        .watch(habitsRepositoryProvider)
        .getTodayCompletionRecord(habit.id)
        ?.notes;
    final controller = TextEditingController(text: note);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          ListTile(
            leading:
                Text(habit.emoji ?? '✅', style: const TextStyle(fontSize: 24)),
            title: Text(habit.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            trailing:
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: controller,
              onChanged: (val) {
                ref
                    .read(habitsNotifierProvider.notifier)
                    .updateHabitNote(habit.id, val);
              },
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Añadir reflexión...',
                filled: true,
                fillColor: Colors.blue.shade50.withAlpha(100),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_outlined,
              size: 64, color: Colors.orange.shade200),
          const SizedBox(height: 16),
          const Text('Completa un hábito para reflexionar',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}
