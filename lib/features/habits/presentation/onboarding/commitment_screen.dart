import 'package:flutter/material.dart';
import 'onboarding_models.dart';
import 'package:signature/signature.dart';
import '../../../../l10n/app_localizations.dart';

class CommitmentScreen extends StatefulWidget {
  final UserIntent userIntent;
  final Function(String commitment) onCommitmentMade;
  final List<String> habitsSummary;

  const CommitmentScreen({
    super.key,
    required this.userIntent,
    required this.onCommitmentMade,
    required this.habitsSummary,
  });

  @override
  State<CommitmentScreen> createState() => _CommitmentScreenState();
}

class _CommitmentScreenState extends State<CommitmentScreen> {
  final TextEditingController _commitmentController = TextEditingController();
  final SignatureController _signatureController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);

  @override
  void dispose() {
    _commitmentController.dispose();
    _signatureController.dispose();
    super.dispose();
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
    final inputLabel = _getInputLabel();

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Casi listo! 🎉',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1a202c),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Estos son los hábitos que te comprometes a realizar:',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff64748b),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Mostrar resumen de hábitos
              Expanded(
                child: ListView.builder(
                  itemCount: widget.habitsSummary.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            widget.habitsSummary[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xff1a202c),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                inputLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1a202c),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => _signatureController.clear(),
                child: const Text('Limpiar firma'),
              ),
              const SizedBox(height: 16),
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
                  onPressed: _signatureController.isNotEmpty
                      ? () {
                          widget.onCommitmentMade('Compromiso firmado');
                        }
                      : null,
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
