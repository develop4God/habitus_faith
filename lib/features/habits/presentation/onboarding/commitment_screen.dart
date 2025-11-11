import 'package:flutter/material.dart';
import 'onboarding_models.dart';
import 'package:signature/signature.dart';
import 'package:lottie/lottie.dart';
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
  bool _isProcessing = false;
  bool _backEnabled = true;

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

  Future<void> _handleCommitment() async {
    setState(() {
      _isProcessing = true;
      _backEnabled = false;
    });
    // Mostrar modal de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/lottie/gears.json', width: 120, height: 120, repeat: true),
              const SizedBox(height: 16),
              const Text(
                'Generando tus primeras tareas, por favor espera...',
                style: TextStyle(fontSize: 18, color: Color(0xff6366f1), fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    await widget.onCommitmentMade('Compromiso firmado');
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Cierra el modal de carga
    // Mostrar modal de éxito
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/lottie/tick_animation_success.json', width: 120, height: 120, repeat: false),
              const SizedBox(height: 16),
              const Text(
                '¡Tus hábitos han sido generados exitosamente!',
                style: TextStyle(fontSize: 18, color: Color(0xff6366f1), fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Cierra el modal de éxito
    // Navega a /habits
    Navigator.of(context).pushReplacementNamed('/habits');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const inputLabel = 'Firma con check con el dedo:';
    const disclaimer = '*Simbólico. Tu firma NO se registrará.';
    final secularCommitments = [
      '¡Voy a lograr mis objetivos!',
      '¡Voy a aprovechar mi tiempo al máximo!',
      '¡Voy a tener mi vida en organización!',
      '¡Voy a olvidarme lo que me preocupa!',
      '¡Voy a ser muy productivo!',
      '¡Voy a ser la mejor versión de mi!'
    ];
    final spiritualCommitments = [
      '¡Voy a confiar en Dios con mis hábitos!',
      '¡Voy a buscar la guía de Jesucristo cada día!',
      '¡Voy a fortalecer mi fe y mi relación con Dios!',
      '¡Voy a vivir con propósito y esperanza!',
      '¡Voy a ser luz y ejemplo para otros!',
      '¡Voy a crecer espiritualmente y servir a mi comunidad!'
    ];
    List<String> commitments;
    if (widget.userIntent == UserIntent.both) {
      commitments = [
        ...spiritualCommitments.take(3),
        ...secularCommitments.take(2),
      ];
    } else if (widget.userIntent == UserIntent.faithBased) {
      commitments = spiritualCommitments;
    } else {
      commitments = secularCommitments;
    }

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
                    onPressed: _backEnabled ? () => Navigator.of(context).pop() : null,
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Haremos un trato',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1a202c),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
                  disclaimer,
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
                      onPressed: isNotEmpty && !_isProcessing
                          ? _handleCommitment
                          : null,
                      child: _isProcessing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
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
