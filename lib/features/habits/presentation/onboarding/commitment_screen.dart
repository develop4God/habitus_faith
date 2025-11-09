import 'package:flutter/material.dart';
import 'onboarding_models.dart';
import '../../../../l10n/app_localizations.dart';

class CommitmentScreen extends StatefulWidget {
  final UserIntent userIntent;
  final Function(String commitment) onCommitmentMade;

  const CommitmentScreen({
    super.key,
    required this.userIntent,
    required this.onCommitmentMade,
  });

  @override
  State<CommitmentScreen> createState() => _CommitmentScreenState();
}

class _CommitmentScreenState extends State<CommitmentScreen> {
  final TextEditingController _commitmentController = TextEditingController();
  String? _selectedCommitment;

  @override
  void dispose() {
    _commitmentController.dispose();
    super.dispose();
  }

  List<String> _getCommitments() {
    switch (widget.userIntent) {
      case UserIntent.faithBased:
        return [
          '¡Voy a crecer en mi fe!',
          '¡Voy a tener disciplina espiritual!',
          '¡Voy a confiar en Dios con mis hábitos!',
          '¡Voy a ser mi mejor versión en Cristo!',
        ];
      case UserIntent.wellness:
        return [
          '¡Voy a conseguir mi objetivo!',
          '¡Voy a aprovechar mi día al máximo!',
          '¡Voy a tener una vida organizada!',
          '¡Voy a ser más disciplinado!',
        ];
      case UserIntent.both:
        return [
          '¡Voy a crecer en mi fe!',
          '¡Voy a conseguir mi objetivo!',
          '¡Voy a tener disciplina espiritual!',
          '¡Voy a aprovechar mi día al máximo!',
          '¡Voy a ser mi mejor versión en Cristo!',
          '¡Voy a tener una vida organizada!',
        ];
    }
  }

  String _getInputLabel() {
    switch (widget.userIntent) {
      case UserIntent.faithBased:
        return 'Firma tu compromiso con Dios:';
      case UserIntent.wellness:
        return 'Firma tu compromiso contigo mismo:';
      case UserIntent.both:
        return 'Firma tu compromiso:';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final commitments = _getCommitments();
    final inputLabel = _getInputLabel();

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Title
              Text(
                '¡Casi listo! 🎉',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1a202c),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sella tu compromiso con una declaración personal',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xff64748b),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Commitment options
              Expanded(
                child: ListView(
                  children: [
                    ...commitments.map((commitment) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _CommitmentOption(
                            text: commitment,
                            isSelected: _selectedCommitment == commitment,
                            onTap: () {
                              setState(() {
                                _selectedCommitment = commitment;
                                _commitmentController.text = commitment;
                              });
                            },
                          ),
                        )),
                    const SizedBox(height: 24),

                    // Custom commitment input
                    Text(
                      inputLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1a202c),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commitmentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu compromiso aquí...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _selectedCommitment = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6366f1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _commitmentController.text.trim().isEmpty
                      ? null
                      : () {
                          widget.onCommitmentMade(
                              _commitmentController.text.trim());
                        },
                  child: Text(
                    l10n.continueButton,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommitmentOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _CommitmentOption({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xff6366f1) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xff6366f1).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color:
                  isSelected ? const Color(0xff6366f1) : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xff1a202c)
                      : const Color(0xff64748b),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
