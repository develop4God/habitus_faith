import 'package:flutter/material.dart';
import 'onboarding_models.dart';
import 'package:signature/signature.dart';
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
  final SignatureController _signatureController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  final ValueNotifier<bool> _isSignatureNotEmpty = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _signatureController.addListener(_onSignatureChanged);
  }

  void _onSignatureChanged() {
    _isSignatureNotEmpty.value = _signatureController.isNotEmpty;
  }

  @override
  void dispose() {
    _commitmentController.dispose();
    _signatureController.dispose();
    _isSignatureNotEmpty.dispose();
    super.dispose();
  }


  List<String> _getCommitments() {
    switch (widget.userIntent) {
      case UserIntent.faithBased:
        return [
          'Me comprometo a fortalecer mi relación con Dios.',
          'Buscaré crecer espiritualmente y vivir mi fe cada día.',
          'Seré constante en mis hábitos espirituales y oración.',
          'Dedicaré tiempo a la reflexión y gratitud diariamente.',
        ];
      case UserIntent.wellness:
        return [
          'Me comprometo a mejorar mi disciplina personal.',
          'Cuidaré mi bienestar físico y mental.',
          'Seré constante y perseverante en mis hábitos saludables.',
          'Dedicaré tiempo a la reflexión y gratitud diariamente.',
        ];
      case UserIntent.both:
        return [
          'Me comprometo a mejorar mi disciplina personal y espiritual.',
          'Buscaré crecer espiritualmente y cuidar mi bienestar.',
          'Seré constante y perseverante en mis hábitos diarios.',
          'Dedicaré tiempo a la reflexión y gratitud diariamente.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const inputLabel = 'Firma con un ✔ el compromiso contigo mismo';
    final commitments = _getCommitments();

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
                'Estos son los compromisos que asumes:',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff64748b),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Compromisos con check
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: commitments.map((text) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xff6366f1), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(fontSize: 16, color: Color(0xff1a202c)),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                inputLabel,
                style: TextStyle(
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
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text(
                  'La firma es simbólica y no se guarda en el sistema.',
                  style: TextStyle(fontSize: 13, color: Color(0xff64748b)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _isSignatureNotEmpty,
                builder: (context, isNotEmpty, child) {
                  return SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6366f1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: isNotEmpty
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
