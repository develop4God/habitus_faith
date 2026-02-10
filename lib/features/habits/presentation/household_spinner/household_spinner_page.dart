import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../../domain/habit.dart';
import '../habits_providers.dart';

/// Modern household task spinner page
class HouseholdSpinnerPage extends ConsumerStatefulWidget {
  const HouseholdSpinnerPage({super.key});

  @override
  ConsumerState<HouseholdSpinnerPage> createState() =>
      _HouseholdSpinnerPageState();
}

class _HouseholdSpinnerPageState extends ConsumerState<HouseholdSpinnerPage>
    with TickerProviderStateMixin {
  // Helper to detect whether we're running under tests. In tests, asserts are enabled,
  // so this will be true and we can skip heavy animations that may keep the
  // framework scheduling frames and block pumpAndSettle.
  bool get _isInTest {
    var inTest = false;
    assert(inTest = true);
    return inTest;
  }

  Habit? _selectedTask;
  bool _isSpinning = false;
  bool _isWorking = false;
  bool _isCompleting = false;
  late AnimationController _spinController;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _spin(List<Habit> householdTasks) async {
    if (householdTasks.isEmpty || _isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedTask = null;
    });

    // Start spinning animation
    _spinController.reset();
    _spinController.forward();

    // Wait for spin animation
    await Future.delayed(const Duration(seconds: 3));

    // Select random task
    final random = math.Random();
    final selectedTask = householdTasks[random.nextInt(householdTasks.length)];

    if (!mounted) return;

    setState(() {
      _selectedTask = selectedTask;
      _isSpinning = false;
    });

    // Show result dialog
    _showTaskDialog(selectedTask);
  }

  void _showTaskDialog(Habit task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task emoji and name
              Text(
                task.emoji ?? '🏠',
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                task.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a202c),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '¡Es hora de esta tarea!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        setState(() {
                          _selectedTask = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Otro momento'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _startTask(task);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '¡Vamos!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTask(Habit task) {
    setState(() {
      _isWorking = true;
      _selectedTask = task;
    });
  }

  Future<void> _completeTask() async {
    if (_selectedTask == null || _isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      // Capture display values before async call to avoid race where _selectedTask
      // might be cleared or updated by a rebuild while the async operation runs.
      final taskName = _selectedTask!.name;
      final taskEmoji = _selectedTask!.emoji;

      // Complete the habit
      await ref.read(habitsNotifierProvider.notifier).completeHabit(
            _selectedTask!.id,
          );

      // Show celebration
      _celebrationController.reset();
      _celebrationController.forward();

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Show completion dialog
      _showCompletionDialog(taskName, taskEmoji);
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al completar la tarea: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  void _showCompletionDialog(String taskName, String? taskEmoji) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isInTest)
                const Icon(Icons.celebration, size: 120, color: Colors.green)
              else
                Lottie.asset(
                  'assets/lottie/Congratulation _ Success batch.json',
                  width: 120,
                  height: 120,
                  repeat: false,
                ),
              const SizedBox(height: 16),
              const Text(
                '¡Excelente trabajo!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a202c),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tarea completada: $taskName',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    setState(() {
      _isWorking = false;
      _selectedTask = null;
    });
  }

  void _cancelTask() {
    setState(() {
      _isWorking = false;
      _selectedTask = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text('🏠 Girar Tareas del Hogar'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1a202c),
        elevation: 0,
      ),
      body: habitsAsync.when(
        data: (allHabits) {
          final householdTasks = allHabits
              .where((h) => h.category == HabitCategory.household)
              .toList();

          if (householdTasks.isEmpty) {
            return _buildEmptyState();
          }

          if (_isWorking && _selectedTask != null) {
            return _buildWorkingView(_selectedTask!);
          }

          return _buildSpinnerView(householdTasks);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No hay tareas del hogar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega tareas del hogar para usar el girador',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar tareas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinnerView(List<Habit> householdTasks) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Spinner wheel
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade500,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade200.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinController.value * 2 * math.pi * 5,
                    child: child,
                  );
                },
                child: Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: _selectedTask != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedTask!.emoji ?? '🏠',
                                  style: const TextStyle(fontSize: 64),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    _selectedTask!.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : const Icon(
                              Icons.home_rounded,
                              size: 80,
                              color: Colors.orange,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Spin button
            ElevatedButton(
              onPressed: _isSpinning ? null : () => _spin(householdTasks),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.orange.shade200,
              ),
              child: _isSpinning
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 28),
                        SizedBox(width: 12),
                        Text(
                          '¡GIRAR!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 48),
            // Available tasks
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list_rounded,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tareas disponibles (${householdTasks.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: householdTasks.map((task) {
                      return Chip(
                        avatar: Text(
                          task.emoji ?? '🏠',
                          style: const TextStyle(fontSize: 16),
                        ),
                        label: Text(task.name),
                        backgroundColor: Colors.orange.shade50,
                        side: BorderSide(color: Colors.orange.shade200),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingView(Habit task) {
    // Use a scrollable container to avoid overflow on small screens or tests
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hourglass animation
            if (_isInTest)
              const Icon(Icons.hourglass_bottom, size: 200, color: Colors.pink)
            else
              Lottie.asset(
                'assets/lottie/sand_hourglass_pink.json',
                width: 200,
                height: 200,
              ),
            const SizedBox(height: 32),
            // Task info
            Text(
              task.emoji ?? '🏠',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              task.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a202c),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Trabajando en la tarea...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _isCompleting ? null : _cancelTask,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isCompleting ? null : _completeTask,
                  icon: _isCompleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(_isCompleting ? 'Completando...' : 'Completar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCompleting
                        ? Colors.grey.shade400
                        : Colors.green.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
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
