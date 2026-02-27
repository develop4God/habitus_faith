import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
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
  late AnimationController _pulseController;

  // Customization options
  Color _wheelColor1 = Colors.orange.shade400;
  Color _wheelColor2 = Colors.deepOrange.shade500;

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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Only start pulse animation if not in test mode
    if (!_isInTest) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _celebrationController.dispose();
    _pulseController.dispose();
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
    final l10n = AppLocalizations.of(context)!;
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
                '¡Tareas al azar del hogar, diviértete!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
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
                      child: Text(l10n.anotherMoment),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.taskCompleteError(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: Text(l10n.householdSpinnerTitle),
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
    final l10n = AppLocalizations.of(context)!;
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
              label: Text(l10n.addTasks),
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
            // Fun message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.purple.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.celebration, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Tareas al azar del hogar, diviértete!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a202c),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Color customization
            _buildColorPicker(),
            const SizedBox(height: 32),
            // Spinner wheel
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.05);
                return Transform.scale(
                  scale: _isSpinning ? 1.0 : scale,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _wheelColor1,
                          _wheelColor2,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _wheelColor1.withValues(alpha: 0.5),
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
                );
              },
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
    final l10n = AppLocalizations.of(context)!;
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
                  child: Text(l10n.cancel),
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
                  label: Text(_isCompleting ? l10n.completing : l10n.complete),
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

  Widget _buildColorPicker() {
    final colorOptions = [
      {
        'colors': [Colors.orange.shade400, Colors.deepOrange.shade500],
        'label': '🟠'
      },
      {
        'colors': [Colors.blue.shade400, Colors.indigo.shade500],
        'label': '🔵'
      },
      {
        'colors': [Colors.green.shade400, Colors.teal.shade500],
        'label': '🟢'
      },
      {
        'colors': [Colors.purple.shade400, Colors.deepPurple.shade500],
        'label': '🟣'
      },
      {
        'colors': [Colors.pink.shade400, Colors.red.shade500],
        'label': '🔴'
      },
      {
        'colors': [Colors.amber.shade400, Colors.yellow.shade600],
        'label': '🟡'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de la rueda:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colorOptions.length,
            itemBuilder: (context, index) {
              final option = colorOptions[index];
              final colors = option['colors'] as List<Color>;
              final isSelected = colors[0] == _wheelColor1;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _wheelColor1 = colors[0];
                    _wheelColor2 = colors[1];
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colors[0].withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      option['label'] as String,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
