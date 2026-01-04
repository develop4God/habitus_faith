import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/simple_onboarding_scoring.dart';
import '../../domain/services/simple_template_selector.dart';
import '../../domain/models/predefined_habits_data.dart'
    as predefined_data;
import '../../data/storage/storage_providers.dart';
import '../../../../widgets/add_habit_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/predefined_habit_translations.dart';

/// Preview page for selected habits before committing
/// 
/// Shows:
/// - Score level label
/// - Selected habits with remove button
/// - Add habit button
/// - Customize/Start CTAs
class HabitPreviewPage extends ConsumerStatefulWidget {
  final OnboardingScore score;

  const HabitPreviewPage({super.key, required this.score});

  @override
  ConsumerState<HabitPreviewPage> createState() => _HabitPreviewPageState();
}

class _HabitPreviewPageState extends ConsumerState<HabitPreviewPage> {
  late List<String> _selectedHabitIds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Get initial template selections
    _selectedHabitIds = SimpleTemplateSelector.selectTemplates(widget.score);
  }

  void _removeHabit(String habitId) {
    if (_selectedHabitIds.length <= 1) {
      // Minimum 1 habit enforcement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes mantener al menos un hábito'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedHabitIds.remove(habitId);
    });
  }

  void _addHabit() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AddHabitDialog(l10n: l10n),
    ).then((result) {
      // If user created a habit from the dialog, we could add it here
      // For now, this opens the full add habit dialog
    });
  }

  Future<void> _startWithHabits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final habitsRepository = ref.read(jsonHabitsRepositoryProvider);
      final storage = ref.read(jsonStorageServiceProvider);
      final l10n = AppLocalizations.of(context);

      // Create habits from selected IDs
      for (final habitId in _selectedHabitIds) {
        final predefinedHabit = predefined_data.predefinedHabits.firstWhere(
          (h) => h.id == habitId,
          orElse: () => predefined_data.predefinedHabits.first,
        );

        // Get localized name
        final name = l10n != null
            ? PredefinedHabitTranslations.getTranslatedName(
                l10n, predefinedHabit.nameKey)
            : habitId;

        // Map category using the extension from predefined_data
        final category =
            predefined_data.PredefinedHabitCategoryX(predefinedHabit.category)
                .toDomainCategory();

        await habitsRepository.createHabit(
          name: name,
          category: category,
          emoji: predefinedHabit.emoji,
        );
      }

      // Mark onboarding as complete
      await storage.setBool('onboarding_complete', true);

      if (mounted) {
        // Navigate to habits page
        Navigator.of(context).pushReplacementNamed('/habits');
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to create habits: $e\n$stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos crear los hábitos. Intenta de nuevo.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff1e293b)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Vista previa',
          style: TextStyle(
            color: Color(0xff1e293b),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Row(
                            children: [
                              Text(
                                '📦',
                                style: TextStyle(fontSize: 32),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tus primeros hábitos',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff1e293b),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Score level label
                          Text(
                            'Nivel: ${widget.score.getScoreLevelLabel()}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xff6366f1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Habit cards
                          ..._buildHabitCards(),

                          const SizedBox(height: 24),

                          // Add habit button
                          _buildAddHabitButton(),
                        ],
                      ),
                    ),
                  ),

                  // Bottom CTAs
                  _buildBottomCTAs(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildHabitCards() {
    final l10n = AppLocalizations.of(context);
    
    return _selectedHabitIds.map((habitId) {
      final predefinedHabit = predefined_data.predefinedHabits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => predefined_data.predefinedHabits.first,
      );

      final nameKey = predefinedHabit.nameKey;
      final name = l10n != null
          ? PredefinedHabitTranslations.getTranslatedName(l10n, nameKey)
          : habitId;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xffe2e8f0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji
              Text(
                predefinedHabit.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),

              // Habit name
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1e293b),
                  ),
                ),
              ),

              // Remove button
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xff64748b)),
                onPressed: () => _removeHabit(habitId),
                tooltip: 'Quitar hábito',
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAddHabitButton() {
    return InkWell(
      onTap: _addHabit,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xff6366f1),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xff6366f1)),
            SizedBox(width: 8),
            Text(
              'Agregar hábito',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff6366f1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCTAs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary CTA: Start
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _startWithHabits,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6366f1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Empezar con estos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary CTA: Customize
          TextButton(
            onPressed: _addHabit,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff6366f1),
            ),
            child: const Text(
              'Personalizar más',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
